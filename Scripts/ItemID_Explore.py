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

OUTPUT_STATS = os.path.join(OUTPUT_DIR, "Tag_Registry.md")
OUTPUT_SIM   = os.path.join(OUTPUT_DIR, "Trader_Archetype_Sim.md")
OUTPUT_TAGS  = os.path.join(OUTPUT_DIR, "Item_Tag_Audit.md")

OUTPUT_STATS_SIMPLE = os.path.join(OUTPUT_DIR, "Tag_Registry_simple.txt")
OUTPUT_SIM_SIMPLE   = os.path.join(OUTPUT_DIR, "Trader_Archetype_Sim_simple.txt")
OUTPUT_TAGS_SIMPLE  = os.path.join(OUTPUT_DIR, "Item_Tag_Audit_simple.txt")

# Descriptor Roots (Filters)
DESCRIPTOR_ROOTS = ["Rarity", "Quality", "Theme", "Origin"]

# Regex Patterns
TAGS_PATTERN = re.compile(r'item\s*=\s*["\']([^"\']+)["\'].*?tags\s*=\s*\{([^}]+)\}', re.DOTALL)
ARCH_ALLOC_RE = re.compile(r'allocations\s*=\s*\{(.*?)\n\s*\}', re.DOTALL)
FILTER_RE = re.compile(r'\{\s*(tags|item)\s*=\s*(.*?)\s*,\s*count\s*=\s*(\d+)\s*\}', re.DOTALL)
WANTS_RE = re.compile(r'wants\s*=\s*\{([^}]+)\}', re.DOTALL)
FORBID_RE = re.compile(r'forbid\s*=\s*\{([^}]+)\}', re.DOTALL)
EXPERT_RE = re.compile(r'expertTags\s*=\s*\{([^}]+)\}', re.DOTALL)

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

def build_registry():
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

def run_stats(registry, simple=False):
    """Generates a hierarchical tag registry report (clean list of all used tags)."""
    total_stats = {}
    for tags in registry.values():
        for tag in tags:
            total_stats[tag] = total_stats.get(tag, 0) + 1

    tree = {}
    for tag_path, count in total_stats.items():
        parts = tag_path.split('.')
        curr = tree
        for i, part in enumerate(parts):
            if part not in curr: curr[part] = {"_children": {}}
            curr = curr[part]["_children"]

    out_path = OUTPUT_STATS_SIMPLE if simple else OUTPUT_STATS
    with open(out_path, 'w', encoding='utf-8') as f:
        if simple:
            f.write("TAG REGISTRY - SIMPLE LIST\n\n")
            
            def print_simple(node_dict, name, depth=0, path=""):
                full_path = f"{path}.{name}" if path else name
                f.write(f"{'  ' * depth}- {full_path}\n")
                for c_name, c_node in sorted(node_dict["_children"].items()):
                    print_simple(c_node, c_name, depth + 1, full_path)
            
            tax_nodes = {k: v for k, v in tree.items() if k not in DESCRIPTOR_ROOTS}
            desc_nodes = {k: v for k, v in tree.items() if k in DESCRIPTOR_ROOTS}
            
            f.write("=== PRIMARY TAXONOMY ===\n")
            for name, node in sorted(tax_nodes.items()): print_simple(node, name)
            f.write("\n=== GLOBAL DESCRIPTORS (FILTERS) ===\n")
            for name, node in sorted(desc_nodes.items()): print_simple(node, name)
        else:
            f.write("# Project Zomboid Dynamic Trading - Tag Registry\n\n")
            
            def render_hierarchy(node_dict, name, path=""):
                full_path = f"{path}.{name}" if path else name
                children = sorted(node_dict["_children"].items())
                
                if children:
                    f.write(f'<li><details>\n<summary><code>{full_path}</code></summary>\n')
                    f.write('<ul style="list-style-type: none; border-left: 1px solid #444; margin-left: 10px; padding-left: 15px;">\n')
                    for c_name, c_node in children:
                        render_hierarchy(c_node, c_name, full_path)
                    f.write("</ul>\n</details></li>\n")
                else:
                    f.write(f'<li><code>{full_path}</code></li>\n')

            def render_section(nodes, title, description):
                f.write(f"## {title}\n> {description}\n\n")
                f.write('<ul style="list-style-type: none; padding-left: 0;">\n')
                for name, node in sorted(nodes.items()):
                    render_hierarchy(node, name)
                f.write("</ul>\n\n")

            tax_nodes = {k: v for k, v in tree.items() if k not in DESCRIPTOR_ROOTS}
            desc_nodes = {k: v for k, v in tree.items() if k in DESCRIPTOR_ROOTS}
            
            render_section(tax_nodes, "📦 Primary Taxonomy", "All core biological and functional categories currently used in system.")
            render_section(desc_nodes, "🔍 Global Descriptors (Filters)", "System-wide attributes for rarity, quality, origin, and theme.")
    print(f"Registry report generated: {out_path}")

