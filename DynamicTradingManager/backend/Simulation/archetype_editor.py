from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List

from .config import default_paths
from .models import ItemDef
from .parse.lua_utils import extract_balanced_block, find_lua_files, parse_quoted_list, read_text
from .parse.items_parser import parse_items
from .sim.tag_logic import matches_all_tags, tag_matches

try:
    from ItemManagement import load_vanilla_items
    from ItemManagement.commons.vanilla_loader import get_translated_name
except ImportError:
    load_vanilla_items = None
    get_translated_name = None


REGISTER_ARCH_RE = re.compile(r'DynamicTrading\.RegisterArchetype\(\s*"([^"]+)"\s*,\s*\{', re.DOTALL)
ALLOC_ENTRY_RE = re.compile(
    r'\{\s*(?:tags\s*=\s*\{([^}]*)\}|item\s*=\s*"([^"]+)")\s*,\s*count\s*=\s*(\d+)\s*\}',
    re.DOTALL,
)


def load_archetype_editor_data() -> dict:
    paths = default_paths()
    items = parse_items(paths.mod_common / "Items")
    archetypes = _load_archetypes(paths.mod_common / "ArchetypeDefinitions", items)
    all_tags = _collect_all_tags(items, archetypes)
    vanilla_items = load_vanilla_items() if load_vanilla_items else {}

    archetype_item_coverage: dict[str, set[str]] = {}
    served_item_ids: set[str] = set()

    for archetype in archetypes:
        covered: set[str] = set()
        for allocation in archetype["allocations"]:
            match_ids = _match_entry_items(allocation, items)
            covered.update(match_ids)
        archetype_item_coverage[archetype["archetype_id"]] = covered
        served_item_ids.update(covered)

    item_catalog = [
        {
            "item_id": item_id,
            "name": _get_item_name(item_id, vanilla_items),
            "tags": item_def.tags,
        }
        for item_id, item_def in sorted(items.items())
    ]

    available_tags = []
    for tag in sorted(all_tags):
        matching_items = _find_matching_items_for_tag(tag, items)
        served_matches = [item_id for item_id in matching_items if item_id in served_item_ids]
        covered_by = [
            archetype["archetype_id"]
            for archetype in archetypes
            if any(item_id in archetype_item_coverage[archetype["archetype_id"]] for item_id in matching_items)
        ]

        available_tags.append(
            {
                "tag": tag,
                "item_count": len(matching_items),
                "covered_item_count": len(served_matches),
                "covered_by_count": len(covered_by),
                "covered_by": covered_by,
                "sample_items": [
                    {
                        "item_id": item_id,
                        "name": _get_item_name(item_id, vanilla_items),
                    }
                    for item_id in matching_items[:5]
                ],
            }
        )

    uncovered_tags = [
        row
        for row in available_tags
        if row["item_count"] > 0 and row["covered_item_count"] == 0
    ]
    uncovered_tags.sort(key=lambda row: (-row["item_count"], row["tag"]))

    archetypes.sort(key=lambda row: row["name"].lower())

    return {
        "meta": {
            "archetype_count": len(archetypes),
            "item_count": len(items),
            "tag_count": len(available_tags),
            "uncovered_tag_count": len(uncovered_tags),
        },
        "archetypes": archetypes,
        "available_tags": available_tags,
        "uncovered_tags": uncovered_tags,
        "item_catalog": item_catalog,
    }


def save_archetype_allocations(archetype_id: str, entries: List[dict]) -> dict:
    paths = default_paths()
    items = parse_items(paths.mod_common / "Items")
    archetypes = _load_archetypes(paths.mod_common / "ArchetypeDefinitions", items)
    all_tags = _collect_all_tags(items, archetypes)
    archetype = next((row for row in archetypes if row["archetype_id"] == archetype_id), None)
    if archetype is None:
        raise ValueError(f"Unknown archetype: {archetype_id}")

    normalized = _normalize_entries(entries, items, all_tags)
    _write_allocations(Path(archetype["source_file"]), archetype_id, normalized)
    return load_archetype_editor_data()


