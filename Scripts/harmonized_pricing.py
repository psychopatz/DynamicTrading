#!/usr/bin/env python3
"""
Harmonized Pricing and Stock Logic Implementation
Data-driven approach using vanilla item stats
"""
import os
import re
import math
from pathlib import Path
from collections import defaultdict

VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"
ITEMS_DIR = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")

def load_vanilla_items():
    """Load all vanilla item definitions with full properties"""
    items = {}
    items_dir = os.path.join(VANILLA_DIR, "generated/items/")
    
    if not os.path.exists(items_dir):
        print(f"❌ Vanilla directory not found: {items_dir}")
        return items
    
    for filename in os.listdir(items_dir):
        if not filename.endswith('.txt'):
            continue
        
        filepath = os.path.join(items_dir, filename)
        with open(filepath, 'r', errors='ignore') as f:
            content = f.read()
        
        # Extract item blocks
        pattern = r'item\s+(\w+)\s*\{([^}]*?(?:\{[^}]*\}[^}]*?)*)\}'
        for match in re.finditer(pattern, content, re.DOTALL):
            item_id = match.group(1)
            props = match.group(2)
            items[item_id] = props
    
    return items

def get_stat(props, key, default=0.0):
    """Extract numeric stat from properties"""
    m = re.search(rf"{key}\s*=\s*(-?\d+\.?\d*)", props, re.IGNORECASE)
    return float(m.group(1)) if m else default

def has_property(props, key):
    """Check if property exists"""
    return re.search(rf"{key}\s*=\s*true", props, re.IGNORECASE) is not None

def calculate_base_max_stock(weight):
    """
    Step A: Determine Base Max Stock (BMS) from Weight
    """
    if weight <= 0.05:
        return 50
    elif weight <= 0.2:
        return 25
    elif weight <= 0.5:
        return 15
    elif weight <= 1.5:
        return 10
    elif weight <= 5.0:
        return 5
    else:
        return 2

def apply_category_multiplier(base_max, category, subcategory):
    """
    Step B: Apply Category Multipliers
    """
    # Perishable/Fresh Food
    if category == "Food" and "Perishable" in subcategory:
        return max(1, int(base_max * 0.5))
    
    # Staples (Ammo, Material)
    if category in ["Resource", "Weapon"] and any(x in subcategory for x in ["Material", "Ammo"]):
        return int(base_max * 2.0)
    
    # Rare/Luxury
    if "Luxury" in subcategory or "Rare" in subcategory:
        return max(1, int(base_max * 0.4))
    
    return base_max

def calculate_min_stock(max_stock, category, subcategory):
    """
    Step C: Determine Min Stock
    """
    # Fresh/Rare
    if "Fresh" in subcategory or "Rare" in subcategory:
        return 0
    
    # High Demand (Material, Ammo)
    if category in ["Resource"] or "Ammo" in subcategory:
        return int(max_stock * 0.4)
    
    # Default
    return int(max_stock * 0.2)

def calculate_food_price(item_id, props):
    """
    Food pricing: basePrice = math.floor(Hunger * 2.5)
    Opened penalty: 30% discount (0.7x)
    """
    hunger = abs(get_stat(props, "HungerChange", 0))
    
    # Base price from hunger
    base_price = math.floor(hunger * 2.5)
    
    # Opened penalty
    if has_property(props, "Opened") or "_Open" in item_id:
        base_price = math.floor(base_price * 0.7)
    
    return max(1, base_price)

def calculate_weapon_price(item_id, props, worth):
    """
    Weapon pricing based on Potential Worth and stats
    """
    condition = get_stat(props, "ConditionMax", 10)
    weight = get_stat(props, "Weight", 1.0)
    
    # Scale based on worth
    if worth > 50:
        multiplier = 3.0
    elif worth > 20:
        multiplier = 2.0
    else:
        multiplier = 1.5
    
    price = math.floor(worth * multiplier)
    
    # Explosives are premium
    if "Aerosol" in item_id or "Grenade" in item_id or "Explosive" in item_id:
        price = max(100, price * 2)
    
    return max(1, price)

def calculate_medical_price(item_id, props, worth):
    """
    Medical pricing scaled within range based on worth
    """
    # Range: 5-50
    if worth <= 5:
        price = 5
    elif worth >= 25:
        price = 50
    else:
        # Scale linearly between 5 and 50
        price = int(5 + (worth / 25.0) * 45)
    
    return price

