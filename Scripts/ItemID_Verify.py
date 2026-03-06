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

def get_dynamic_tags():
    """Extracts the FULL tag library from Docs/Tags_Reference.md."""
    tag_ref_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../Docs/Tags_Reference.md")
    all_tags = []
    if os.path.exists(tag_ref_path):
        with open(tag_ref_path, "r") as f:
            content = f.read()
            # Find everything inside backticks that looks like a tag (Root.Sub or Global.*)
            # This captures full hierarchies like Food.NonPerishable.Canned
            all_tags = re.findall(r"`([A-Z][a-zA-Z]+\.[^`]+)`", content)
    
    # Sort and unique
    all_tags = sorted(list(set(all_tags)))
    
    # Simple split for the LLM to see roots vs others
    roots = sorted(list(set([t.split('.')[0] for t in all_tags if '.' in t])))
    return all_tags, roots

def get_opening_maps(vanilla_path, silent=False):
    """Maps UnopenedID -> OpenedID using recipe itemMappers."""
    mapping = {}
    if not silent: print("[*] Building Opening Map from Recipes...")
    recipe_dir = os.path.join(vanilla_path, "generated/recipes/")
    if not os.path.exists(recipe_dir):
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
    
    cap = get_stat("Capacity", 0.0)
    wr = get_stat("WeightReduction", 0.0)
    res_val = get_stat("MetalValue") + get_stat("FuelValue")
    fuel_ratio = get_stat("FireFuelRatio", 0.0)
    
    # Calculate Total Uses from UseDelta
    use_delta = get_stat("UseDelta", 0.0)
    total_uses = int(round(1.0 / use_delta)) if use_delta > 0 else 1
    
    # Extract LearnedRecipes count
    recipes = len(re.findall(r"LearnedRecipes\s*=\s*([^,\n\s;]+)", props))

    if cap > 0:
        # Boosted base multiplier for containers/storage items
        worth = (cap * (wr / 10 + 1)) / (weight + 0.1) * 2.5
    elif category == "Food":
        hunger = abs(get_stat("HungerChange"))
        thirst = abs(get_stat("ThirstChange"))
        calories = get_stat("Calories") / 100.0
        # Penalties: positive Unhappy/Boredom/Stress are BAD stats in PZ
        penalties = (max(0, get_stat("UnhappyChange")) + max(0, get_stat("BoredomChange")) + max(0, get_stat("StressChange"))) * 2
        
        # Shelf-life factor
        fresh = get_stat("DaysFresh")
        rotten = get_stat("DaysTotallyRotten")
        shelf_life = (fresh + rotten) / 2.0
        
        stability = 0
        if "cannedfood = true" in p_lower: stability += 50
        elif "packaged = true" in p_lower: stability += 10
        
        worth = (hunger + (thirst/2) + calories - penalties + stability + shelf_life) / (weight * 1.5 + 0.1)
    elif "Weapon" in category:
        avg_dmg = (get_stat("MinDamage") + get_stat("MaxDamage")) / 2
        max_range = get_stat("MaxRange", 1.0)
        max_hit = get_stat("MaxHitcount", 1.0)
        condition = get_stat("ConditionMax", 5)
        reliability = get_stat("ConditionLowerChanceOneIn", 5)
        swing_time = get_stat("MinimumSwingtime", 1.0)
        worth = ((avg_dmg * max_range * max_hit) + (condition * reliability / 5)) / (weight * 2 + swing_time * 10 + 0.1)
    elif category in ["Clothing", "ProtectiveGear"]:
        bite = get_stat("BiteDefense")
        scratch = get_stat("ScratchDefense")
        bullet = get_stat("BulletDefense")
        insulation = get_stat("Insulation")
        wind_res = get_stat("WindResistance")
        run_mod = get_stat("RunSpeedModifier", 1.0)
        combat_mod = get_stat("CombatSpeedModifier", 1.0)
        penalty = (1.0 - run_mod) * 100 + (1.0 - combat_mod) * 50
        
        worth = ((bite * 3) + scratch + (bullet * 2) + (insulation * 20) + (wind_res * 10)) / (weight * 3 + penalty + 1)
    elif recipes > 0 or category == "Literature":
        worth = (recipes * 25 + 5) / (weight + 0.1)
    elif fuel_ratio > 0:
        worth = (fuel_ratio * 15) / (weight + 0.1)
    else:
        worth = (res_val / 10 + 1) / (weight + 0.1)
    
    # Scale worth by total uses for drainables
    if total_uses > 1:
        worth *= (total_uses * 0.8) # Slight diminishing returns per use
        
    # 30% Discount for already opened items
    id_lower = item_id.lower()
    is_opened = "opened = true" in p_lower or "open = true" in p_lower or "open" in id_lower or "opened" in id_lower
    if is_opened:
        worth *= 0.7
        
    return round(max(0.1, worth), 2)

