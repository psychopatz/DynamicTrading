# ItemGenerator - Property & Spawn Analysis Integration

**Status**: ✅ Complete  
**Version**: 1.0  
**Date**: 2025

## Overview

The ItemGenerator now includes comprehensive property and spawn rate analysis capabilities. This allows you to query items by their properties, analyze spawn weights from ProceduralDistributions.lua, and generate documentation about all 372+ item properties found in vanilla Project Zomboid B42.

## What Was Integrated

### New Modules Added

1. **`Utils/property_analyzer.py`**
   - Extract and analyze all properties from vanilla item scripts
   - Query items by specific property values
   - Export property data in multiple formats
   - Generate comprehensive property documentation

2. **`Utils/spawn_analyzer.py`**
   - Parse ProceduralDistributions.lua for spawn weights
   - Calculate rarity tiers based on spawn frequency
   - Analyze 3,984 items with spawn data
   - Generate rarity statistics and documentation

### Updated Files

- **`Utils/__init__.py`**: Added exports for new analyzer functions
- **`Utils/config.py`**: Added `VANILLA_SCRIPTS_DIR` constant
- **`main.py`**: Added 8 new CLI commands for property/spawn analysis

## New CLI Commands

### Property Analysis Commands

#### 1. Find Items by Property

Find all items that have a specific property, with optional value filtering.

```bash
# Find all items with property
python main.py --find-property StressChange

# Find items with specific value
python main.py --find-property StressChange "-10"
```

**Example Output**:
```
🔍 Searching for items with property: StressChange
✅ Found 273 items:

  StressChange = -10:
    - Catalog
    - Cigar
    - TobaccoChewing

  StressChange = -40:
    - Book
    - BookFancy_Bible
    - Book_AdventureNonFiction
    ... and 95 more

📊 Total: 273 items with 'StressChange'
```

#### 2. List All Properties

List all properties with usage counts, filtered by minimum usage.

```bash
# List all properties used by at least 100 items
python main.py --list-properties 100

# List all properties (no filter)
python main.py --list-properties 1
```

**Example Output**:
```
📋 Listing all item properties (min usage: 100)...

Boolean Properties (15):
  CanHaveHoles                   - used by  576 items
  KnockBackOnNoDeath             - used by  356 items
  IsCookable                     - used by  261 items

String Properties (56):
  ItemType                       - used by 5098 items
  DisplayCategory                - used by 5098 items
  Icon                           - used by 4676 items

📊 Total: 71 unique properties
```

#### 3. Dump Property Data

Export all items with a specific property in various formats.

```bash
# Export as formatted table (console output)
python main.py --dump-property StressChange table

# Export as CSV file
python main.py --dump-property StressChange csv

# Export as JSON dictionary
python main.py --dump-property StressChange dict
```

#### 4. Generate Property Documentation

Create comprehensive markdown documentation of all 372 properties.

```bash
python main.py --analyze-properties
```

**Generates**: `Docs/Item_Script_Parameters.md` (28KB, 468 lines)
- Boolean flags (80 properties)
- Numeric properties (158 properties)
- String properties (134 properties)
- Usage counts and examples for each

### Spawn Analysis Commands

#### 5. Show Rarity Statistics

Display distribution of items across rarity tiers based on spawn weights.

```bash
python main.py --rarity-stats
```

**Example Output**:
```
📊 Spawn Rarity Statistics

 Total items analyzed: 3984

 Rarity Distribution:
   Ultra Rare:  135 items (  3.4%)
   Legendary:   245 items (  6.1%)
   Rare:        706 items ( 17.7%)
   Uncommon:   1077 items ( 27.0%)
   Common:     1821 items ( 45.7%)
```

#### 6. Find Items by Rarity

List items of a specific rarity tier.

```bash
python main.py --find-rarity UltraRare
python main.py --find-rarity Legendary
python main.py --find-rarity Rare
python main.py --find-rarity Uncommon
python main.py --find-rarity Common
```

