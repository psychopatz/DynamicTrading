# Project Zomboid Item Analysis Documentation

This directory contains comprehensive documentation for analyzing and categorizing Project Zomboid items.

## Documentation Files

### 📋 [Item_Script_Parameters.md](Item_Script_Parameters.md)
**Complete reference of all item script parameters** (372 properties)

Contains:
- **80 Boolean Flags**: All true/false properties (e.g., `TwoHandWeapon`, `DamageMakeHole`, `Sterile`)
- **158 Numeric Properties**: Damage, durability, weight, combat stats
- **134 String Properties**: Icons, sprites, sounds, categories, tags

Organized into sections:
- Boolean Flags (by usage frequency)
- Numeric Properties (grouped by purpose: Combat, Durability, Stats)
- String Properties (Visual/Audio, Categories, Other)

**Use this to**: Understand what properties are available for rarity detection and tagging

---

### 📊 [Item_Spawn_Rates.md](Item_Spawn_Rates.md)
**Spawn rate analysis from ProceduralDistributions.lua** (3,984 items)

Rarity Distribution:
- **Ultra Rare** (3.4%): 135 items with spawn weight < 0.1
- **Legendary** (6.1%): 245 items with spawn weight 0.1-0.5
- **Rare** (17.7%): 706 items with spawn weight 0.5-2.0
- **Uncommon** (27.0%): 1,077 items with spawn weight 2.0-5.0
- **Common** (45.7%): 1,821 items with spawn weight > 5.0

Includes:
- Lists of rarest and most common items
- Example spawn weights and locations
- Python code for calculating weighted rarity scores

**Use this to**: Determine base rarity from spawn frequency

---

## Automated Rarity Detection Approach

### Multi-Factor Rarity Analysis

Combine multiple data sources for accurate rarity determination:

#### 1. **Spawn Frequency** (Primary - 60% weight)
```python
spawn_weight = get_spawn_weight_from_procedural_distributions(item_name)
spawn_score = max(0, 100 - spawn_weight * 10)  # Lower spawn = higher score
```

#### 2. **Combat/Utility Stats** (Secondary - 20% weight)
```python
# For weapons
damage_score = item.MaxDamage * 50

# For armor
protection_score = (item.BloodDefense + item.BitDefense) * 10

# For tools
utility_score = item.ConditionMax * 5
```

#### 3. **Durability** (10% weight)
```python
durability_score = item.ConditionMax * 2
```

#### 4. **Tags & Categories** (10% weight)
```python
tag_score = 0
if 'base:military' in item.Tags: tag_score += 30
if 'base:police' in item.Tags: tag_score += 20
if 'base:tactical' in item.Tags: tag_score += 25
if 'base:survivalgear' in item.Tags: tag_score += 15

if item.DisplayCategory == 'SurvivalGear': tag_score += 20
```

#### 5. **Boolean Indicators**
```python
if item.TwoHandWeapon: bonus += 10
if item.RequiresEquippedBothHands: bonus += 15
if item.IsHighTier: bonus += 20
if item.Sterile: bonus += 10  # For medical items
```

### Complete Rarity Calculation

```python
def calculate_comprehensive_rarity(item):
    """
    Calculate item rarity score (0-100) using multiple factors
    
    Returns rarity tier:
    - 90-100: Ultra Rare
    - 75-89:  Legendary  
    - 60-74:  Rare
    - 40-59:  Uncommon
    - 0-39:   Common
    """
    # 1. Spawn frequency (60%)
    spawn_weight = get_spawn_weight(item.name)
    spawn_score = max(0, 100 - spawn_weight * 10)
    
    # 2. Combat/utility stats (20%)
    stat_score = 0
    if hasattr(item, 'MaxDamage'):
        stat_score = item.MaxDamage * 50
    elif hasattr(item, 'BloodDefense'):
        stat_score = (item.BloodDefense + item.BitDefense) * 10
    elif hasattr(item, 'ConditionMax'):
        stat_score = item.ConditionMax * 5
    
    # 3. Durability (10%)
    durability_score = getattr(item, 'ConditionMax', 0) * 2
    
    # 4. Tags & categories (10%)
    tag_score = 0
    tags = getattr(item, 'Tags', '').lower()
    if 'military' in tags: tag_score += 30
    if 'police' in tags: tag_score += 20
    if 'tactical' in tags: tag_score += 25
    
    category = getattr(item, 'DisplayCategory', '')
    if category == 'SurvivalGear': tag_score += 20
    
    # 5. Boolean indicators (bonuses)
    bonus = 0
    if getattr(item, 'TwoHandWeapon', False): bonus += 10
    if getattr(item, 'RequiresEquippedBothHands', False): bonus += 15
    if getattr(item, 'IsHighTier', False): bonus += 20
    
    # Calculate weighted score
    final_score = (
        spawn_score * 0.6 +
        min(100, stat_score) * 0.2 +
        min(100, durability_score) * 0.1 +
        min(100, tag_score) * 0.1 +
        bonus
    )
    
    # Cap at 100
    final_score = min(100, final_score)
    
    # Determine tier
    if final_score >= 90: return 'Ultra Rare'
    elif final_score >= 75: return 'Legendary'
    elif final_score >= 60: return 'Rare'
    elif final_score >= 40: return 'Uncommon'
    else: return 'Common'
```