def get_vanilla_data(vanilla_path, silent=False):
    item_data, fluid_data, duplicates = {}, {}, {}
    opening_map = get_opening_maps(vanilla_path, silent=silent)
    
    if not silent: print(f"[*] Scanning Vanilla Scripts: {vanilla_path}")
    for root, dirs, files in os.walk(vanilla_path):
        for file in sorted(files):
            if not file.endswith(".txt"): continue
            file_rel = os.path.relpath(os.path.join(root, file), vanilla_path)
            with open(os.path.join(root, file), "r", errors="ignore") as f:
                content = f.read()
                
                # Items
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
                        "origin": file_rel, "category": category, "subcat": subcat,
                        "tags": raw_tags, "eat_type": raw_eat, "props": props,
                        "opened_variant": opening_map.get(item_id)
                    }
                
                # Fluids
                fluid_blocks = re.findall(r"fluid\s+([a-zA-Z_]\w*)\s*\{([^}]*)\}", content, re.DOTALL)
                for fluid_id, props in fluid_blocks:

                    fluid_data[fluid_id] = {
                        "origin": file_rel, "category": "Fluids", "subcat": "General",
                        "tags": "N/A", "eat_type": "N/A", "props": props, "worth": 1.0
                    }
    
    combined_data = {**item_data, **fluid_data}
    for item_id, data in combined_data.items():
        oprops = data["props"]
        inherited = ""
        oid = data.get("opened_variant")
        if oid and oid in item_data: inherited = item_data[oid]["props"]
        combined_props = oprops + "\n" + inherited
        
        def gsl(key, default=0.0, p=combined_props):
            m = re.search(fr"{key}\s*=\s*(-?\d+\.?\d*)", p, re.IGNORECASE)
            return float(m.group(1)) if m else default

        worth = calculate_worth(item_id, combined_props, data["category"], data["subcat"])
        weight = gsl("Weight", 0.1)
        data["worth"] = worth
        data["weight"] = weight
        
        # --- Automated Stock Logic (BMS) ---
        if weight <= 0.05: bms = 50
        elif weight <= 0.2: bms = 25
        elif weight <= 0.5: bms = 15
        elif weight <= 1.5: bms = 10
        elif weight <= 5.0: bms = 5
        else: bms = 2
        
        # Multipliers
        mult = 1.0
        p_lower = combined_props.lower()
        if data["category"] == "Food" and ("fresh = true" in p_lower or "perishable = true" in p_lower):
            mult *= 0.5
        if data["category"] in ["Weapon", "Resource"] and ("ammo" in item_id.lower() or "nail" in item_id.lower()):
            mult *= 2.0
        
        max_stock = max(1, int(bms * mult))
        min_stock = int(max_stock * 0.2)
        data["stock"] = {"min": min_stock, "max": max_stock}

        # --- Automated Tag Guessing (No-Collision) ---
        root_map = {
            "Food": "Food", "Clothing": "Clothing", "Literature": "Literature",
            "Medical": "Medical", "Weapon": "Weapon", "WeaponPart": "Weapon.Part",
            "Container": "Container", "Electronics": "Electronics", "Tool": "Tool",
            "Resource": "Resource", "Appliance": "Appliance", "Fluids": "Food",
            "ProtectiveGear": "Clothing"
        }
        root = root_map.get(data["category"], "Misc")
        sub = data["subcat"]
        data["dt_tags"] = [f"{root}.{sub}", "Rarity.Common"]

        # --- Lua Snippet Generation ---
        tag_str = ', '.join([f'"{t}"' for t in data["dt_tags"]])
        data["lua"] = f'{{ item="Base.{item_id}", tags={{{tag_str}}}, basePrice={int(worth)}, stockRange={{min={min_stock}, max={max_stock}}} }},'

        # Advanced Stats for display
        data["capacity"] = gsl("Capacity", 0.0)
        data["weight_reduction"] = gsl("WeightReduction", 0.0)
        use_delta = gsl("UseDelta", 0.0)
        data["total_uses"] = int(round(1.0 / use_delta)) if use_delta > 0 else 1
        data["fire_fuel"] = gsl("FireFuelRatio", 0.0)
        data["unhappy"] = gsl("UnhappyChange", 0.0)
        data["recipes"] = len(re.findall(r"LearnedRecipes\s*=\s*([^,\n\s;]+)", combined_props))
        
        # Food Specific
        data["fresh"] = gsl("DaysFresh", 0.0)
        data["rotten"] = gsl("DaysTotallyRotten", 0.0)
        data["hunger"] = abs(gsl("HungerChange", 0.0))
        
        # Clothing Specific
        if data["category"] in ["Clothing", "ProtectiveGear"]:
            data["insulation"] = gsl("Insulation", 0.0)
            data["wind_res"] = gsl("WindResistance", 0.0)
            data["bite_def"] = gsl("BiteDefense", 0.0)
            data["scratch_def"] = gsl("ScratchDefense", 0.0)
            data["bullet_def"] = gsl("BulletDefense", 0.0)
            data["condition_max"] = gsl("ConditionMax", 0.0)
                    
    return item_data, fluid_data

