# Version-Agnostic Event Integration Blueprint (V1 + V2)

## 1. Purpose
This document defines how to unify the Event, Faction, and Economy flow so V1 (radio trader interaction) and V2 (NPC interaction) run on the same simulation core with no compatibility branches.

Primary goal:
- Player can switch between V1 and V2 without simulation conflicts, event desync, or ModData migration pain.

Out of scope:
- Rewriting V1/V2 interaction UX.
- Replacing radio/NPC interaction systems.


## 2. Problem Summary
Current behavior indicates partial unification:
- `Flash` faction events work because they are driven from faction simulation (`faction.ActiveFlashEvent`).
- `Meta` and `Seasonal` are designed as global events in engine ModData, but do not consistently trigger/display.

Root inconsistencies discovered:
1. Mixed key usage for engine ModData transmission and listeners (`DynamicTrading_Engine_v1.3` vs `DynamicTrading_Engine_v2`).
2. UI panels do not use a single normalized global event source (Meta and Seasonal paths differ).
3. Event loading/registration is spread across common and version files.
4. Legacy global flash logic still exists in global tick path and conflicts with faction-only flash target architecture.
5. Faction flash currently assumes a single active event object, blocking configured multi-flash stacking.


## 3. Non-Negotiable Design Rules
These rules define the new baseline for both V1 and V2.

1. Single simulation authority:
- Common modules (`DynamicTradingCommon`) own Economy, Engine, Factions, Roster, Stock, and Events.

2. Event scope split:
- `Flash`: faction-scoped only.
- `Meta`: global-scoped only.
- `Seasonal`: global-scoped only.

3. Stacking model:
- Multipliers are multiplicative and stack across all active global events + all active faction flash events.
- No duplicate same-event instances in active sets.

4. Version role boundaries:
- V1 and V2 only differ by interaction transport/UI (radio vs NPC).
- V1 and V2 do not implement separate event simulation logic.

5. Canonical persistence keys:
- Keep and use only canonical keys for shared systems:
  - `DynamicTrading_Engine_v2`
  - `DynamicTrading_Factions`
  - `DynamicTrading_Roster`
  - `DynamicTrading_Stock`
- V1-specific key `DynamicTrading_V1_Radio` remains interaction metadata only.

6. Sandbox-driven control:
- Add `AllowMetaEvents` to toggle all Meta activation globally.
- Keep `AllowSeasonalEvents` for Seasonal activation globally.
- Add `FactionFlashMinActive` and `FactionFlashMaxActive` to control per-faction concurrent flash event bounds.


## 4. Target Runtime Architecture

### 4.1 Shared Core (authoritative)
- Engine (`DynamicTrading_Engine.lua`)
  - Owns global world state and global active events.
- Event Manager (`DT_EventManager.lua`)
  - Owns registry and event effect getters.
  - Owns global event tick logic for Meta/Seasonal.
  - Owns faction event update logic for Flash.
- Faction Simulation (`Factions/Simulation.lua`)
  - Calls `UpdateFaction(faction)` once per daily cycle.
- Economy (`DynamicTrading_Economy.lua`, common pricing)
  - Always resolves stacked modifiers through shared getters.

### 4.2 Adapters (non-authoritative)
- V1:
  - Radio discovery lifecycle and trader visibility.
- V2:
  - NPC spawn/behavior interaction.
- Neither adapter should generate, expire, or own global events.


## 5. Data Contracts

### 5.1 Global events contract
Storage:
- `DynamicTrading_Engine_v2.EventSystem.activeEvents`

Shape:
- `{ [eventID] = { expires = -1 or dayNumber } }`

Semantics:
- `meta` and `seasonal` only.
- `expires = -1` means condition-bound persistent activation.

### 5.2 Faction flash contract
Storage:
- `DynamicTrading_Factions[factionID].ActiveFlashEvents`

Shape:
- `{{ id = string, expires = hourNumber, targetCasualties = number|0 }, ...}`

Semantics:
- `flash` only.
- Multiple concurrent flash events allowed.
- Active count must stay within sandbox bounds (`FactionFlashMinActive` to `FactionFlashMaxActive`).

Migration rule:
- If legacy `ActiveFlashEvent` exists, convert it into a single-entry `ActiveFlashEvents` list during load/migration.

### 5.4 Sandbox Options Contract
New/updated shared options:
- `AllowMetaEvents` (bool): enables/disables all Meta event activation.
- `AllowSeasonalEvents` (bool): enables/disables all Seasonal event activation.
- `FactionFlashMinActive` (int): minimum maintained concurrent flash events per faction.
- `FactionFlashMaxActive` (int): maximum allowed concurrent flash events per faction.

Rules:
- If `AllowMetaEvents == false`, all active Meta events are force-cleared from global active events.
- If `AllowSeasonalEvents == false`, all active Seasonal events are force-cleared from global active events.
- `FactionFlashMinActive` is clamped to `>= 0`.
- `FactionFlashMaxActive` is clamped to `>= FactionFlashMinActive`.

### 5.3 Registry contract
Storage:
- `DynamicTrading.Events.Registry[eventID] = def`

