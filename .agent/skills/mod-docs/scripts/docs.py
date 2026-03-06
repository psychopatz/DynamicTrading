import argparse
import os
import json
import re
import random
import string
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent.resolve()
SKILL_DIR = SCRIPT_DIR.parent
RESOURCES_DIR = SKILL_DIR / "resources"
DOCS_DIR = RESOURCES_DIR / "docs"
WORKSPACE_ROOT = SKILL_DIR.parent.parent.parent
SHORTCODES_FILE = RESOURCES_DIR / "shortcodes.json"

SUGGESTION_TEMPLATE = """
[Standard Format Tutorial]
Title: Case-sensitive title or short summary
Tags: [tag1, tag2]

[Document Content]

Tip: Run --verify to check your documentation syntax.
"""

def get_all_txt_files(path):
    txt_files = []
    for root, _, files in os.walk(path):
        for file in files:
            if file.endswith(".txt"):
                txt_files.append(Path(root) / file)
    return txt_files

def do_verify():
    print(f"Verifying documentation in: {DOCS_DIR}\n" + "="*40)
    registry = load_registry()
    files = get_all_txt_files(DOCS_DIR)
    errors = 0
    successes = 0
    collisions = []
    virtuals = []
    orphaned_codes = []
    
    # Analyze registry for collisions and virtuals
    shortcodes = load_shortcodes()
    for code, path_str in shortcodes.items():
        doc_path = DOCS_DIR / (path_str + ".txt")
        if not doc_path.exists():
            orphaned_codes.append(code)

    for slug, entry in registry.items():
        if entry.get('collision'): collisions.append(slug)
        elif entry.get('virtual') and not entry.get('collision'): virtuals.append(slug)

    for f in sorted(files):
        rel = f.relative_to(DOCS_DIR)
        title, tags, content = parse_doc(f)
        issues = []
        
        if not title: issues.append("Missing or invalid 'Title:' header")
        if not tags: issues.append("Missing or invalid 'Tags:' header (must be [tag1, tag2, ...])")
        if not content.strip(): issues.append("Empty body content")
        
        # Check Token Strictness
        if f.name == "index.txt" and len(content.splitlines()) > 40:
            issues.append(f"Token Strictness Violation: Directory Index body is {len(content.splitlines())} lines long (Max 40 allowed).")
            issues.append("  Please segregate detailed implementation logic into standalone file docs and use @shortcodes to reference them.")
            
        if issues:
            print(f"[ERROR] {rel}")
            for iss in issues: print(f"  - {iss}")
            errors += 1
        else:
            successes += 1
            
    if orphaned_codes:
        print("\n" + "="*40 + "\nAuto-Cleaning Orphaned Shortcodes (Points to deleted files):")
        for code in orphaned_codes:
            print(f"  - Removed [{code}] -> {shortcodes[code]}")
            del shortcodes[code]
        # Persist cleanup
        save_shortcodes(shortcodes)
        print("  ✓ Cleanup persisted to shortcodes.json")

    # Prune manual registry
    registry_path = RESOURCES_DIR / "registry.json"
    if registry_path.exists():
        try:
            raw_reg = json.loads(registry_path.read_text())
            orphaned_manual = []
            for slug, entry in raw_reg.items():
                p = entry.get('path', '')
                if not p: continue
                # Must exist as either file.txt or folder/index.txt
                doc_file = DOCS_DIR / (p + ".txt")
                doc_idx = DOCS_DIR / p / "index.txt"
                if not doc_file.exists() and not doc_idx.exists():
                    orphaned_manual.append(slug)
            
            if orphaned_manual:
                print("\n" + "="*40 + "\nAuto-Cleaning Orphaned Registry Entries (Registry.json):")
                for slug in orphaned_manual:
                    print(f"  - Removed [{slug}] -> {raw_reg[slug].get('path')}")
                    del raw_reg[slug]
                save_registry(raw_reg)
                print("  ✓ Cleanup persisted to registry.json")
        except:
            pass

    if collisions:
        print("\n" + "="*40 + "\nSlug Collisions (Qualified Slugs Generated):")
        for c in sorted(list(set(collisions))): print(f"  - {c}")

    print("="*40)
    print(f"Verification Complete: {successes} Passed, {errors} Failed.")
    if virtuals: print(f"Note: {len(virtuals)} files are currently using Virtual Slugs.")
    return errors == 0