**Example Output**:
```
🔍 Finding UltraRare items...

✅ Found 135 UltraRare items:

  Antibiotics                              weight:  0.001  locations:   4
  PillsVitamins                            weight:  0.010  locations:   8
  FirstAidKit                              weight:  0.050  locations:  12

📊 Total: 135 UltraRare items shown
```

#### 7. Generate Spawn Documentation

Create markdown documentation of spawn rates analysis.

```bash
python main.py --analyze-spawns
```

**Generates**: `Docs/Item_Spawn_Rates.md` (8.3KB)
- Rarity distribution table
- Top 20 items for each rarity tier
- Spawn weights and location counts

## Usage Examples

### Query Items with Specific Property

```bash
# Find all items that reduce stress
python main.py --find-property StressChange

# Find only items that reduce stress by exactly 10
python main.py --find-property StressChange "-10"

# Find all alcoholic items
python main.py --find-property Alcoholic "true"

# Find all two-handed weapons
python main.py --find-property TwoHandWeapon "true"

# Find items with specific damage
python main.py --find-property MaxDamage "2.5"
```

### Analyze Properties

```bash
# List commonly used properties (100+ items)
python main.py --list-properties 100

# List all properties regardless of usage
python main.py --list-properties 1

# Export property data for external analysis
python main.py --dump-property Weight csv
python main.py --dump-property MaxDamage json
```

### Rarity Analysis

```bash
# Check rarity distribution
python main.py --rarity-stats

# Find ultra-rare items for trader pricing
python main.py --find-rarity UltraRare

# Find common items (>50% spawn weight)
python main.py --find-rarity Common
```

### Generate Documentation

```bash
# Create complete property reference
python main.py --analyze-properties

# Create spawn rate analysis
python main.py --analyze-spawns
```

## Integration with ItemGenerator

### Using Property Data in Tagging

The property analyzer can be used to improve automatic tagging:

```python
from Utils import find_items_with_property

# Find all items with stress reduction for "Relaxant" tag
stress_items = find_items_with_property(VANILLA_SCRIPTS_DIR, "StressChange", "-")

# Find all military items for special pricing
military_items = find_items_with_property(VANILLA_SCRIPTS_DIR, "Tags", "Military")
```

### Using Spawn Data for Rarity-Based Pricing

The spawn analyzer enables rarity-based pricing:

```python
from Utils import get_spawn_weight, calculate_rarity_from_spawn

item_id = "Antibiotics"
spawn_weight = get_spawn_weight(item_id)  # Returns: 0.001
rarity_tier = calculate_rarity_from_spawn(spawn_weight)  # Returns: "UltraRare"

# Use rarity tier to adjust pricing
if rarity_tier == "UltraRare":
    price_multiplier = 5.0
elif rarity_tier == "Legendary":
    price_multiplier = 3.0
# ... etc
```

### Enhanced Rarity Scoring

The spawn analyzer provides a comprehensive rarity calculation:

```python
from Utils import calculate_enhanced_rarity_score

# Calculate multi-factor rarity score
score, tier, breakdown = calculate_enhanced_rarity_score(item_id, item_props)

# breakdown contains:
# - spawn_score: 0-100 based on spawn weight (60% weight)
# - stat_score: 0-100 based on combat/utility stats (20% weight)
# - durability_score: 0-100 based on ConditionMax (10% weight)
# - tag_score: 0-100 based on special tags (10% weight)
# - bonus: Additional points for special flags
# - final_score: Weighted total (0-100)
# - tier: UltraRare/Legendary/Rare/Uncommon/Common
```

## Property Statistics

### Total Properties Analyzed: 372

- **Boolean Flags**: 80 properties
  - Examples: `TwoHandWeapon`, `IsCookable`, `Cosmetic`
- **Numeric Properties**: 158 properties
  - Examples: `Weight`, `MaxDamage`, `StressChange`
- **String Properties**: 134 properties
  - Examples: `DisplayCategory`, `Tags`, `Icon`

### Most Common Properties