---

## Integration with PriceGenerator

To integrate this analysis into the existing PriceGenerator tagging system:

### 1. **Add Spawn Data Loader**

Create `Scripts/PriceGenerator/Utils/spawn_loader.py`:

```python
"""Load and cache ProceduralDistributions spawn data"""
import re
from pathlib import Path

PROC_DIST_FILE = "/path/to/ProceduralDistributions.lua"

_spawn_cache = None

def load_spawn_data():
    """Load spawn weights from ProceduralDistributions.lua"""
    global _spawn_cache
    if _spawn_cache:
        return _spawn_cache
    
    spawn_data = {}
    # Parse ProceduralDistributions.lua (see analyze_spawn_rates.py)
    # ... parsing logic ...
    
    _spawn_cache = spawn_data
    return spawn_data

def get_spawn_weight(item_id):
    """Get average spawn weight for an item"""
    data = load_spawn_data()
    spawns = data.get(item_id, [])
    
    if not spawns:
        return 5.0  # Default medium rarity
    
    return sum(w for _, w in spawns) / len(spawns)
```

### 2. **Enhanced Rarity Detection**

Update `Scripts/PriceGenerator/Utils/tagging.py`:

```python
from .spawn_loader import get_spawn_weight

def determine_rarity_enhanced(item_id, props):
    """Enhanced rarity using spawn data + properties"""
    
    # Get spawn weight
    spawn_weight = get_spawn_weight(item_id)
    spawn_score = max(0, 100 - spawn_weight * 10)
    
    # Get property-based scores
    damage_score = get_stat(props, 'MaxDamage', 0) * 50
    condition_score = get_stat(props, 'ConditionMax', 0) * 2
    
    # Tag analysis
    tag_score = 0
    if 'military' in props.lower() or 'Military' in item_id:
        tag_score += 30
    if 'police' in props.lower() or 'Police' in item_id:
        tag_score += 20
    
    # Calculate final score
    final = spawn_score * 0.6 + damage_score * 0.2 + condition_score * 0.1 + tag_score * 0.1
    
    # Determine tier
    if final >= 90: return "UltraRare"
    elif final >= 75: return "Legendary"
    elif final >= 60: return "Rare"
    elif final >= 40: return "Uncommon"
    else: return "Common"
```

---

## Using the MCP Server

The `MCP/pz-mcp-server` provides tools for automated item analysis:

### Build and Start
```bash
cd MCP/pz-mcp-server
npm install
npm run build
node dist/index.js
```

### Query Item Properties
```javascript
// Through MCP tools
const item = await searchItems({ query: "AssaultRifle" });
console.log(item.properties);
// Shows all 372 possible properties
```

### Generate New Documentation
```bash
# Re-analyze vanilla items
python3 Scripts/analyze_item_properties.py

# Re-analyze spawn rates
python3 Scripts/analyze_spawn_rates.py
```

---

## Property Index Quick Reference

### Most Useful for Rarity Detection

**Boolean Flags:**
- `TwoHandWeapon` - Indicates powerful weapons
- `IsHighTier` - Explicitly marked high tier
- `Sterile` - Valuable medical items
- `SurvivalGear` - Rare equipment
- `RequiresEquippedBothHands` - Heavy/powerful items

**Numeric Properties:**
- `MaxDamage` - Weapon power (0.1 - 3.0+)
- `ConditionMax` - Item durability (1 - 100)
- `Weight` - Extreme values often rare
- `BloodDefense` / `BitDefense` - Armor quality
- `ProtectionLevel` - Overall protection

**String Properties:**
- `DisplayCategory` - Item classification
- `Tags` - Contains rarity indicators (military, police, tactical)
- `Categories` - Weapon/item type

### Spawn Weight Ranges

| Tier | Weight | % of Items | Examples |
|------|--------|------------|----------|
| Ultra Rare | <0.1 | 3.4% | HamRadio2, Military gear, Special items |
| Legendary | 0.1-0.5 | 6.1% | Assault rifles, Advanced armor |
| Rare | 0.5-2.0 | 17.7% | Police equipment, Power tools |
| Uncommon | 2.0-5.0 | 27.0% | Kitchen knives, Work clothing |
| Common | >5.0 | 45.7% | Food items, Basic supplies |

---

## Next Steps

1. ✅ **Documentation Complete** - All properties and spawn rates cataloged
2. 🔄 **Integration** - Add spawn data loader to PriceGenerator
3. 📊 **Testing** - Validate rarity scores against known items
4. 🎯 **Refinement** - Adjust weights based on gameplay testing
5. 🤖 **Automation** - Set up CI/CD to regenerate docs on game updates

---

## Files Generated By

- `Scripts/analyze_item_properties.py` - Extracts all properties from vanilla scripts
- `Scripts/analyze_spawn_rates.py` - Parses ProceduralDistributions.lua

**Last Updated:** March 6, 2026
**Game Build:** 42
**Total Items Analyzed:** 5,085 (properties) + 3,984 (spawn data)