def get_nearby_docs(start_path, max_depth=5):
    found_docs = []
    start_path_obj = Path(start_path)
    if not start_path_obj.exists(): return []
    for root, dirs, files in os.walk(start_path_obj):
        rel_root = Path(root).relative_to(start_path_obj)
        depth = len(rel_root.parts)
        if depth > max_depth:
            dirs[:] = []
            continue
        for file in files:
            if file.endswith(".txt") and file != "index.txt":
                full_path = Path(root) / file
                doc_rel_path = full_path.relative_to(DOCS_DIR).with_suffix('')
                found_docs.append(str(doc_rel_path))
    return sorted(found_docs)

def load_shortcodes():
    if SHORTCODES_FILE.exists():
        try:
            return json.loads(SHORTCODES_FILE.read_text())
        except:
            pass
    return {}

def save_shortcodes(data):
    RESOURCES_DIR.mkdir(parents=True, exist_ok=True)
    SHORTCODES_FILE.write_text(json.dumps(data, indent=4))

def save_registry(data):
    path = RESOURCES_DIR / "registry.json"
    RESOURCES_DIR.mkdir(parents=True, exist_ok=True)
    # Filter out virtual/shortcode entries before saving
    manual_data = {k: v for k, v in data.items() if not v.get('virtual') and not v.get('is_shortcode')}
    path.write_text(json.dumps(manual_data, indent=4))

def get_or_create_shortcode(path_str, shortcodes):
    path_str = path_str.replace("\\", "/").strip("/")
    # Check if path already has a code
    for code, p in shortcodes.items():
        if p == path_str:
            return code
    
    # Create new code
    chars = string.ascii_lowercase + string.digits
    while True:
        code = ''.join(random.choice(chars) for _ in range(4))
        if code not in shortcodes:
            shortcodes[code] = path_str
            save_shortcodes(shortcodes)
            return code

def load_registry():
    path = RESOURCES_DIR / "registry.json"
    registry = {}
    if path.exists():
        try:
            registry = json.loads(path.read_text())
        except:
            pass
            
    # Load shortcodes
    shortcodes = load_shortcodes()
    
    # Auto-Indexing: Scan DOCS_DIR
    known_paths = {entry["path"].replace("\\", "/").strip("/").lower() for entry in registry.values()}
    stem_map = {} 
    
    all_files = get_all_txt_files(DOCS_DIR)
    for f_path in all_files:
        if f_path.name == "index.txt": continue
        rel_path = f_path.relative_to(DOCS_DIR).with_suffix('')
        rel_str = str(rel_path).replace("\\", "/").strip("/")
        
        # Ensure every .txt has a shortcode
        get_or_create_shortcode(rel_str, shortcodes)

        if rel_str.lower() not in known_paths:
            stem = f_path.stem.lower()
            if stem not in stem_map: stem_map[stem] = []
            stem_map[stem].append(rel_str)
            
    # Apply unique slugs
    for stem, paths in stem_map.items():
        if len(paths) == 1:
            rel_str = paths[0]
            if stem not in registry:
                title, tags, _ = parse_doc(DOCS_DIR / (rel_str + ".txt"))
                if title:
                    registry[stem] = {"path": rel_str, "desc": title, "tags": tags, "virtual": True}
        else:
            for rel_str in paths:
                parts = rel_str.split("/")
                qualified_slug = ""
                if len(parts) >= 2:
                    parent = parts[-2]
                    prefix_map = {"DynamicTradingV1": "v1", "DynamicTradingV2": "v2", "DynamicTradingCommon": "common"}
                    prefix = prefix_map.get(parent, parent.lower())
                    qualified_slug = f"{prefix}/{stem}"
                final_slug = qualified_slug if qualified_slug else rel_str
                title, tags, _ = parse_doc(DOCS_DIR / (rel_str + ".txt"))
                if title:
                    if final_slug not in registry:
                        registry[final_slug] = {"path": rel_str, "desc": title, "tags": tags, "virtual": True, "collision": True}
                    if rel_str not in registry:
                        registry[rel_str] = registry[final_slug]

    # Inject shortcodes into registry for fast lookup
    for code, path_str in shortcodes.items():
        # Find matching entry to inherit metadata
        matched_entry = None
        for alias, entry in registry.items():
            if entry["path"].replace("\\", "/").strip("/") == path_str:
                matched_entry = entry
                break
        
        if matched_entry:
            registry[code] = {**matched_entry, "is_shortcode": True}
        else:
            # Maybe it's a folder or index? 
            registry[code] = {"path": path_str, "desc": "Shortcode Link", "tags": [], "is_shortcode": True}

    return registry

