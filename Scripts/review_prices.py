#!/usr/bin/env python3
"""
Hand-review AlreadyHas items and set realistic prices based on PZ economy
"""
import os
import re
import subprocess
import json
from pathlib import Path
from collections import defaultdict

# PZ Economy Baseline Tiers (more realistic)
PRICE_TIERS = {
    'Food': {
        'Staple': {
            'range': (5, 15),
            'examples': 'apples, bread, basic vegetables',
            'hunger': 'low (0-10)'
        },
        'Substantial': {
            'range': (15, 35),
            'examples': 'meat, fish, full meals',
            'hunger': 'medium (10-20)'
        },
        'Luxury': {
            'range': (40, 80),
            'examples': 'rare fruits, premium foods',
            'hunger': 'high (20+)'
        },
        'Bait': {
            'range': (1, 5),
            'examples': 'worms, insects',
            'hunger': 'none - crafting'
        }
    },
    'Medical': {
        'Basic': {
            'range': (5, 15),
            'examples': 'bandages, alcohol wipes',
            'utility': 'common'
        },
        'Advanced': {
            'range': (20, 50),
            'examples': 'sutures, antibiotics',
            'utility': 'rare/specialized'
        }
    },
    'Weapon': {
        'Melee': {
            'range': (15, 60),
            'examples': 'axes, baseball bats',
            'tier': 'common'
        },
        'Ranged': {
            'range': (40, 150),
            'examples': 'guns, crossbows',
            'tier': 'rare'
        },
        'Ammo': {
            'range': (1, 2),
            'examples': 'bullets, shells per round',
            'tier': 'consumable'
        },
        'Explosive': {
            'range': (50, 200),
            'examples': 'grenades, bombs',
            'tier': 'very rare'
        }
    },
    'Clothing': {
        'Common': {
            'range': (5, 20),
            'examples': 'shirts, pants, basic gear',
            'armor': 'low'
        },
        'Protected': {
            'range': (30, 80),
            'examples': 'armor vests, tactical gear',
            'armor': 'high'
        }
    },
    'Container': {
        'Small': {
            'range': (10, 25),
            'examples': 'pouches, small bags',
            'capacity': '0-15'
        },
        'Medium': {
            'range': (25, 60),
            'examples': 'backpacks, duffels',
            'capacity': '15-40'
        },
        'Large': {
            'range': (60, 150),
            'examples': 'large backpacks, crates',
            'capacity': '40+'
        }
    },
    'Electronics': {
        'Common': {
            'range': (10, 30),
            'examples': 'radios, batteries',
            'utility': 'basic'
        },
        'Advanced': {
            'range': (40, 100),
            'examples': 'generators, components',
            'utility': 'complex'
        }
    },
    'Tool': {
        'Basic': {
            'range': (5, 20),
            'examples': 'hammers, crowbars',
            'durability': 'low-medium'
        },
        'Specialized': {
            'range': (20, 60),
            'examples': 'welding torches, saws',
            'durability': 'high'
        }
    },
    'Resource': {
        'Common': {
            'range': (0.5, 2),
            'examples': 'nails, scraps',
            'scarcity': 'common'
        },
        'Rare': {
            'range': (5, 20),
            'examples': 'metal bars, fuel',
            'scarcity': 'rare'
        }
    }
}

def load_current_prices():
    """Load current prices from Lua files"""
    prices = {}
    items_dir = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")
    
    for lua_file in items_dir.rglob("*.lua"):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        with open(lua_file, 'r') as f:
            content = f.read()
        
        # Extract: { item="Base.ITEMID", basePrice=N,
        pattern = r'{\s*item="Base\.(\w+)",\s*basePrice=(\d+),'
        for match in re.finditer(pattern, content):
            item_id = match.group(1)
            price = int(match.group(2))
            prices[item_id] = price
    
    return prices

def extract_already_has(limit=None):
    """Extract items from AlreadyHas category"""
    cmd = [
        "python3",
        "Scripts/ItemID_Verify.py",
        "--chunk", str(limit or 500),
        "--status", "AlreadyHas",
        "--llm"
    ]
    
    result = subprocess.run(cmd, cwd="/home/psychopatz/Zomboid/Workshop/DynamicTrading",
                          capture_output=True, text=True, timeout=120)
    return result.stdout

def parse_items_from_output(output):
    """Parse item info from verification output"""
    items = []
    current_item = None
    
    lines = output.split('\n')
    for line in lines:
        match = re.match(r'\[(\w+)\]\s+\(Origin:', line)
        if match:
            if current_item:
                items.append(current_item)
            current_item = {
                'id': match.group(1),
                'category': None,
                'hunger': 0,
                'weight': 0,
                'stats': {}
            }
        elif current_item and ':' in line and line.strip():
            parts = line.split('|')
            for part in parts:
                part = part.strip()
                if ':' in part:
                    key, val = part.split(':', 1)
                    key = key.strip()
                    val = val.strip()
                    
                    if key == 'Category':
                        current_item['category'] = val
                    elif key == 'Hunger':
                        try:
                            current_item['hunger'] = float(val.split('.')[0])
                        except:
                            pass
                    elif key == 'Weight':
                        try:
                            current_item['weight'] = float(val.split()[0])
                        except:
                            pass
                    
                    current_item['stats'][key] = val
    
    if current_item:
        items.append(current_item)
    
    return items