def get_mod_data(mod_path, silent=False):
    mod_data, mod_duplicates = {}, {}
    if not silent: print(f"[*] Scanning Mod Registries: {mod_path}")
    if not os.path.exists(mod_path): return mod_data, mod_duplicates
    
    for root, dirs, files in os.walk(mod_path):
        for file in sorted(files):
            if not file.endswith(".lua"): continue
            file_rel = os.path.relpath(os.path.join(root, file), mod_path)
            with open(os.path.join(root, file), "r", errors="ignore") as f:
                content = f.read()
                # Handle both item = "Base.X" and ["Base.X"] patterns
                found = re.findall(r'(?:item\s*=\s*|\[)"Base\.(\w+)"', content)
                for m in found:
                    if m in mod_data:
                        if m not in mod_duplicates:
                            mod_duplicates[m] = [mod_data[m]["origin"]]
                        mod_duplicates[m].append(file_rel)
                    mod_data[m] = {"origin": file_rel}
    return mod_data, mod_duplicates

def write_mod_duplicates(output_dir, mod_dupes):
    if not mod_dupes: return
    print(f"[*] Writing Mod Duplicates results...")
    target_dir = os.path.join(output_dir, "Duplicates")
    os.makedirs(target_dir, exist_ok=True)
    
    # Organize dupes by source file (a dupe can belong to multiple files)
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


