#!/usr/bin/env python3
"""
Analyze all Project Zomboid item script files and extract unique properties
with their data types and usage examples.
"""
import re
import os
from collections import defaultdict
from pathlib import Path

VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/generated/items/"

def parse_item_file(filepath):
    """Parse a single item file and extract all properties with examples"""
    properties = defaultdict(lambda: {'type': set(), 'examples': [], 'count': 0})
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all item blocks
    item_blocks = re.finditer(r'item\s+(\w+)\s*\{([^}]+)\}', content, re.DOTALL)
    
    for match in item_blocks:
        item_name = match.group(1)
        item_content = match.group(2)
        
        # Parse each property line
        lines = item_content.split('\n')
        for line in lines:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            
            # Match property = value pattern
            prop_match = re.match(r'(\w+)\s*=\s*(.+?),?\s*$', line)
            if prop_match:
                prop_name = prop_match.group(1)
                prop_value = prop_match.group(2).rstrip(',').strip()
                
                # Determine type
                value_type = get_value_type(prop_value)
                
                properties[prop_name]['type'].add(value_type)
                properties[prop_name]['count'] += 1
                
                # Store example if we don't have many yet
                if len(properties[prop_name]['examples']) < 3:
                    properties[prop_name]['examples'].append({
                        'value': prop_value,
                        'item': item_name
                    })
    
    return properties

def get_value_type(value):
    """Determine the type of a property value"""
    # Check for boolean
    if value.lower() in ['true', 'false']:
        return 'Boolean'
    
    # Check for float
    if re.match(r'^-?\d+\.\d+$', value):
        return 'Float'
    
    # Check for integer
    if re.match(r'^-?\d+$', value):
        return 'Integer'
    
    # Check for string (quoted or unquoted)
    return 'String'

def merge_properties(all_props, file_props):
    """Merge properties from a file into the global collection"""
    for prop, data in file_props.items():
        all_props[prop]['type'].update(data['type'])
        all_props[prop]['count'] += data['count']
        all_props[prop]['examples'].extend(data['examples'][:2])
        # Keep only first 5 examples
        all_props[prop]['examples'] = all_props[prop]['examples'][:5]

