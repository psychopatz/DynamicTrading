# Dynamic Trading: Event Creation Guide

This guide provides detailed instructions on how to create and register new events for the Dynamic Trading mod (V1 & V2). 

## 1. Event Registration
Events are registered using the `DynamicTrading.Events.Register` function.

```lua
DynamicTrading.Events.Register("YourEventID", {
    name = "Human Readable Name",
    type = "flash", -- flash, meta, or seasonal
    sentiment = "Neutral", -- Positive, Negative, Neutral
    -- ... parameters ...
})
```

## 2. Event Types
| Type | Description |
| :--- | :--- |
| **Flash** | Triggered randomly for specific factions (V2) or via global lottery (V1). Usually short-lived. |
| **Meta** | State-driven. Active as long as its `condition` function returns `true`. |
| **Seasonal** | Time-driven. Usually active during specific months or dates. |

## 3. Impact Parameters

### A. Faction Impact (V2 Only)
Direct hits to a faction's state. Applied immediately or distributed over time.
- `memberCountPct`: (Number) % of population lost. Distributed over event duration.
- `wealthAdd`: (Number) Flat change to faction wealth.
- `stockpileAdd`: (Table) e.g., `{ food = -100, ammo = 50 }`.
- `stabilityAdd`: (Number) Changes internal stability days (affects event frequency).

### B. Attrition (V2 Only)
Simulates resource shortages or disease.
- `sickPct`: (Number) Chance for members to become sick daily.
- `medsPerSick`: (Number) Amount of `meds` required per sick person. Failure to supply causes deaths.

### C. World Economy
Global modifiers that affect all factions and players.
- `scavengeEfficiencyMult`: (Multiplier) Affects scavenging yields.
- `consumptionMults`: (Table) Multipliers for resource burn (e.g., `{ food = 2.0 }`).

### D. Demographics
- `recruitMult`: (Multiplier) Modifies global recruit generation rate.
- `attritionAdd`: (Number) Increases the base passive death rate for all factions.

### E. Stock & Trading
- `volumeMult`: (Multiplier) Changes the amount of items generated in trader stock.
- `expertTags`: (List) Tags that receive a +1 quality / expert level boost.
- `forbidTags`: (List) Tags that are explicitly banned (traders won't sell/buy them).
- `injections`: (Table) Extra items to force into stock (e.g., `{ Ammo = 5 }`).

### F. Pricing (Classic)
- `effects`: (Table) Tag-based price and volume multipliers.
```lua
effects = {
    ["Firearm"] = { price = 2.0, volume = 0.5 }
}
```

## 4. Conditions and Logic
- `condition`: (Function) For Meta/Seasonal. Returns `true` to activate.
- `canSpawn`: (Function) For Flash. Returns `true` if the event can trigger. Received `faction` as an argument in V2.

## 5. Complete Example: "Great Famine"
```lua
DynamicTrading.Events.Register("GreatFamine", {
    name = "The Great Famine",
    type = "flash",
    sentiment = "Negative",
    
    -- High consumption, low growth
    world = {
        consumptionMults = { food = 3.0 }
    },
    demographics = {
        recruitMult = 0.1,
        attritionAdd = 0.05
    },
    
    -- Stock Restrictions
    stock = {
        forbidTags = { "Food", "Luxury" }, -- Traders hoard food
        volumeMult = 0.5
    },
    
    -- Faction Stability hit
    factionImpact = {
        stabilityAdd = -10
    },
    
    canSpawn = function(faction)
        -- Only if it's summer and faction is already low on food
        local month = getGameTime():getMonth()
        return (month >= 5 and month <= 8) and (faction.stockpile.food or 0) < 1000
    end
})
```