def _collect_all_tags(items: Dict[str, ItemDef], archetypes: list[dict] | None = None) -> set[str]:
    tags: set[str] = set()

    def add_tag_family(tag_name: str) -> None:
        parts = [part for part in tag_name.split(".") if part]
        for index in range(len(parts)):
            tags.add(".".join(parts[: index + 1]))

    for item_def in items.values():
        for tag in item_def.tags:
            add_tag_family(tag)

    for archetype in archetypes or []:
        for allocation in archetype.get("allocations", []):
            for tag in allocation.get("tags") or []:
                add_tag_family(tag)

    return tags


def _load_archetypes(archetypes_root: Path, items: Dict[str, ItemDef]) -> list[dict]:
    vanilla_items = load_vanilla_items() if load_vanilla_items else {}
    archetypes: list[dict] = []

    for lua_file in find_lua_files(archetypes_root):
        normalized = str(lua_file).replace("\\", "/")
        if "/Items/" not in normalized:
            continue

        content = read_text(lua_file)
        for match in REGISTER_ARCH_RE.finditer(content):
            archetype_id = match.group(1).strip()
            open_idx = match.end() - 1
            block = extract_balanced_block(content, open_idx)
            if not block:
                continue

            name_match = re.search(r'name\s*=\s*"([^"]+)"', block)
            name = name_match.group(1).strip() if name_match else archetype_id

            allocations: list[dict] = []
            alloc_match = re.search(r"allocations\s*=\s*\{", block)
            if alloc_match:
                alloc_open_idx = alloc_match.end() - 1
                alloc_block = extract_balanced_block(block, alloc_open_idx)
                for source_order, entry_match in enumerate(ALLOC_ENTRY_RE.finditer(alloc_block)):
                    if entry_match.group(1) is not None:
                        entry = {
                            "kind": "tag",
                            "tags": parse_quoted_list(entry_match.group(1)),
                            "count": int(entry_match.group(3)),
                            "source_order": source_order,
                        }
                    else:
                        entry = {
                            "kind": "item",
                            "item_id": entry_match.group(2).strip(),
                            "count": int(entry_match.group(3)),
                            "source_order": source_order,
                        }

                    allocations.append(_entry_to_payload(entry, items, vanilla_items))

                for index, allocation in enumerate(allocations):
                    allocation["position"] = index
                    allocation.pop("source_order", None)

            archetypes.append(
                {
                    "archetype_id": archetype_id,
                    "name": name,
                    "source_file": str(lua_file),
                    "allocations": allocations,
                    "allocation_count": len(allocations),
                    "tag_allocation_count": len([row for row in allocations if row["kind"] == "tag"]),
                    "item_allocation_count": len([row for row in allocations if row["kind"] == "item"]),
                }
            )

    return archetypes


def _entry_to_payload(entry: dict, items: Dict[str, ItemDef], vanilla_items: dict) -> dict:
    matching_items = _match_entry_items(entry, items)
    payload = {
        "kind": entry["kind"],
        "count": int(entry["count"]),
        "matched_item_count": len(matching_items),
        "sample_items": [
            {
                "item_id": item_id,
                "name": _get_item_name(item_id, vanilla_items),
            }
            for item_id in matching_items[:5]
        ],
        "source_order": entry.get("source_order", 0),
    }

    if entry["kind"] == "tag":
        payload["tags"] = list(entry["tags"])
        payload["label"] = " + ".join(entry["tags"])
    else:
        item_id = entry["item_id"]
        payload["item_id"] = item_id
        payload["label"] = item_id
        payload["item_name"] = _get_item_name(item_id, vanilla_items)

    return payload


def _match_entry_items(entry: dict, items: Dict[str, ItemDef]) -> list[str]:
    if entry["kind"] == "item":
        item_id = entry["item_id"]
        return [item_id] if item_id in items else []

    tags = entry.get("tags") or []
    if not tags:
        return []

    return [
        item_id
        for item_id, item_def in items.items()
        if matches_all_tags(item_def.tags, tags)
    ]


