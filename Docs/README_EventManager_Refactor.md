# DT Event Manager: Modular Refactor

## Overview
The `DT_EventManager.lua` system has been refactored from a monolithic 616-line file into a modular architecture with 4 specialized sub-modules. This improves maintainability, testability, and scalability.

## Architecture

### Main Module: `DT_EventManager.lua` (22 lines)
**Purpose**: Initialization and module loader.

- Initializes global `DynamicTrading.Events` namespace
- Requires all sub-modules in order
- Entry point for the entire event system

**Key Functions**:
- None (purely initialization)

---

### Module 1: `DT_EventManager_Registry.lua` (~60 lines)
**Purpose**: Event registration and configuration helpers.

**Responsibilities**:
- Register events into the global registry
- Validate event definitions
- Calculate faction flash slot bounds (min/max)
- Discover available flash event candidates

**Key Functions**:
- `Register(id, data)` - Register a new event definition
- `GetFactionFlashSlotBounds()` - Return min/max active flash events per faction (from sandbox)
- `GetFlashCandidates()` - Return list of flash events available to spawn
- All functions emit debug prints for traceability

---

### Module 2: `DT_EventManager_GlobalEvents.lua` (~280 lines)
**Purpose**: Global event tick processing and global modifier calculations.

**Responsibilities**:
- Process hourly global event ticks (expiry, activation, deactivation)
- Enforce sandbox toggle states (AllowMeta, AllowSeasonal)
- Rebuild active event cache from engine state
- Calculate global event modifiers (price, volume, system, demographics, world, injections)

**Key Functions**:
- `Tick(data)` - Main global event tick (processes expiry, meta/seasonal activation, sandbox enforcement)
- `RebuildActiveCache(data)` - Normalize active events from engine and cache them for fast access
- `GetActiveGlobalEventDefs(engineData)` - Return list of active global (non-flash) event definitions
- `GetPriceModifier(itemTags, verbose)` - Calculate global price multiplier
- `GetVolumeModifier(itemTags)` - Calculate global volume multiplier
- `GetSystemModifier(key)` - Calculate global system stat multiplier
- `GetDemographicsModifier(key)` - Calculate global demographics modifier
- `GetWorldModifier(key, subKey)` - Calculate global world condition modifier
- `GetInjections()` - Aggregate global item tag injections
- All functions emit detailed debug prints for modifier tracing

---

### Module 3: `DT_EventManager_FactionEvents.lua` (~350 lines)
**Purpose**: Faction flash event processing and faction-specific modifier calculations.

**Responsibilities**:
- Update faction flash event state (expiry, slot enforcement, spawn logic)
- Handle event spawning with weighted randomization (wildcard events)
- Apply immediate event impacts (wealth, stockpile, stability)
- Calculate faction-specific modifiers (system, price, volume, injections, expert/forbid tags)
- Manage schema migration from single `ActiveFlashEvent` to multi-event `ActiveFlashEvents` list

**Key Functions**:
- `UpdateFaction(faction)` - Main faction event tick (expiry, slot bounds, spawn logic, impact application)
- `GetFactionFlashEventDefs(faction)` - Return list of active flash event defs for a faction
- `GetFactionSystemModifier(faction, key)` - Calculate stacked global + faction system multiplier
- `GetFactionPriceModifier(faction, itemTags, verbose)` - Calculate stacked global + faction price multiplier
- `GetFactionVolumeModifier(faction, itemTags)` - Calculate stacked global + faction volume multiplier
- `GetFactionInjections(faction)` - Aggregate global + faction item tag injections
- `GetFactionExpertTags(faction)` - Aggregate expert tags from all faction flash events
- `GetFactionForbidTags(faction)` - Aggregate forbid tags from all faction flash events
- All functions emit comprehensive debug prints for event spawning, expiry, stacking tracing

---

## Debug Output Structure

All modules emit debug prints with consistent hierarchical naming:

```
[DynamicTrading] [Events] [Module] Message
```

Examples:
```
[DynamicTrading] [Events] [Registry] Registered event: WarEvent | Type: flash | Sentiment: Negative
[DynamicTrading] [Events] [GlobalEvents] === GLOBAL TICK START === (Day: 45)
[DynamicTrading] [Events] [GlobalEvents] Meta event ACTIVATED: Inflation
[DynamicTrading] [Events] [FactionEvents] === FACTION UPDATE START === [RiverFaction]
[DynamicTrading] [Events] [FactionEvents] Event [WarEvent] expired for faction RiverFaction
[DynamicTrading] [Events] [FactionEvents] Faction [RiverFaction] flash event ACTIVATED: Supply Crisis duration=48h targetCasulties=12
[DynamicTrading] [Events] [FactionEvents] Flash price mult from Supply Crisis tag=guns for faction=RiverFaction mult=1.5
```