Required fields:
- `name`, `type`, `description`
- `type in { flash, meta, seasonal }`

Optional fields:
- `condition` (meta/seasonal)
- `canSpawn` (flash)
- `effects`, `system`, `stock`, `world`, `demographics`, `factionImpact`, `attrition`


## 6. Execution Flow (authoritative)

### 6.1 Daily Engine tick
1. Engine daily simulation starts.
2. Engine decays heat and resets global deflation checklist.
3. Event manager global tick evaluates and mutates global active events:
- Activate/deactivate Meta by condition.
- Activate/deactivate Seasonal by condition.
- Do not run global Flash lottery.
4. Rebuild active global event cache.
5. Transmit `DynamicTrading_Engine_v2` to clients.

### 6.2 Daily Faction simulation
For each faction:
1. Process expiry for each active flash event instance.
2. Ensure active flash count respects configured min/max bounds.
3. Roll/select additional faction flash events if below min/target and constraints allow.
4. Apply immediate impacts for newly activated events.
5. Apply distributed casualties/attrition per active flash event during simulation updates.
6. Persist faction state and transmit faction ModData.

### 6.3 Economy pricing/stock generation
When pricing/volume is computed:
1. Apply global event modifiers from active global list.
2. Apply stacked faction flash modifiers from all active faction flash events.
3. Apply inflation/heat and other existing modifiers.
4. Return final multiplier/product.


## 7. UI Contract (Faction Intelligence)

### 7.1 Flash tab
Data source:
- selected faction `ActiveFlashEvents` + registry lookup for each entry.
- show all active flash events, each with independent expiry.

### 7.2 Meta tab
Data source:
- normalized list built from `DynamicTrading_Engine_v2.EventSystem.activeEvents` + registry filter `type == meta`.
- if `AllowMetaEvents == false`, show `Disabled by Sandbox` state.

### 7.3 Seasonal tab
Data source:
- same normalized global list + registry filter `type == seasonal`.
- Must not read a separate stale local list path.
- if `AllowSeasonalEvents == false`, show `Disabled by Sandbox` state.

### 7.4 Market tab
Data source:
- global normalized list + selected faction flash events.
- Display breakdown:
  - global event contribution
  - faction flash contribution (summed/stacked across active flash entries)
  - heat contribution

### 7.5 Performance Contract
- Engine ModData is the primary source for global events.
- Client cache is fallback only when engine data is temporarily unavailable.
- Build normalized active lists only on data-change events (sync/tick), not every frame.
- Pre-index by event type (`meta`, `seasonal`, `flash`) for O(1)-style tab filtering.


## 8. Version-Agnostic Bootstrap Strategy
Create one common bootstrap module and load it from both V1 and V2 entry paths.

Bootstrap responsibilities:
1. Require common config/tags/events/engine/factions/roster/stock/economy.
2. Register event hooks once (guarded).
3. Ensure core tables exist (`DynamicTrading`, `DynamicTrading.Events`, etc).
4. Perform one-time sanity validation log.

Guard pattern:
- `DynamicTrading._coreBootstrapped = true` after first load.
- Skip duplicate hook registration on subsequent requires.

Result:
- V1/V2 can be enabled independently or switched without duplicating core init.


## 9. Migration and Cleanup Plan

### Phase A: Schema + sandbox + key normalization
1. Replace all legacy key references to canonical key:
- replace `DynamicTrading_Engine_v1.3` usages in shared/client listeners with `DynamicTrading_Engine_v2`.
2. Ensure all event-change transmissions use `DynamicTrading_Engine_v2`.
3. Add new sandbox options and clamps (`AllowMetaEvents`, `FactionFlashMinActive`, `FactionFlashMaxActive`).
4. Add migration from `ActiveFlashEvent` to `ActiveFlashEvents`.
5. Add one helper to retrieve normalized global event defs from engine active events.

### Phase B: Scope + logic enforcement
1. Remove/disable global flash generation from global tick path.
2. Keep faction flash generation in `UpdateFaction(faction)` only.
3. Upgrade faction logic to concurrent flash list with min/max enforcement.
4. Keep Meta/Seasonal activation in global tick only.
5. Force-clear Meta/Seasonal when their sandbox toggles are disabled.

### Phase C: UI + bootstrap + switch hygiene
1. Refactor `DT_FactionEconomics_EventList` to use one source helper for Meta and Seasonal.
2. Ensure all tabs repaint on engine key updates.
3. Add explicit text states:
- no active events
- meta disabled by sandbox
- seasonal disabled by sandbox
4. Add shared bootstrap module.
5. Make V1 and V2 manifests call bootstrap first.
6. Remove duplicate requires/hook registrations in version modules.
7. Add V1 -> V2 transition cleanup for V1-only radio metadata (`DynamicTrading_V1_Radio`) while preserving shared simulation keys.


## 10. Exact File Touchpoint Plan

