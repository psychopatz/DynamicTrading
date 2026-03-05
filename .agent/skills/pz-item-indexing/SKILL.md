---
name: pz-item-indexing
description: Standardized workflow for indexing vanilla Project Zomboid items into the Dynamic Trading mod. Includes pricing math, weight-based stock logic, and "No-Collision" tagging standards.
---

# Project Zomboid Item Indexing

This skill provides the data-driven logic for translating vanilla Project Zomboid item statistics into balanced trader registries for the Dynamic Trading mod.

## When to use this skill

- Use this whenever the user asks to "index new items" or "add items from vanilla".
- Trigger this when processing categories found in `Scripts/Output/VanillaOnly/`.

## How to use it

### 1. Data Processing

Run the modular processing script to generate the latest item registry and missing items list:

```bash
python3 Scripts/ItemID_Process.py --simple
```

This generates split, AI-friendly reports in `Scripts/Output/VanillaOnly/`.

### 2. Pricing Logic (B42 Standard)

Calculate `basePrice` using the following hierarchy:

- **Default**: `math.floor(PotentialWorth)`.
- **Food**: Use `math.floor(Hunger * 2.5)` if it provides a better balance.
- **Opened Items**: Apply a `0.7x` multiplier.
- **Minimum**: Ensure `basePrice` is at least `1`.

### 3. Stock Range Logic (Weight-Based)

Determine `maxStock` using the item's **Weight**:

- `Weight <= 0.05` -> `50`
- `Weight <= 0.2`  -> `25`
- `Weight <= 0.5`  -> `15`
- `Weight <= 1.5`  -> `10`
- `Weight <= 5.0`  -> `5`
- `Weight > 5.0`   -> `2`

**Multipliers for Max Stock:**

- `0.5x` for Perishables (Fresh Food).
- `2.0x` for Staples (Ammo, Build Materials).
- `0.4x` for Rare/Luxury items.

**Min Stock Calculation:**

- Default: `math.floor(Max * 0.2)`.

### 4. "No-Collision" Tagging Standards

Assign hierarchical tags using the `Root.Sub.Detail` format.

- **Casing**: PascalCase.
- **Count**: Singular nouns only.
- **Roots**: Must use one of: `Appliance`, `Clothing`, `Container`, `Electronics`, `Food`, `Literature`, `Medical`, `Misc`, `Resource`, `Tool`, `Vehicle`, `Weapon`.
- **Descriptors**: Use `Rarity.*`, `Quality.*`, `Origin.*`, or `Theme.*`.

### 5. Implementation & Verification

1. **Register** items in `Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items/[Category]/[Subcat].lua`.
2. **Verify** by running `python3 Scripts/ItemID_Process.py`. Items should move from `VanillaOnly` to `AlreadyHas`.
3. **Audit** by running `python3 Scripts/ItemID_Explore.py` to ensure tagging hierarchy is correct.
