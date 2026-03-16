from __future__ import annotations

import copy
from collections import Counter
from typing import Any, Dict

from ..commons.vanilla_loader import get_translated_name
from ..tag.tagging import generate_tags
from ..parse.overrides import load_overrides, get_override_for_item, apply_override
from .config_store import get_pricing_config
from .pricing import calculate_price_details
from .stock import calculate_stock_range
from .tag_utils import expand_hierarchy


def build_pricing_tag_catalog(items: Dict[str, str], pricing_config: Dict[str, Any] | None = None) -> Dict[str, Any]:
    config = pricing_config or get_pricing_config()
    current_additions = config.get("tag_price_additions", {})
    overrides = {
        override.get("item"): override
        for override in load_overrides()
        if override.get("item")
    }

    catalog: dict[str, dict[str, Any]] = {}
    for item_id, props in items.items():
        if not props:
            continue

        base_tags = generate_tags(item_id, props)
        override = overrides.get(item_id)
        tags = override.get("tags", base_tags) if override else base_tags
        primary = next(
            (
                tag for tag in tags
                if isinstance(tag, str) and not tag.startswith(("Rarity.", "Quality.", "Origin.", "Theme."))
            ),
            "Misc.General",
        )

        for tag in expand_hierarchy(tags):
            entry = catalog.setdefault(
                tag,
                {
                    "tag": tag,
                    "item_count": 0,
                    "domains": Counter(),
                    "samples": [],
                    "current_addition": float(current_additions.get(tag, 0.0)),
                },
            )
            entry["item_count"] += 1
            entry["domains"][primary] += 1
            if len(entry["samples"]) < 3:
                entry["samples"].append(
                    {
                        "item_id": item_id,
                        "name": get_translated_name(item_id, props),
                    }
                )

    rows = []
    for tag, entry in catalog.items():
        rows.append(
            {
                "tag": tag,
                "item_count": entry["item_count"],
                "current_addition": entry["current_addition"],
                "domains": [
                    {"tag": domain, "count": count}
                    for domain, count in entry["domains"].most_common(6)
                ],
                "samples": entry["samples"],
            }
        )

    rows.sort(key=lambda row: (-row["item_count"], row["tag"]))
    return {"tags": rows}


def preview_pricing_tag(
    items: Dict[str, str],
    tag: str,
    addition: float = 0.0,
    limit: int = 40,
    pricing_config: Dict[str, Any] | None = None,
) -> Dict[str, Any]:
    base_config = pricing_config or get_pricing_config()
    preview_config = copy.deepcopy(base_config)
    preview_config.setdefault("tag_price_additions", {})
    overrides = {
        override.get("item"): override
        for override in load_overrides()
        if override.get("item")
    }

    if abs(float(addition)) < 1e-9:
        preview_config["tag_price_additions"].pop(tag, None)
    else:
        preview_config["tag_price_additions"][tag] = float(addition)

    matches = []
    domains: Counter[str] = Counter()
    current_total = 0.0
    preview_total = 0.0

    for item_id, props in items.items():
        if not props:
            continue

        base_tags = generate_tags(item_id, props)
        override = overrides.get(item_id)
        tags = override.get("tags", base_tags) if override else base_tags
        if tag not in set(expand_hierarchy(tags)):
            continue

        current_details = calculate_price_details(item_id, props, tags, base_config)
        preview_details = calculate_price_details(item_id, props, tags, preview_config)
        stock_range = calculate_stock_range(item_id, props, tags)
        current_price, current_tags, current_stock_min, current_stock_max, _ = apply_override(
            item_id,
            current_details["price"],
            tags,
            stock_range["min"],
            stock_range["max"],
            [override] if override else [],
        )
        preview_price, preview_tags, preview_stock_min, preview_stock_max, _ = apply_override(
            item_id,
            preview_details["price"],
            tags,
            stock_range["min"],
            stock_range["max"],
            [override] if override else [],
        )
        domains[current_details["primary_tag"]] += 1
        current_total += current_price
        preview_total += preview_price
        matches.append(
            {
                "item_id": item_id,
                "name": get_translated_name(item_id, props),
                "primary_tag": current_details["primary_tag"],
                "current_price": int(current_price),
                "preview_price": int(preview_price),
                "delta": int(preview_price) - int(current_price),
                "tags": list(current_tags),
                "stock_min": int(current_stock_min),
                "stock_max": int(current_stock_max),
                "preview_stock_min": int(preview_stock_min),
                "preview_stock_max": int(preview_stock_max),
                "has_override": bool(override),
            }
        )

    matches.sort(key=lambda row: (-abs(row["delta"]), -row["preview_price"], row["name"]))
    total_items = len(matches)

    return {
        "tag": tag,
        "addition": float(addition),
        "saved_addition": float(base_config.get("tag_price_additions", {}).get(tag, 0.0)),
        "item_count": total_items,
        "domains": [{"tag": domain, "count": count} for domain, count in domains.most_common(10)],
        "stats": {
            "avg_current_price": round(current_total / total_items, 2) if total_items else 0.0,
            "avg_preview_price": round(preview_total / total_items, 2) if total_items else 0.0,
        },
        "items": matches[: max(1, limit)],
    }
