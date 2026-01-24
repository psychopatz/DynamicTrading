# Dynamic Trading v2 - Unified Roadmap & Architecture

**PROJECT:** Dynamic Trading & Faction System (Build 42)
**ENGINE VERSION:** `DynamicTrading_Engine_v2`
**FRAMEWORK:** Hybrid (DTNPC Puppets + Faction Souls)
**MODE:** Multiplayer (Dedicated/Hosted) & Singleplayer

---

## 1. CORE PHILOSOPHY

**Objective:** Create a living, persistent economy where NPCs are data ("Souls") that only manifest physically ("Puppets") when needed.

1. **Split Data Architecture:**
   * **Engine:** `DynamicTrading_Engine_v2` (Time, Events, Global State).
   * **Factions:** `DynamicTrading_Factions` (Macro resources, Tech level, Relations).
   * **Roster:** `DynamicTrading_Roster` (NPC Data/Souls).
   * **Stock:** `DynamicTrading_Stock` (Inventory/Pricing).
2. **Server Authority:**
   * Only the Server writes to critical ModData.
   * Clients request actions via `DT_ClientCommands`.
3. **Mutual Exclusivity:**
   * NPCs cannot be on the Radio and spawned physically at the same time.
4. **The "Puppet" Rule:**
   * `IsoZombie` objects are temporary. They spawn, trade/interact, and then `removeFromWorld`.
   * Persistence is handled entirely by the **Roster** (The "Soul").

---

## 2. ROADMAP

### Phase 1: Foundation & Isolation (Current)

- [X] **Legacy Isolation:** `v1.1` code moved to `Legacy/` directories.
- [ ] **Engine Initialization:** Implement `DynamicTrading_Engine_v2` localized signals.
- [ ] **Dependency Cleanup:** Ensure new modules do not require Legacy files.

### Phase 2: Core System Consolidation

- [ ] **NPC System (DTNPC):**
  - Finalize `DTNPC_ClientSync` for robust multiplayer sync.
  - Implement behaviors: `Trade`, `Guard`, `Flee`, `Follow`.
- [ ] **Faction System:**
  - Implement `DynamicTrading_Factions` persistence.
  - Connect NPC spawning to Faction Roster (Faction A spawns NPC B).
- [ ] **Event Markers:**
  - "One-time" vs "Persistent" markers.
  - Visual indicators (Arrows) pointing to active Trading Zones.

### Phase 3: Gameplay Loop

- [ ] **Trading Interface:** New UI accessing `v2` Stock data.
- [ ] **Dynamic Events:**
  - "Price Fluctuation" driven by Faction State (Starving Factions pay more for food).
  - "Stock Resupply" logic simulating off-screen production.

---

## 3. DATA SCHEMA (v2)

### A. `DynamicTrading_Engine_v2` (Global State)

*The conductor handling time, events, and region density.*

```lua
{
    SimState = {
        lastSimulationDay = 0,
        systemLock = false
    },
    ZoneState = {
        ["Rosewood"] = {
            dailyCap = 5,
            assignedTraders = { "Trader_001", "Trader_005" }
        }
    },
    EventState = {
        activeEvents = { ["Flash_Blight"] = 148 },
        currentMultipliers = {
            ["Food"] = { buy = 2.5, sell = 0.5 }
        }
    }
}
```

### B. `DynamicTrading_Factions` (The Macro Economy)

*Tracks shared resources for groups.*

```lua
{
    ["Federation"] = {
        displayName = "The Federation",
        stockpile = { food=500.0, ammo=1000, meds=50.0 },
        state = "Stable", -- "Stable", "Starving", "Booming"
        homeBases = { "Rosewood_FireStation" },
        memberCount = 12,
        reputation = { ["User_A"] = 100 }
    }
}
```

### C. `DynamicTrading_Roster` (The Soul)

*Persistent Identity. Links to a Faction and DTNPC visual data.*

```lua
{
    ["Trader_001"] = {
        name = "Sgt. Miller",
        factionID = "Federation",
        homeCoords = {x=10850, y=9800, z=0},
      
        -- State
        status = "Active", -- "Active", "Expired", "Dead"
        returnTime = -1, -- If > GameTime, NPC is "Away"
        isPhysicallySpawned = false,

        -- Visuals (DTNPC Brain)
        brain = { 
            name = "Sgt. Miller",
            outfit = { "Base.Hat_Army", ... },
            hairStyle = "CrewCut"
        },
      
        -- Memory
        memory = { 
            ["User_A"] = { 
                trust = 50, 
                lastSeen = 145.5,
                tradeVolume = 5000 
            } 
        }
    }
}
```

### D. `DynamicTrading_Stock` (Inventory)

```lua
{
    ["Trader_001"] = {
        lastRestockTime = 140.0,
        items = {
            ["Base.CannedBeans"] = {
                qty = 14,
                basePrice = 10,
                dynamicMod = 1.0
            }
        }
    }
}
```

---

## 4. SYSTEMS INTERACTION

### The Daily Simulation (05:00 AM)

1. **Engine:** Updates `ZoneState` (which traders are active today).
2. **Engine:** Updates `EventState` (modifiers).
3. **Factions:** Consume resources (`Stockpile -= Consumption`). Update State (Stable -> Starving).

### Player Interaction (Radio)

1. **Check:** Is Trader in `ZoneState.assignedTraders`?
2. **Check:** Is `returnTime` valid?
3. **Result:** Open Trade UI via Radio. Lock Trader from physical spawn for X hours.

### Player Interaction (Physical)

1. **Trigger:** Player enters zone defined by EventMarker/Coordinates.
2. **Check:** Is Trader available (not on radio, active in zone)?
3. **Spawn:** Client requests Spawn. Server validates and sends `DTNPC_Spawn` command.
4. **Behavior:** NPC acts as defined (Guard, Trade) until Player leaves or Time expires.
