import argparse
import os
import json
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent.resolve()
SKILL_DIR = SCRIPT_DIR.parent
RESOURCES_DIR = SKILL_DIR / "resources"
DOCS_DIR = RESOURCES_DIR / "docs"
WORKSPACE_ROOT = SKILL_DIR.parent.parent.parent

def get_nearby_docs(start_path, max_depth=5):
    found_docs = []
    start_path_obj = Path(start_path)
    for root, dirs, files in os.walk(start_path_obj):
        rel_root = Path(root).relative_to(start_path_obj)
        depth = len(rel_root.parts)
        if depth > max_depth:
            dirs[:] = []  # Stop walking deeper
            continue
        
        for file in files:
            if file.endswith(".txt") and file != "index.txt":
                full_path = Path(root) / file
                doc_rel_path = full_path.relative_to(DOCS_DIR).with_suffix('')
                found_docs.append(str(doc_rel_path))
    return sorted(found_docs)

def do_docs(doc_path_str):
    target_rel = Path(doc_path_str)
    workspace_path = WORKSPACE_ROOT / target_rel
    
    doc_file_path = DOCS_DIR / target_rel.with_suffix('.txt')
    doc_dir_path = DOCS_DIR / target_rel
    index_file = doc_dir_path / "index.txt"
    
    path_exists_in_workspace = workspace_path.exists()
    is_directory = workspace_path.is_dir() if path_exists_in_workspace else False

    # 1. Precise File Search (Found)
    if doc_file_path.exists() and doc_file_path.is_file() and doc_file_path.name != "index.txt":
        print(f"--- Document: {doc_path_str} ---")
        print(doc_file_path.read_text())
        return

    # 2. Directory Search
    if is_directory or (doc_dir_path.exists() and doc_dir_path.is_dir()):
        has_index = index_file.exists() and index_file.is_file()
        topics = []
        if doc_dir_path.exists() and doc_dir_path.is_dir():
            items = os.listdir(doc_dir_path)
            topics = [f"{doc_path_str}/{item.replace('.txt', '')}" for item in items if item.endswith(".txt") and item != "index.txt"]
        
        if "DynamicTradingV1" in doc_path_str or "DynamicTradingV2" in doc_path_str:
            common_dir = DOCS_DIR / "Contents/mods/DynamicTradingCommon"
            if common_dir.exists() and common_dir.is_dir():
                common_items = os.listdir(common_dir)
                common_topics = [f"Contents/mods/DynamicTradingCommon/{item.replace('.txt', '')}" 
                                 for item in common_items if item.endswith(".txt") and item != "index.txt"]
                topics.extend(common_topics)
        
        topics = sorted(list(set(topics)))

        # Only print header if we actually have a landing page or related topics
        if has_index or topics:
            if has_index:
                print(index_file.read_text())
                if topics: print("="*40)
            
            if topics:
                print("Related Topics (including shared systems):")
                for topic in topics:
                    print(f"  - {topic}")
            return

        # Found in workspace but NO doc
        if path_exists_in_workspace:
            print(f"Not found, Suggestion: Create the Directory documentation at:")
            print(f"  {index_file}")
            return

    # 3. File found in workspace but NO doc
    if path_exists_in_workspace:
        print(f"Not found, Suggestion: Create the documentation file at:")
        print(f"  {doc_file_path}")
        return

    # 4. Completely Not Found / Invalid Path
    print(f"Invalid Path / Not Found: {doc_path_str}")
    
    nearby = get_nearby_docs(DOCS_DIR, max_depth=99)
    filtered_nearby = [n for n in nearby if doc_path_str.lower() in n.lower()]
    if filtered_nearby:
        print("\nSimilar documentation paths found:")
        for n in filtered_nearby:
            print(f"  - {n}")

def main():
    parser = argparse.ArgumentParser(description="Mod Docs: Efficient documentation retrieval tool.")
    parser.add_argument("--overview", action="store_true", help="Prints the high-level architecture overview of the project.")
    parser.add_argument("--docs", type=str, metavar="PATH", help="Print the manual entry text for a specific path.")
    
    args = parser.parse_args()
    
    if args.overview:
        overview_path = RESOURCES_DIR / "overview.txt"
        if overview_path.exists():
            print(overview_path.read_text())
        else:
            print("Overview file not found.")
            
    elif args.docs:
        do_docs(args.docs)
        
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
