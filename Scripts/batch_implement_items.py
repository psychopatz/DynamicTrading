#!/usr/bin/env python3
"""
Batch implement items from UnsureItems chunks into the mod registry
"""
import os
import re
import sys
import subprocess
import json
from pathlib import Path

ITEMS_DIR = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")
OUTPUT_DIR = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Scripts/Output/UnsureItems")

# Category mappings
CATEGORY_TO_DIR = {
    "Food": "Food",
    "Weapon": "Weapon",
    "Clothing": "Clothing",
    "Tool": "Tool",
    "Medical": "Medical",
    "Container": "Container",
    "Resource": "Resource",
    "Literature": "Literature",
    "Electronics": "Electronics",
    "Appliance": "Appliance",
    "Vehicle": "Vehicle",
    "Furniture": "Misc",
    "Explosion": "Weapon",
    "Explosives": "Weapon",
    "Junk": "Misc",
    "Generic": "Misc",
}

SUBCATEGORY_MAPPING = {
    # Food subcategories
    "Food": {
        "Meat": "DT_Meat.lua",
        "Fruit": "DT_Perishable.lua",
        "Vegetable": "DT_Perishable.lua",
        "Grain": "DT_Perishable.lua",
        "Spice": "DT_Cooking.lua",
        "Cooking": "DT_Cooking.lua",
        "Canned": "DT_NonPerishable.lua",
        "Bait": "DT_Perishable.lua",
        "Sweets": "DT_Perishable.lua",
        "Baked": "DT_Perishable.lua",
        "Crustacean": "DT_Perishable.lua",
        "Beverage": "DT_Drink.lua",
        "Alcohol": "DT_Drink.lua",
        "NonAlcoholic": "DT_Drink.lua",
        "Drink": "DT_Drink.lua",
    },
    "Weapon": {
        "Melee": "MeleeWeapons.lua",
        "Firearm": "RangedWeapons.lua",
        "Ranged": "RangedWeapons.lua",
        "Explosives": "RangedWeapons.lua",
        "Projectile": "RangedWeapons.lua",
        "Ammo": "Ammo.lua",
        "Part": "WeaponParts.lua",
    }
}

def extract_chunk(chunk_size=10, offset=0):
    """Extract a chunk of items from UnsureItems using ItemID_Verify.py"""
    cmd = [
        "python3", 
        "Scripts/ItemID_Verify.py",
        "--chunk", str(chunk_size),
        "--status", "UnsureItems",
        "--llm"
    ]
    
    result = subprocess.run(cmd, cwd="/home/psychopatz/Zomboid/Workshop/DynamicTrading", 
                          capture_output=True, text=True, timeout=60)
    return result.stdout

def parse_chunk_output(output):
    """Parse the chunk output into structured item data"""
    items = []
    current_item = None
    
    lines = output.split('\n')
    for line in lines:
        # Item name pattern: [ItemName]
        match = re.match(r'\[(\w+)\]\s+\(Origin:', line)
        if match:
            if current_item:
                items.append(current_item)
            current_item = {'id': match.group(1), 'stats': {}}
        elif current_item and line.strip():
            # Parse stats
            parts = line.split('|')
            for part in parts:
                part = part.strip()
                if ':' in part:
                    key, val = part.split(':', 1)
                    key = key.strip()
                    val = val.strip()
                    current_item['stats'][key] = val
    
    if current_item:
        items.append(current_item)
    
    return items

def get_category_from_item(item_id, item_stats):
    """Infer category from item stats and characteristics"""
    category = item_stats.get('Category', 'Misc')
    return CATEGORY_TO_DIR.get(category, 'Misc')

def get_tags_for_item(item_id, item_stats, category):
    """Generate appropriate tags for an item"""
    tags = []
    cat = item_stats.get('Category', 'Misc')
    subcat = item_stats.get('Subcat', 'General')
    
    # Add main category tag
    if cat == 'Food':
        if 'Canned' in subcat or 'Pickled' in subcat:
            tags.append("Food.NonPerishable.Canned")
        elif 'Meat' in subcat:
            tags.append(f"Food.Perishable.Meat")
        elif 'Fruit' in subcat:
            tags.append(f"Food.Perishable.Fruit")
        elif 'Vegetable' in subcat:
            tags.append(f"Food.Perishable.Vegetable")
        elif 'Grain' in subcat or 'Baked' in subcat:
            tags.append(f"Food.Perishable.Grain")
        elif 'Beverage' in subcat or 'Drink' in subcat:
            tags.append(f"Food.NonPerishable.Drink")
        elif 'Spice' in subcat or 'Seasoning' in subcat:
            tags.append(f"Food.Perishable.Spice")
        else:
            tags.append("Food.Perishable.Sweets")
    elif cat == 'Clothing':
        tags.append("Clothing.General")
    elif cat == 'Weapon':
        if 'Explosives' in item_id or 'Aerosol' in item_id:
            tags.append("Weapon.Explosives")
        else:
            tags.append("Weapon.Ranged")
    elif cat == 'Tool':
        tags.append("Tool.General")
    elif cat == 'Medical':
        tags.append("Medical.General")
    elif cat == 'Container':
        tags.append("Container.Storage")
    else:
        tags.append(f"{category}.General")
    
    # Add rarity tag
    tags.append("Rarity.Common")
    
    return tags

