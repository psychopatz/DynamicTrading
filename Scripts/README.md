# Dynamic Trading Maintenance Scripts

These scripts help keep the mod up to date with vanilla Project Zomboid items.

## 1. Item Comparison Tool (`compare_ids.py`)

This script compares all items defined in the vanilla game scripts against the items currently registered in the mod's Lua files. It organizes findings by their source script (e.g., `Food.txt`, `Weapons.txt`).

### Usage

Run from the `Scripts/` directory:

```bash
python3 compare_ids.py
```

### Outputs (Saved to `Scripts/Output/`)

The results are split into three folders based on status:

- **`VanillaOnly/`**: Items found in the base game but NOT in your mod. Grouped by their vanilla script file. Use these to find missing content.
- **`AlreadyHas/`**: Items correctly registered in both the game and your mod.
- **`Invalid/`**: IDs in your mod that don't match any vanilla item (potentially renamed or deleted in Build 42). Grouped by the mod's Lua file where they are registered.
- **`fluids_found.txt`**: A flat list of all available fluid types in the game.

### Options

You can override the default paths if needed:

```bash
python3 compare_ids.py --vanilla "/path/to/pz/scripts" --mod "/path/to/mod/items"
```