def parse_doc(file_path):
    if not file_path.exists():
        return None, [], ""
    try:
        content = file_path.read_text()
    except:
        return None, [], ""
    lines = content.splitlines()
    title = ""
    tags = []
    body_start = 0
    
    if lines and lines[0].startswith("Title:"):
        title = lines[0][6:].strip()
        body_start = 1
        if len(lines) > body_start and lines[1].startswith("Tags:"):
            raw_tags = lines[1][5:].strip()
            raw_tags = raw_tags.strip("[]")
            tags = [t.strip() for t in raw_tags.split(",") if t.strip()]
            body_start = 2
            
    while body_start < len(lines) and not lines[body_start].strip():
        body_start += 1
        
    return title, tags, "\n".join(lines[body_start:])

def find_in_registry(query, registry):
    # Direct slug match (case-insensitive)
    query_l = query.lower()
    for alias, entry in registry.items():
        if alias.lower() == query_l:
            return entry["path"], entry
            
    # Path match (case-insensitive)
    query_norm = query.replace("\\", "/").strip("/").lower()
    for alias, entry in registry.items():
        if entry["path"].replace("\\", "/").strip("/").lower() == query_norm:
            return entry["path"], entry
            
    return query, None

def get_embedded_refs(content):
    refs = re.findall(r'@(\w+)|\[([\w\-/.]+)\]', content)
    found = []
    for r in refs:
        found.append(r[0] if r[0] else r[1])
    return sorted(list(set(found)))

