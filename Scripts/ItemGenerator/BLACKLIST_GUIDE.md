# Blacklist Configuration Guide

## Quick Start

The blacklist is located at `Scripts/ItemGenerator/src/blacklist.json`.

## Configuration Format

```json
{
  "comment": "Description of the blacklist",
  "itemIds": [
    "ItemName1",
    "ItemName2"
  ],
  "properties": {
    "names": [
      "propertyName1",
      "propertyName2"
    ],
    "values": {
      "PropertyName": [value1, value2],
      "AnotherProperty": [value3]
    }
  }
}
```

## Examples

### 1. Blacklist Specific Items

Don't sell currency items:

```json
"itemIds": [
  "Money",
  "MoneyBundle"
]
```

### 2. Blacklist by Property Name

Exclude all items with a "hidden" property:

```json
"properties": {
  "names": [
    "hidden"
  ]
}
```

This will exclude items like:
```lua
item F_Hair_Stubble {
    hidden = true,
    ...
}
```

### 3. Blacklist by Property Value

Exclude items with specific property values:

```json
"properties": {
  "values": {
    "Weight": [10, 50],
    "MaxCapacity": [100]
  }
}
```

This will exclude:
- All items with Weight = 10 OR Weight = 50
- All items with MaxCapacity = 100

## Common Use Cases

### Exclude Non-Tradeable Items

```json
{
  "itemIds": [
    "Money",
    "MoneyBundle",
    "KeyRing",
    "WaterDropCOL"
  ],
  "properties": {
    "names": [
      "hidden",
      "CantBeDropped"
    ]
  }
}
```

### Exclude Heavy Items

```json
{
  "properties": {
    "values": {
      "Weight": [10, 15, 20, 25, 30]
    }
  }
}
```

### Exclude Quest Items

```json
{
  "properties": {
    "names": [
      "IsWaterSource",
      "RemoveUnlessLearned"
    ]
  }
}
```

## Property Name vs Property Value

### Property Name
Blacklists ANY item that HAS this property (regardless of value):

```json
"names": ["hidden"]
```

Matches:
- `hidden = TRUE`
- `hidden = FALSE`
- `hidden = SomeValue`

### Property Value
Blacklists items where property has SPECIFIC value:

```json
"values": {
  "Weight": [10]
}
```

Matches ONLY:
- `Weight = 10`

Does NOT match:
- `Weight = 9`
- `Weight = 10.5`
- No Weight property

## CLI Commands

### View Configuration

```bash
# Show full configuration
python -m ItemGenerator.main --blacklist-show

# Show statistics
python -m ItemGenerator.main --blacklist-stats
```

### Add Entries

```bash
# Add item ID
python -m ItemGenerator.main --blacklist-add-id KeyRing

# Add property name
python -m ItemGenerator.main --blacklist-add-prop CantBeDropped

# Add property:value (number)
python -m ItemGenerator.main --blacklist-add-value Weight 50

# Add property:value (string)
python -m ItemGenerator.main --blacklist-add-value Category Clothing
```

## Testing Your Blacklist

```python
# In Python console
import sys
sys.path.insert(0, 'Scripts/ItemGenerator')

from Utils import load_vanilla_items

# Load with blacklist
items_filtered = load_vanilla_items(apply_blacklist=True, verbose_blacklist=True)

# Check specific item
if 'Money' in items_filtered:
    print("Money is NOT blacklisted")
else:
    print("Money IS blacklisted")
```

## Tips

1. **Case Sensitivity**: Item IDs and property names are case-sensitive
2. **Numeric Values**: Values like `10` and `10.0` are treated as equal
3. **Reload**: Blacklist is cached - restart Python or use `reload_blacklist()`
4. **Validation**: Test your blacklist before deploying to production
5. **Backup**: Keep a backup of your blacklist.json before making changes

## Property Discovery

To find what properties are available:

```bash
# List all properties in vanilla items
python -m ItemGenerator.main --list-properties

# Find items with specific property
python -m ItemGenerator.main --find-property hidden

# Analyze property usage
python -m ItemGenerator.main --analyze-properties
```

## Troubleshooting

### Item Not Being Filtered

1. Check item ID spelling (case-sensitive)
2. Verify the property name exists on the item
3. Ensure property value matches exactly (type matters)
4. Test with `verbose_blacklist=True` to see what's being filtered

### Too Many Items Filtered

1. Check if property name is too broad (e.g., "Type" appears on many items)
2. Use property:value instead of property name for precision
3. Review blacklist stats: `--blacklist-stats`

### Blacklist Not Loading

1. Check JSON syntax (use a JSON validator)
2. Ensure file is at `Scripts/ItemGenerator/src/blacklist.json`
3. Check file permissions
4. Look for error messages in console output
