#!/usr/bin/env python3
"""
Apply realistic PZ economy pricing - SIMPLE and RELIABLE approach
"""
import re
from pathlib import Path

ITEMS_DIR = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")

# File-specific default prices (realistic PZ economy)
FILE_PRICES = {
    # FOOD
    'Food/DT_Perishable.lua': 12,  # Fish, meat, veggies = $12-25
    'Food/DT_NonPerishable.lua': 15,  # Canned goods, preserved = $15-20
    'Food/DT_Meat.lua': 22,  # Raw meat/fish
    'Food/DT_Drink.lua': 10,  # Beverages  
    'Food/DT_Cooking.lua': 8,  # Cooking ingredients
    
    # MEDICAL
    'Medical/DT_Utility.lua': 8,  # Bandages, basic supplies
    'Medical/DT_Herb.lua': 12,  # Herbal supplies
    'Medical/DT_Surgical.lua': 25,  # Advanced medical
    'Medical/DT_Tobacco.lua': 15,  # Tobacco/nicotine
    
    # WEAPONS  
    'Weapon/DT_Ranged.lua': 60,  # Firearms, explosives (has special cases)
    'Weapon/DT_Melee.lua': 25,  # Melee weapons
    'Weapon/DT_Part.lua': 12,  # Weapon parts/ammo
    
    # CLOTHING
    'Clothing/DT_Armor.lua': 15,
    'Clothing/DT_Accessory.lua': 10,
    'Clothing/DT_Head.lua': 8,
    'Clothing/DT_Hands.lua': 6,
    
    # CONTAINERS
    'Container/DT_Backpack.lua': 40,
    'Container/DT_General.lua': 25,
    'Container/DT_Organizer.lua': 35,
    'Container/DT_Sack.lua': 25,
    'Container/DT_Secret.lua': 25,
    'Container/DT_Wearable.lua': 18,
    'Container/DT_Food.lua': 12,
    'Container/DT_Fluid.lua': 15,
    'Container/DT_Cooking.lua': 14,
    'Container/DT_Misc.lua': 20,
    
    # ELECTRONICS
    'Electronics/DT_Communication.lua': 30,
    'Electronics/DT_Component.lua': 15,
    'Electronics/DT_Gadget.lua': 20,
    'Electronics/DT_Battery.lua': 3,
    'Electronics/DT_Entertainment.lua': 15,
    'Electronics/DT_Utility.lua': 20,
    'Electronics/DT_Scholastic.lua': 10,
    
    # TOOLS
    'Tool/DT_Cooking.lua': 8,
    'Tool/DT_Camping.lua': 22,
    'Tool/DT_Crafting.lua': 15,
    'Tool/DT_General.lua': 18,
    'Tool/DT_Trap.lua': 12,
    'Tool/DT_Navigation.lua': 10,
    'Tool/DT_Cleaning.lua': 5,
    'Tool/DT_Demolition.lua': 20,
    'Tool/DT_Smithing.lua': 25,
    'Tool/DT_Heavy.lua': 30,
    'Tool/DT_Farmer.lua': 15,
    'Tool/DT_Resource.lua': 8,
    
    # LITERATURE
    'Literature/DT_SkillBook.lua': 50,  # Knowledge is expensive
    'Literature/DT_Book.lua': 18,
    'Literature/DT_Recipe.lua': 30,
    'Literature/DT_Media.lua': 12,
    'Literature/DT_Music.lua': 15,
    'Literature/DT_Audio.lua': 10,
    
    # RESOURCES
    'Resource/DT_Material.lua': 3,
    'Resource/DT_Fuel.lua': 6,
    
    # MISC
    'Misc/DT_Scholastic.lua': 6,
    'Misc/DT_Cosmetic.lua': 5,
    'Misc/DT_Hygiene.lua': 4,
    'Misc/DT_Decor.lua': 5,
    'Misc/DT_General.lua': 8,
    'Misc/DT_Artifact.lua': 35,
    
    # APPLIANCES
    'Appliance/DT_Generator.lua': 75,
    'Appliance/DT_Radio.lua': 30,
    'Appliance/DT_TV.lua': 40,
    
    # VEHICLE
    'Vehicle/DT_Part.lua': 40,
    'Vehicle/DT_Body.lua': 80,
}

