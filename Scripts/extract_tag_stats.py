import os
import re
import argparse
from collections import Counter

# Configuration
BASE_DIR = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/"
ITEMS_DIR = os.path.join(BASE_DIR, "Items/")
ARCH_DIR = os.path.join(BASE_DIR, "ArchetypeDefinitions/")
# Create output directory if it doesn't exist
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Output")
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

OUTPUT_STATS = os.path.join(OUTPUT_DIR, "tag_statistics.txt")
OUTPUT_SIM   = os.path.join(OUTPUT_DIR, "archetype_simulation.txt")
OUTPUT_TAGS  = os.path.join(OUTPUT_DIR, "tags_audit.txt")

# Regex Patterns
TAGS_PATTERN = re.compile(r'item\s*=\s*["\']([^"\']+)["\'].*?tags\s*=\s*\{([^}]+)\}', re.DOTALL)
ARCH_ALLOC_RE = re.compile(r'allocations\s*=\s*\{(.*?)\n\s*\}', re.DOTALL)
FILTER_RE = re.compile(r'\{\s*(tags|item)\s*=\s*(.*?)\s*,\s*count\s*=\s*(\d+)\s*\}', re.DOTALL)

# Configuration for Attributes vs Identities
ATTRIBUTE_ROOTS = {"Quality", "Rarity", "Origin", "Theme"}

def matches_all_tags(item_tags, required_tags):
    """Standardized hierarchical tag matching (mimics Lua Common.MatchesAllTags)."""
    if not required_tags: return False
    for req in required_tags:
        matched = False
        for it in item_tags:
            if it == req or it.startswith(req + "."):
                matched = True
                break
        if not matched: return False
    return True

def get_item_registry():
    """Builds a master list of { itemID: tags[] } across all files."""
    registry = {}
    for filename in sorted(os.listdir(ITEMS_DIR)):
        if not filename.endswith(".lua"): continue
        with open(os.path.join(ITEMS_DIR, filename), 'r', encoding='utf-8') as f:
            content = f.read()
            # Extract matches
            items = TAGS_PATTERN.findall(content)
            for item_id, tags_str in items:
                tags = [t.strip().strip('"').strip("'") for t in tags_str.split(',')]
                registry[item_id] = tags
    return registry

def run_stats(registry):
    """Generates a redesigned hierarchical tag statistics report."""
    total_stats = {}
    
    # 1. Count occurrences
    for tags in registry.values():
        for tag in tags:
            total_stats[tag] = total_stats.get(tag, 0) + 1

    # 2. Build Tree Structure
    tree = {}
    for tag_path, count in total_stats.items():
        parts = tag_path.split('.')
        curr = tree
        for i, part in enumerate(parts):
            if part not in curr:
                curr[part] = {"_count": 0, "_children": {}}
            if i == len(parts) - 1:
                curr[part]["_count"] = count
            curr = curr[part]["_children"]

    # 3. Write Report
    with open(OUTPUT_STATS, 'w', encoding='utf-8') as f:
        f.write("╔══════════════════════════════════════════════════════════╗\n")
        f.write("║      Project Zomboid Dynamic Trading - Tag Hierarchy      ║\n")
        f.write("╚══════════════════════════════════════════════════════════╝\n\n")
        
        f.write(f"{'  Tag Structure':<50} │ {'Count':<8}\n")
        f.write("╌" * 53 + "┼" + "╼" * 10 + "\n")

        def print_node(node_dict, name, prefix="", is_last=True, depth=0):
            # Connector logic
            if depth == 0:
                connector = ""
                new_prefix = ""
            else:
                connector = "└── " if is_last else "├── "
                new_prefix = prefix + ("    " if is_last else "│   ")
            
            # Label
            label = f"{prefix}{connector}{name}"
            count_str = str(node_dict["_count"]) if node_dict["_count"] > 0 else "-"
            
            # Format row: Label [dots] Count
            padding = 52 - len(label)
            f.write(f"{label} {'.' * padding} {count_str:>8}\n")
            
            # Children
            children = sorted(node_dict["_children"].items())
            for i, (child_name, child_node) in enumerate(children):
                print_node(child_node, child_name, new_prefix, i == len(children) - 1, depth + 1)

        # Print all root categories
        roots = sorted(tree.items())
        for i, (name, node) in enumerate(roots):
            print_node(node, name, is_last=(i == len(roots) - 1), depth=0)
            f.write("\n")

    print(f"Stats report generated at: {OUTPUT_STATS}")