def write_hierarchical_files(output_dir, status_folder, ids_subset, vanilla_data, mod_data):
    if not ids_subset: return
    print(f"[*] Writing {status_folder} results...")
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
            # Only redirect to UnsureItems for the main categories, not for Duplicates/Invalid
            if meta.get("tags") == "None" and status_folder in ["VanillaOnly", "AlreadyHas"]:
                current_root = "UnsureItems"
            
        origin = meta.get("origin", "Unknown.txt").replace(".lua", "").replace(".txt", "")
        # Handle nested status folders (e.g., Duplicates/Vanilla)
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
            if meta.get("fire_fuel", 0) > 0:
                extra.append(f"Fuel: {meta.get('fire_fuel'):<4}")
            if meta.get("unhappy", 0) != 0:
                extra.append(f"Unhappy: {meta.get('unhappy'):<3}")
            
            # Food Stats
            if meta.get("hunger", 0) != 0:
                extra.append(f"Hung: {meta.get('hunger'):<3}")
            if meta.get("fresh", 0) > 0:
                extra.append(f"Fresh: {meta.get('fresh'):<3} Rot: {meta.get('rotten'):<3}")
            
            # Clothing Stats
            if meta.get("category") in ["Clothing", "ProtectiveGear"]:
                extra.append(f"Ins: {meta.get('insulation'):<3} Wind: {meta.get('wind_res'):<3}")
                extra.append(f"Def(B/S/P): {meta.get('bite_def'):.0f}/{meta.get('scratch_def'):.0f}/{meta.get('bullet_def'):.0f}")
                if meta.get("condition_max", 0) > 0:
                    extra.append(f"Cond: {meta.get('condition_max'):<3}")
                
            extra_str = " | " + " | ".join(extra) if extra else ""
            f.write(f"{obj_id:<45} | Potential Worth: {worth:<8} | Weight: {weight:<6}{extra_str} | Tags: {meta.get('tags','N/A')}\n")
            if "lua" in meta:
                f.write(f"  LUA: {meta['lua']}\n")