def run_simulation(registry, simple=False):
    """Simulates archetype allocations and generates a Markdown or Simple report."""
    archetypes = {}
    for root, _, files in os.walk(ARCH_DIR):
        for file in files:
            if file.endswith(".lua"):
                with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                    content = f.read()
                name_match = re.search(r'RegisterArchetype\(\s*["\']([^"\']+)["\']', content)
                if name_match:
                    name = name_match.group(1)
                    allocs_match = ARCH_ALLOC_RE.search(content)
                    allocations = []
                    if allocs_match:
                        for f_type, f_val, f_count in FILTER_RE.findall(allocs_match.group(1)):
                            if f_type == "item":
                                allocations.append({"item": f_val.strip('"\''), "count": int(f_count)})
                            else:
                                tags = [t.strip().strip('"\'') for t in f_val.strip('{}').split(',')]
                                allocations.append({"tags": tags, "count": int(f_count)})
                    
                    wants = {}
                    wants_match = WANTS_RE.search(content)
                    if wants_match:
                        pairs = re.findall(r'\[\s*["\']([^"\']+)["\']\s*\]\s*=\s*([\d.]+)', wants_match.group(1))
                        for tag, val in pairs: wants[tag] = val
                    
                    forbid = []
                    forbid_match = FORBID_RE.search(content)
                    if forbid_match: forbid = [t.strip().strip('"\'') for t in forbid_match.group(1).split(',')]
                    
                    expert = []
                    expert_match = EXPERT_RE.search(content)
                    if expert_match: expert = [t.strip().strip('"\'') for t in expert_match.group(1).split(',')]

                    archetypes[name] = {"allocations": allocations, "wants": wants, "forbid": forbid, "expert": expert}

    out_path = OUTPUT_SIM_SIMPLE if simple else OUTPUT_SIM
    all_served = set()
    with open(out_path, 'w', encoding='utf-8') as f:
        if simple:
            f.write("TRADER ARCHETYPE SIMULATION - SIMPLE LIST\n\n")
            for name, data in sorted(archetypes.items()):
                f.write(f"=== {name} ===\n")
                if data["expert"]: f.write(f"Expert: {', '.join(data['expert'])}\n")
                if data["wants"]: f.write(f"Wants: {data['wants']}\n")
                if data["forbid"]: f.write(f"Forbid: {', '.join(data['forbid'])}\n")
                for i, alloc in enumerate(data["allocations"]):
                    if "item" in alloc:
                        exists = alloc["item"] in registry
                        f.write(f"  [{i+1}] Item: {alloc['item']} x{alloc['count']} {'(OK)' if exists else '(MISSING)'}\n")
                        if exists: all_served.add(alloc["item"])
                    else:
                        hits = [iid for iid, tags in registry.items() if matches_all_tags(tags, alloc["tags"])]
                        f.write(f"  [{i+1}] Tags: {','.join(alloc['tags'])} x{alloc['count']} ({len(hits)} matches)\n")
                        all_served.update(hits)
                f.write("\n")
        else:
            f.write("# Project Zomboid Dynamic Trading - Trader Archetype Sim\n\n")
            for name, data in sorted(archetypes.items()):
                f.write(f"<details>\n<summary><b>{name}</b></summary>\n\n")
                if data["expert"] or data["wants"] or data["forbid"]:
                    f.write("| Type | Details |\n| :--- | :--- |\n")
                    if data["expert"]: f.write(f"| **Expert** | `{', '.join(data['expert'])}` |\n")
                    if data["wants"]: f.write(f"| **Wants** | {', '.join([f'`{k}` ({v}x)' for k,v in data['wants'].items()])} |\n")
                    if data["forbid"]: f.write(f"| **Forbid** | `{', '.join(data['forbid'])}` |\n")
                    f.write("\n")
                f.write("| # | Filter | Count | Matches | Status |\n| :--- | :--- | :--- | :--- | :--- |\n")
                for i, alloc in enumerate(data["allocations"]):
                    if "item" in alloc:
                        exists = alloc["item"] in registry
                        f.write(f"| {i+1:02} | `ID: {alloc['item']}` | {alloc['count']} | 1 | {'✅' if exists else '❌'} |\n")
                        if exists: all_served.add(alloc["item"])
                    else:
                        hits = [iid for iid, tags in registry.items() if matches_all_tags(tags, alloc["tags"])]
                        status = "✅" if hits else "🚨 EMPTY"
                        f.write(f"| {i+1:02} | `Tags: {', '.join(alloc['tags'])}` | {alloc['count']} | {len(hits)} | {status} |\n")
                        all_served.update(hits)
                        if hits:
                            items_str = ", ".join([f"`{iid}`" for iid in sorted(hits)])
                            summary = f"Show {len(hits)} matches"
                            f.write(f"| | | | | <details><summary>{summary}</summary>{items_str}</details> |\n")
                f.write("\n</details>\n\n---\n")

        unserved = set(registry.keys()) - all_served
        f.write(f"\n# UNSERVED ITEMS (The 'Orphans' List): {len(unserved)}\n")
        if unserved:
            by_cat = {}
            for iid in sorted(unserved):
                cat = registry[iid][0].split('.')[0] if registry[iid] else "Unknown"
                if cat not in by_cat: by_cat[cat] = []
                by_cat[cat].append(iid)
            for cat, items in sorted(by_cat.items()):
                if simple:
                    f.write(f"\n[{cat}] ({len(items)} items)\n")
                    for iid in items: f.write(f"- {iid}\n")
                else:
                    f.write(f"<details>\n<summary><b>{cat}</b> ({len(items)})</summary>\n\n{', '.join([f'`{i}`' for i in items])}\n\n</details>\n")
    print(f"Simulation report generated: {out_path}")

