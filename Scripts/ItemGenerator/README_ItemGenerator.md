# ItemGenerator - Modular Item Management System

Automated item registration and pricing system for Dynamic Trading mod with intelligent tagging.

## 📁 Project Structure

```
Scripts/
├── ItemGenerator.py          # Main entry point (2.6 KB)
└── src/                    # Modular components
    ├── __init__.py           # Package exports
    ├── config.py             # Configuration & mappings (2.7 KB)
    ├── vanilla_loader.py     # Vanilla item database (1.9 KB)
    ├── tagging.py            # Intelligent categorization (9.2 KB)
    ├── pricing.py            # Category-specific pricing (6.6 KB)
    ├── stock.py              # Stock range calculations (2.2 KB)
    └── lua_handler.py        # Lua file operations (8.9 KB)
```

## 🚀 Usage

### Update Mode
Recalculate prices and stock ranges for all registered items:
```bash
python Scripts/ItemGenerator.py update
```

### Add Mode
Add new unregistered vanilla items with intelligent tagging:
```bash
python Scripts/ItemGenerator.py add 100    # Add 100 items
python Scripts/ItemGenerator.py add 500    # Add 500 items
```

## 🏗️ Architecture

### Core Modules

**vanilla_loader.py**
- Loads vanilla item definitions from PZ scripts
- Extracts stats: Weight, HungerChange, Capacity, etc.
- Provides helper functions: `get_stat()`, `has_property()`

**tagging.py**
- Intelligent item categorization
- Generates nested tags: `Food.Meat.Perishable`, `Weapon.Melee.Blade`
- Determines rarity, quality, origin, and theme descriptors
- Pattern-based exclusion system

**pricing.py**
- Category-specific pricing formulas:
  - **Food**: `Hunger × 2.5` (opened items: 30% discount)
  - **Weapons**: Damage × condition / weight
  - **Clothing**: Protection-based tiers (Heavy Armor $1000+)
  - **Literature**: Knowledge premium by rarity ($40-$60)
  - **Medical**: Sterile premium + rarity scaling
  - **Containers**: Capacity × weight reduction utility

**stock.py**
- Weight-based stock ranges (BMS table)
- Category multipliers:
  - Perishable: 0.5×
  - Staples (Ammo/Material): 2.0×
  - Rare/Luxury: 0.4×
- Min stock calculation (0.2× default, 0.4× high demand)

**lua_handler.py**
- Lua file reading/writing operations
- Item registration tracking
- Batch addition with category routing
- Dynamic file mapping

**config.py**
- Path configuration
- Exclusion patterns (Corpses, Crafted items, etc.)
- Category-to-file mapping for 67+ Lua files

## 🏷️ Tagging System

### Primary Categories
- `Food.*` - Meat, Fruit, Vegetable, Drink, Cooking
- `Weapon.*` - Melee, Firearm, Explosive
- `Clothing.*` - Armor, Head, Hands, Feet
- `Literature.*` - SkillBook, Recipe, Media, Book
- `Medical.*` - Surgical, General
- `Container.*` - Backpack, Organizer
- `Tool.*` - Crafting, Farming, General
- `Resource.*` - Fuel, Material
- `Electronics.*` - Battery, Gadget

### Quality Descriptors
- `Quality.Sterile` - Medical equipment
- `Quality.Luxury` - High-end items
- `Quality.Waste` - Broken/empty items

### Rarity Levels
- `Rarity.Common` - Standard items
- `Rarity.Uncommon` - Police/sterile items
- `Rarity.Rare` - High-level skill books, rare gear
- `Rarity.Legendary` - Level 5 skill books

### Origin Tags
- `Origin.Police` - Law enforcement
- `Origin.Militia` - Military gear
- `Origin.Clinical` - Medical facilities
- `Origin.Industrial` - Factory equipment

### Theme Tags
- `Theme.Survival` - Camping/outdoor
- `Theme.Combat` - Tactical gear
- `Theme.Winter` - Cold weather items

## 📊 Results

**Current Status:**
- **5,086 items registered** (99.6% coverage)
- **34 items remaining** (excluded: corpses, furniture, debug)
- **67 Lua files** managed

**Latest Batch:**
- Added 3,080 items with automated pricing
- All items have harmonized pricing formulas
- Weight-based stock ranges applied

## 🔧 Configuration

Edit `Scripts/src/config.py` to:
- Modify exclusion patterns
- Update category-to-file mappings
- Change path configurations

## 📝 Example Output

```
📦 Loading vanilla item database...
✅ Loaded 5085 vanilla items

📁 Weapon: 98 items
  ✅ Added 89 items to DT_Melee.lua
  ✅ Added 9 items to DT_Ranged.lua

📁 Food: 45 items
  ✅ Added 30 items to DT_Perishable.lua
  ✅ Added 15 items to DT_Meat.lua

✅ COMPLETE: Added 143 new items
```

## 🎯 Benefits

1. **Modular**: Easy to maintain and extend
2. **Intelligent**: Automated categorization from vanilla stats
3. **Scalable**: Handles 5000+ items efficiently
4. **Consistent**: Unified pricing and stock logic
5. **Type-Safe**: Clear separation of concerns

## 📚 Migration Notes

Old `PriceGenerator.py` backed up as `PriceGenerator.py.backup`
- All functionality preserved
- Identical pricing/stock calculations
- Improved code organization