def calculate_clothing_price(item_id, props, worth):
    """
    Clothing pricing scaled based on protection stats and worth
    """
    bite = get_stat(props, "BiteDefense", 0)
    scratch = get_stat(props, "ScratchDefense", 0)
    bullet = get_stat(props, "BluntDefense", 0)
    
    total_protection = bite + scratch + bullet
    
    # Heavy Armor (Bullet > 70)
    if bullet > 70:
        return int(1000 + (worth * 10))
    
    # Tactical/Riot (Bite/Scratch > 50)
    if bite > 50 or scratch > 50:
        return int(500 + (worth * 5))
    
    # Winter/Hazard gear
    insulation = get_stat(props, "Insulation", 0)
    wind_resist = get_stat(props, "WindResist", 0)
    if insulation > 0.5 or wind_resist > 0.5:
        return int(250 + (worth * 3))
    
    # Specialized gear
    if total_protection > 20:
        return int(100 + (worth * 2))
    
    # Basic clothing
    return max(5, int(10 + worth))

def calculate_container_price(item_id, props):
    """
    Container pricing based on capacity and weight reduction
    """
    capacity = get_stat(props, "Capacity", 0)
    weight = get_stat(props, "Weight", 0.1)
    weight_reduction = get_stat(props, "WeightReduction", 0)
    
    if capacity == 0:
        return 15  # Default for non-capacity containers
    
    # Utility factor
    utility = 1.0 + (weight_reduction / 100.0)
    
    # Base price: capacity per weight ratio
    base_price = (capacity * utility) / (weight + 0.1) * 2.5
    
    return math.floor(max(10, base_price))

def calculate_literature_price(item_id, props):
    """
    Literature pricing with knowledge premium
    """
    # Check for skill book indicators
    if "SkillBook" in item_id or "Book" in item_id:
        # Check if it teaches recipes
        recipes = len(re.findall(r"LearnedRecipes\s*=", props))
        if recipes > 0:
            return max(30, 15 + recipes * 10)
        
        # Regular skill book
        if "SkillBook" in item_id:
            return 50
        
        # Regular book
        return 20
    
    # Magazines and media
    if "Magazine" in item_id:
        return 8
    
    return 15

def calculate_price(item_id, props, category, subcategory):
    """
    Master pricing function using harmonized logic
    """
    weight = get_stat(props, "Weight", 0.1)
    
    # Calculate "Potential Worth" for non-food items
    worth = 0
    if category != "Food":
        # Simple worth calculation
        cap = get_stat(props, "Capacity", 0)
        wr = get_stat(props, "WeightReduction", 0)
        condition = get_stat(props, "ConditionMax", 1)
        
        if cap > 0:
            worth = (cap * (wr / 10 + 1)) / (weight + 0.1) * 2.5
        else:
            worth = (1.0 / (weight + 0.01)) * condition
    
    # Apply category-specific pricing
    if category == "Food":
        return calculate_food_price(item_id, props)
    elif category == "Weapon":
        return calculate_weapon_price(item_id, props, worth)
    elif category == "Medical":
        return calculate_medical_price(item_id, props, worth)
    elif category == "Clothing":
        return calculate_clothing_price(item_id, props, worth)
    elif category == "Container":
        return calculate_container_price(item_id, props)
    elif category == "Literature":
        return calculate_literature_price(item_id, props)
    elif category == "Resource":
        # Materials are cheap
        return max(1, int(weight * 10))
    elif category == "Electronics":
        return max(10, int(worth * 1.5))
    elif category == "Tool":
        uses = int(1.0 / get_stat(props, "UseDelta", 0.01)) if get_stat(props, "UseDelta", 0) > 0 else 1
        return max(5, int((uses / 20.0) + worth))
    else:
        return max(5, int(worth * 2))

def infer_category_from_path(file_path):
    """Infer category from file path"""
    path_str = str(file_path)
    
    if "Food/" in path_str:
        if "Perishable" in path_str:
            return "Food", "Perishable"
        elif "NonPerishable" in path_str:
            return "Food", "NonPerishable"
        else:
            return "Food", "General"
    elif "Weapon/" in path_str:
        return "Weapon", "General"
    elif "Medical/" in path_str:
        return "Medical", "General"
    elif "Clothing/" in path_str:
        return "Clothing", "General"
    elif "Container/" in path_str:
        return "Container", "General"
    elif "Literature/" in path_str:
        return "Literature", "General"
    elif "Resource/" in path_str:
        return "Resource", "Material"
    elif "Electronics/" in path_str:
        return "Electronics", "General"
    elif "Tool/" in path_str:
        return "Tool", "General"
    else:
        return "Misc", "General"

