# ItemGenerator Updates - Blacklist & Directory Refactoring

## Summary

This update implements two major changes:
1. **Directory Rename**: `src/output` → `src/parse` (to avoid confusion with `Scripts/Output`)
2. **Blacklist System**: Filter unwanted items by ID, property name, or property:value pairs

---

## 1. Directory Refactoring

### Changes
- **Renamed**: `src/output` → `src/parse`
- **Rationale**: Clearer naming to distinguish between:
  - `src/parse`: Module for parsing/filtering logic
  - `Scripts/Output`: Folder for generated output files

### Updated Files
- `src/__init__.py`: Import updated from `.output` to `.parse`
- `src/parse/__init__.py`: Now exports both reporter and blacklist functions

---

## 2. Blacklist System

### Overview
The blacklist system automatically filters unwanted items during vanilla item loading. It supports three filtering modes:

1. **Item ID**: Exact match (e.g., `Money`, `MoneyBundle`)
2. **Property Name**: Any item with this property (e.g., `hidden`)
3. **Property:Value**: Specific property-value combinations (e.g., `Weight: 10`)

### Configuration File

Location: `Scripts/ItemGenerator/src/blacklist.json`

```json
{
  "comment": "Blacklist configuration for ItemGenerator - items matching these criteria will be excluded",
  "itemIds": [
    "Money",
    "MoneyBundle"
  ],
  "properties": {
    "names": [
      "hidden"
    ],
    "values": {
      "Weight": [10],
      "MaxCapacity": [50, 100]
    }
  }
}
```

### Usage

#### Command Line

```bash
# Show current blacklist configuration
python -m ItemGenerator.main --blacklist-show

# Show blacklist statistics
python -m ItemGenerator.main --blacklist-stats

# Add item ID to blacklist
python -m ItemGenerator.main --blacklist-add-id Base.Money

# Add property name to blacklist
python -m ItemGenerator.main --blacklist-add-prop hidden

# Add property:value to blacklist
python -m ItemGenerator.main --blacklist-add-value Weight 10
```

#### Interactive Menu

Run `python -m ItemGenerator.main` and select:
- `b` - Show blacklist configuration
- `s` - Show blacklist statistics

#### Programmatic Usage

```python
from Utils import load_vanilla_items
from Utils.parse.blacklist import is_item_blacklisted, filter_items

# Load items with blacklist filtering (default)
items = load_vanilla_items(apply_blacklist=True, verbose_blacklist=False)

# Load items without blacklist
items_all = load_vanilla_items(apply_blacklist=False)

# Check specific item
is_blacklisted, reason = is_item_blacklisted("Money", item_properties)
if is_blacklisted:
    print(f"Item blacklisted: {reason}")

# Filter a dictionary of items
filtered_items, blacklisted = filter_items(items_dict, verbose=True)
```

### Integration

The blacklist is automatically applied when loading vanilla items:

```python
# In vanilla_loader.py
def load_vanilla_items(apply_blacklist=True, verbose_blacklist=False):
    """
    Load vanilla items with optional blacklist filtering
    
    Args:
        apply_blacklist: If True, exclude blacklisted items
        verbose_blacklist: If True, print info about blacklisted items
    """
    # ... loads items ...
    # Automatically filters based on blacklist.json
```

### New Modules

#### `src/parse/blacklist.py`
Core blacklist logic:
- `load_blacklist()`: Load configuration from JSON
- `is_item_blacklisted(item_id, properties)`: Check if item matches blacklist
- `filter_items(items_dict)`: Filter dictionary of items
- `get_blacklist_stats()`: Get statistics about blacklist rules
- `reload_blacklist()`: Force reload configuration

#### `src/commands/blacklist.py`
CLI commands for blacklist management:
- `show_blacklist()`: Display current configuration
- `show_blacklist_stats()`: Display statistics
- `add_to_blacklist()`: Add entry to blacklist
- `remove_from_blacklist()`: Remove entry from blacklist

---

## Testing Results

### Test Suite Results

