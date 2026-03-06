import os
from .helpers import sanitize_path

def write_mod_duplicates(output_dir, mod_dupes):
    if not mod_dupes: return
    print(f"[*] Writing Mod Duplicates results...")
    target_dir = os.path.join(output_dir, "Duplicates")
    os.makedirs(target_dir, exist_ok=True)
    
    file_reports = {}
    for obj_id, locations in mod_dupes.items():
        loc_str = "[" + ", ".join(f'"{loc}"' for loc in sorted(locations)) + "]"
        count = len(locations)
        line = f"{obj_id:<45} Count: {count:<2} Location: {loc_str}\n"
        
        for loc in locations:
            report_name = loc.replace(".lua", ".txt")
            if report_name not in file_reports:
                file_reports[report_name] = []
            file_reports[report_name].append(line)
            
    for report_name, lines in file_reports.items():
        report_path = os.path.join(target_dir, report_name)
        os.makedirs(os.path.dirname(report_path), exist_ok=True)
        with open(report_path, "w") as f:
            f.write(f"--- Duplicates found in or conflicting with {report_name.replace('.txt', '.lua')} ---\n")
            f.writelines(sorted(lines))

def write_hierarchical_files(output_dir, status_folder, ids_subset, vanilla_data, mod_data, simple=False, items_per_file=50):
    if not ids_subset: return
    print(f"[*] Writing {status_folder} results (Simple: {simple})...")
    
    file_buffers = {}

    for obj_id in ids_subset:
        meta = vanilla_data.get(obj_id)
        current_root = status_folder
        
        if not meta:
            meta = mod_data.get(obj_id, {"origin": "Unknown.txt"})
            category, subcat, worth, weight = "Invalid", "General", 0.0, 0.1
        else:
            category = meta.get("category", "Uncategorized")
            subcat = meta.get("subcat", "General")
            worth = meta.get("worth", 1.0)
            weight = meta.get("weight", 0.1)
            if meta.get("tags") == "None" and status_folder in ["VanillaOnly", "AlreadyHas"]:
                current_root = "UnsureItems"
        
        origin = meta.get("origin", "Unknown.txt").replace(".lua", "").replace(".txt", "")
        path_parts = current_root.split('/')
        target_dir = os.path.join(output_dir, *path_parts, sanitize_path(origin), category)
        os.makedirs(target_dir, exist_ok=True)
        file_path = os.path.join(target_dir, f"{subcat}.txt")
        
        with open(file_path, "a") as f:
            extra = []
            if meta.get("capacity", 0) > 0:
                extra.append(f"Cap: {meta.get('capacity'):<4} WR: {meta.get('weight_reduction'):<3}")
            if meta.get("total_uses", 1) > 1:
                extra.append(f"Uses: {meta.get('total_uses'):<3}")
            if meta.get("recipes", 0) > 0:
                extra.append(f"Recipes: {meta.get('recipes'):<2}")
            
            extra_str = " | " + " | ".join(extra) if extra else ""
            f.write(f"{obj_id:<45} | Potential Worth: {worth:<8} | Weight: {weight:<6}{extra_str}\n")
            if "lua" in meta:
                f.write(f"  LUA: {meta['lua']}\n")