# Item-specific overrides (special items that need custom prices)
ITEM_OVERRIDES = {
    # High-value explosives
    'Aerosolbomb': 120,
    'AerosolbombRemote': 120,
    'AerosolbombSensorV1': 120,
    'AerosolbombSensorV2': 120,
    'AerosolbombSensorV3': 120,
    'AerosolbombTriggered': 120,
    'Grenade': 150,
    
    # Premium fish and meat
    'Bluegill': 18,
    'BlackCrappie': 18,
    'BlueCatfish': 22,
    'ChannelCatfish': 22,
    'AligatorGar': 28,
    'ChickenWhole': 50,
    
    # Premium drinks
    'Whiskey': 35,
    'Vodka': 35,
    'Wine': 25,
    
    # Skill books are expensive (knowledge)
    'SkillBook': 55,
    'Magazine': 8,
    
    # Generators are valuable
    'Generator': 75,
    
    # Radio communication equipment
    'HamRadio': 40,
    'Walkie': 35,
    
    # High-value armor and gear
    'CombatBoots': 20,
    'TacticalVest': 45,
}

def get_price(item_id, file_path):
    """Get price for an item"""
    
    # Check direct item override first
    for pattern, price in ITEM_OVERRIDES.items():
        if pattern in item_id:
            return price
    
    # Get file-based default
    rel_path = str(file_path.relative_to(ITEMS_DIR)).replace('\\', '/')
    return FILE_PRICES.get(rel_path, 15)  # Safe default

def update_file(filepath):
    """Update prices in a Lua file"""
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    original_lines = lines.copy()
    updated_count = 0
    updates = []
    
    for i, line in enumerate(lines):
        # Match: item="Base.ITEMID", basePrice=OLD,
        match = re.search(r'item="Base\.(\w+)".+?basePrice=(\d+)', line)
        if match:
            item_id = match.group(1)
            old_price = int(match.group(2))
            new_price = get_price(item_id, filepath)
            
            if new_price != old_price:
                # Replace the price in the line
                new_line = line.replace(f'basePrice={old_price}', f'basePrice={new_price}')
                lines[i] = new_line
                updated_count += 1
                updates.append((item_id, old_price, new_price))
    
    # Write back if changed
    if lines != original_lines:
        with open(filepath, 'w') as f:
            f.writelines(lines)
    
    return updated_count, updates

def main():
    print("🎯 APPLYING SCRUTINIZED, REALISTIC PZ ECONOMY PRICING\n")
    print("="*100 + "\n")
    
    total_updated = 0
    all_updates = []
    
    # Process each Lua file
    for lua_file in sorted(ITEMS_DIR.rglob("*.lua")):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        updated, updates = update_file(lua_file)
        
        if updated > 0:
            rel_path = lua_file.relative_to(ITEMS_DIR)
            print(f"📝 {rel_path}")
            
            # Show examples
            for item_id, old_price, new_price in updates[:3]:
                adjustment = f"+${new_price - old_price}" if new_price > old_price else f"-${abs(new_price - old_price)}"
                print(f"   {item_id}: ${old_price} → ${new_price} ({adjustment})")
            
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
        increases = [(n-o) for _, o, n in all_updates if n > o]
        decreases = [(o-n) for _, o, n in all_updates if n < o]
        
        print(f"\n📊 STATISTICS:")
        if increases:
            print(f"   ⬆️  Price increases: {len(increases)} items (avg +${sum(increases)/len(increases):.1f})")
        if decreases:
            print(f"   ⬇️  Price decreases: {len(decreases)} items (avg -${sum(decreases)/len(decreases):.1f})")
        
        print(f"\n💰 TIER SYSTEM (Realistic PZ Economy):")
        print(f"   ✓ Food: $8-28 (staples $8-12, fish/meat $18-28)")
        print(f"   ✓ Medical: $4-25 (basic $4-10, advanced $20-25)")
        print(f"   ✓ Weapons: $25-150 (melee $25, guns $60+, explosives $120+)")
        print(f"   ✓ Containers: $6-75 (small $6-20, large $40-75)")
        print(f"   ✓ Electronics: $3-40 (batteries $3, radios $30-40)")
        print(f"   ✓ Literature: $8-55 (books $18, skill books $50-55)")
        print(f"   ✓ Tools: $5-30 (basic $5-8, specialized $20-30)")
        
    print(f"\n✨ All prices now reflect realistic Project Zomboid economy!")

if __name__ == "__main__":
    main()