| Property | Usage | Type |
|----------|-------|------|
| ItemType | 5,098 items | String |
| DisplayCategory | 5,098 items | String |
| Icon | 4,676 items | String |
| WorldStaticModel | 3,845 items | String |
| Tags | 3,492 items | String |
| Weight | 3,289 items | Numeric |

## Spawn Rate Statistics

### Total Items with Spawn Data: 3,984

| Rarity Tier | Count | Percentage | Spawn Weight Range |
|-------------|-------|------------|-------------------|
| Ultra Rare | 135 | 3.4% | < 0.1 |
| Legendary | 245 | 6.1% | 0.1 - 0.5 |
| Rare | 706 | 17.7% | 0.5 - 2.0 |
| Uncommon | 1,077 | 27.0% | 2.0 - 5.0 |
| Common | 1,821 | 45.7% | ≥ 5.0 |

## Technical Details

### File Locations

- **Property Analyzer**: `Scripts/ItemGenerator/Utils/property_analyzer.py`
- **Spawn Analyzer**: `Scripts/ItemGenerator/Utils/spawn_analyzer.py`
- **Vanilla Scripts**: `/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/generated/items/`
- **ProceduralDistributions**: `/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/lua/server/Items/ProceduralDistributions.lua`

### Performance

- Property analysis: ~2-3 seconds for all 15 item files
- Spawn analysis: ~1-2 seconds to parse ProceduralDistributions.lua
- Property queries: Instant (< 100ms) with caching

### Caching

Spawn data is automatically cached after first load:
- Cache persists for the Python session
- Force reload: `load_spawn_data(force_reload=True)`

## Future Enhancements

### Planned Features

1. **Multi-Property Queries**
   - Query items matching multiple criteria
   - Example: Items with both `StressChange < 0` AND `Weight < 1.0`

2. **Property Correlation Analysis**
   - Find common property combinations
   - Example: "Items with X usually also have Y"

3. **Rarity-Based Auto-Tagging**
   - Automatically tag items based on rarity tier
   - Example: Add "Rare" tag to items with spawn weight < 0.5

4. **Interactive Property Browser**
   - TUI interface for exploring properties
   - Filter, sort, and export capabilities

## Troubleshooting

### Command Not Found

If you get "Invalid mode" error:
```bash
# Make sure to use -- prefix for analysis commands
python main.py --find-property StressChange  # ✅ Correct
python main.py find-property StressChange    # ❌ Wrong
```

### ProceduralDistributions.lua Not Found

If spawn analysis fails:
1. Check Steam installation path
2. Update path in `spawn_analyzer.py` line 59-64
3. Or specify path manually: `get_spawn_weight(item_id, "/path/to/ProceduralDistributions.lua")`

### Property Not Found

If a property returns no results:
1. Check property name spelling (case-sensitive)
2. List all properties: `python main.py --list-properties 1`
3. Property may not exist in vanilla items

## Quick Reference

```bash
# PROPERTY QUERIES
python main.py --find-property <name> [value]
python main.py --list-properties [min_usage]
python main.py --dump-property <name> [format]

# SPAWN ANALYSIS
python main.py --find-rarity <tier>
python main.py --rarity-stats

# DOCUMENTATION
python main.py --analyze-properties
python main.py --analyze-spawns

# ORIGINAL MODES (still available)
python main.py                    # Interactive menu
python main.py update             # Update prices
python main.py add 100            # Add 100 items
python main.py add --all          # Add all items
```

## Summary

The ItemGenerator now provides powerful property and spawn analysis capabilities:

✅ **Query 273 items** with `StressChange` property  
✅ **Analyze 372 properties** across 5,085 vanilla items  
✅ **Analyze 3,984 items** with spawn rate data  
✅ **Calculate rarity tiers** based on multi-factor scoring  
✅ **Generate documentation** for properties and spawn rates  
✅ **Export data** in CSV, JSON, and table formats  
✅ **Integrated** seamlessly with existing ItemGenerator CLI  

This integration enables sophisticated item analysis, better automatic tagging, and data-driven pricing strategies for the DynamicTrading mod.
