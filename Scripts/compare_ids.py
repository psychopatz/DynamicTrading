import re
import os
import argparse

# Default Paths
VANILLA_DIR = "/home/psychopatz/.steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"
if not os.path.exists(VANILLA_DIR):
    VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"

MOD_ITEMS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items/")
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Output/")

def sanitize_path(name):
    """Sanitize and truncate names for folder safety."""
    if not name: return "General"
    clean = re.sub(r'[<>:"/\\|?*;]', '_', name)
    return clean[:50].strip()

def get_opening_maps(vanilla_path):
    """Maps UnopenedID -> OpenedID using recipe itemMappers."""
    mapping = {}
    print("[*] Building Opening Map from Recipes...")
    recipe_dir = os.path.join(vanilla_path, "generated/recipes/")
    if not os.path.exists(recipe_dir):
        # Fallback for different path structures
        recipe_dir = os.path.join(os.path.dirname(vanilla_path), "generated/recipes/")
    
    if not os.path.exists(recipe_dir): return mapping
    
    for file in sorted(os.listdir(recipe_dir)):
        if not file.endswith(".txt"): continue
        with open(os.path.join(recipe_dir, file), "r", errors="ignore") as f:
            content = f.read()
            mappers = re.findall(r"itemMapper\s+\w+\s*\{([^}]*)\}", content, re.DOTALL)
            for mapper_content in mappers:
                pairs = re.findall(r"(?:Base\.)?(\w+)\s*=\s*(?:Base\.)?(\w+)", mapper_content)
                for opened, unopened in pairs:
                    mapping[unopened] = opened
    return mapping

def calculate_worth(item_id, props, category, subcat):
    """Calculates a numerical multiplier based on item stats."""
    p_lower = props.lower()
    
    def get_stat(key, default=0.0):
        # Case-insensitive search for the key
        m = re.search(fr"{key}\s*=\s*(-?\d+\.?\d*)", props, re.IGNORECASE)
        return float(m.group(1)) if m else default

    weight = get_stat("Weight", 0.1)
    worth = 1.0
    
    if category == "Food":
        hunger = abs(get_stat("HungerChange"))
        thirst = abs(get_stat("ThirstChange"))
        calories = get_stat("Calories") / 100.0
        # Penalties: positive Unhappy/Boredom/Stress are BAD stats in PZ
        penalties = (max(0, get_stat("UnhappyChange")) + max(0, get_stat("BoredomChange")) + max(0, get_stat("StressChange"))) * 2
        
        stability = 0
        if "cannedfood = true" in p_lower: stability += 50
        elif "packaged = true" in p_lower: stability += 10
        
        worth = (hunger + (thirst/2) + calories - penalties + stability) / (weight * 1.5 + 0.1)
    elif "Weapon" in category:
        avg_dmg = (get_stat("MinDamage") + get_stat("MaxDamage")) / 2
        max_range = get_stat("MaxRange", 1.0)
        max_hit = get_stat("MaxHitcount", 1.0)
        if max_hit == 1.0: max_hit = get_stat("MaxHitCount", 1.0)
        condition = get_stat("ConditionMax", 5)
        reliability = get_stat("ConditionLowerChanceOneIn", 5)
        swing_time = get_stat("MinimumSwingtime", 1.0)
        
        worth = ((avg_dmg * max_range * max_hit) + (condition * reliability / 5)) / (weight * 2 + swing_time * 10 + 0.1)
    elif category in ["Clothing", "ProtectiveGear"]:
        bite = get_stat("BiteDefense")
        scratch = get_stat("ScratchDefense")
        insulation = get_stat("Insulation")
        run_mod = get_stat("RunSpeedModifier", 1.0)
        combat_mod = get_stat("CombatSpeedModifier", 1.0)
        penalty = (1.0 - run_mod) * 100 + (1.0 - combat_mod) * 50
        
        worth = ((bite * 2.5) + scratch + (insulation * 20)) / (weight * 3 + penalty + 1)
    else:
        res_val = get_stat("MetalValue") + get_stat("FuelValue")
        worth = (res_val / 10 + 1) / (weight + 0.1)
    
    # 30% Discount for already opened items (Case-insensitive ID or Opened property)
    id_lower = item_id.lower()
    is_opened = "opened = true" in p_lower or "open = true" in p_lower or "open" in id_lower or "opened" in id_lower
    if is_opened:
        worth *= 0.7
        
    return round(max(0.1, worth), 2)

def calculate_stock(weight):
    """Calculates max stock based on weight."""
    return max(1, int(20 / (weight + 0.1)))