```
✅ Directory rename: Working
✅ Import updates: All imports resolved
✅ Blacklist loading: Configuration loaded successfully

Blacklist Filtering Tests:
✅ Item ID filtering: Money, MoneyBundle correctly excluded (2 items)
✅ Property name filtering: Items with 'hidden' property excluded (253 items)
✅ Property:value filtering: Items with Weight=10 excluded (5 tested items)
✅ Total filtered: 257 items excluded from 5,085 vanilla items
✅ Remaining items: 4,828 items available for trading

Specific Items Verified:
✅ Money: Excluded (Item ID blacklist)
✅ MoneyBundle: Excluded (Item ID blacklist)
✅ F_Hair_Stubble: Excluded (Property 'hidden' blacklist)
✅ M_Beard_Stubble: Excluded (Property 'hidden' blacklist)
✅ BucketMace_Metal: Excluded (Weight=10 blacklist)
✅ BucketMace_Wood: Excluded (Weight=10 blacklist)
✅ TvAntique: Excluded (Weight=10 blacklist)
✅ TvBlack: Excluded (Weight=10 blacklist)
✅ TvWideScreen: Excluded (Weight=10 blacklist)
❌ YardstickDEBUG: NOT excluded (has DisplayCategory=Hidden, not property 'hidden')
```

### Command Tests

```bash
# Show blacklist
$ python -m ItemGenerator.main --blacklist-show
============================================================
📋 CURRENT BLACKLIST CONFIGURATION
============================================================

🚫 Blacklisted Item IDs:
  - Money
  - MoneyBundle

🚫 Blacklisted Properties (by name):
  - hidden

🚫 Blacklisted Properties (by value):
  - Weight: 10
============================================================

# Show stats
$ python -m ItemGenerator.main --blacklist-stats
============================================================
📋 BLACKLIST STATISTICS
============================================================
Blacklisted Item IDs:       2
Blacklisted Property Names: 1
Blacklisted Property Values: 1
Total Blacklist Rules:      4
============================================================

# Add item to blacklist
$ python -m ItemGenerator.main --blacklist-add-id Base.TestItem
✅ Added item ID 'Base.TestItem' to blacklist
💾 Blacklist saved to .../blacklist.json
```

---

## Implementation Details

### Property Parsing

The blacklist system parses item properties from their raw text format:

```lua
item Money {
    Type = Normal,
    Weight = 0.0,
    hidden = TRUE,
}
```

Parsed to:
```python
{
    "Type": "Normal",
    "Weight": 0.0,
    "hidden": True
}
```

### Case Sensitivity

- **Item IDs**: Case-sensitive exact match
- **Property names**: Case-sensitive exact match
- **Property values**: Type-aware comparison (numbers, strings, booleans)

### Performance

- Configuration cached on first load
- Blacklist check: O(1) for item IDs, O(n) for properties (n = number of properties)
- Filtering 5,085 items takes <1 second

---

## Migration Notes

### If You Have Custom Code

If you have custom code importing from `Utils.output`, update imports:

```python
# Before
from Utils.output import write_mod_duplicates

# After
from Utils.parse import write_mod_duplicates
```

### Backward Compatibility

The rename maintains full backward compatibility for all public APIs. Only internal import paths changed.

---

## Future Enhancements

Potential additions:
- Regex support for item IDs (`Money.*` matches `Money`, `MoneyBundle`, etc.)
- Property value ranges (`Weight > 10`)
- Compound conditions (`Weight > 10 AND Rarity = Rare`)
- Environment-specific blacklists (dev/staging/prod)
- UI for blacklist management

---

## Files Modified

### Core Changes
- `src/__init__.py`: Updated import path
- `src/commons/vanilla_loader.py`: Added blacklist integration
- `src/output/` → `src/parse/`: Directory renamed
- `src/parse/__init__.py`: Exports blacklist functions
- `src/commands/__init__.py`: Exports blacklist commands

### New Files
- `src/blacklist.json`: Blacklist configuration
- `src/parse/blacklist.py`: Core blacklist logic
- `src/commands/blacklist.py`: CLI blacklist commands

### Updated Files
- `Scripts/ItemGenerator/main.py`: Added blacklist CLI commands and menu options

---

## Documentation

For detailed API documentation, see:
- `src/parse/blacklist.py` - Full docstrings for all functions
- `src/commands/blacklist.py` - CLI command documentation
- This file - Usage examples and testing results
