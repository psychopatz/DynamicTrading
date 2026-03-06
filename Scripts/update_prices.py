#!/usr/bin/env python3
"""
Calculate proper pricing for all items based on vanilla stats and economic formulas
"""
import os
import re
import subprocess
from pathlib import Path
import math

VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"

def get_stat(props, key, default=0.0):
    """Extract numeric stat from item properties"""
    m = re.search(rf"{key}\s*=\s*(-?\d+\.?\d*)", props, re.IGNORECASE)
    return float(m.group(1)) if m else default

def load_vanilla_items():
    """Load all vanilla item definitions with their full properties"""
    items = {}
    
    items_dir = os.path.join(VANILLA_DIR, "generated/items/")
    if not os.path.exists(items_dir):
        print(f"❌ Vanilla items directory not found: {items_dir}")
        return items
    
    for filename in os.listdir(items_dir):
        if not filename.endswith('.txt'):
            continue
        
        filepath = os.path.join(items_dir, filename)
        with open(filepath, 'r', errors='ignore') as f:
            content = f.read()
        
        # Extract item blocks: item ItemName { ... }
        pattern = r'item\s+(\w+)\s*\{([^}]*?(?:\{[^}]*\}[^}]*?)*)\}'
        matches = re.finditer(pattern, content, re.DOTALL)
        
        for match in matches:
            item_id = match.group(1)
            props = match.group(2)
            items[item_id] = props
    
    return items

def calculate_food_price(item_id, props):
    """
    Food pricing: basePrice = Hunger * 2.5 (with freshness scaling)
    Opened penalty: 30% discount (0.7x)
    """
    hunger = abs(get_stat(props, "HungerChange"))
    thirst = abs(get_stat(props, "ThirstChange"))
    
    # Calories factor
    calories = get_stat(props, "Calories", 0) / 100.0
    
    # Freshness factor
    fresh = get_stat(props, "DaysFresh", 1)
    rotten = get_stat(props, "DaysTotallyRotten", 2)
    shelf_life = (fresh + rotten) / 2.0 if (fresh + rotten) > 0 else 1.0
    shelf_factor = min(1.5, shelf_life / 100.0) if shelf_life > 0 else 0.5
    
    # Canned goods stability bonus
    stability = 1.0
    if "cannedfood = true" in props.lower():
        stability = 1.2
    elif "packaged = true" in props.lower():
        stability = 1.1
    
    # Base price from hunger
    base_price = hunger * 2.5
    
    # Apply modifiers
    price = base_price * shelf_factor * stability
    
    # Penalties for negative stats
    penalties = max(0, get_stat(props, "UnhappyChange")) + \
                max(0, get_stat(props, "BoredomChange")) + \
                max(0, get_stat(props, "StressChange"))
    price *= (1.0 - min(0.3, penalties * 0.1))
    
    # Opened penalty
    if "Opened = true" in props:
        price *= 0.7
    
    return math.floor(max(1, price))

def calculate_weapon_price(item_id, props):
    """
    Weapon pricing based on damage/utility stats
    """
    weight = get_stat(props, "Weight", 0.1)
    
    # Damage stats
    damage = get_stat(props, "HitAngleMod")
    condition = get_stat(props, "Condition", 1)
    uses = int(1.0 / get_stat(props, "UseDelta", 0.01)) if get_stat(props, "UseDelta", 0) > 0 else 1
    
    # Condition factor
    condition_factor = condition if condition > 0 else 0.5
    
    # Durability factor (uses)
    durability_factor = min(2.0, uses / 100.0) if uses > 0 else 0.5
    
    # Base price from weight and damage
    base_price = (weight * 20) + damage * 5
    price = base_price * condition_factor * durability_factor
    
    # Special weapon bonuses
    if "Ammo" in item_id or "ammo" in props.lower():
        price = max(1, int(weight * 50))
    elif "Explosive" in item_id or "explosive" in props.lower():
        price = max(10, int(damage * 10))
    
    return math.floor(max(1, price))