def get_vanilla_data(vanilla_path):
    item_data, fluid_data = {}, {}
    opening_map = get_opening_maps(vanilla_path)
    
    print(f"[*] Scanning Vanilla Scripts: {vanilla_path}")
    for root, dirs, files in os.walk(vanilla_path):
        for file in sorted(files):
            if not file.endswith(".txt"): continue
            with open(os.path.join(root, file), "r", errors="ignore") as f:
                content = f.read()
                item_blocks = re.findall(r"item\s+([a-zA-Z_]\w*)\s*\{([^}]*)\}", content, re.DOTALL)
                for item_id, props in item_blocks:
                    cat_match = re.search(r"DisplayCategory\s*=\s*([^,\n\s;]+)", props)
                    eat_match = re.search(r"EatType\s*=\s*([^,\n\s;]+)", props)
                    tag_match = re.search(r"Tags\s*=\s*([^,\n\s;]+)", props)
                    
                    raw_tags = tag_match.group(1).strip() if tag_match else "None"
                    raw_eat = eat_match.group(1).strip() if eat_match else "None"
                    category = sanitize_path(cat_match.group(1).strip() if cat_match else "Uncategorized")
                    
                    subcat = "General"
                    if eat_match: subcat = sanitize_path(raw_eat)
                    elif tag_match:
                        first_tag = raw_tags.split(';')[0].split(',')[0].strip()
                        subcat = sanitize_path(first_tag)
                    
                    item_data[item_id] = {
                        "origin": file, "category": category, "subcat": subcat,
                        "tags": raw_tags, "eat_type": raw_eat, "props": props,
                        "opened_variant": opening_map.get(item_id)
                    }
                
                fluid_blocks = re.findall(r"fluid\s+([a-zA-Z_]\w*)\s*\{([^}]*)\}", content, re.DOTALL)
                for fluid_id, props in fluid_blocks:
                    fluid_data[fluid_id] = {
                        "origin": file, "category": "Fluids", "subcat": "General",
                        "tags": "N/A", "eat_type": "N/A", "props": props, "worth": 1.0
                    }
    
    # Second pass for inheritance and final worth
    for item_id, data in item_data.items():
        original_props = data["props"]
        inherited_props = ""
        opened_id = data.get("opened_variant")
        
        if opened_id and opened_id in item_data:
            inherited_props = item_data[opened_id]["props"]
            
        # We want original props to take priority (be first in search), but also check inherited.
        # So we put original props at the front.
        combined_props = original_props + "\n" + inherited_props
            
        data["worth"] = calculate_worth(item_id, combined_props, data["category"], data["subcat"])
        
        m = re.search(r"Weight\s*=\s*(-?\d+\.?\d*)", combined_props, re.IGNORECASE)
        data["max_stock"] = calculate_stock(float(m.group(1)) if m else 0.1)
                    
    return item_data, fluid_data

def get_mod_data(mod_path):
    mod_data = {}
    print(f"[*] Scanning Mod Registries: {mod_path}")
    if not os.path.exists(mod_path): return mod_data
    for file in sorted(os.listdir(mod_path)):
        if not file.endswith(".lua"): continue
        with open(os.path.join(mod_path, file), "r", errors="ignore") as f:
            content = f.read()
            for m in re.findall(r'item\s*=\s*"Base\.(\w+)"', content): mod_data[m] = {"origin": file}
            for m in re.findall(r'\["Base\.(\w+)"\]', content): mod_data[m] = {"origin": file}
    return mod_data

def write_hierarchical_files(output_dir, status_folder, ids_subset, vanilla_data, mod_data):
    print(f"[*] Writing {status_folder} results...")
    for obj_id in ids_subset:
        meta = vanilla_data.get(obj_id)
        current_root = status_folder
        
        if not meta:
            meta = mod_data.get(obj_id, {"origin": "Unknown.txt"})
            category, subcat, worth, stock = "Invalid", "General", 0.0, 1
        else:
            category = meta.get("category", "Uncategorized")
            subcat = meta.get("subcat", "General")
            worth = meta.get("worth", 1.0)
            stock = meta.get("max_stock", 10)
            
            # Identify Dev/Junk/Unsure items (no tags and potentially junk metadata)
            if meta.get("tags") == "None" and status_folder != "Invalid":
                current_root = "UnsureItems"
            
        origin = meta.get("origin", "Unknown.txt").replace(".lua", "").replace(".txt", "")
        target_dir = os.path.join(output_dir, current_root, sanitize_path(origin), category)
        os.makedirs(target_dir, exist_ok=True)
        file_path = os.path.join(target_dir, f"{subcat}.txt")
        with open(file_path, "a") as f:
            f.write(f"{obj_id:<45} | Worth: {worth:<8} | MaxStock: {stock:<6} | Tags: {meta.get('tags','N/A')}\n")

def main():
    parser = argparse.ArgumentParser(description="Compare Vanilla PZ Items/Fluids with Mod Registries")
    parser.add_argument("--vanilla", default=VANILLA_DIR, help="Path to vanilla scripts")
    parser.add_argument("--mod", default=MOD_ITEMS_DIR, help="Path to mod item Lua files")
    parser.add_argument("--output", default=OUTPUT_DIR, help="Path for output")
    args = parser.parse_args()

    if os.path.exists(args.output):
        import shutil
        shutil.rmtree(args.output)
    os.makedirs(args.output, exist_ok=True)

    v_items, v_fluids = get_vanilla_data(args.vanilla)
    m_data = get_mod_data(args.mod)
    v_combined = {**v_items, **v_fluids}
    
    vanilla_only = sorted(list(set(v_combined.keys()) - set(m_data.keys())))
    already_has = sorted(list(set(v_combined.keys()) & set(m_data.keys())))
    mod_invalid = sorted(list(set(m_data.keys()) - set(v_combined.keys())))
    
    write_hierarchical_files(args.output, "VanillaOnly", vanilla_only, v_combined, m_data)
    write_hierarchical_files(args.output, "AlreadyHas", already_has, v_combined, m_data)
    write_hierarchical_files(args.output, "Invalid", mod_invalid, v_combined, m_data)
    
    print("\n--- Summary ---")
    print(f"Total Vanilla:          {len(v_combined)}")
    print(f"Total Mod Registered:   {len(m_data)}")
    print(f"Missing (Vanilla Only): {len(vanilla_only)}")
    print(f"Correctly Registered:   {len(already_has)}")
    print(f"Invalid Mod IDs:        {len(mod_invalid)}")

if __name__ == "__main__":
    main()
