import os
import re
import argparse

# Configuration
BASE_DIR = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/"
ITEMS_DIR = os.path.join(BASE_DIR, "Items/")
DESCRIPTOR_ROOTS = ["Rarity", "Quality", "Theme", "Origin"]
TAGS_PATTERN = re.compile(r'item\s*=\s*["\']([^"\']+)["\'].*?tags\s*=\s*\{([^}]+)\}', re.DOTALL)

def build_registry():
    """Builds a master list of { itemID: tags[] } across all files."""
    registry = {}
    if not os.path.exists(ITEMS_DIR):
        return registry
        
    for filename in sorted(os.listdir(ITEMS_DIR)):
        if not filename.endswith(".lua"): continue
        with open(os.path.join(ITEMS_DIR, filename), 'r', encoding='utf-8') as f:
            content = f.read()
            items = TAGS_PATTERN.findall(content)
            for item_id, tags_str in items:
                tags = [t.strip().strip('"').strip("'") for t in tags_str.split(',')]
                registry[item_id] = tags
    return registry

def build_tag_tree(registry):
    """Builds a hierarchical tree from the registry."""
    tree = {}
    for tags in registry.values():
        for tag_path in tags:
            parts = tag_path.split('.')
            curr = tree
            for i, part in enumerate(parts):
                if part not in curr: curr[part] = {"_count": 0, "_children": {}}
                if i == len(parts) - 1:
                    curr[part]["_count"] += 1
                curr = curr[part]["_children"]
    return tree

def get_node(tree, path):
    """Retrieves a specific node in the tree based on a dot-separated path."""
    if not path: return tree
    parts = path.split('.')
    curr = tree
    for part in parts:
        if part not in curr: return None
        curr = curr[part]["_children"]
    return curr

def count_recursive_items(node):
    """Recursively counts items starting from a specific node."""
    total = node.get("_count", 0)
    for child in node.get("_children", {}).values():
        total += count_recursive_items(child)
    return total

def print_roots(tree):
    """Prints the top-level taxonomy roots and descriptors."""
    print("=== PRIMARY TAXONOMY ROOTS ===")
    tax_nodes = {k: v for k, v in tree.items() if k not in DESCRIPTOR_ROOTS}
    for name, node in sorted(tax_nodes.items()):
        count = count_recursive_items(node)
        has_children = "Yes" if node["_children"] else "No"
        print(f"  {name:<20} Items: {count:<4} Sub-categories: {has_children}")

    print("\n=== GLOBAL DESCRIPTORS (FILTERS) ===")
    desc_nodes = {k: v for k, v in tree.items() if k in DESCRIPTOR_ROOTS}
    for name, node in sorted(desc_nodes.items()):
        count = count_recursive_items(node)
        has_children = "Yes" if node["_children"] else "No"
        print(f"  {name:<20} Items: {count:<4} Sub-categories: {has_children}")
    
    print("\nUse --path <RootName> to explore further.")

def print_path(tree, path):
    """Prints the immediate children of a specific tag path."""
    node = get_node(tree, path)
    if not node:
        print(f"Error: Path '{path}' not found in registry.")
        return

    print(f"=== PATH: {path} ===")
    
    # Calculate items directly assigned to this exact path
    # We need to find the specific node in its parent to get _count
    parts = path.split('.')
    parent_node = get_node(tree, '.'.join(parts[:-1])) if len(parts) > 1 else tree
    target_part = parts[-1]
    direct_count = parent_node[target_part].get("_count", 0) if parent_node and target_part in parent_node else 0

    print(f"Items assigned DIRECTLY to {path}: {direct_count}")
    
    if not node:
         print(f"\nNo sub-categories found (Leaf Node).")
         return
         
    print("\n-- Sub-categories --")
    for name, child in sorted(node.items()):
        count = count_recursive_items(child)
        has_children = "Yes" if child["_children"] else "No"
        print(f"  {name:<25} Items (Recursive): {count:<4} Deeper: {has_children}")
        
    print(f"\nTo look deeper, use: --path {path}.<SubCategory>")

def main():
    parser = argparse.ArgumentParser(description="LLM Interactive Tag Query Tool")
    parser.add_argument("--path", type=str, help="Dot-separated tag path to query (e.g., 'Food.Fruit')")
    args = parser.parse_args()

    registry = build_registry()
    if not registry:
        print("Error: Could not find dynamic trading item registry.")
        return

    tree = build_tag_tree(registry)

    if args.path:
        print_path(tree, args.path)
    else:
        print_roots(tree)

if __name__ == "__main__":
    main()