def update_item_in_file(lua_file, vanilla_items):
    """Update single file with harmonized pricing and stock logic"""
    with open(lua_file, 'r') as f:
        lines = f.readlines()
    
    original_lines = lines.copy()
    updated_count = 0
    updates = []
    matched_count = 0
    
    category, subcategory = infer_category_from_path(lua_file)
    
    for i, line in enumerate(lines):
        # Match: item="Base.ITEMID", basePrice=OLD, tags={...}, stockRange={min=X, max=Y}
        match = re.search(r'item="Base\.(\w+)",\s*basePrice=(\d+),\s*tags=\{([^}]+)\},\s*stockRange=\{min=(\d+),\s*max=(\d+)\}', line)
        
        if match:
            item_id = match.group(1)
            old_price = int(match.group(2))
            tags_str = match.group(3)
            old_min = int(match.group(4))
            old_max = int(match.group(5))
            
            # Get vanilla props
            if item_id not in vanilla_items:
                continue
            
            props = vanilla_items[item_id]
            
            # Calculate new price
            new_price = calculate_price(item_id, props, category, subcategory)
            
            # Calculate new stock range
            weight = get_stat(props, "Weight", 0.1)
            base_max = calculate_base_max_stock(weight)
            new_max = apply_category_multiplier(base_max, category, subcategory)
            new_min = calculate_min_stock(new_max, category, subcategory)
            
            # Update if changed
            if new_price != old_price or new_min != old_min or new_max != old_max:
                # Replace in line
                new_line = line.replace(f'basePrice={old_price}', f'basePrice={new_price}')
                new_line = new_line.replace(f'stockRange={{min={old_min}, max={old_max}}}', 
                                           f'stockRange={{min={new_min}, max={new_max}}}')
                lines[i] = new_line
                updated_count += 1
                updates.append((item_id, old_price, new_price, old_min, new_min, old_max, new_max))
    
    # Write back if changed
    if lines != original_lines:
        with open(lua_file, 'w') as f:
            f.writelines(lines)
    
    return updated_count, updates

def main():
    print("🎯 HARMONIZED PRICING AND STOCK LOGIC")
    print("="*100)
    print("Data-driven approach using vanilla item stats\n")
    
    print("📊 Loading vanilla items...")
    vanilla_items = load_vanilla_items()
    print(f"✅ Loaded {len(vanilla_items)} vanilla items\n")
    
    total_updated = 0
    all_updates = []
    
    # Process all Lua files
    for lua_file in sorted(ITEMS_DIR.rglob("*.lua")):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        updated, updates = update_item_in_file(lua_file, vanilla_items)
        
        if updated > 0:
            rel_path = lua_file.relative_to(ITEMS_DIR)
            print(f"📝 {rel_path}")
            
            # Show examples
            for item_id, old_p, new_p, old_min, new_min, old_max, new_max in updates[:3]:
                price_change = f"${old_p}→${new_p}" if old_p != new_p else f"${new_p}"
                stock_change = f"{old_min}-{old_max}→{new_min}-{new_max}" if (old_min != new_min or old_max != new_max) else f"{new_min}-{new_max}"
                print(f"   {item_id}: {price_change} | Stock: {stock_change}")
            
            if len(updates) > 3:
                print(f"   ... and {len(updates)-3} more items")
            
            print(f"   ✅ {updated} items\n")
            total_updated += updated
            all_updates.extend(updates)
    
    # Summary
    print("="*100)
    print(f"🎉 TOTAL ITEMS UPDATED: {total_updated}")
    print("="*100)
    
    if all_updates:
        print(f"\n💰 HARMONIZED FRAMEWORK APPLIED:")
        print(f"   ✓ Food: Hunger × 2.5 formula (with opened penalty)")
        print(f"   ✓ Stock: Weight-based BMS + Category multipliers")
        print(f"   ✓ Min/Max: Calculated from weight and category")
        print(f"   ✓ Scaling: Medical/Clothing scaled within ranges by worth")
        print(f"   ✓ Premium: Explosives, skill books, and rare items marked up")
    
    print(f"\n✨ All items now use data-driven pricing and stock logic!")

if __name__ == "__main__":
    main()
