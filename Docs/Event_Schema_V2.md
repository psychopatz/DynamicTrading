# Dynamic Trading V2: Event Schema

This document outlines the structure of an Event definition in Dynamic Trading V2. Events are defined in Lua tables and registered via `DynamicTrading.Events.Register`.

## Event Definition Structure

```lua
DynamicTrading.Events.Register("UniqueEventID", {
    -- [CORE IDENTITY]
    name = "String",                -- Display name of the event
    type = "flash" | "meta" | "seasonal", -- Event Category
    sentiment = "Positive" | "Negative" | "Neutral", -- General vibe (affects Director AI)
    description = "String",         -- Flavour text (shown in logs/UI)
    
    -- [TRIGGER CONDITIONS]
    -- Function returning boolean. 
    -- In V2, the 'faction' object is passed as an argument for context-aware filtering.
    canSpawn = function(faction) return true end, 
    
    -- [SYSTEM MODIFIERS] (Global or Faction-Global)
    system = {
        traderLimit = 1.0,  -- Multiplier for daily traded amount cap
        scanChance = 1.0,   -- Multiplier for "Check Price" success chance
    },
    
    -- [TRADING IMPACTS]
    -- Applied to specific Item Tags (defined in DT/Common/Tags.lua)
    effects = {
        ["TagName"] = { 
            price = 1.0,    -- Buy/Sell Price Multiplier
            vol = 1.0       -- Stock Volume Multiplier
        }
    },
    
    -- [STOCKPILE MANIPULATION] (V2 Specific)
    stock = {
        volumeMult = 1.0,   -- Global multiplier for ALL stock
        
        -- Injections: Add specific items to trader inventory daily
        injections = {
            ["Base.CannedBeans"] = 10,
            ["Base.ShotgunShells"] = 5
        },
        
        -- Expert Tags: Trader WILL trade these tags even if they usually don't
        expertTags = { "Medical", "Ammo" },
        
        -- Forbid Tags: Trader WILL NOT trade these tags
        forbidTags = { "Luxury" }
    },
    
    -- [FACTION SIMULATION IMPACTS] (V2 Specific)
    -- These effects apply consequences to the Faction Simulation loop.
    factionImpact = {
        -- IMMEDIATE IMPACTS (Applied once on start)
        wealthAdd = 0,      -- Add/Remove Currency
        stabilityAdd = 0,   -- Add/Remove "Stable Days" counter
        stockpileAdd = {    -- Add/Remove Virtual Resources
            food = 0,
            ammo = 0,
            meds = 0,
            fuel = 0
        },
        
        -- ONGOING IMPACTS (Applied Daily via Simulation)
        memberCountPct = 0.0, -- Target % of population to kill over duration (0.1 = 10%)
    },
    
    -- [ATTRITION LOGIC] (Complex Simulation)
    -- Requires faction to burn resources to prevent death
    attrition = {
        resource = "meds",  -- Resource to consume (food, meds, ammo, fuel)
        pct = 0.0,          -- % of population affected (sick/starving)
        cost = 1.0          -- Amount of resource needed per affected person
        -- Logic: If Stockpile < (Population * pct * cost) -> Casualties occur
    },
    
    -- [GLOBAL WORLD MODIFIERS] (Meta/Seasonal Only)
    -- These affect ALL factions and the wider world state
    world = {
        attritionAdd = 0.0, -- Daily % death roll for ALL survivor groups (e.g. Zombie Migration)
    },
    
    -- [DEMOGRAPHICS] (Deprecated/Legacy V1)
    -- Used for global population tracking in V1, largely superseded by 'world' or 'factionImpact'
    demographics = {
        attritionAdd = 0.0 
    }
})
```

## Detailed Property Breakdown

### Core Identity
*   **`id`** (First arg of Register): Must be unique. Used for save data and lookups.
*   **`type`**:
    *   `flash`: Short-term, high impact. Can be Global (affects everyone) or Faction-Specific (affects one group).
    *   `meta`: Long-term, background state (e.g., "Economic Depression"). Triggered by conditions.
    *   `seasonal`: Time-of-year events (e.g., "Winter").
*   **`sentiment`**: Help the Director AI decide when to use this.
    *   `Positive`: Good things. Used for rewards or random boons.
    *   `Negative`: Bad things. Used for crises, punishments for instability, or "Wildcards".

### Triggers (`canSpawn`)
*   **Context:** In V2, the Director calls this with the `faction` table as an argument.
*   **Usage:**
    ```lua
    canSpawn = function(faction) 
        -- Only triggers for factions in Muldraugh with > 50 members
        return faction.town == "Muldraugh" and faction.memberCount > 50 
    end
    ```

### Faction Impacts (`factionImpact`)
This section controls how the event modifies the *simulation* of a faction.
*   **`wealthAdd`**: Immediate cash injection/drain.
*   **`stockpileAdd`**: Immediate resource package.
*   **`memberCountPct`**: Calculates a *total target casualty count* at the start of the event. The simulation then kills a portion of these targets each day until the event ends or the target is reached.

### Attrition (`attrition`)
Defines a "Resource Check" crisis.
*   **Example:** "Flu Outbreak"
    ```lua
    attrition = {
        resource = "meds",
        pct = 0.3,      -- 30% of population is sick
        cost = 2.0      -- Each sick person needs 2 meds/day
    }
    ```
*   **Resolution:**
    *   **Success:** Faction has enough Meds. Meds are consumed. Nobody dies.
    *   **Failure:** Faction has insufficient Meds. A % of the *sick* population dies.

### Stockpile Manipulation (`stock`)
Controls the physical items available in the Trader User Interface.
*   **`injections`**: Forces specific items into the shop. useful for "Relief Drops" or "Black Market Arms" where specific items appear regardless of normal supply logic.
*   **`expertTags`**: Overrides the faction's "Trade Type". A "Food" trader usually won't buy Guns. If an event adds "Ammo" to `expertTags`, they will temporarily trade Ammo at full price.
