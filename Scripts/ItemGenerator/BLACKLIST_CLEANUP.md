# Automatic Blacklist Cleanup Feature

## Overview

The blacklist system now **automatically removes blacklisted items** from your Lua files. This happens in two ways:

### 1. **Automatic During Add Operations** ✨ NEW!

When you use `add` command to add new items, the system will:
- Remove any existing blacklisted items from the target file
- Skip adding any new items that are blacklisted
- Reformat and normalize the entire file

**Example:**
```bash
python -m ItemGenerator.main add 50
```

**What happens:**
```
📁 Weapons: 15 items
  🚫 Removing blacklisted item: Money (Item ID 'Money' is blacklisted)
  🚫 Removing blacklisted item: MoneyBundle (Item ID 'MoneyBundle' is blacklisted)
  ✅ Removed 2 blacklisted item(s)
  🚫 Skipping blacklisted item: Axe (Property 'Weight' has blacklisted value '10.0')
  ✅ Added 12 items to DT_Melee.lua
```

### 2. **Manual Cleanup Command** 🧹

Run cleanup on all existing Lua files without adding new items:

```bash
# Preview what would be removed (dry run)
python -m ItemGenerator.main --blacklist-cleanup --dry-run

# Actually remove blacklisted items
python -m ItemGenerator.main --blacklist-cleanup
```

**Interactive Menu:**
```
Select an operation:
...
🚫 BLACKLIST MANAGEMENT:
  b. Show blacklist configuration
  s. Show blacklist statistics
  c. Cleanup blacklisted items from Lua files
...

Enter choice: c
Dry run first? (y/n): y
```

---

## How It Works

### Automatic Removal During Add

The `add_items_to_file()` function now:

1. **Loads existing items** from the Lua file
2. **Checks each item against blacklist**:
   - Item ID blacklist
   - Property name blacklist
   - Property:value blacklist
