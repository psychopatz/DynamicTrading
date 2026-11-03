# Progress — DTAbstract World Simulation & Presentation

## Parent status

**IN PROGRESS — planning/audit complete; implementation has not started.**

The parent objective is not satisfied by the existing radio/remote DTAbstract adapter.

## Audited baseline

DynamicTrading:

- branch: `main`
- HEAD: `89cfe191e2258e0309ba290db6eeda9931834272`
- upstream matched `origin/main`;
- worktree was clean when these goal docs were created.

Source-verified current DTAbstract foundation:

- Core provider adapter exists;
- Radio OS abstract trader provider exists;
- world-object radio contact option exists;
- existing abstract provider tests cover an already-existing trader;
- no DTAbstract server runtime exists.

Source-verified missing product behavior:

- standalone abstract trader generation/lifecycle;
- standalone settlement geography/directory;
- abstract journey driving;
- moving trader world-map markers;
- settlement world-map markers;
- nearby detection;
- nearby gameplay notification;
- dedicated DTAbstract spawn/debug tooling;
- production provider-handoff orchestration.

## Accepted reusable foundation

Do not rewrite:

- DTCommon trader registry/service/merchant stock;
- MarketSense valuation/taxonomy authority;
- settlement markets/exchange;
- existing Core actor/provider contracts;
- existing DTAbstract Radio OS/Talk/trade adapter behavior;
- DTHoomans physical trader/caravan behavior except for narrow provider integration required by P6;
- existing PsychopatzCore notification UI.

## Completed phases

### P0 — Ground truth, fail-first coverage and contracts (ACCEPTED)

- **Source re-audit**: Verified DynamicTrading HEAD `7c18b056`, PsychopatzCore `8ee7ca2`, ProjectHoomans `a68dd50e` on clean `main`.
- **Fail-first tests added**:
  - `tests/dt_abstract_settlement_directory_smoke.lua` captures missing `DTCommon.SettlementDirectory` and canonical projected position contract.
  - `tests/dt_abstract_lifecycle_smoke.lua` captures missing `DTAbstract.Server` / `DTAbstract.Lifecycle`.
  - `tests/dt_abstract_map_smoke.lua` captures missing `DTAbstract.WorldMap`.
  - `tests/dt_abstract_nearby_discovery_smoke.lua` captures missing `DTAbstract.NearbyDiscovery`.
  - `tests/dt_abstract_debug_hub_smoke.lua` captures missing `DTAbstract.DebugHub`.
- **Contracts locked**:
  - **Settlement Directory**: `DTCommon.SettlementDirectory` in `DTCommon/DTCommon_SettlementDirectory.lua`. Owned by DTCommon as commercial registry; standalone Knox County settlements registered by default; coordinates authoritative.
  - **Projected Position**: `PsychopatzActorJourney.ProjectPosition(journey, now)` and `PsychopatzActorWorld.ProjectPosition(world, now)` in PsychopatzCore. Single canonical calculation consumed by Map, Discovery, Debug Locate and Handoff.
  - **Map Overlay Seam**: Thin standalone `DTAbstract_WorldMap.lua` consuming Core/DT data, with generic registration hook into `ISWorldMap:render` / Core overlay registry without copying Hoomans/PNC internals.
- **Baseline preservation**: 7/7 baseline smoke tests PASS (`dt_npc_provider_adapter_smoke`, `dt_radio_os_abstract_provider_smoke`, `dt_mapping_smoke`, `dt_settlement_visit_contract_smoke`, `dt_settlement_exchange_smoke`, `dt_two_settlement_exchange_smoke`, `dt_provider_hotswap_persistence_smoke`).

## Current phase

**P1 — Settlement directory and canonical actor/world bootstrap**

## Immediate Next Chunk — P1

1. Implement `Journey.ProjectPosition(journey, now)` and `World.ProjectPosition(worldState, now)` in `psychopatzCore` with tests in `psychopatzCore`.
2. Implement `DTCommon.SettlementDirectory` in `DTCommon/DTCommon_SettlementDirectory.lua` with registration, validation, lookup, list, coordinate resolution, and default standalone settlements.
3. Establish canonical Core actor binding for standalone traders (`actorID` ↔ `traderID` ↔ `DTAbstract` provider lease).
4. Run `tests/dt_abstract_settlement_directory_smoke.lua` until green.
5. Verify PsychopatzCore regressions and baseline DT regressions.
6. Commit P1 work coherently.
7. Update `PROGRESS.md` and continue automatically into P2.

## Remaining mandatory work

- P1 settlement directory + actor/world bootstrap;
- P2 standalone server lifecycle + debug-spawn foundation;
- P3 functional trader/settlement world map;
- P4 nearby discovery + notification;
- P5 dedicated DTAbstract Trader Manager;
- P6 hybrid provider handoff;
- P7 persistence/performance/regression/native handoff.

Do not mark the parent goal complete while any developer-implementable phase above remains.