def main():
    parser = argparse.ArgumentParser(description="Compare Vanilla PZ Items/Fluids with Mod Registries")
    parser.add_argument("--vanilla", default=VANILLA_DIR, help="Path to vanilla scripts")
    parser.add_argument("--mod", default=MOD_ITEMS_DIR, help="Path to mod item Lua files")
    parser.add_argument("--output", default=OUTPUT_DIR, help="Path for output")
    parser.add_argument("--chunk", type=int, default=0, help="Number of items to output to console for indexing")
    parser.add_argument("--category", help="Filter chunk by category (e.g., Beverages, Food)")
    parser.add_argument("--status", default="VanillaOnly", choices=["VanillaOnly", "AlreadyHas", "Invalid", "UnsureItems"], help="Source list for chunking")
    parser.add_argument("--llm", action="store_true", help="Output in LLM-optimized format (concise stats, tag ref)")
    parser.add_argument("--getTags", nargs='?', const='all', help="On-demand tag lookup. Use 'all' or a root category (e.g., Food)")
    args = parser.parse_args()

    if args.getTags:
        all_tags, roots = get_dynamic_tags()
        if args.getTags.lower() == 'all':
            print(f"--- FULL TAG LIBRARY ---\n{', '.join(all_tags)}")
        else:
            branch = args.getTags.capitalize()
            filtered = [t for t in all_tags if t.startswith(branch + ".")]
            if filtered:
                print(f"--- TAG BRANCH: {branch} ---\n{', '.join(filtered)}")
            else:
                print(f"No tags found for branch: {branch}")
        return

    v_items, v_fluids = get_vanilla_data(args.vanilla, silent=args.llm) if not args.llm else (get_vanilla_data(args.vanilla, silent=True), {})[0] 
    m_data, m_dupes = get_mod_data(args.mod, silent=args.llm)
    v_combined = {**v_items, **v_fluids}
    
    vanilla_only = sorted(list(set(v_combined.keys()) - set(m_data.keys())))
    already_has = sorted(list(set(v_combined.keys()) & set(m_data.keys())))
    mod_invalid = sorted(list(set(m_data.keys()) - set(v_combined.keys())))

    unsure_items = [obj_id for obj_id in vanilla_only if v_combined[obj_id].get("tags") == "None"]

    if args.chunk > 0:
        source_map = {
            "VanillaOnly": vanilla_only,
            "AlreadyHas": already_has,
            "Invalid": mod_invalid,
            "UnsureItems": unsure_items
        }
        target_list = source_map.get(args.status, vanilla_only)
        
        if args.llm:
            # Pre-collect chunk items to keep output clean
            chunk_items = []
            count = 0
            for obj_id in target_list:
                meta = v_combined.get(obj_id)
                if not meta: meta = m_data.get(obj_id, {})
                if args.category:
                    cat_match = args.category.lower() in meta.get("origin", "").lower() or args.category.lower() in meta.get("category", "").lower()
                    if not cat_match: continue
                
                chunk_items.append((obj_id, meta))
                count += 1
                if count >= args.chunk: break

            if count == 0:
                print(f"No items found matching category: {args.category or 'Any'} with status: {args.status}")
                return

            print(f"--- CHUNK: {args.status} | Filter: {args.category or 'Any'} ---")
            for obj_id, meta in chunk_items:
                p = meta.get("props", "")
                print(f"[{obj_id}] (Origin: {meta.get('origin', 'Unknown')})")
                
                # Stats Extraction
                def fnd(key):
                    m = re.search(fr"{key}\s*=\s*(-?\d+\.?\d*)", p, re.IGNORECASE)
                    return m.group(1) if m else None

                stats = {
                    "Potencial Worth": meta.get("worth"), "Weight": fnd("Weight"), "Category": meta.get("category"), 
                    "Subcat": meta.get("subcat"),
                    "Hunger": fnd("HungerChange"), "Thirst": fnd("ThirstChange"), "Cal": fnd("Calories"),
                    "Fresh": fnd("DaysFresh"), "Rotten": fnd("DaysTotallyRotten"),
                    "Cap": fnd("Capacity"), "WR": fnd("WeightReduction"),
                    "Uses": int(round(1.0 / float(fnd("UseDelta")))) if fnd("UseDelta") and float(fnd("UseDelta")) > 0 else 1,
                    "Condition": fnd("ConditionMax"), "Tags": meta.get("tags")
                }
                
                active_stats = [f"{k}: {v}" for k, v in stats.items() if v and v != "0.0" and v != "None"]
                print(f"  {' | '.join(active_stats)}")
            return

        print(f"\n--- CHUNK OUTPUT (Size: {args.chunk}, Status: {args.status}, Category: {args.category or 'Any'}) ---")
        count = 0
        for obj_id in target_list:
            meta = v_combined.get(obj_id)
            if not meta: # Handle Invalid IDs not in Vanilla
                meta = m_data.get(obj_id, {})
            
            # Category filter
            if args.category:
                cat_match = args.category.lower() in meta.get("origin", "").lower() or args.category.lower() in meta.get("category", "").lower()
                if not cat_match: continue
            
            if "lua" in meta:
                print(meta["lua"])
                count += 1
            else:
                # Fallback for items with no automated LUA (mainly Invalid)
                print(f"-- [NO LUA GEN] {obj_id} (Origin: {meta.get('origin', 'Unknown')})")
                count += 1

            if count >= args.chunk:
                break
        print(f"--- END CHUNK ({count} items found) ---\n")
        return
    
    write_hierarchical_files(args.output, "VanillaOnly", vanilla_only, v_combined, m_data)
    write_hierarchical_files(args.output, "AlreadyHas", already_has, v_combined, m_data)
    write_hierarchical_files(args.output, "Invalid", mod_invalid, v_combined, m_data)
    write_mod_duplicates(args.output, m_dupes)
    
    print("\n--- Summary ---")
    print(f"Total Vanilla Unique:   {len(v_combined)}")
    print(f"Total Mod Registered:   {len(m_data)}")
    print(f"Missing (Vanilla Only): {len(vanilla_only)}")
    print(f"Correctly Registered:   {len(already_has)}")
    print(f"Invalid Mod IDs:        {len(mod_invalid)}")
    print(f"Mod Duplicates:         {len(m_dupes)}")

if __name__ == "__main__":
    main()