3. **Removes blacklisted items** (prints what's being removed)
4. **Adds new items** (skips any that are blacklisted)
5. **Normalizes and reformats** the entire file

### Manual Cleanup

The `cleanup_blacklisted_items()` function:

1. **Scans all Lua files** in your mod directory
2. **Extracts all items** from each file
3. **Filters out blacklisted items**
4. **Rewrites each file** with only non-blacklisted items
5. **Reports statistics** (files processed, items removed)

---

## Examples

### Scenario 1: You Add Money to Blacklist

**Before:**
```lua
DT_General.items = {
    { item="Base.Money", basePrice=1, tags={...} },
    { item="Base.Hammer", basePrice=10, tags={...} },
    { item="Base.MoneyBundle", basePrice=10, tags={...} },
}
```

**Add Money to blacklist:**
```bash
python -m ItemGenerator.main --blacklist-add-id Money
python -m ItemGenerator.main --blacklist-add-id MoneyBundle
```

**Next time you add items:**
```bash
python -m ItemGenerator.main add 10
```

**After:**
```lua
DT_General.items = {
    -- Money and MoneyBundle automatically removed!
    { item="Base.Hammer", basePrice=10, tags={...} },
    { item="Base.Saw", basePrice=15, tags={...} },  -- newly added
    { item="Base.Screwdriver", basePrice=8, tags={...} },  -- newly added
}
```

### Scenario 2: Cleanup Existing Files

You have 50 Lua files with heavy items (Weight=10) and want to remove them all:

```bash
# Add Weight=10 to blacklist
python -m ItemGenerator.main --blacklist-add-value Weight 10

# Preview cleanup
python -m ItemGenerator.main --blacklist-cleanup --dry-run

# Output:
# 📄 DT_Material.lua
#    Found 15 items, removing 3:
#      🚫 TvAntique: Property 'Weight' has blacklisted value '10.0'
#      🚫 TvBlack: Property 'Weight' has blacklisted value '10.0'
#      🚫 TvWideScreen: Property 'Weight' has blacklisted value '10.0'
#
# 📊 Would remove 9 blacklisted items from 3 files

# Confirm and execute
python -m ItemGenerator.main --blacklist-cleanup

# Output:
# ✅ Removed 9 blacklisted items from 3 files
```

---

## Configuration

The blacklist is in `src/blacklist.json`:

```json
{
  "itemIds": [
    "Money",
    "MoneyBundle"
  ],
  "properties": {
    "names": [
      "hidden"
    ],
    "values": {
      "Weight": [10]
    }
  }
}
```

**After modifying blacklist.json:**
- Changes take effect immediately on next `add` or `cleanup` operation
- No need to restart anything
- Use `--blacklist-show` to verify changes

---

## CLI Commands Reference

### Blacklist Management
```bash
# Show current blacklist
python -m ItemGenerator.main --blacklist-show

# Show statistics
python -m ItemGenerator.main --blacklist-stats

# Add entries
python -m ItemGenerator.main --blacklist-add-id Money
python -m ItemGenerator.main --blacklist-add-prop hidden
python -m ItemGenerator.main --blacklist-add-value Weight 10
```

### Cleanup Commands
```bash
# Dry run (preview only)
python -m ItemGenerator.main --blacklist-cleanup --dry-run

# Actually remove
python -m ItemGenerator.main --blacklist-cleanup
```

### Regular Add (with automatic cleanup)
```bash
# Add 50 new items (automatically removes blacklisted items)
python -m ItemGenerator.main add 50

# Add all remaining items
python -m ItemGenerator.main add --all
```

---

## When Items Are Removed

### During `add` Command:
✅ **Automatic** - happens every time you add items  
✅ **Per-file** - only the files being modified  
✅ **Silent** - shows what's being removed but continues  

### During `cleanup` Command:
✅ **Manual** - you explicitly run the command  
✅ **All files** - scans entire mod directory  
✅ **Verbose** - detailed report of what's removed  

---

## Best Practices

1. **Test with dry run first**
   ```bash
   python -m ItemGenerator.main --blacklist-cleanup --dry-run
   ```

2. **Backup before bulk cleanup**
   ```bash
   cd Contents/mods/DynamicTradingV2/42.13/
   tar -czf backup_$(date +%Y%m%d).tar.gz *.lua
   ```

3. **Verify blacklist before cleanup**
   ```bash
   python -m ItemGenerator.main --blacklist-show
   ```

4. **Add items incrementally**
   - Automatic cleanup happens on each add
   - No need to run manual cleanup unless you modify blacklist

5. **Use property:value for precision**
   - Property name blacklists ALL items with that property
   - Property:value only blacklists specific values
   - Example: `Weight: [10, 15, 20]` is more precise than blacklisting "Weight" property

---

## Technical Details

### Function Signature
```python
def add_items_to_file(filepath, new_items, vanilla_items=None):
    """
    Add new items and fully normalize existing + new items in the file.
    Also removes any blacklisted items automatically.
    
    Args:
        filepath: Path to the Lua file
        new_items: List of new items to add
        vanilla_items: Vanilla item data for blacklist checking (optional)
    """
```

**Key change:** Added `vanilla_items` parameter. When provided, blacklist filtering is enabled.

### Integration Points

**Modified Files:**
- `src/commons/lua_handler.py`: Added blacklist checking to `add_items_to_file()`
- `src/commons/lua_handler.py`: Added `cleanup_blacklisted_items()` function
- `src/commands/cleanup.py`: New cleanup command module
- `main.py`: Added `--blacklist-cleanup` command and interactive menu option

---

## Testing Results

**Test Environment:** 
- 3 Lua files with 484 items total
- Blacklist: 2 item IDs (Money, MoneyBundle), 1 property (hidden), 1 property:value (Weight=10)

**Results:**
```
📄 DT_General.lua
   Found 83 items, removing 4 (tents with Weight=10)

📄 DT_Melee.lua
   Found 386 items, removing 2 (bucket maces with Weight=10)

📄 DT_Material.lua
   Found 15 items, removing 3 (TVs with Weight=10)

✅ Removed 9 blacklisted items from 3 files
```

**Performance:**
- Cleanup of 484 items across 3 files: < 1 second
- No data corruption or formatting issues
- Proper normalization and grouping maintained

---

## Comparison: Before vs After

### Before This Feature

❌ **Manual removal required**
- Had to find each file with blacklisted items
- Manually edit and remove lines
- Risk of syntax errors
- Time-consuming for many files

❌ **Items kept getting re-added**
- Blacklist only filtered new loads
- Existing registrations remained
- Had to manually clean after each blacklist change

### After This Feature

✅ **Automatic removal**
- Happens every time you add items
- Or run dedicated cleanup command
- Zero manual editing required

✅ **Stays clean**
- Once blacklisted, items never reappear
- New blacklist rules auto-apply to existing files
- One command to clean everything

✅ **Safe and reliable**
- Dry run mode for previewing
- Detailed reporting of what's removed
- Maintains file formatting and normalization

---

## FAQ

**Q: What happens to existing files when I add to blacklist?**  
A: Nothing immediately. They're cleaned next time you run `add` command on that file, or when you run `--blacklist-cleanup`.

**Q: Can I undo a cleanup?**  
A: Yes, if you have backups. Or remove items from blacklist and re-add them.

**Q: Does cleanup affect price/stock values?**  
A: No, cleanup only removes items. Use `update` command to change prices/stock.

**Q: Will this delete my blacklist.json?**  
A: No, cleanup never modifies blacklist.json, only Lua files.

**Q: Can I cleanup specific files only?**  
A: Currently no - cleanup processes all Lua files. You can edit blacklist.json to control what gets removed.

**Q: What if I accidentally blacklist everything?**  
A: Use dry run first! `--blacklist-cleanup --dry-run` shows what would be removed without making changes.

---

## See Also

- [BLACKLIST_GUIDE.md](BLACKLIST_GUIDE.md) - Configuration examples and property discovery
- [BLACKLIST_UPDATE.md](BLACKLIST_UPDATE.md) - Full implementation details and API reference
- `src/blacklist.json` - Your blacklist configuration file
