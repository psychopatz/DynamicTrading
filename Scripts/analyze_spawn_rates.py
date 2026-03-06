#!/usr/bin/env python3
"""
Parse ProceduralDistributions.lua to extract spawn chance data for items.
This helps determine item rarity based on spawn frequency.
"""
import re
from collections import defaultdict
from pathlib import Path

PROC_DIST_FILE = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/lua/server/Items/ProceduralDistributions.lua"

def parse_procedural_distributions():
    """Parse the ProceduralDistributions.lua file"""
    
    with open(PROC_DIST_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Store spawn data: {item_name: [(location, spawn_weight), ...]}
    spawn_data = defaultdict(list)
    
    # Find all distribution lists
    # Pattern: location = { items = { "ItemName", Weight, "ItemName2", Weight2, ... } }
    distribution_blocks = re.findall(
        r'(\w+)\s*=\s*\{[^}]*items\s*=\s*\{([^}]+)\}',
        content,
        re.DOTALL
    )
    
    for location, items_str in distribution_blocks:
        # Parse items and weights
        # Split by comma and process pairs
        items_list = [x.strip() for x in items_str.split(',')]
        
        i = 0
        while i < len(items_list) - 1:
            item_entry = items_list[i]
            
            # Check if this is an item name (quoted string)
            if '"' in item_entry or "'" in item_entry:
                item_name = item_entry.strip('"\'')
                
                # Next should be weight
                try:
                    weight_str = items_list[i + 1].strip()
                    weight = float(weight_str)
                    
                    # Handle Base. prefix
                    if item_name.startswith('Base.'):
                        item_name = item_name.split('.', 1)[1]
                    
                    spawn_data[item_name].append((location, weight))
                    i += 2
                except (ValueError, IndexError):
                    i += 1
            else:
                i += 1
    
    return spawn_data

def calculate_rarity_stats(spawn_data):
    """Calculate statistics about item spawn rates"""
    
    stats = {
        'total_items': len(spawn_data),
        'rarity_distribution': {
            'ultra_rare': 0,    # < 0.1
            'legendary': 0,     # 0.1 - 0.5
            'rare': 0,          # 0.5 - 2.0
            'uncommon': 0,      # 2.0 - 5.0
            'common': 0,        # > 5.0
        }
    }
    
    for item, spawns in spawn_data.items():
        if not spawns:
            continue
        
        # Calculate average spawn weight across all locations
        avg_weight = sum(w for _, w in spawns)  / len(spawns)
        
        if avg_weight < 0.1:
            stats['rarity_distribution']['ultra_rare'] += 1
        elif avg_weight < 0.5:
            stats['rarity_distribution']['legendary'] += 1
        elif avg_weight < 2.0:
            stats['rarity_distribution']['rare'] += 1
        elif avg_weight < 5.0:
            stats['rarity_distribution']['uncommon'] += 1
        else:
            stats['rarity_distribution']['common'] += 1
    
    return stats

def generate_spawn_documentation(spawn_data):
    """Generate markdown documentation for spawn rates"""
    
    doc = """# Project Zomboid Spawn Rate Analysis

## Overview
This document provides spawn rate data extracted from `ProceduralDistributions.lua` to help determine item rarity.

**Total Items with Spawn Data:** {total_items}

## Spawn Weight Distribution

| Rarity Tier | Spawn Weight Range | Item Count | Percentage |
|-------------|-------------------|------------|------------|
| Ultra Rare  | < 0.1             | {ultra_rare} | {ultra_rare_pct:.1f}% |
| Legendary   | 0.1 - 0.5         | {legendary} | {legendary_pct:.1f}% |
| Rare        | 0.5 - 2.0         | {rare} | {rare_pct:.1f}% |
| Uncommon    | 2.0 - 5.0         | {uncommon} | {uncommon_pct:.1f}% |
| Common      | > 5.0             | {common} | {common_pct:.1f}% |

---

## Rarest Items (Ultra Rare)

Items with average spawn weight < 0.1:

| Item | Avg Weight | Spawn Locations | Details |
|------|------------|-----------------|---------|
"""
    
    stats = calculate_rarity_stats(spawn_data)
    
    # Sort items by average spawn weight
    sorted_items = []
    for item, spawns in spawn_data.items():
        if spawns:
            avg_weight = sum(w for _, w in spawns) / len(spawns)
            sorted_items.append((item, avg_weight, spawns))
    
    sorted_items.sort(key=lambda x: x[1])
    
    # Ultra rare items
    ultra_rare_items = [(item, weight, spawns) for item, weight, spawns in sorted_items if weight < 0.1]
    for item, avg_weight, spawns in ultra_rare_items[:30]:  # Top 30
        locations = ', '.join([loc for loc, _ in spawns[:3]])
        if len(spawns) > 3:
            locations += f' (+{len(spawns)-3} more)'
        weights = ', '.join([f"{w:.2f}" for _, w in spawns[:3]])
        doc += f"| `{item}` | {avg_weight:.3f} | {len(spawns)} | {locations} |\n"
    
    doc += """\n\n## Legendary Items

Items with average spawn weight 0.1 - 0.5:

| Item | Avg Weight | Spawn Locations | Sample Weights |
|------|------------|-----------------|----------------|
"""
    
    legendary_items = [(item, weight, spawns) for item, weight, spawns in sorted_items if 0.1 <= weight < 0.5]
    for item, avg_weight, spawns in legendary_items[:30]:  # Top 30
        locations = len(spawns)
        weights = ', '.join([f"{w:.2f}" for _, w in spawns[:3]])
        doc += f"| `{item}` | {avg_weight:.3f} | {locations} | {weights} |\n"
    
    doc += """\n\n## Common Items

Items with highest spawn weights (> 10):

| Item | Avg Weight | Spawn Locations |
|------|------------|-----------------|
"""
    
    common_items = [(item, weight, spawns) for item, weight, spawns in sorted_items if weight > 10]
    common_items.sort(key=lambda x: x[1], reverse=True)  # Sort by weight descending
    
    for item, avg_weight, spawns in common_items[:30]:  # Top 30
        locations = len(spawns)
        doc += f"| `{item}` | {avg_weight:.2f} | {locations} |\n"
    
    doc += """\n\n## Usage Guide

### Integrating Spawn Data with Item Properties

To determine comprehensive rarity, combine spawn weight with item properties:

1. **Calculate Weighted Rarity Score**
   ```python
   def calculate_rarity_score(item):
       # Get spawn weight (lower = rarer)
       spawn_weight = get_spawn_weight(item)
       spawn_score = max(0, 100 - spawn_weight * 10)
       
       # Get property scores
       damage_score = item.MaxDamage * 50 if hasattr(item, 'MaxDamage') else 0
       durability_score = item.ConditionMax * 2
       
       # Check special tags
       tag_score = 0
       if 'military' in item.tags: tag_score += 30
       if 'police' in item.tags: tag_score += 20
       if 'tactical' in item.tags: tag_score += 25
       
       # Calculate final score (0-100 scale)
       final_score = (spawn_score * 0.6 + damage_score * 0.2 + 
                     durability_score * 0.1 + tag_score * 0.1)
       
       return min(100, final_score)
   ```

2. **Rarity Tier Assignment**
   - **Ultra Rare** (90-100): Spawn weight < 0.1, high stats, special tags
   - **Legendary** (75-89): Spawn weight 0.1-0.5, exceptional stats
   - **Rare** (60-74): Spawn weight 0.5-2.0, good stats
   - **Uncommon** (40-59): Spawn weight 2.0-5.0, moderate stats
   - **Common** (0-39): Spawn weight > 5.0, basic stats

### Example Calculations

**Military Rifle (e.g., AssaultRifle)**
- Spawn weight: 0.15 → spawn_score = 98.5
- MaxDamage: 1.8 → damage_score = 90
- ConditionMax: 10 → durability_score = 20
- Tags: military → tag_score = 30
- **Final Score: 88.5 (Legendary)**

**Kitchen Knife**
- Spawn weight: 8.0 → spawn_score = 20
- MaxDamage: 0.5 → damage_score = 25
- ConditionMax: 5 → durability_score = 10
- Tags: none → tag_score = 0
- **Final Score: 18.0 (Common)**

---

## Data Source
- File: `media/lua/server/Items/ProceduralDistributions.lua`
- Build: 42
- Last Updated: Generated from game installation
"""
    
    total = stats['total_items']
    
    return doc.format(
        total_items=total,
        ultra_rare=stats['rarity_distribution']['ultra_rare'],
        ultra_rare_pct=stats['rarity_distribution']['ultra_rare'] / total * 100 if total > 0 else 0,
        legendary=stats['rarity_distribution']['legendary'],
        legendary_pct=stats['rarity_distribution']['legendary'] / total * 100 if total > 0 else 0,
        rare=stats['rarity_distribution']['rare'],
        rare_pct=stats['rarity_distribution']['rare'] / total * 100 if total > 0 else 0,
        uncommon=stats['rarity_distribution']['uncommon'],
        uncommon_pct=stats['rarity_distribution']['uncommon'] / total * 100 if total > 0 else 0,
        common=stats['rarity_distribution']['common'],
        common_pct=stats['rarity_distribution']['common'] / total * 100 if total > 0 else 0,
    )

def main():
    print("🔍 Parsing ProceduralDistributions.lua...")
    
    spawn_data = parse_procedural_distributions()
    
    print(f"✅ Found spawn data for {len(spawn_data)} items")
    
    print("\n📝 Generating spawn documentation...")
    doc = generate_spawn_documentation(spawn_data)
    
    # Write to file
    output_path = Path(__file__).parent.parent / "Docs" / "Item_Spawn_Rates.md"
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    
    print(f"\n✅ Documentation written to {output_path}")
    
    # Calculate stats
    stats = calculate_rarity_stats(spawn_data)
    print(f"\n📊 Rarity Distribution:")
    for tier, count in stats['rarity_distribution'].items():
        pct = count / stats['total_items'] * 100 if stats['total_items'] > 0 else 0
        print(f"   {tier.replace('_', ' ').title():12} {count:5} items ({pct:5.1f}%)")

if __name__ == '__main__':
    main()