def run_simulation(registry, verbose=False):
    """Simulates archetype allocations vs current item registry."""
    archetypes = {}
    
    # 1. Parse Archetypes
    for root_path, dirs, files in os.walk(ARCH_DIR):
        for filename in files:
            if not (filename.startswith("DT_") and filename.endswith(".lua")): continue
            with open(os.path.join(root_path, filename), 'r', encoding='utf-8') as f:
                content = f.read()
                arch_name_match = re.search(r'RegisterArchetype\(\s*["\']([^"\']+)["\']', content)
                if not arch_name_match: continue
                
                name = arch_name_match.group(1)
                alloc_match = ARCH_ALLOC_RE.search(content)
                if not alloc_match: continue
                
                allocations = []
                filters = FILTER_RE.findall(alloc_match.group(1))
                for f_type, f_val, f_count in filters:
                    if f_type == "item":
                        allocations.append({"item": f_val.strip('"').strip("'"), "count": int(f_count)})
                    else:
                        tags = [t.strip().strip('"').strip("'") for t in f_val.strip('{}').split(',')]
                        allocations.append({"tags": tags, "count": int(f_count)})
                archetypes[name] = allocations

    # 2. Simulate
    with open(OUTPUT_SIM, 'w', encoding='utf-8') as f:
        f.write("Project Zomboid Dynamic Trading - Archetype Simulation Report\n")
        f.write("=" * 60 + "\n\n")
        
        for arch_name, allocs in sorted(archetypes.items()):
            f.write(f"Archetype: {arch_name}\n")
            f.write("-" * (len(arch_name) + 11) + "\n")
            
            for i, alloc in enumerate(allocs):
                status_label = ""
                if "item" in alloc:
                    target = alloc["item"]
                    exists = target in registry
                    status_label = "[FOUND]" if exists else "[MISSING!]"
                    f.write(f"  [{i+1:02}] ID   : {target:<35} x{alloc['count']:<2} -> {status_label}\n")
                else:
                    tag_list = alloc["tags"]
                    hits = [iid for iid, itags in registry.items() if matches_all_tags(itags, tag_list)]
                    tag_str = ", ".join(tag_list)
                    match_count = len(hits)
                    status_label = f"[{match_count} matches]" if match_count > 0 else "[EMPTY!]"
                    f.write(f"  [{i+1:02}] Tags : {tag_str:<35} x{alloc['count']:<2} -> {status_label}\n")
                    
                    if hits:
                        if verbose:
                            for j, item_id in enumerate(sorted(hits)):
                                f.write(f"       > {item_id}\n")
                        else:
                            examples = sorted(hits)[:5]
                            f.write(f"       Ex: {', '.join(examples)}{'...' if len(hits) > 5 else ''}\n")
                    else:
                        f.write("       WARNING: No items match these tags in the registry.\n")
            f.write("\n")
            f.write("\n")

    print(f"Simulation report generated at: {OUTPUT_SIM}")

def run_tags_audit(registry):
    """Generates an audit report of every item and its tags using a hierarchical tree structure."""
    
    # 1. Map tags to items
    tag_to_items = {}
    for item_id, tags in registry.items():
        for tag in tags:
            if tag not in tag_to_items:
                tag_to_items[tag] = []
            tag_to_items[tag].append(item_id)
            
    # 2. Build Tree Structure
    tree = {}
    for tag_path, items in tag_to_items.items():
        parts = tag_path.split('.')
        curr = tree
        for i, part in enumerate(parts):
            if part not in curr:
                curr[part] = {"_items": [], "_children": {}}
            if i == len(parts) - 1:
                curr[part]["_items"] = sorted(items)
            curr = curr[part]["_children"]

    # 3. Write Report
    with open(OUTPUT_TAGS, 'w', encoding='utf-8') as f:
        f.write("╔══════════════════════════════════════════════════════════╗\n")
        f.write("║       Project Zomboid Dynamic Trading - Tag Audit        ║\n")
        f.write("╚══════════════════════════════════════════════════════════╝\n\n")

        def print_node(node_dict, name, prefix="", is_last=True, depth=0):
            # Connector logic for the tag node
            if depth == 0:
                connector = ""
                new_prefix = ""
            else:
                connector = "└── " if is_last else "├── "
                new_prefix = prefix + ("    " if is_last else "│   ")
            
            # Print Tag Label
            label = f"{prefix}{connector}{name}"
            f.write(f"{label}\n")
            
            # Print Items under this Tag
            items = node_dict.get("_items", [])
            children = sorted(node_dict.get("_children", {}).items())
            
            has_children = len(children) > 0
            
            for i, item_id in enumerate(items):
                item_is_last = (i == len(items) - 1) and not has_children
                item_connector = "└── " if item_is_last else "├── "
                f.write(f"{new_prefix}{item_connector}  - {item_id}\n")

            # Print Children
            for i, (child_name, child_node) in enumerate(children):
                print_node(child_node, child_name, new_prefix, i == len(children) - 1, depth + 1)

        # Print all root categories
        roots = sorted(tree.items())
        for i, (name, node) in enumerate(roots):
            print_node(node, name, is_last=(i == len(roots) - 1), depth=0)
            f.write("\n")

    print(f"Tags audit report generated at: {OUTPUT_TAGS}")

def main():
    parser = argparse.ArgumentParser(description="Dynamic Trading Analysis Tool")
    parser.add_argument("--stats", action="store_true", help="Generate tag statistics report")
    parser.add_argument("--simulate", action="store_true", help="Generate archetype simulation report")
    parser.add_argument("--tags", action="store_true", help="Generate report of all items and their tags")
    parser.add_argument("--all", action="store_true", help="Generate all reports")
    parser.add_argument("--verbose", action="store_true", help="List all items in the simulation report")
    args = parser.parse_args()
    
    registry = get_item_registry()
    
    # If no specific action is provided, default to --all
    if not (args.stats or args.simulate or args.tags or args.all):
        args.all = True
    
    if args.all or args.stats:
        run_stats(registry)
    if args.all or args.simulate:
        run_simulation(registry, verbose=args.verbose)
    if args.all or args.tags:
        run_tags_audit(registry)

if __name__ == "__main__":
    main()