def do_docs(doc_path_str):
    registry = load_registry()
    resolved_path, reg_metadata = find_in_registry(doc_path_str, registry)
    
    target_rel = Path(resolved_path)
    workspace_path = WORKSPACE_ROOT / target_rel
    doc_file_path = DOCS_DIR / target_rel.with_suffix('.txt')
    doc_dir_path = DOCS_DIR / target_rel
    index_file = doc_dir_path / "index.txt"
    
    # Fallback for "File-as-Directory" padding (massive files spoofed as dirs)
    if not doc_file_path.exists() and target_rel.suffix:
        fallback_dir_path = DOCS_DIR / target_rel.parent / target_rel.stem
        if fallback_dir_path.exists() and fallback_dir_path.is_dir() and (fallback_dir_path / "index.txt").exists():
            doc_dir_path = fallback_dir_path
            index_file = fallback_dir_path / "index.txt"
    
    path_exists_in_workspace = workspace_path.exists()
    is_directory = workspace_path.is_dir() if path_exists_in_workspace else False
    
    related = set()

    # 1. Precise File Search
    if doc_file_path.exists() and doc_file_path.is_file() and doc_file_path.name != "index.txt":
        title, tags, content = parse_doc(doc_file_path)
        print(content)
        
        all_tags = set(tags)
        if reg_metadata: all_tags.update(reg_metadata.get('tags', []))
        
        # Discovery B: Semantic Tags (Registry)
        print("\n" + "="*40 + "\nRelated Topics (Registry Tags):")
        processed_paths = {resolved_path.lower()}
        best_aliases = {} # path -> (alias, desc)
        
        shortcodes = load_shortcodes()
        path_to_code = {v.lower(): k for k, v in shortcodes.items()}

        for alias, entry in registry.items():
            if any(t in entry.get('tags', []) for t in all_tags) and entry['path'].lower() != resolved_path.lower():
                p = entry['path'].lower()
                if p not in processed_paths:
                    # Prefer shortcode if available
                    display_alias = path_to_code.get(p, alias)
                    if p not in best_aliases or len(display_alias) < len(best_aliases[p][0]):
                        best_aliases[p] = (display_alias, entry.get('desc', 'Related system'))

        if best_aliases:
            for p in sorted(best_aliases.keys()):
                alias, desc = best_aliases[p]
                print(f"  [{alias}] - {desc}")
        else:
            print("  None found.")
        return

    # 2. Directory Search
    if is_directory or (doc_dir_path.exists() and doc_dir_path.is_dir()):
        has_index = index_file.exists() and index_file.is_file()
        title, tags, content = parse_doc(index_file) if has_index else ("", [], "")
        
        if has_index:
            print(content)

        # Discovery Mode (3 Types)
        fs_topics = []
        if doc_dir_path.exists() and doc_dir_path.is_dir():
            for item in os.listdir(doc_dir_path):
                if item.endswith(".txt") and item != "index.txt":
                    slug = item.replace(".txt", "")
                    item_rel_path = str(target_rel / slug)
                    alias = next((a for a, e in registry.items() if e['path'] == item_rel_path), item_rel_path)
                    fs_topics.append(alias)

        tag_topics = []
        all_tags = set(tags)
        if reg_metadata: all_tags.update(reg_metadata.get('tags', []))
        if all_tags:
            for alias, entry in registry.items():
                if any(t in entry.get('tags', []) for t in all_tags) and entry['path'] != resolved_path:
                    tag_topics.append((alias, entry.get('desc', 'Matching tags')))

        embedded_refs = []
        if has_index:
            refs = get_embedded_refs(content)
            for ref in refs:
                _, meta = find_in_registry(ref, registry)
                embedded_refs.append((ref, meta.get('desc', 'Reference') if meta else "Path"))

        if fs_topics or tag_topics or embedded_refs:
            if has_index: print("="*40)
            print("Related Topics (Contextual Discovery):")
            processed_paths = {resolved_path.lower()}
            best_aliases = {} # path -> (alias, desc)
            
            shortcodes = load_shortcodes()
            path_to_code = {v.lower(): k for k, v in shortcodes.items()}

            # Aggregate from all 3 sources
            all_potential = []
            for t in fs_topics: all_potential.append(t)
            for t_alias, _ in tag_topics: all_potential.append(t_alias)
            for r_path, _ in embedded_refs: all_potential.append(r_path)
            
            for alias in all_potential:
                _, meta = find_in_registry(alias, registry)
                if meta:
                    p = meta['path'].lower()
                    if p != resolved_path.lower() and p not in processed_paths:
                        # Find shortest alias (prefer shortcode)
                        best_a = path_to_code.get(p, alias)
                        for a, e in registry.items():
                            if e['path'].lower() == p and len(a) < len(best_a):
                                best_a = a
                        
                        if p not in best_aliases or len(best_a) < len(best_aliases[p][0]):
                            best_aliases[p] = (best_a, meta.get('desc', 'Link'))

            for p in sorted(best_aliases.keys()):
                alias, desc = best_aliases[p]
                print(f"  [{alias}] - {desc}")
            return

        # Discovery A: Recursive Exploration (if no items found)
        if not has_index:
            nearby = get_nearby_docs(DOCS_DIR, max_depth=99)
            sub_topics = [n for n in nearby if n.startswith(resolved_path + "/")]
            if sub_topics:
                print(f"No direct documentation, but sub-topics found:")
                for n in sub_topics[:10]:
                    print(f"  - {n}")
                print("-" * 20) # Separator before suggestion

        # Suggestion if strictly missing
        if not has_index and path_exists_in_workspace:
            print(f"Not found, Suggestion: Create the Directory documentation at:\n  {index_file}")
            print(SUGGESTION_TEMPLATE)
        return

    # 3. File found in workspace but NO doc
    if path_exists_in_workspace:
        print(f"Not found, Suggestion: Create the documentation file at:\n  {doc_file_path}")
        print(SUGGESTION_TEMPLATE)
        return

    # 4. Invalid Path
    print(f"Invalid Path / Not Found: {doc_path_str}")

def main():
    parser = argparse.ArgumentParser(
        description="Mod Docs: High-efficiency documentation retrieval system for Dynamic Trading.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage Examples:
  python3 docs.py --docs economy          # Query by Slug (Alias)
  python3 docs.py --docs wk4b             # Query by Shortcode (High Efficiency)
  python3 docs.py --docs Contents/mods/.. # Query by Workspace Path
  python3 docs.py --verify                # Check syntax and index health

Key Features:
  - Auto-Indexing: Any .txt with 'Title:' header is automatically discoverable.
  - Shortcodes: Unique 4-character IDs (e.g. wk4b) for minimum token usage.
  - Smart Discovery: Shows Related Topics via Tag Matching and @references.
  - Minimalist: Outputs only document body to conserve agent context tokens.
        """
    )
    parser.add_argument("--overview", action="store_true", help="Display project-level architectural overview.")
    parser.add_argument("--docs", type=str, metavar="ID", help="Print manual for a slug, shortcode, or path.")
    parser.add_argument("--verify", action="store_true", help="Verify documentation syntax and report collisions/orphans.")
    args = parser.parse_args()
    if args.overview:
        overview_path = RESOURCES_DIR / "overview.txt"
        if overview_path.exists(): print(overview_path.read_text())
    elif args.verify:
        do_verify()
    elif args.docs:
        do_docs(args.docs)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
