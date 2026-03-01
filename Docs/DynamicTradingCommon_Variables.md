# Dynamic Trading Common: Variable and Data Schema Mapping

This document provides a comprehensive map of the variables, registries, and shared logic used across Dynamic Trading V1 and V2.

## 1. Item and Archetype Registries

These registries serve as the source of truth for all trading entities.

### Item Master List (`DynamicTrading.Config.MasterList`)
**Location:** `media/lua/shared/DT/Common/Config.lua`

* `MasterList`: Table { [ItemFullType] = ItemData }
  * `ItemData`:
    * `item`: String (Full item type, e.g., "Base.Axe")
    * `basePrice`: Float (Baseline value before modifiers)
    * `tags`: Table of Strings (Used for categorization and events)
    * `stockRange`: Table { min, max } (Limits for stock generation)
    * `chance`: Float (Optional weight override for the lottery)

### Archetype Registry (`DynamicTrading.Archetypes`)
**Location:** `media/lua/shared/DT/Common/Config.lua`

* `Archetypes`: Table { [ArchetypeID] = ArchetypeData }
  * `ArchetypeData`:
    * `id`: String (e.g., "Doctor", "Gunrunner")
    * `allocations`: Table { [Tag] = count } (Guaranteed items in stock)
    * `forbid`: Table of Strings (Tags this archetype refuses to trade)
    * `wants`: Table { [Tag] = multiplier } (Bonus price when buying from player)
    * `expertTags`: Table of Strings (Items that always spawn in perfect condition)

### Fluid Registry (`DynamicTrading.Fluids`)
**Location:** `media/lua/shared/DT/Common/Items/DT_Fluids.lua`

* `Fluids`: Table { [FluidType] = FluidData }
  * `FluidData`:
    * `basePrice`: Float (Price per unit of liquid)
    * `tags`: Table of Strings (Used for pricing modifiers)

---

## 2. Tag System (`DynamicTrading.Tags`)

**Location:** `media/lua/shared/DT/Common/Tags.lua`

* `Tags`: Table { [TagName] = TagData }
  * `TagData`:
    * `priceMult`: Float (Global multiplier for item value)
    * `weight`: Integer (Frequency in the stock generation lottery)

---

## 3. Shared Economy Logic

**Location:** `media/lua/shared/DT/Common/Trading/DT_Economy_Common.lua`

The common economy module processes variables from registries and active events to calculate final values.

### Pricing Modifiers
* **Buy Price (Trader -> Player):**
  * `BasePrice` * `TagMult` * `EventPriceMult` * `GlobalHeat` * `DiffBuyMult` * `ConditionScale`
  * *Fluids:* `(ContainerPrice * Mults) + (FluidPrice * Amount * FluidMults)`
* **Sell Price (Player -> Trader):**
  * `BasePrice` * `DiffSellMult` * `ConditionRatio` * `EventPriceMult` * `GlobalHeat` * `LocalDeflation` * `ArchetypeWants`

---

## 4. Event System (`DynamicTrading.Events`)

**Location:** `media/lua/shared/DT/Common/Events/DT_EventManager.lua`

* `Registry`: All defined events (Flash, Meta, Seasonal).
* `ActiveEvents`: Currently running events.
  * `expires`: Integer (World day of expiration, -1 for persistent).
* `effects`: Sub-table in an event definition.
  * `[Tag]`: { price = Float, vol = Float } (Multipliers for price and stock quantity).
* `system`: Sub-table for global modifiers (e.g. `traderLimit`, `globalStock`).
* `inject`: Sub-table for guaranteed items (e.g. { "Medical" = 5 }).