def generate_documentation(properties):
    """Generate markdown documentation"""
    doc = """# Project Zomboid Item Script Parameters Reference

## Overview
This document catalogs all script parameters found in Project Zomboid's item definitions, extracted from vanilla game files in Build 42.

**Statistics:**
- Total unique properties: {total_props}
- Boolean flags: {bool_count}
- Numeric properties: {numeric_count}
- String properties: {string_count}

---

## Boolean Flags

Boolean flags control specific behaviors or attributes of items. They are set to either `true` or `false`.

| Property | Usage Count | Purpose | Example Item |
|----------|------------|---------|--------------|
"""
    
    total_props = len(properties)
    bool_count = sum(1 for p in properties.values() if 'Boolean' in p['type'])
    numeric_count = sum(1 for p in properties.values() if {'Float', 'Integer'} & p['type'])
    string_count = sum(1 for p in properties.values() if 'String' in p['type'])
    
    # Sort properties by count (most common first)
    sorted_props = sorted(properties.items(), key=lambda x: x[1]['count'], reverse=True)
    
    # Boolean flags section
    bool_props = [(name, data) for name, data in sorted_props if 'Boolean' in data['type']]
    for prop_name, data in bool_props:
        example = data['examples'][0] if data['examples'] else {'value': '-', 'item': '-'}
        purpose = infer_purpose(prop_name)
        doc += f"| `{prop_name}` | {data['count']} | {purpose} | {example['item']} |\n"
    
    doc += """\n\n## Numeric Properties

### Damage & Combat

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
"""
    
    # Group numeric properties by category
    combat_keywords = ['damage', 'hit', 'crit', 'attack', 'swing', 'range', 'knock', 'push', 'splat']
    condition_keywords = ['condition', 'durability', 'break', 'repair']
    stat_keywords = ['weight', 'capacity', 'reduceinfection', 'bandage', 'protection', 'insulation', 'waterproof', 'windresistance']
    
    numeric_props = [(name, data) for name, data in sorted_props if ({'Float', 'Integer'} & data['type']) and 'Boolean' not in data['type']]
    
    # Combat properties
    for prop_name, data in numeric_props:
        if any(kw in prop_name.lower() for kw in combat_keywords):
            types = '/'.join(sorted(data['type']))
            examples = ', '.join([ex['value'] for ex in data['examples'][:3]])
            desc = infer_purpose(prop_name)
            doc += f"| `{prop_name}` | {types} | {data['count']} | {desc} | {examples} |\n"
    
    doc += """
### Durability & Condition

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
"""
    
    for prop_name, data in numeric_props:
        if any(kw in prop_name.lower() for kw in condition_keywords):
            types = '/'.join(sorted(data['type']))
            examples = ', '.join([ex['value'] for ex in data['examples'][:3]])
            desc = infer_purpose(prop_name)
            doc += f"| `{prop_name}` | {types} | {data['count']} | {desc} | {examples} |\n"
    
    doc += """
### Item Stats & Effects

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
"""
    
    for prop_name, data in numeric_props:
        if any(kw in prop_name.lower() for kw in stat_keywords):
            types = '/'.join(sorted(data['type']))
            examples = ', '.join([ex['value'] for ex in data['examples'][:3]])
            desc = infer_purpose(prop_name)
            doc += f"| `{prop_name}` | {types} | {data['count']} | {desc} | {examples} |\n"
    
    doc += """
### Other Numeric Properties

| Property | Type | Usage Count | Example Values |
|----------|------|------------|----------------|
"""
    
    covered_keywords = combat_keywords + condition_keywords + stat_keywords
    for prop_name, data in numeric_props:
        if not any(kw in prop_name.lower() for kw in covered_keywords):
            types = '/'.join(sorted(data['type']))
            examples = ', '.join([ex['value'] for ex in data['examples'][:3]])
            doc += f"| `{prop_name}` | {types} | {data['count']} | {examples} |\n"
    
    doc += """\n\n## String Properties

### Visual & Audio

| Property | Usage Count | Description | Example Values |
|----------|------------|-------------|----------------|
"""
    
    visual_keywords = ['icon', 'sprite', 'anim', 'sound', 'texture', 'model', 'color']
    category_keywords = ['category', 'type', 'tags']
    
    string_props = [(name, data) for name, data in sorted_props if 'String' in data['type'] and 'Boolean' not in data['type']]
    
    for prop_name, data in string_props:
        if any(kw in prop_name.lower() for kw in visual_keywords):
            examples = ', '.join([f"`{ex['value'][:30]}`" for ex in data['examples'][:2]])
            desc = infer_purpose(prop_name)
            doc += f"| `{prop_name}` | {data['count']} | {desc} | {examples} |\n"
    
    doc += """
### Categories & Classification

| Property | Usage Count | Description | Example Values |
|----------|------------|-------------|----------------|
"""
    
    for prop_name, data in string_props:
        if any(kw in prop_name.lower() for kw in category_keywords):
            examples = ', '.join([f"`{ex['value'][:30]}`" for ex in data['examples'][:2]])
            desc = infer_purpose(prop_name)
            doc += f"| `{prop_name}` | {data['count']} | {desc} | {examples} |\n"
    
    doc += """
### Other String Properties

| Property | Usage Count | Example Values |
|----------|------------|----------------|
"""
    
    covered_keywords = visual_keywords + category_keywords
    for prop_name, data in string_props:
        if not any(kw in prop_name.lower() for kw in covered_keywords):
            examples = ', '.join([f"`{ex['value'][:30]}`" for ex in data['examples'][:2]])
            doc += f"| `{prop_name}` | {data['count']} | {examples} |\n"
    
    # Add rarity determination section
    doc += """
---

## Determining Item Rarity

### Recommended Approach

Item rarity can be determined using a multi-factor analysis:

1. **Spawn Frequency** (Primary Factor)
   - Parse `ProceduralDistributions.lua` to get spawn weights
   - Lower spawn weight = Higher rarity

2. **Static Properties** (Secondary Factors)
   - `Weight`: Extremely light or heavy items often rare
   - `ConditionMax`: Higher durability may indicate rarity
   - `MaxDamage`: Higher damage output for weapons
   - `DisplayCategory`: Certain categories like SurvivalGear are rarer

3. **Tags Analysis**
   - Items with `base:military`, `base:police` tags tend to be rare
   - `base:tactical`, `base:survivalgear` indicate higher tier

4. **Boolean Indicators**
   - `MultiStage`: Complex craftable items
   - `TwoHandWeapon`: Often indicates powerful weapons
   - `RequiresEquippedBothHands`: Heavy/powerful items

### Suggested Rarity Tiers

- **Common**: High spawn weight (>5), basic functionality, low stats
- **Uncommon**: Medium spawn weight (2-5), moderate stats, specialized categories
- **Rare**: Low spawn weight (0.5-2), high stats, military/police tags
- **Legendary**: Very low spawn weight (<0.5), exceptional stats, unique properties

"""
    
    return doc.format(
        total_props=total_props,
        bool_count=bool_count,
        numeric_count=numeric_count,
        string_count=string_count
    )

