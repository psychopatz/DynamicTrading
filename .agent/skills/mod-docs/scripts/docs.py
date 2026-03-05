import argparse
import os
import json
import re
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent.resolve()
SKILL_DIR = SCRIPT_DIR.parent
RESOURCES_DIR = SKILL_DIR / "resources"
DOCS_DIR = RESOURCES_DIR / "docs"
WORKSPACE_ROOT = SKILL_DIR.parent.parent.parent

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
    files = get_all_txt_files(DOCS_DIR)
    errors = 0
    successes = 0
    
    for f in sorted(files):
        rel = f.relative_to(DOCS_DIR)
        title, tags, content = parse_doc(f)
        issues = []
        
        if not title:
            issues.append("Missing or invalid 'Title:' header")
        if not tags:
            issues.append("Missing or invalid 'Tags:' header (must be [tag1, tag2, ...])")
        if not content.strip():
            issues.append("Empty body content")
            
        if issues:
            print(f"[ERROR] {rel}")
            for iss in issues:
                print(f"  - {iss}")
            errors += 1
        else:
            successes += 1
            
    print("="*40)
    print(f"Verification Complete: {successes} Passed, {errors} Failed.")
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

def load_registry():
    path = RESOURCES_DIR / "registry.json"
    if path.exists():
        try:
            return json.loads(path.read_text())
        except:
            pass
    return {}

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
    if query in registry:
        return registry[query]["path"], registry[query]
    query_norm = query.replace("\\", "/").strip("/")
    for alias, entry in registry.items():
        if entry["path"].replace("\\", "/").strip("/") == query_norm:
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
        for alias, entry in registry.items():
            if any(t in entry.get('tags', []) for t in all_tags) and entry['path'] != resolved_path:
                related.add((alias, entry.get('desc', 'Related system')))
        
        if related:
            print("\n" + "="*40 + "\nRelated Topics (Registry Tags):")
            for r_path, r_desc in sorted(list(related)):
                print(f"  [{r_path}] - {r_desc}")
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
            processed = set()
            # 1. FS Topics
            for t in sorted(fs_topics):
                _, meta = find_in_registry(t, registry)
                print(f"  [{t}] - {meta.get('desc', 'Local') if meta else 'Local'}")
                processed.add(t)
            # 2. Tag Topics
            for t_alias, t_desc in sorted(tag_topics):
                if t_alias not in processed:
                    print(f"  [{t_alias}] - {t_desc}")
                    processed.add(t_alias)
            # 3. Embedded Refs
            for r_path, r_desc in sorted(embedded_refs):
                if r_path not in processed:
                    print(f"  [{r_path}] - {r_desc}")
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
    parser = argparse.ArgumentParser(description="Mod Docs: Efficient documentation retrieval tool.")
    parser.add_argument("--overview", action="store_true", help="Overview.")
    parser.add_argument("--docs", type=str, metavar="PATH", help="Print manual.")
    parser.add_argument("--verify", action="store_true", help="Verify all documentation syntax.")
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
