import os
import re
from collections import Counter

# Configuration
ITEMS_DIR = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items/"
OUTPUT_FILE = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Scripts/tag_statistics.txt"

# Tags that act as "Filters/Attributes"
ATTRIBUTE_ROOTS = {"Quality", "Rarity", "Origin", "Theme"}

# Regex to find tags={...} in Lua files
TAGS_PATTERN = re.compile(r'tags\s*=\s*\{([^}]+)\}')

def extract_tags_from_file(filepath):
    """Parses a Lua file and returns a dictionary of tags and their counts."""
    file_stats = Counter()
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
            matches = TAGS_PATTERN.findall(content)
            for match in matches:
                raw_tags = [t.strip().strip('"').strip("'") for t in match.split(',')]
                if not raw_tags:
                    continue
                
                identities = []
                attributes = []
                
                for tag in raw_tags:
                    if not tag: continue
                    file_stats[tag] += 1
                    
                    # Sort into Identity vs Attribute
                    root = tag.split('.')[0]
                    if root in ATTRIBUTE_ROOTS:
                        attributes.append(tag)
                    else:
                        identities.append(tag)
                    
                    # Hierarchy Tracking
                    parts = tag.split('.')
                    if len(parts) > 1:
                        for i in range(1, len(parts)):
                            parent = ".".join(parts[:i])
                            file_stats[parent] += 1

                # Intersection Tracking
                # For every identity in this item, associate it with every attribute
                for ident in identities:
                    for attr in attributes:
                        # Key format: "Identity | Attribute"
                        intersection_key = f"{ident} | {attr}"
                        file_stats[f"INTERSECT:{intersection_key}"] += 1

    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        
    return file_stats

def main():
    all_files_stats = {}
    total_stats = Counter()
    
    # List all DT_*.lua files
    files = [f for f in os.listdir(ITEMS_DIR) if f.startswith("DT_") and f.endswith(".lua")]
    files.sort()
    
    for filename in files:
        filepath = os.path.join(ITEMS_DIR, filename)
        stats = extract_tags_from_file(filepath)
        if stats:
            all_files_stats[filename] = stats
            total_stats.update(stats)
            
    # Write to output file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("Project Zomboid Dynamic Trading - Tag Hierarchy Statistics\n")
        f.write("========================================================\n\n")
        
        for filename, stats in all_files_stats.items():
            f.write(f"File: {filename}\n")
            f.write("-" * (len(filename) + 6) + "\n")
            
            # 1. Show Main Hierarchy (Excluding Intersections)
            filtered_stats = {k: v for k, v in stats.items() if not k.startswith("INTERSECT:")}
            for tag, count in sorted(filtered_stats.items()):
                depth = tag.count('.')
                indent = "  " * (depth + 1)
                f.write(f"{indent}{tag:<30} : {count}\n")
            
            # 2. Show Intersection Analysis (What filters are active)
            intersections = {k[10:]: v for k, v in stats.items() if k.startswith("INTERSECT:")}
            if intersections:
                f.write("\n  [Filter Intersections]\n")
                # Group by Identity
                current_ident = ""
                for key, count in sorted(intersections.items()):
                    ident, attr = key.split(" | ")
                    if ident != current_ident:
                        f.write(f"    {ident}:\n")
                        current_ident = ident
                    f.write(f"      + {attr:<26} : {count}\n")
            f.write("\n")
            
        f.write("Global Hierarchy Totals\n")
        f.write("=======================\n")
        global_flat = {k: v for k, v in total_stats.items() if not k.startswith("INTERSECT:")}
        for tag, count in sorted(global_flat.items()):
            depth = tag.count('.')
            indent = "  " * depth
            f.write(f"{indent}{tag:<32} : {count}\n")

        # Global Instersections
        global_inter = {k[10:]: v for k, v in total_stats.items() if k.startswith("INTERSECT:")}
        if global_inter:
            f.write("\nGlobal Filter Intersections\n")
            f.write("===========================\n")
            current_ident = ""
            for key, count in sorted(global_inter.items()):
                ident, attr = key.split(" | ")
                if ident != current_ident:
                    f.write(f"\n{ident}:\n")
                    current_ident = ident
                f.write(f"  + {attr:<28} : {count}\n")
            
    print(f"Statistics generated at: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
