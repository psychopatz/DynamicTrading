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
  - **Tip**: Cap weight at **50.0**. Items heavier than 50kg cannot be picked up from the ground because they exceed the default absolute capacity of the player's main inventory, causing a "bugged action" error in the console.
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
