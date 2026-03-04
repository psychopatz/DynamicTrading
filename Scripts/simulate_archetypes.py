import os
import re
import json

# Configuration
BASE_DIR = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/"
ITEMS_DIR = os.path.join(BASE_DIR, "Items/")
ARCHETYPES_ROOT = os.path.join(BASE_DIR, "ArchetypeDefinitions/")
OUTPUT_FILE = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Scripts/archetype_simulation.txt"

# Regex Patterns
TAGS_PATTERN = re.compile(r'item\s*=\s*["\']([^"\']+)["\'].*?tags\s*=\s*\{([^}]+)\}', re.DOTALL)
ALLOCATION_PATTERN = re.compile(r'allocations\s*=\s*\{(.*?)\n\s*\}', re.DOTALL)
FILTER_PATTERN = re.compile(r'\{\s*(tags|item)\s*=\s*(.*?)\s*,\s*count\s*=\s*(\d+)\s*\}', re.DOTALL)

def matches_all_tags(item_tags, required_tags):
    """Python implementation of Common.MatchesAllTags logic."""
    if not required_tags:
        return False
    for req in required_tags:
        matched = False
        for item_t in item_tags:
            if item_t == req or item_t.startswith(req + "."):
                matched = true
                break
        if not matched:
            return False
    return True

def parse_items():
    """Builds a master list of ID -> Tags."""
    master_list = {}
    for filename in os.listdir(ITEMS_DIR):
        if not filename.endswith(".lua"): continue
        with open(os.path.join(ITEMS_DIR, filename), 'r') as f:
            content = f.read()
            # This regex is simplified; actual Lua parsing is complex but works for registry format
            raw_items = re.findall(r'\{.*?item\s*=\s*["\']([^"\']+)["\'].*?tags\s*=\s*\{([^}]+)\}.*?\}', content, re.DOTALL)
            for item_id, tags_str in raw_items:
                tags = [t.strip().strip('"').strip("'") for t in tags_str.split(',')]
                master_list[item_id] = tags
    return master_list

def parse_archetypes():
    """Extracts allocations from archetype files."""
    archetypes = {}
    for root, dirs, files in os.walk(ARCHETYPES_ROOT):
        for filename in files:
            if not (filename.startswith("DT_") and filename.endswith(".lua")): continue
            with open(os.path.join(root, filename), 'r') as f:
                content = f.read()
                arch_name_match = re.search(r'RegisterArchetype\(\s*["\']([^"\']+)["\']', content)
                if not arch_name_match: continue
                
                name = arch_name_match.group(1)
                alloc_match = ALLOCATION_PATTERN.search(content)
                if not alloc_match: continue
                
                allocations = []
                inner = alloc_match.group(1)
                filters = FILTER_PATTERN.findall(inner)
                for type_key, value, count in filters:
                    if type_key == "item":
                        allocations.append({"item": value.strip('"').strip("'"), "count": int(count)})
                    elif type_key == "tags":
                        tags = [t.strip().strip('"').strip("'") for t in value.strip('{}').split(',')]
                        allocations.append({"tags": tags, "count": int(count)})
                
                archetypes[name] = allocations
    return archetypes

def simulate():
    master_list = parse_items()
    archetypes = parse_archetypes()
    
    with open(OUTPUT_FILE, 'w') as f:
        f.write("Project Zomboid Dynamic Trading - Archetype Stock Simulation\n")
        f.write("===========================================================\n\n")
        
        for name, allocs in archetypes.items():
            f.write(f"Archetype: {name}\n")
            f.write("-" * (len(name) + 11) + "\n")
            
            for i, alloc in enumerate(allocs):
                if "item" in alloc:
                    target = alloc["item"]
                    exists = target in master_list
                    status = "FOUND" if exists else "MISSING!"
                    f.write(f"  Allocation #{i+1}: Specific Item [{target}] x{alloc['count']} -> {status}\n")
                else:
                    target_tags = alloc["tags"]
                    hits = []
                    for item_id, item_tags in master_list.items():
                        # Inline simulation of MatchesAllTags
                        all_match = True
                        for req in target_tags:
                            if not any(t == req or t.startswith(req + ".") for t in item_tags):
                                all_match = False
                                break
                        if all_match:
                            hits.append(item_id)
                    
                    tag_str = ", ".join(target_tags)
                    f.write(f"  Allocation #{i+1}: Tags [{tag_str}] x{alloc['count']}\n")
                    f.write(f"    - Potential Items Found: {len(hits)}\n")
                    if hits:
                        # Show some examples
                        examples = sorted(hits)[:5]
                        f.write(f"    - Examples: {', '.join(examples)}{'...' if len(hits) > 5 else ''}\n")
                    else:
                        f.write("    - WARNING: No items match this criteria!\n")
            f.write("\n")

    print(f"Simulation generated at: {OUTPUT_FILE}")

if __name__ == "__main__":
    simulate()
