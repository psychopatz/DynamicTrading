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
    """Simulates archetype allocations and generates a comprehensive Markdown or Simple report."""
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
    
    # Advanced Audit Sets
    all_served = set()
    simulation_errors = [] # (archetype, tags)
    expert_mappings = {} # item -> [archetypes]
    forbidden_summary = {} # item -> [archetypes]
    
    global_wants_tags = set()
    for arch_data in archetypes.values():
        global_wants_tags.update(arch_data["wants"].keys())

    with open(out_path, 'w', encoding='utf-8') as f:
        if simple: f.write("TRADER ARCHETYPE SIMULATION - SIMPLE LIST\n\n")
        else: f.write("# Project Zomboid Dynamic Trading - Trader Archetype Sim\n\n")

        # 1. Main Simulation Loop
        for name, data in sorted(archetypes.items()):
            if not simple: f.write(f"<details>\n<summary><b>{name}</b></summary>\n\n")
            else: f.write(f"=== {name} ===\n")

            if data["expert"] or data["wants"] or data["forbid"]:
                if not simple:
                    f.write("| Type | Details |\n| :--- | :--- |\n")
                    if data["expert"]: f.write(f"| **Expert** | `{', '.join(data['expert'])}` |\n")
                    if data["wants"]: f.write(f"| **Wants** | {', '.join([f'`{k}` ({v}x)' for k,v in data['wants'].items()])} |\n")
                    if data["forbid"]: f.write(f"| **Forbid** | `{', '.join(data['forbid'])}` |\n")
                    f.write("\n")
                else:
                    if data["expert"]: f.write(f"Expert: {', '.join(data['expert'])}\n")
                    if data["wants"]: f.write(f"Wants: {data['wants']}\n")
                    if data["forbid"]: f.write(f"Forbid: {', '.join(data['forbid'])}\n")

            # Collect Expert Data
            for e_tag in data["expert"]:
                if e_tag not in expert_mappings: expert_mappings[e_tag] = []
                expert_mappings[e_tag].append(name)

            # Collect Forbidden Data
            for f_tag in data["forbid"]:
                # Map this tag to items for the unsellable check later
                for iid, i_tags in registry.items():
                    if matches_all_tags(i_tags, [f_tag]):
                        if iid not in forbidden_summary: forbidden_summary[iid] = []
                        forbidden_summary[iid].append(name)

            if not simple: f.write("| # | Filter | Count | Matches | Status |\n| :--- | :--- | :--- | :--- | :--- |\n")
            
            for i, alloc in enumerate(data["allocations"]):
                if "item" in alloc:
                    exists = alloc["item"] in registry
                    if not simple:
                        f.write(f"| {i+1:02} | `ID: {alloc['item']}` | {alloc['count']} | 1 | {'✅' if exists else '❌'} |\n")
                    else:
                        f.write(f"  [{i+1}] Item: {alloc['item']} x{alloc['count']} {'(OK)' if exists else '(MISSING)'}\n")
                    if exists: all_served.add(alloc["item"])
                    else: simulation_errors.append((name, f"Item ID: {alloc['item']}"))
                else:
                    hits = [iid for iid, tags in registry.items() if matches_all_tags(tags, alloc["tags"])]
                    status = "✅" if hits else "🚨 EMPTY"
                    if hits: all_served.update(hits)
                    else: simulation_errors.append((name, f"Tags: {', '.join(alloc['tags'])}"))

                    if not simple:
                        f.write(f"| {i+1:02} | `Tags: {', '.join(alloc['tags'])}` | {alloc['count']} | {len(hits)} | {status} |\n")
                        if hits:
                            items_str = ", ".join([f"`{iid}`" for iid in sorted(hits)])
                            f.write(f"| | | | | <details><summary>Show {len(hits)} matches</summary>{items_str}</details> |\n")
                    else:
                        f.write(f"  [{i+1}] Tags: {','.join(alloc['tags'])} x{alloc['count']} ({len(hits)} matches) {status}\n")
            
            if not simple: f.write("\n</details>\n\n---\n")
            else: f.write("\n")

        # 2. FINAL AUDIT SUMMARY
        f.write("# ECONOMY AUDIT SUMMARY\n\n")

        def build_and_render_tree(f, items_or_tags, registry, title, description, simple, meta_map=None):
            """Helper to build a tree from a list of items or tags and render it hierarchically."""
            tree = {}
            # If items_or_tags is a list of item IDs
            is_item_list = all(x in registry for x in items_or_tags if isinstance(x, str))
            if is_item_list:
                tag_to_items = {}
                for iid in items_or_tags:
                    for tag in registry[iid]:
                        tag_to_items.setdefault(tag, []).append(iid)
                for tag_path, items in tag_to_items.items():
                    parts = tag_path.split('.')
                    curr = tree
                    for i, part in enumerate(parts):
                        if part not in curr: curr[part] = {"_children": {}}
                        if meta_map:
                            sub_path = '.'.join(parts[:i+1])
                            if sub_path in meta_map:
                                curr[part].setdefault("_meta", set()).update(meta_map[sub_path])
                        if i == len(parts) - 1: curr[part]["_items"] = sorted(items)
                        curr = curr[part]["_children"]
            else:
                # If it's a list of tags (for Expert or Forbidden)
                for tag_path in items_or_tags:
                    parts = tag_path.split('.')
                    curr = tree
                    for i, part in enumerate(parts):
                        if part not in curr: curr[part] = {"_children": {}}
                        if meta_map:
                            sub_path = '.'.join(parts[:i+1])
                            if sub_path in meta_map:
                                curr[part].setdefault("_meta", set()).update(meta_map[sub_path])
                        curr = curr[part]["_children"]

            def get_recursive_item_count(node_dict):
                items = set(node_dict.get("_items", []))
                for child in node_dict["_children"].values():
                    items.update(get_recursive_item_count(child))
                return items

            if simple:
                f.write(f"=== {title.upper()} ===\n")
                def print_simple(node_dict, name, depth=0):
                    f.write(f"{'  ' * depth}# {name}\n")
                    if "_meta" in node_dict:
                        f.write(f"{'  ' * (depth+2)}Archetypes: {', '.join(sorted(node_dict['_meta']))}\n")
                    items = node_dict.get("_items", [])
                    if items: f.write(f"{'  ' * (depth+2)}Items: {', '.join(items)}\n")
                    for c_name, c_node in sorted(node_dict["_children"].items()):
                        print_simple(c_node, c_name, depth + 2) # Stronger indent for simple txt
                for name, node in sorted(tree.items()): print_simple(node, name)
                f.write("\n")
            else:
                f.write(f"<details>\n<summary><b>{title}</b> - {description}</summary>\n\n")
                f.write('<ul style="list-style-type: none; padding-left: 0;">\n')
                def print_md(node_dict, name, depth=0):
                    all_items = get_recursive_item_count(node_dict)
                    if not all_items and not node_dict["_children"]: return # Skip dead ends
                    count_str = f" ({len(all_items)})" if all_items else ""
                    f.write(f'<li><details>\n<summary><b>{name}</b>{count_str}</summary>\n\n')
                    # Standard indent of 25px per level with a stronger border
                    f.write('<div style="border-left: 3px solid #666; margin-left: 25px; padding-left: 20px; margin-top: 10px; margin-bottom: 20px;">\n\n')
                    if "_meta" in node_dict:
                        f.write(f"**Archetypes**: {', '.join([f'`{a}`' for a in sorted(node_dict['_meta'])])}\n\n")
                    items = node_dict.get("_items", [])
                    if items:
                        f.write(f"**Items** ({len(items)}): {', '.join([f'`{i}`' for i in items])}\n\n")
                    children = sorted(node_dict["_children"].items())
                    if children:
                        # Adding padding-left: 20px to effectively indent the 'second subitem' (nested categories)
                        f.write('<ul style="list-style-type: none; padding-left: 20px; border-top: 1px solid #444; padding-top: 15px;">\n')
                        for c_name, c_node in children: print_md(c_node, c_name, depth + 1)
                        f.write("</ul>\n")
                    f.write("</div>\n</details></li>\n")
                for name, node in sorted(tree.items()): print_md(node, name)
                f.write("</ul>\n</details>\n\n")

        # Unserved Items
        unserved = set(registry.keys()) - all_served
        build_and_render_tree(f, sorted(unserved), registry, f"1. Unserved Items ({len(unserved)})", "Items never allocated", simple)

        # Errors (Empty Tags)
        if not simple: f.write(f"<details>\n<summary><b>2. Simulation Errors ({len(simulation_errors)})</b> - Tag filters with 0 matches</summary>\n\n")
        else: f.write(f"=== 2. SIMULATION ERRORS ({len(simulation_errors)}) ===\n")
        if simulation_errors:
            for arch, err in simulation_errors:
                if not simple: f.write(f"- 🚨 **{arch}**: `{err}`\n")
                else: f.write(f"[{arch}] {err}\n")
        else: f.write("No errors found.\n")
        if not simple: f.write("\n</details>\n\n")

        # Unfavored Items
        unfavored = [iid for iid, tags in registry.items() if not any(matches_all_tags(tags, [wt]) for wt in global_wants_tags)]
        build_and_render_tree(f, sorted(unfavored), registry, f"3. Unfavored Items ({len(unfavored)})", "Items matching NO archetype 'wants' tags", simple)

        # Unsellable Items
        num_arch = len(archetypes)
        unsellable = [iid for iid, archs in forbidden_summary.items() if len(set(archs)) >= num_arch]
        build_and_render_tree(f, sorted(unsellable), registry, f"4. Unsellable Items ({len(unsellable)})", "Global orphans forbidden by ALL traders", simple)

        # Forbidden Log
        if not simple: f.write(f"<details>\n<summary><b>5. Global Forbidden Log</b> - Tags forbidden by archetypes</summary>\n\n")
        else: f.write("=== 5. GLOBAL FORBIDDEN LOG ===\n")
        arch_forbid = {}
        for arch, data in archetypes.items():
            if data["forbid"]: arch_forbid[arch] = data["forbid"]
        if arch_forbid:
            for arch, f_tags in sorted(arch_forbid.items()):
                if not simple: f.write(f"- **{arch}** forbids: `{', '.join(f_tags)}`\n")
                else: f.write(f"[{arch}] Forbids: {', '.join(f_tags)}\n")
        else: f.write("No forbidden tags defined.\n")
        if not simple: f.write("\n</details>\n\n")

        # Expert Tags
        # Map expert tags to the items they actually affect
        expert_items = set()
        for tag in expert_mappings.keys():
            if tag in registry:
                expert_items.add(tag)
            else:
                for iid, i_tags in registry.items():
                    if matches_all_tags(i_tags, [tag]):
                        expert_items.add(iid)
        
        build_and_render_tree(f, sorted(expert_items), registry, f"6. Expert Items ({len(expert_items)})", "Items recognized as expert with specialized pricing", simple, meta_map=expert_mappings)

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
                def print_md(node_dict, name, depth=0, path=""):
                    full_path = f"{path}.{name}" if path else name
                    all_items = get_recursive_item_count(node_dict)
                    f.write(f'<li><details>\n<summary><b>{full_path}</b> ({len(all_items)})</summary>\n\n')
                    
                    f.write('<div style="border-left: 2px solid #444; margin-left: 20px; padding-left: 15px; margin-top: 10px; margin-bottom: 20px;">\n\n')
                    
                    items = node_dict.get("_items", [])
                    if items:
                        f.write(f"### 🏷️ Direct Tag: `{full_path}`\n")
                        f.write(f"**Items tagged specifically with this level** ({len(items)}):\n")
                        f.write(f"> {', '.join([f'`{i}`' for i in items])}\n\n")
                    
                    children = sorted(node_dict["_children"].items())
                    if children:
                        if items: f.write("---\n\n")
                        f.write(f"### 📂 Sub-Categories of `{full_path}`\n")
                        f.write('<ul style="list-style-type: none; padding-left: 0;">\n')
                        for c_name, c_node in children:
                            print_md(c_node, c_name, depth + 1, full_path)
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