def _find_matching_items_for_tag(tag: str, items: Dict[str, ItemDef]) -> list[str]:
    matches = []
    for item_id, item_def in items.items():
        if any(tag_matches(item_tag, tag) for item_tag in item_def.tags):
            matches.append(item_id)
    return matches


def _get_item_name(item_id: str, vanilla_items: dict) -> str:
    bare_id = item_id.split(".", 1)[1] if "." in item_id else item_id
    props = vanilla_items.get(bare_id) if isinstance(vanilla_items, dict) else None
    if props and get_translated_name:
        return get_translated_name(bare_id, props)
    return bare_id


def _normalize_entries(entries: List[dict], items: Dict[str, ItemDef], all_tags: set[str]) -> list[dict]:
    normalized: list[dict] = []
    for index, entry in enumerate(entries):
        kind = str(entry.get("kind", "")).strip().lower()
        try:
            count = int(entry.get("count", 0))
        except (TypeError, ValueError) as exc:
            raise ValueError(f"Allocation #{index + 1} has an invalid count.") from exc

        if count < 1:
            raise ValueError(f"Allocation #{index + 1} must have a count of at least 1.")

        if kind == "tag":
            tags = [str(tag).strip() for tag in (entry.get("tags") or []) if str(tag).strip()]
            if not tags:
                raise ValueError(f"Allocation #{index + 1} is missing tag values.")
            unknown = [tag for tag in tags if tag not in all_tags]
            if unknown:
                raise ValueError(f"Allocation #{index + 1} uses unknown tag(s): {', '.join(unknown)}")
            normalized.append({"kind": "tag", "tags": tags, "count": count})
            continue

        if kind == "item":
            item_id = str(entry.get("item_id", "")).strip()
            if not item_id:
                raise ValueError(f"Allocation #{index + 1} is missing an item ID.")
            if item_id not in items:
                raise ValueError(f"Allocation #{index + 1} uses an unknown item ID: {item_id}")
            normalized.append({"kind": "item", "item_id": item_id, "count": count})
            continue

        raise ValueError(f"Allocation #{index + 1} has an unsupported kind: {kind}")

    return normalized


def _write_allocations(file_path: Path, archetype_id: str, entries: list[dict]) -> None:
    content = read_text(file_path)

    for match in REGISTER_ARCH_RE.finditer(content):
        if match.group(1).strip() != archetype_id:
            continue

        block_start = match.end() - 1
        block = extract_balanced_block(content, block_start)
        if not block:
            break

        alloc_match = re.search(r"allocations\s*=\s*\{", block)
        if not alloc_match:
            raise ValueError(f"Archetype {archetype_id} does not define an allocations block.")

        alloc_open_idx = alloc_match.end() - 1
        alloc_block = extract_balanced_block(block, alloc_open_idx)
        if not alloc_block:
            raise ValueError(f"Unable to locate allocations block for archetype {archetype_id}.")

        updated_block = (
            block[:alloc_open_idx]
            + _render_allocations(entries)
            + block[alloc_open_idx + len(alloc_block):]
        )

        updated_content = (
            content[:block_start]
            + updated_block
            + content[block_start + len(block):]
        )
        file_path.write_text(updated_content, encoding="utf-8")
        return

    raise ValueError(f"Unable to locate archetype definition for {archetype_id} in {file_path.name}.")


def _render_allocations(entries: list[dict]) -> str:
    if not entries:
        return "{\n    }"

    lines = ["{"]
    for index, entry in enumerate(entries):
        suffix = "," if index < len(entries) - 1 else ""
        if entry["kind"] == "tag":
            tags = ", ".join(f'"{tag}"' for tag in entry["tags"])
            lines.append(f'        {{ tags={{{tags}}}, count = {entry["count"]} }}{suffix}')
        else:
            lines.append(f'        {{ item = "{entry["item_id"]}", count = {entry["count"]} }}{suffix}')
    lines.append("    }")
    return "\n".join(lines)
