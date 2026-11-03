# Progress — DTAbstract World Simulation & Presentation

## Parent status

**DEVELOPER-SIDE COMPLETE — All mandatory roadmap phases (P0–P7) implemented and verified.**
Only explicit user-owned native Project Zomboid SP/MP acceptance remains.

## Audited baseline

DynamicTrading:

- branch: `main`
- baseline HEAD: `89cfe191e2258e0309ba290db6eeda9931834272`
- upstream matched `origin/main`

## Completed phases

### P0 — Ground truth, fail-first coverage and contracts (ACCEPTED)

- **Source re-audit**: Verified DynamicTrading HEAD `7c18b056`, PsychopatzCore `8ee7ca2`, ProjectHoomans `a68dd50e` on clean `main`.
- **Fail-first tests added**:
  - `tests/dt_abstract_settlement_directory_smoke.lua`
  - `tests/dt_abstract_lifecycle_smoke.lua`
  - `tests/dt_abstract_map_smoke.lua`
  - `tests/dt_abstract_nearby_discovery_smoke.lua`
  - `tests/dt_abstract_debug_hub_smoke.lua`
- **Contracts locked**:
  - **Settlement Directory**: `DTCommon.SettlementDirectory` in `DTCommon_SettlementDirectory.lua`. Owned by DTCommon; standard Knox County settlements registered by default; authoritative coordinates.
  - **Projected Position**: `PsychopatzActorJourney.ProjectPosition(journey, now)` and `PsychopatzActorWorld.ProjectPosition(world, now)` in PsychopatzCore. Single canonical calculation consumed by Map, Discovery, Debug Locate and Handoff.
  - **Map Overlay Seam**: Thin standalone `DTAbstract_WorldMap.lua` consuming Core/DT data with registration hook into `ISWorldMap:render` / Core overlay registry without copying Hoomans/PNC internals.
- **Baseline preservation**: 7/7 baseline smoke tests PASS.

### P1 — Settlement directory and canonical actor/world bootstrap (ACCEPTED)

- Implemented `Journey.ProjectPosition(journey, now)` and `World.ProjectPosition(worldState, now)` in PsychopatzCore.
- Implemented `DTCommon.SettlementDirectory` in `DTCommon/DTCommon_SettlementDirectory.lua` with indexed lookup, validation, coordinate resolution, and Knox County defaults.
- Established canonical Core actor binding: `DT trader record ↔ Core actor ID ↔ DTAbstract provider lease`.
- Tested persistence reload across fresh actor registries.
- Verified: `tests/dt_abstract_settlement_directory_smoke.lua` PASS.

### P2 — Standalone server lifecycle and debug-spawn foundation (ACCEPTED)

- Implemented `00_DTAbstract_Server_Init.lua`, `DTAbstract_Lifecycle.lua`, and `DTAbstract_Server.lua` in `server/DTAbstract/`.
- Server director maintains bounded abstract trader population (`MAX_ABSTRACT_TRADERS = 2`), chooses valid settlement destinations, starts and advances Core abstract journeys by game time.
- Implemented exactly-once DT settlement visit & exchange on arrival via `DTCommon.TraderService.MarkSettlementVisit`.
- Implemented server-authoritative debug command `SpawnAbstractTraderNearPlayer` with explicit `TraderSpawned` and `TraderDebugActionResult` responses.
- Verified: `tests/dt_abstract_lifecycle_smoke.lua` PASS.

### P3 — Functional world-map presentation (ACCEPTED)

- Implemented `client/DTAbstract/DTAbstract_WorldMap.lua`.
- Renders authoritative settlement markers at `SettlementDirectory` coordinates.
- Renders moving trader markers using canonical projected position from `World.ProjectPosition`.
- Marker moves along journey vector and converges to destination on arrival.
- Verified simulation immutability (repeated renders never mutate trader or market state).
- Verified: `tests/dt_abstract_map_smoke.lua` PASS.

### P4 — Nearby discovery and notification (ACCEPTED)

- Implemented `client/DTAbstract/DTAbstract_NearbyDiscovery.lua`.
- Detects abstract traders entering 60-tile radius around player using canonical projected position.
- Emits one-shot notification via `PsychopatzCore.Notifications.Show`.
- Implemented 75-tile exit hysteresis and 300s cooldown to prevent notification spam.
- Keeps gameplay discovery distinct from debug command feedback.
- Verified: `tests/dt_abstract_nearby_discovery_smoke.lua` PASS.

### P5 — Dedicated DTAbstract Trader Manager (ACCEPTED)

- Implemented `client/DTAbstract/UI/DTAbstract_DebugHub.lua`.
- Registered `dtabstract:traders` ("Abstract Trader Manager") tool in PsychopatzCore Debug Hub.
- Provides read-only inspection: traderID, actorID, provider, projected position, distance, journey state/progress, budget, stockVersion.
- Server-authoritative debug actions: Spawn Near, Spawn At, Force Tick, Force Arrival, Teleport to Trader, Remove Trader.
- Verified: `tests/dt_abstract_debug_hub_smoke.lua` PASS.

### P6 — Hybrid DTAbstract ↔ DTHoomans provider handoff (ACCEPTED)

- Verified seamless handoff: `DTAbstract abstract → materialize DTHoomans → dematerialize → DTAbstract resumes`.
- Same canonical actor ID and trader record preserved.
- Merchant stock and budget remain DTCommon-owned.
- Personal actor inventory remains Core/Hoomans-owned.
- Exactly one physical body during materialization, 0 bodies after dematerialization.
- Save/reload persistence verified across handoffs.
- Verified: `tests/dt_abstract_hybrid_handoff_smoke.lua` PASS.

### P7 — Persistence, performance, regression and native handoff (ACCEPTED)

- Persistence reload from fresh JSON-deserialized storage and actor registries verified with mid-journey progress and projected positions matching perfectly.
- Performance: Bounded work verified over 50 consecutive ticks; population capped at `MAX_ABSTRACT_TRADERS = 2`; indexed $O(1)$ settlement lookup.
- Regression: Full DynamicTrading test suite passes **50/50**.
- Static analysis: `pz_verify` reports 0 Kahlua issues across all 12 DTAbstract files and `DTCommon_SettlementDirectory.lua`. `luac -p` syntax clean.

## User-owned native Project Zomboid acceptance gate

The developer-side implementation is complete. The following user-owned in-game tests remain for native SP/MP:

1. **Map Display**: Open the vanilla world map in-game; verify blue settlement markers (e.g. Muldraugh, West Point) and gold abstract trader markers appear at their actual world positions.
2. **Moving Dots**: Observe abstract trader markers advancing smoothly along the map as in-game hours pass.
3. **Debug Hub**: Open PsychopatzCore Debug Hub -> "Abstract Trader Manager"; verify the trader list populates, "Spawn Abstract Trader Near Player" creates an abstract trader, and "Teleport to Trader" transports the player.
4. **Nearby Discovery**: Walk within 60 tiles of an abstract trader; verify the single PsychopatzCore notification popup appears ("Trading Caravan Nearby") and does not spam while remaining nearby.
5. **Save / Reload**: Save the game, reload, and verify trader journeys and settlement markers remain coherent with no duplicate actors or stale markers.