Enable with: `DynamicTrading.Debug = true` in any mod console or file

---

## Data Flow

### Hourly Global Tick
```
DT_EventManager.Tick() [called by Engine]
├─ Clean up expired global events
├─ Force-clear sandbox-disabled events (Meta/Seasonal)
├─ Evaluate Meta/Seasonal conditions
│  ├─ If shouldBeActive and not isActive → activate
│  └─ If not shouldBeActive and isActive → deactivate
├─ Transmit engine data (if changed)
└─ Rebuild active cache
```

### Daily Faction Update
```
DT_EventManager.UpdateFaction() [called by Simulation loop]
├─ Ensure schema (migrate legacy single-event if needed)
├─ Expire old faction flash events
├─ Track stability (for wildcard chance calculation)
├─ Enforce min slots (spawn forced events until minimum met)
├─ Optional spawn (attempt chance-based spawn up to max slots)
│  ├─ Roll against base chance + stability bonus
│  │  └─ If pass and unstable for 14+ days → wildcard selection
│  ├─ Apply immediate impacts (wealth, stockpile, stability)
│  └─ Sync legacy mirror field
└─ Return (faction state persisted by caller)
```

### Price Modifier Calculation (Trading Context)
```
GetFactionPriceModifier(faction, itemTags)
├─ Apply global modifiers from active Meta/Seasonal events
├─ Apply faction-specific modifiers from all active Flash events
├─ Stack multiplicative
└─ Return final multiplier
(Each step emitted as debug print if verbose=true)
```

---

## Migration Notes (for developers)

### Old Import
```lua
require "DT/Common/Events/DT_EventManager"
```

### New Import
Same as above — the main module auto-loads all sub-modules.

### Adding New Features

1. **New Registry Helper?** → Add to `DT_EventManager_Registry.lua`
2. **New Global Event Logic?** → Add to `DT_EventManager_GlobalEvents.lua`
3. **New Faction Event Logic or Modifier?** → Add to `DT_EventManager_FactionEvents.lua`

All new functions should follow the naming convention:
- `DynamicTrading.Events.Function_Name()`
- Emit debug prints with `[DynamicTrading] [Events] [Module] Message` format

---

## Testing / Debugging Tips

### Enable Full Event Debug Output
```lua
DynamicTrading.Debug = true
```

Then watch console:
- **Global Tick**: Hourly (watch Meta/Seasonal activation and sandbox toggling)
- **Faction Update**: Daily per faction (watch slot enforcement and wildcard calculation)
- **Modifier Calculations**: On-demand (set `verbose=true` when calling price modifier functions)

### Check Active Global Events
```lua
print(DynamicTrading.Events.ActiveEvents)
```
Outputs list of active Meta/Seasonal event definitions.

### Check Faction Flash Events
```lua
local faction = DynamicTrading_Factions.GetFactionByID("MyFaction")
local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
print(#flashDefs, "active flash events")
for _, def in ipairs(flashDefs) do
    print("  -", def.name, "(expires in", math.max(0, faction.ActiveFlashEvents[_].expires - getGameTime():getWorldAgeHours()), "hours)")
end
```

### Trigger a Test Event Spawn
```lua
local faction = DynamicTrading_Factions.GetFactionByID("MyFaction")
DynamicTrading.Events.UpdateFaction(faction)
-- Check faction.ActiveFlashEvents for new entries
print("Active flash events after update:", #faction.ActiveFlashEvents)
```

---

## Line Count Reduction

| File | Old | New | Delta |
|------|-----|-----|-------|
| Main | 616 | 22 | -594 ↓ |
| Registry | - | 60 | new |
| GlobalEvents | - | 280 | new |
| FactionEvents | - | 350 | new |
| **Total** | **616** | **712** | **+96 (header/docs)** |

The increase in total is due to:
- Module boilerplate (requires, init prints)
- Comprehensive debug prints (visibility gain > size cost)
- Better code organization (readability gain)

---

## Future Enhancements

1. **Caching**: Pre-compute modifier combinations for frequently-called price lookups
2. **Event Questing**: Add quest/objective system tied to active events
3. **Regional Events**: Extend global events to be region-scoped
4. **Event Chains**: Support event sequences (e.g., "shortage" → "famine" escalation)