def calculate_armor_price(item_id, props):
    """
    Armor pricing based on protection stats
    """
    # Protection stats
    bite_protection = get_stat(props, "BiteDefense")
    scratch_protection = get_stat(props, "ScratchDefense")
    bullet_protection = get_stat(props, "BluntDefense")
    
    # Total protection value
    total_protection = bite_protection + scratch_protection + bullet_protection
    
    # Condition factor
    condition = get_stat(props, "Condition", 1)
    condition_factor = condition if condition > 0 else 0.5
    
    # Base price from protection
    base_price = (total_protection * 5) + 10
    price = base_price * condition_factor
    
    # Quality modifiers
    if "Ruined" in item_id or "ruined" in props.lower():
        price *= 0.3
    elif "Tattered" in item_id:
        price *= 0.6
    
    return math.floor(max(1, price))

def calculate_container_price(item_id, props):
    """
    Container pricing based on capacity and weight reduction
    """
    capacity = get_stat(props, "Capacity")
    weight = get_stat(props, "Weight", 0.1)
    weight_reduction = get_stat(props, "WeightReduction")
    
    # Utility factor
    utility = 1.0 + (weight_reduction / 100.0)
    
    # Base price: capacity per weight
    base_price = (capacity * utility) / (weight + 0.1) * 2.5
    
    return math.floor(max(1, base_price))

def calculate_tool_price(item_id, props):
    """
    Tool pricing based on uses and effectiveness
    """
    weight = get_stat(props, "Weight", 0.1)
    use_delta = get_stat(props, "UseDelta", 0.01)
    uses = int(1.0 / use_delta) if use_delta > 0 else 1
    
    # Effectiveness bonus if it teaches recipes
    recipes = len(re.findall(r"LearnedRecipes\s*=", props))
    recipe_bonus = 1.0 + (recipes * 2.0)
    
    # Base price
    base_price = (uses / 10.0) + (recipe_bonus * 5)
    
    return math.floor(max(1, base_price))

def get_item_category(props):
    """Determine item category from properties"""
    props_lower = props.lower()
    
    if "hungerchange" in props_lower or "thirstchange" in props_lower:
        return "Food"
    elif "bitedefense" in props_lower or "scratchdefense" in props_lower:
        return "Armor"
    elif "capacity" in props_lower:
        return "Container"
    elif "damagemodifier" in props_lower or "hitanglemod" in props_lower:
        return "Weapon"
    elif "learnedrecipes" in props_lower:
        return "Tool"
    else:
        return "Misc"

def calculate_price(item_id, props):
    """Calculate proper price based on item type and stats"""
    category = get_item_category(props)
    
    if category == "Food":
        return calculate_food_price(item_id, props)
    elif category == "Armor":
        return calculate_armor_price(item_id, props)
    elif category == "Container":
        return calculate_container_price(item_id, props)
    elif category == "Weapon":
        return calculate_weapon_price(item_id, props)
    elif category == "Tool":
        return calculate_tool_price(item_id, props)
    else:
        # Generic pricing
        weight = get_stat(props, "Weight", 0.1)
        return math.floor(max(1, weight * 10))

def update_prices_in_file(filepath, vanilla_items):
    """Update prices in a Lua registry file"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    updated_count = 0
    
    # Find all item entries: { item="Base.XYZ", basePrice=N, ...
    pattern = r'{\s*item="Base\.(\w+)",\s*basePrice=(\d+),'
    
    def replace_price(match):
        nonlocal updated_count
        item_id = match.group(1)
        old_price = int(match.group(2))
        
        if item_id in vanilla_items:
            new_price = calculate_price(item_id, vanilla_items[item_id])
            if new_price != old_price:
                updated_count += 1
                return f'{{ item="Base.{item_id}", basePrice={new_price},'
        
        return match.group(0)
    
    content = re.sub(pattern, replace_price, content)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        return updated_count
    
    return 0

def main():
    print("📊 Loading vanilla item stats...")
    vanilla_items = load_vanilla_items()
    print(f"✅ Loaded {len(vanilla_items)} vanilla items\n")
    
    items_dir = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")
    
    total_updated = 0
    
    # Process all Lua files recursively
    for lua_file in items_dir.rglob("*.lua"):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        print(f"📝 Processing {lua_file.relative_to(items_dir)}...")
        updated = update_prices_in_file(str(lua_file), vanilla_items)
        
        if updated > 0:
            print(f"   ✅ Updated {updated} item prices")
            total_updated += updated
    
    print(f"\n🎉 Total prices updated: {total_updated}")
    print("✨ All items now have proper pricing based on vanilla stats!")

if __name__ == "__main__":
    main()
