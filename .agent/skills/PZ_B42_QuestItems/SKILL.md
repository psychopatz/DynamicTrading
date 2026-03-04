---
name: Project Zomboid Build 42 Item Implementation
description: Patterns and gotchas for creating and modifying items in PZ Build 42, including crash prevention and dynamic properties.
---

# Project Zomboid Build 42 Item Implementation

This skill covers the specific requirements and common pitfalls when implementing custom items and dynamic item logic in Project Zomboid Build 42 (B42).

## 1. Item Script Definitions (media/scripts/)

### Critical: ItemType Parity

In B42, the legacy `Type = Normal` is often replaced by `ItemType`. Using an invalid or abstract `ItemType` (like `base:item`) will cause a **NullPointerException** in the Java `InstanceItem` call.

- **Correct Type**: Use `ItemType = base:normal` for standard items.
- **Quotes**: Always wrap `DisplayName` and `Tooltip` in double quotes if they contain spaces or special characters.
- **Weights**: Use floating-point numbers for `Weight` (e.g., `1.0` instead of `1`).

```javascript
module MyMod
{
    item MyCustomItem
    {
        DisplayCategory = Tool,
        ItemType = base:normal,
        Weight = 1.0,
        DisplayName = "My Custom Item",
        Icon = MyIconName,
        Tooltip = "A detailed description.",
    }
}
```

## 2. Dynamic Properties in Lua

To modify items dynamically after they are spawned (e.g., for unique quest items), use the following methods on the `InventoryItem` object.

### Methods

- `item:setName("Unique Name")`: Changes the display name in the inventory.
- `item:setTooltip("Custom Tooltip Text")`: Sets a multi-line tooltip shown on hover.
- `item:setActualWeight(float)`: Changes the item's weight. Must also call `item:setCustomWeight(true)`.
- `item:getModData()`: Store persistent custom variables (Quest IDs, Timestamps).

### Example

```lua
local item = inventory:AddItem("MyMod.MyCustomItem")
if item then
    item:setName("Package for Bob")
    item:setTooltip("Deliver to the warehouse in Muldraugh.")
    item:setActualWeight(10.0)
    item:setCustomWeight(true)
    
    local data = item:getModData()
    data.QuestID = "QUEST_001"
end
```

## 3. Icon (Texture) Gotchas

Build 42 has refined the texture atlas.

- If an icon shows as a **Question Mark**, the texture name is likely incorrect or missing from the load path.
- Many vanilla icons now use specific prefixes or are located in subfolders.
- **Verified Parcel Icons**: `Parcel_Small_Food`, `Parcel_Medium_Food`, `Parcel_Large_Hardware`, `Parcel_Medium_Military`, `GenericMedicalParcel1`, `Present4`.

## 4. Spawning Logic

- **Singleplayer**: `inventory:AddItem("Module.Type")` is the most robust method. It returns the created item object.
- **Multiplayer**: Items spawned on the server must be synchronized. Use `sendAddItemToContainer(inventory, item)` after adding.

## 5. Mod Indexing and Economic Balancing

For Dynamic Trading, maintaining parity with vanilla Build 42 items and establishing a logical economy is critical.

### The `compare_ids.py` Tool

Use this tool to sync the mod's item registration with vanilla scripts.

- **Invalid**: IDs found in the mod but not in vanilla B42. **Action**: Remove immediately from Lua files.
- **AlreadyHas**: IDs correctly registered. **Action**: Use for refining `basePrice` and `tags`.
- **VanillaOnly**: Items in the game but not in the mod. **Action**: Source for expanding the trader inventory.

### Harmonized Pricing and Stock Logic

Use a data-driven approach based on item stats (Weight, Nutrition, Damage) to establish the `basePrice` and `stockRange`.

#### 1. Pricing (Base Price)

Sync `basePrice` with the `worth` calculated in the `compare_ids.py` script. The script accounts for:

- **Food**: Hunger/Thirst reduction, Calories, and Stability (Canned/Packaged).
- **Weapons**: Damage, Range, Hit Count, Durability, and Swing Time.
- **Clothing**: Bite/Scratch defense and Insulation.
- **Opened Items**: Apply a **30% discount** (0.7x multiplier) for items with `Opened = true` or `_Open` suffix.

#### 2. Stock Range Logic (Min/Max)

Stock levels are primarily driven by **Weight**, then modified by **Category**.

#### Step A: Determine Base Max Stock (BMS)

| Item Weight | Base Max Stock |
| :--- | :--- |
| `<= 0.05` | 50 |
| `<= 0.2` | 25 |
| `<= 0.5` | 15 |
| `<= 1.5` | 10 |
| `<= 5.0` | 5 |
| `> 5.0` | 2 |

#### Step B: Apply Multipliers

- **Perishable / Fresh Food**: `0.5x`
- **Staples (Ammo, Material, Currency)**: `2.0x`
- **Rare / Luxury**: `0.4x` (Min 1)
- **Quest Items**: `1` (Manual Override)

#### Step C: Determine Min Stock

- **Default**: `Floor(Max * 0.2)`
- **High Demand (Material, Ammo)**: `Floor(Max * 0.4)`
- **Currency**: `Floor(Max * 0.8)`
- **Rare / Fresh**: `0`

### Standardized Property Tagging (Dot-Notation)

To ensure consistency and modularity, follow the `Category.SubCategory.Detail` hierarchy.

#### **Core Rules**

1. **Format**: `RootCategory.SubCategory.Detail` (e.g., `Food.Meat.Fresh`).
2. **Casing**: Always use `PascalCase`.
3. **Naming**: Use singular nouns (e.g., `Tool`, not `Tools`).

#### **Taxonomy Roots**

- `Food`, `Weapon`, `Clothing`, `Medical`, `Resource`, `Container`, `Tool`, `Junk`.

#### **Descriptor Roots (Secondary)**

- `Rarity.*`: `Common`, `Uncommon`, `Rare`, `Legendary`.
- `Theme.*`: `Winter`, `Camping`, `Survival`, `Hazard`.
- `Quality.*`: `Luxury`, `Primitive`, `Sterile`.
- `Origin.*`: `Military`, `Police`, `Industrial`, `Medical`, `Mod`.

### **Archetype Compatibility (Dual-Tagging)**

Use **Dual Tagging** to satisfy both generic and specific trader requirements:

1. **Taxonomy Tag**: `Weapon.Firearm.Rifle` (Generic stock targeting).
2. **Origin/Quality Tag**: `Origin.Mod.Brita` or `Quality.Luxury` (Specific targeting).

```lua
-- Example: Canned Beans Registration
{ item="Base.TinnedBeans", basePrice=10, tags={"Food.Canned.Vegetable", "Rarity.Common"}, stockRange={min=5, max=20} }
```