Core simulation/event files:
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Events/DT_EventManager.lua`
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Faction/TradingSys/DynamicTrading_Engine.lua`
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Faction/TradingSys/Factions/Simulation.lua`

UI files:
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/client/DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_EventList.lua`
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/client/DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_Market.lua`
- `Contents/mods/DynamicTradingCommon/42.13/media/lua/client/DT/UI/Faction/DT_FactionInfoWindow.lua`

Adapter/manifest files:
- `Contents/mods/DynamicTradingV1/42.13/media/lua/shared/DT/V1/Manifest.lua`
- `Contents/mods/DynamicTradingV2/42.13/media/lua/shared/DT/V2/Config.lua`
- New common bootstrap file under shared common path.


## 11. Testing and Validation Matrix

### 11.1 Runtime modes
1. Singleplayer with V1 enabled only.
2. Singleplayer with V2 enabled only.
3. MP host + client with V1 interaction.
4. MP host + client with V2 interaction.

### 11.2 Switch scenarios
1. Start world in V1, save, reload with V2.
2. Start world in V2, save, reload with V1.
3. Alternate V1/V2 across multiple reloads.

Expected:
- Same faction counts and IDs.
- Same engine heat and active global events.
- No duplicated event listeners (no repeated logs per tick).

### 11.3 Event behavior checks
1. Flash trigger and expiry happens per faction only.
2. Meta events activate when thresholds pass.
3. Seasonal events activate based on season when sandbox allows.
4. Multiple global events stack correctly.
5. Multiple faction flash events stack correctly per faction.
6. Global + faction flash stack correctly.
7. Meta/Seasonal force-clear correctly when toggles are disabled.

### 11.4 UI checks
1. Flash tab shows all selected faction flash events.
2. Meta tab shows global meta only.
3. Seasonal tab shows global seasonal only.
4. Meta tab shows `Disabled by Sandbox` when disabled.
5. Seasonal tab shows `Disabled by Sandbox` when disabled.
6. Market tab reflects stacked modifiers and heat breakdown.
7. Engine-first source remains stable; cache fallback only appears during brief sync gaps.
8. Tabs refresh after ModData receive for engine key.


## 12. Logging and Diagnostics
Add concise debug logs behind `DynamicTrading.Debug`:
1. On global event activation/deactivation with event ID/type.
2. On faction flash activation/expiry with faction ID.
3. On UI event list source count:
- global count
- faction flash present or not.
4. On bootstrap initialization once-only confirmation.

Do not spam logs every frame.


## 13. Risks and Mitigations

Risk 1: Duplicate hooks from dual manifest loading
- Mitigation: bootstrap guard + event-listener registration guards.

Risk 2: Old saves carrying stale local event cache
- Mitigation: rebuild active cache from engine active map on load and after each daily tick.

Risk 3: Seasonal never appears due to sandbox setting
- Mitigation: explicit UI state message for disabled seasonal events.

Risk 4: UI inconsistency in MP due to partial sync timing
- Mitigation: always derive UI global event list from latest engine ModData, not local stale copies.

Risk 5: Performance regression from rebuilding event lists every UI render
- Mitigation: event list normalization and type indexing are recomputed only on update signals.

Risk 6: Transition artifacts when switching V1 to V2
- Mitigation: clean V1-only radio metadata on V2 transition while preserving shared economy/faction/engine data.


## 14. Rollback Plan
If regression appears:
1. Keep backup branch before Phase A changes.
2. Revert in reverse order:
- Phase C (UI/bootstrap/cleanup) -> B (scope/logic) -> A (schema/sandbox/key normalization).
3. Preserve schema compatibility (do not rename ModData structures) to avoid save corruption.


## 15. Definition of Done
All of the following must be true:
1. V1 and V2 use identical shared event/economy/faction simulation paths.
2. No compatibility fallback code paths for event ownership.
3. `Flash` is faction-only, `Meta/Seasonal` are global-only.
4. Global event sync uses only `DynamicTrading_Engine_v2` key.
5. Concurrent faction flash events function within configurable min/max bounds.
6. User can switch V1/V2 between loads with no data conflict.
7. Faction Intelligence tabs and market breakdown reflect real stacked states.
8. Meta/Seasonal sandbox toggles correctly disable, clear, and display state.


## 16. Implementation Checklist (Execution-Ready)
1. Schema migration (`ActiveFlashEvent` -> `ActiveFlashEvents`).
2. Sandbox options patch (`AllowMetaEvents`, `FactionFlashMinActive`, `FactionFlashMaxActive`).
3. Key normalization patch.
4. Global flash removal from engine global tick.
5. Concurrent faction flash logic implementation.
6. UI global source normalization helper.
7. Seasonal and Meta tab sandbox-disabled states.
8. Bootstrap module introduction and manifest cleanup.
9. V1 -> V2 radio metadata cleanup.
10. Listener guards audit.
11. SP validation.
12. MP validation.
13. V1 <-> V2 switch validation.
14. Final documentation update and release notes.


## 17. Notes for Future Extensions
- If per-region global events are introduced, add `scope = global|region` in schema and preserve current global semantics as default.
- Keep V1/V2 adapter boundaries strict to avoid reintroducing split simulation logic.