def calculate_price(item_id, item_stats):
    """Calculate appropriate base price"""
    try:
        worth = float(item_stats.get('Potencial Worth', '1.0').split()[0])
    except:
        worth = 1.0
    
    # Convert "Potential Worth" to approximate base price (rough heuristic)
    if worth > 100:
        base_price = int(worth / 20)
    elif worth > 20:
        base_price = int(worth / 5)
    else:
        base_price = max(1, int(worth * 2))
    
    return max(1, base_price)

def calculate_stock_range(item_id, item_stats):
    """Calculate min/max stock range based on weight and category"""
    try:
        weight = float(item_stats.get('Weight', '0.1').split()[0])
    except:
        weight = 0.1
    
    # Base multipliers for stock range
    if weight <= 0.05:
        base_max = 50
    elif weight <= 0.2:
        base_max = 25
    elif weight <= 0.5:
        base_max = 15
    elif weight <= 1.5:
        base_max = 10
    elif weight <= 5.0:
        base_max = 5
    else:
        base_max = 2
    
    category = item_stats.get('Category', 'Misc')
    
    # Apply category multipliers
    if 'Canned' in category or 'NonPerishable' in category:
        multiplier = 1.5
    elif 'Perishable' in category or category == 'Food':
        multiplier = 0.5
    elif 'Rare' in item_id or 'Special' in item_id:
        multiplier = 0.4
    else:
        multiplier = 1.0
    
    max_stock = max(1, int(base_max * multiplier))
    min_stock = max(1, int(max_stock * 0.2))
    
    return {'min': min_stock, 'max': max_stock}

def format_item_entry(item_id, item_stats):
    """Format item entry for Lua registration"""
    base_price = calculate_price(item_id, item_stats)
    stock_range = calculate_stock_range(item_id, item_stats)
    
    category = get_category_from_item(item_id, item_stats)
    tags = get_tags_for_item(item_id, item_stats, category)
    
    tags_str = ', '.join([f'"{tag}"' for tag in tags])
    
    entry = f'{{ item="Base.{item_id}", basePrice={base_price}, tags={{{tags_str}}}, stockRange={{min={stock_range["min"]}, max={stock_range["max"]}}} }}'
    
    return entry, category, tags

def add_items_to_registry(items):
    """Add items to appropriate Lua registry files"""
    added_count = 0
    
    for item_data in items:
        item_id = item_data['id']
        stats = item_data['stats']
        
        entry, category_dir, tags = format_item_entry(item_id, stats)
        
        # Determine target file
        category = stats.get('Category', 'Misc')
        target_dir = ITEMS_DIR / CATEGORY_TO_DIR.get(category, 'Misc')
        
        # Determine target filename based on tags
        target_file = None
        if category == 'Food':
            if 'Canned' in tags[0]:
                target_file = target_dir / 'DT_NonPerishable.lua'
            elif 'Drink' in tags[0]:
                target_file = target_dir / 'DT_Drink.lua'
            elif 'Spice' in tags[0]:
                target_file = target_dir / 'DT_Cooking.lua'
            else:
                target_file = target_dir / 'DT_Perishable.lua'
        elif category == 'Weapon':
            if 'Explosives' in tags[0]:
                target_file = target_dir / 'Weapons.lua'
            else:
                target_file = target_dir / 'Weapons.lua'
        else:
            # Find first lua file in category
            lua_files = list(target_dir.glob('*.lua'))
            if lua_files:
                target_file = lua_files[0]
        
        if not target_file:
            print(f"❌ No target file found for {item_id}")
            continue
        
        if not target_file.exists():
            print(f"⚠️  File not found: {target_file}")
            continue
        
        # Read file and add item before closing bracket
        with open(target_file, 'r') as f:
            content = f.read()
        
        # Insert before the final closing parenthesis
        if 'RegisterBatch(' in content:
            # Find the last }), before the closing
            insert_pos = content.rfind('})')
            if insert_pos != -1:
                # Add proper indentation and comma
                new_content = content[:insert_pos] + '    ' + entry + ',\n' + content[insert_pos:]
                
                with open(target_file, 'w') as f:
                    f.write(new_content)
                
                print(f"✅ {item_id} -> {target_file.name} (${calculate_price(item_id, stats)})")
                added_count += 1
    
    return added_count

def main():
    target = 2000
    chunk_size = 10
    
    print(f"🚀 Starting batch implementation until {target} total registered items\n")
    
    while True:
        # Check current count
        result = subprocess.run(
            ["python3", "Scripts/ItemID_Verify.py"],
            cwd="/home/psychopatz/Zomboid/Workshop/DynamicTrading",
            capture_output=True, text=True, timeout=60
        )
        
        # Extract total count
        match = re.search(r'Total Mod Registered:\s+(\d+)', result.stdout)
        if match:
            current_count = int(match.group(1))
            print(f"📊 Current registered items: {current_count}/{target}")
            
            if current_count >= target:
                print(f"\n✨ Target reached! {current_count} items registered")
                break
        
        # Process next chunk
        print(f"\n📥 Extracting chunk of {chunk_size} items...")
        chunk_output = extract_chunk(chunk_size)
        
        items = parse_chunk_output(chunk_output)
        if not items:
            print("❌ No items extracted. Stopping.")
            break
        
        print(f"📝 Processing {len(items)} items...")
        added = add_items_to_registry(items)
        print(f"✅ Added {added}/{len(items)} items\n")
        
        if added == 0:
            print("⚠️  No items were added in this chunk. Stopping to prevent infinite loop.")
            break

if __name__ == "__main__":
    main()