def run_tags_audit(registry, simple=False):
    """Generates an item tag audit report with hierarchical collapsible sections."""
    tag_to_items = {}
    for item_id, tags in registry.items():
        for tag in tags:
            if tag not in tag_to_items: tag_to_items[tag] = []
            tag_to_items[tag].append(item_id)

    tree = {}
    for tag_path, items in tag_to_items.items():
        parts = tag_path.split('.')
        curr = tree
        for i, part in enumerate(parts):
            if part not in curr: curr[part] = {"_children": {}}
            if i == len(parts) - 1: curr[part]["_items"] = sorted(items)
            curr = curr[part]["_children"]

    def get_recursive_item_count(node_dict):
        items = set(node_dict.get("_items", []))
        for child in node_dict["_children"].values():
            items.update(get_recursive_item_count(child))
        return items

    out_path = OUTPUT_TAGS_SIMPLE if simple else OUTPUT_TAGS
    with open(out_path, 'w', encoding='utf-8') as f:
        if simple:
            f.write("ITEM TAG AUDIT - SIMPLE LIST\n\n")
            
            def print_simple(node_dict, name, depth=0):
                f.write(f"{'  ' * depth}# {name}\n")
                items = node_dict.get("_items", [])
                if items: f.write(f"{'  ' * (depth+1)}Items: {', '.join(items)}\n")
                for c_name, c_node in sorted(node_dict["_children"].items()):
                    print_simple(c_node, c_name, depth + 1)
            
            tax_nodes = {k: v for k, v in tree.items() if k not in DESCRIPTOR_ROOTS}
            desc_nodes = {k: v for k, v in tree.items() if k in DESCRIPTOR_ROOTS}
            
            f.write("=== PRIMARY TAXONOMY ===\n")
            for name, node in sorted(tax_nodes.items()): print_simple(node, name)
            f.write("\n=== GLOBAL DESCRIPTORS (FILTERS) ===\n")
            for name, node in sorted(desc_nodes.items()): print_simple(node, name)
        else:
            f.write("# Project Zomboid Dynamic Trading - Tag Audit\n\n")
            
            def render_audit_section(nodes, title, description):
                f.write(f"## {title}\n> {description}\n\n")
                f.write('<ul style="list-style-type: none; padding-left: 0;">\n')
                def print_md(node_dict, name, depth=0):
                    all_items = get_recursive_item_count(node_dict)
                    f.write(f'<li><details>\n<summary><b>{name}</b> ({len(all_items)})</summary>\n\n')
                    
                    f.write('<div style="border-left: 2px solid #444; margin-left: 20px; padding-left: 15px; margin-top: 10px; margin-bottom: 20px;">\n\n')
                    
                    items = node_dict.get("_items", [])
                    if items:
                        f.write(f"### 🏷️ Direct Tag: `{name}`\n")
                        f.write(f"**Items tagged specifically with this level** ({len(items)}):\n")
                        f.write(f"> {', '.join([f'`{i}`' for i in items])}\n\n")
                    
                    children = sorted(node_dict["_children"].items())
                    if children:
                        if items: f.write("---\n\n")
                        f.write(f"### 📂 Sub-Categories of `{name}`\n")
                        f.write('<ul style="list-style-type: none; padding-left: 0;">\n')
                        for c_name, c_node in children:
                            print_md(c_node, c_name, depth + 1)
                        f.write("</ul>\n")
                    
                    f.write("</div>\n</details></li>\n")
                for name, node in sorted(nodes.items()): print_md(node, name)
                f.write("</ul>\n\n")

            tax_nodes = {k: v for k, v in tree.items() if k not in DESCRIPTOR_ROOTS}
            desc_nodes = {k: v for k, v in tree.items() if k in DESCRIPTOR_ROOTS}

            render_audit_section(tax_nodes, "📦 Primary Taxonomy", "Items grouped by their core biological or functional categories.")
            render_audit_section(desc_nodes, "🔍 Global Descriptors (Filters)", "Items grouped by rarity, quality, origin, and theme.")

    print(f"Tags audit report generated: {out_path}")

def main():
    parser = argparse.ArgumentParser(description="Dynamic Trading Analysis Tool")
    parser.add_argument("--simple", action="store_true", help="Generate simple text reports instead of Markdown")
    
    args = parser.parse_args()

    print(f"Building item registry from: {ITEMS_DIR}")
    registry = build_registry()

    # Always run all tasks
    run_stats(registry, simple=args.simple)
    run_simulation(registry, simple=args.simple)
    run_tags_audit(registry, simple=args.simple)

    print("\nAll reports generated successfully in Scripts/Output/")

if __name__ == "__main__":
    main()