def infer_purpose(prop_name):
    """Infer the purpose of a property from its name"""
    purposes = {
        'DamageMakeHole': 'Can penetrate and create holes',
        'SplatBloodOnNoDeath': 'Splatter blood even if enemy survives',
        'KnockBackOnNoDeath': 'Knockback effect on surviving enemies',
        'TwoHandWeapon': 'Requires both hands to wield',
        'MultiStage': 'Item has multiple construction stages',
        'CanBandage': 'Can be used to bandage wounds',
        'ReduceInfection': 'Reduces infection chance',
        'Sterile': 'Sterile medical item (bonus effect)',
        'CanBeRemote': 'Can be triggered remotely',
        'IsWaterSource': 'Can be used as water source',
        'KeepOnDeplete': 'Item remains after use',
        'ReplaceOnDeplete': 'Transforms into another item when depleted',
        'IsCookable': 'Can be cooked',
        'DangerousUncooked': 'Harmful if eaten raw',
        'Alcoholic': 'Contains alcohol',
        'Poison': 'Poisonous item',
    }
    
    return purposes.get(prop_name, f"Controls {prop_name.lower().replace('_', ' ')}")

def analyze_procedural_distributions():
    """Analyze ProceduralDistributions.lua for spawn data"""
    # This would parse ProceduralDistributions.lua to extract spawn chances
    # For now, return placeholder
    return {}

def main():
    print("🔍 Analyzing Project Zomboid item scripts...")
    
    all_properties = defaultdict(lambda: {'type': set(), 'examples': [], 'count': 0})
    
    # Process all item files
    item_files = Path(VANILLA_DIR).glob("*.txt")
    for item_file in item_files:
        print(f"   Processing {item_file.name}...")
        file_props = parse_item_file(item_file)
        merge_properties(all_properties, file_props)
    
    print(f"\n✅ Found {len(all_properties)} unique properties")
    
    # Generate documentation
    print("\n📝 Generating documentation...")
    doc = generate_documentation(all_properties)
    
    # Write to file
    output_path = Path(__file__).parent.parent / "Docs" / "Item_Script_Parameters.md"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(doc)
    
    print(f"\n✅ Documentation written to {output_path}")
    print(f"   Total properties documented: {len(all_properties)}")

if __name__ == '__main__':
    main()
