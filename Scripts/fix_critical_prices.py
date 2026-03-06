#!/usr/bin/env python3
"""
MANUAL PRICE REVIEW AND ADJUSTMENT
Fixes obvious mistakes and allows human review of remaining items
"""
import re
from pathlib import Path

ITEMS_DIR = Path("/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")

# CRITICAL FIXES: Items that are wildly off
CRITICAL_FIXES = {
    # Ammo should be $0.50-1 per round, NOT $60
    'Bullets': 0.50,
    'Shells': 0.50,
    'Arrows': 1,
    'Bolts': 1,
    
    # Batteries should be $2-3, not $60
    'Battery': 2,
    
    # Health items need reality check
    'Bandaid': 2,
    'Gauze': 3,
    'Splint': 5,
    
    # Skill books are premium
    'Book': 25,  # Regular books
    'SkillBook': 50,  # Skill books
    'Magazine': 8,
    
    # Alcohol costs
    'Whiskey': 30,
    'Wine': 20,
    'Beer': 12,
    'Vodka': 30,
}

def apply_critical_fixes():
    """Apply critical price fixes to obviously wrong items"""
    total_fixed = 0
    
    for lua_file in sorted(ITEMS_DIR.rglob("*.lua")):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        with open(lua_file, 'r') as f:
            content = f.read()
        
        original = content
        fixed_items = []
        
        # For each critical pattern, find and fix prices
        for pattern, correct_price in CRITICAL_FIXES.items():
            # Find all items with this pattern
            item_pattern = f'item="Base.([^"]*{pattern}[^"]*)"'
            price_pattern = f'{item_pattern},\\s*basePrice=\\d+,'
            
            def replacer(match):
                item_name = match.group(1)
                old_match = match.group(0)
                # Also capture the old price to show what changed
                old_price_match = re.search(r'basePrice=(\d+)', old_match)
                if old_price_match:
                    old_price = int(old_price_match.group(1))
                    if old_price != correct_price:
                        fixed_items.append((item_name, old_price, correct_price))
                
                return re.sub(r'basePrice=\d+', f'basePrice={correct_price}', old_match)
            
            content = re.sub(price_pattern, replacer, content)
        
        if content != original:
            with open(lua_file, 'w') as f:
                f.write(content)
            
            if fixed_items:
                print(f"📝 {lua_file.relative_to(ITEMS_DIR)}")
                for item, old, new in fixed_items[:5]:
                    print(f"   🔧 {item}: ${old} → ${new}")
                if len(fixed_items) > 5:
                    print(f"   ... and {len(fixed_items)-5} more")
                total_fixed += len(fixed_items)
    
    return total_fixed

def analyze_prices_for_review():
    """Analyze all prices and suggest categories needing review"""
    print("\n📋 PRICING ANALYSIS FOR MANUAL REVIEW\n")
    print("="*100)
    
    categories = {}
    
    for lua_file in sorted(ITEMS_DIR.rglob("*.lua")):
        if lua_file.name == "DT_Fluids.lua":
            continue
        
        rel_path = str(lua_file.relative_to(ITEMS_DIR))
        
        with open(lua_file, 'r') as f:
            content = f.read()
        
        prices = []
        for match in re.finditer(r'basePrice=(\d+)', content):
            prices.append(int(match.group(1)))
        
        if prices:
            categories[rel_path] = {
                'count': len(prices),
                'min': min(prices),
                'max': max(prices),
                'avg': sum(prices) / len(prices),
            }
    
    print("\nCATEGORY PRICING OVERVIEW:")
    print("-"*100)
    for cat in sorted(categories.keys()):
        info = categories[cat]
        print(f"{cat:50} Count:{info['count']:3} Min:${info['min']:3} Max:${info['max']:3} Avg:${info['avg']:6.1f}")
    
    print("\n" + "="*100)
    print("\n⚠️  RECOMMENDED MANUAL REVIEW ITEMS:")
    print("-"*100)
    print("1. Ammo files: Prices should be $0.50-1 per round, much lower than current")
    print("2. Tool files: Basic tools $10-20, specialized tools $25-40")
    print("3. Medical files: Basic items $3-10, advanced items $15-40")
    print("4. Skill books: Should be $40-60+ (knowledge premium)")
    print("5. Weapons: Range should be $30-150 depending on rarity/power")
    print("\nNext step: Review each file and manually adjust outliers")

def main():
    print("🔧 APPLYING CRITICAL PRICE FIXES\n")
    print("="*100 + "\n")
    
    fixed = apply_critical_fixes()
    
    print(f"\n✅ {fixed} items fixed with critical adjustments\n")
    
    analyze_prices_for_review()

if __name__ == "__main__":
    main()