def suggest_price(item_id, item_data, category_type):
    """Suggest realistic PZ price based on item characteristics"""
    category = item_data.get('category', 'Misc')
    hunger = abs(item_data.get('hunger', 0))
    
    # Food pricing logic
    if category == 'Food':
        if hunger <= 3:  # Bait, seeds
            return (2, 5)
        elif hunger <= 8:  # Basic staples
            return (8, 15)
        elif hunger <= 15:  # Significant meals
            return (20, 35)
        else:  # Luxury
            return (45, 80)
    
    # Medical
    elif category in ['FirstAid', 'Medical']:
        if 'Bandage' in item_id:
            return (4, 10)
        elif 'Alcohol' in item_id or 'Wipe' in item_id:
            return (3, 8)
        else:
            return (15, 40)
    
    # Weapons/Explosives
    elif category in ['Weapon', 'Explosives', 'AnimalPartWeapon']:
        if 'Aerosol' in item_id:
            return (80, 150)
        elif 'Bone' in item_id:
            return (5, 15)
        else:
            return (25, 80)
    
    # Clothing/Armor
    elif category in ['Clothing', 'Armor']:
        return (10, 40)
    
    # Containers
    elif category == 'Bag':
        return (15, 50)
    
    # Electronics
    elif category == 'Electronics':
        return (15, 50)
    
    # Tools
    elif category in ['Tool', 'WeaponPart']:
        return (10, 40)
    
    # Materials
    elif category == 'Material':
        return (2, 8)
    
    # Generic animal parts
    elif 'Animal' in category:
        return (5, 20)
    
    # Default
    return (5, 15)

def display_review_batch(items, current_prices, start_idx=0, batch_size=15):
    """Display items for manual review"""
    print("\n" + "="*120)
    print(f"BATCH REVIEW: Items {start_idx+1}-{min(start_idx+batch_size, len(items))}")
    print("="*120)
    
    for i, item in enumerate(items[start_idx:start_idx+batch_size]):
        item_id = item['id']
        current_price = current_prices.get(item_id, '?')
        category = item.get('category', 'Unknown')
        hunger = item.get('hunger', 0)
        weight = item.get('weight', 0)
        
        min_suggest, max_suggest = suggest_price(item_id, item, category)
        
        print(f"\n[{start_idx + i + 1}] {item_id}")
        print(f"    Category: {category} | Current Price: ${current_price} | Hunger: {hunger}")
        print(f"    Weight: {weight} | Suggested Range: ${min_suggest}-${max_suggest}")
        print(f"    Stats: {', '.join([f'{k}:{v}' for k,v in list(item['stats'].items())[:3]])}")

def main():
    print("📊 Loading current prices...")
    current_prices = load_current_prices()
    print(f"✅ Loaded {len(current_prices)} current items\n")
    
    print("📥 Extracting AlreadyHas items (this may take a moment)...")
    output = extract_already_has(500)
    items = parse_items_from_output(output)
    print(f"✅ Parsed {len(items)} items from AlreadyHas\n")
    
    print("PRICE TIER REFERENCE:")
    print("-" * 120)
    for cat, tiers in list(PRICE_TIERS.items())[:5]:
        print(f"\n{cat}:")
        for tier, info in tiers.items():
            print(f"  {tier:15} ${info['range'][0]:3}-${info['range'][1]:3}  ({info['examples']})")
    
    # Sort by category for grouped review
    by_category = defaultdict(list)
    for item in items:
        by_category[item['category']].append(item)
    
    print(f"\n\n📋 Items by Category:")
    print("-" * 120)
    for cat in sorted(by_category.keys()):
        count = len(by_category[cat])
        print(f"  {cat:25} {count:4} items")
    
    print(f"\n\n🎯 RECOMMENDATION:")
    print("-" * 120)
    print("Review items by category. The script shows:")
    print("  - Current prices (which are too low)")
    print("  - Suggested realistic PZ prices")
    print("  - Item stats for decision making")
    print("\nNext step: Manually edit prices per category in Lua files, referencing PRICE_TIERS.")
    print("Focus on:")
    print("  - Food: Most items under-priced by 5-10x")
    print("  - Medical: Basic items $5-15, advanced $25-50")
    print("  - Weapons: $30-80 for common, $100+ for rare")
    print("="*120)

if __name__ == "__main__":
    main()
