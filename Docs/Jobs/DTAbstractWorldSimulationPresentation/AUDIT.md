# Audit — DTAbstract World Simulation & Presentation

## Current re-audit

Date: 2026-11-03

Repositories inspected:

- DynamicTrading `main` at `57140979111109ba620a690811484b17cbab34e2`, ahead of `origin/main` by 9.
- PsychopatzCore `main` at `23be8741ad3298ed02332a1cc40df257905fc122`, ahead of `origin/main` by 1.
- ProjectHoomans `main` at `a68dd50e3c2ec7d127cb86de02b85c2505b410aa`, matching `origin/main`.

Worktrees were clean at audit time.

DynamicTrading `tests/run_tests.py` was rerun and reported **PASS 50/50**. That result is real, but the current suite does not prove several production integration requirements below.

## Preserved implementation foundation

The agent added real useful code:

- `DTCommon.SettlementDirectory`.
- Core `Journey.ProjectPosition` / `World.ProjectPosition`.
- DTAbstract server lifecycle and server debug command router.
- DTAbstract map marker model/renderer.
- DTAbstract nearby-discovery algorithm.
- DTAbstract Debug Hub registration and command helper functions.
- provider adapter compatibility tests.
- persistence/performance smoke fixtures.

Do not discard this foundation wholesale.

## Finding A — the one-Core-map-host migration is not complete

The earlier Core NPC Foundation adopter contract explicitly required:

> Register Hoomans map layers through one Core registry; avoid duplicate ISWorldMap monkey patches.

Current production source does not satisfy that contract.

### ProjectHoomans still owns an active generic map host

ProjectHoomans still composes and actively uses:

- `PNC_MapLayerRegistry.lua`
- `PNC_MapToolbar.lua`
- `PNC_MapHoomansMenu*.lua`
- `PNC_MapDisplaySettings.lua`
- `PNC_WorldDiscoveryDebugMap.lua`
- marker/icon/map runtime files

`PNC_ClientComposition.lua` still requires `PNC/UI/Map/PNC_MapRuntime`.

These are not merely dead historical files.

### PsychopatzCore has no production MapOverlayRegistry

DTAbstract checks for:

`PsychopatzCore.MapOverlayRegistry.Register(...)`

but no such production registry exists in PsychopatzCore.

Therefore DTAbstract falls back to its own direct `ISWorldMap.render` monkey patch when `ISWorldMap` happens to exist at module load time.

Result:

```text
ProjectHoomans -> PNC.MapLayers -> patches ISWorldMap.render
DTAbstract     -> own fallback -> patches ISWorldMap.render
PsychopatzCore -> no generic production map overlay host
```

This is redundant active infrastructure and violates the intended migration architecture.

## Finding B — DTAbstract map attachment is not actually proven

`DTAbstract_WorldMap.lua` does not explicitly load `ISUI/Maps/ISWorldMap` before its one-time fallback installation.

If `ISWorldMap` is nil when DTAbstract client init runs, the fallback is skipped and there is no retry.

`tests/dt_abstract_map_smoke.lua` directly calls `WorldMap.Render(mockMap)`. It proves marker construction/render math but not that the production vanilla map hook is installed or survives mixed-mod load order.

The user's native screenshot showing only vanilla map controls is therefore compatible with a real attachment/composition failure.

## Finding C — the dedicated DTAbstract Trader Manager has no UI

`DTAbstract_DebugHub.lua` registers `dtabstract:traders` in the Core Debug Hub, but:

```lua
function DebugHub.Open()
    return true
end
```

There is no trader-manager window/list/buttons.

The smoke test verifies registration and helper-command dispatch only. It does not prove the documented player-facing manager exists.

P5 must be reopened.

## Finding D — debug results are sent but not received/presented

The server emits:

- `TraderSpawned`
- `TraderDebugActionResult`

No DTAbstract client `OnServerCommand` receiver handles those messages.

Therefore the explicit debug-result feedback required by the roadmap is not implemented.

Gameplay nearby notification and debug command result remain conceptually separate, but only the gameplay notification helper currently has presentation logic.

## Finding E — client actor/world projection is not synchronized

DTAbstract server lifecycle creates/updates Core actors in the server-side actor registry.

The client map, nearby discovery, and debug listing read `PsychopatzCore.Actors.DefaultRegistry` or a lifecycle registry if one is injected.

No production Core/DT transport was found that synchronizes the authoritative DTAbstract actor world/journey registry to clients.

The current map/discovery/debug smokes inject one in-process registry into both producer and consumer. That is not equivalent to native client/server separation.

This can make the client know the trader record while lacking the actor world needed to determine its current position.

P3, P4 and P5 therefore remain incomplete even though their algorithmic smokes pass.

## Finding F — production actor persistence is not wired

Core exposes registry `Save`/`Load`, and the P7 smoke manually serializes a registry, reconstructs a fresh registry, and verifies it.

No production DTAbstract/Core persistence path was found that actually invokes the actor-registry save/load lifecycle for these standalone actors.

A persisted DT trader can therefore retain `actorID` while the corresponding Core actor is absent after a real restart.

The manual codec proof is valuable but is not production persistence acceptance.

P2/P7 must remain open until real save/reload wiring and recovery are proven.

## Finding G — provider handoff is adapter compatibility, not production orchestration

Production DTAbstract lifecycle calls `Acquire`.

No production DTAbstract runtime path currently drives the complete:

`Switch/Materialize/Dematerialize/Release`

handoff according to proximity/provider availability.

`dt_abstract_hybrid_handoff_smoke.lua` manually invokes the provider adapters in sequence.

That proves the low-level adapters can interoperate; it does not prove automatic runtime handoff exists.

P6 must be reopened.

## Finding H — some documented debug actions are incomplete

`DebugHub.SpawnAt(x, y, z, ...)` dispatches the same `SpawnAbstractTraderNearPlayer` command, while the server currently computes its own deterministic 25-tile offset and does not honor the supplied explicit position.

Materialize/dematerialize controls documented in the acceptance contract are also not exposed in the current manager helper set.

## Finding I — settlement-directory ownership needs cleanup

`DTCommon_SettlementDirectory.lua` provides a useful bounded provider registry and standalone defaults.

However:

- the default entries are fixed Knox population centers, not Hoomans-style generated settlements;
- the module directly special-cases `PNC.Communities` despite already having a provider-registration seam.

The direct PNC fallback leaks optional adopter knowledge into DTCommon and should become a narrow Hoomans/DTHoomans adapter provider.

Whether standalone DTAbstract should use fixed trading hubs, generated settlements, or both must remain explicit product policy rather than being accidentally implied by the word “settlement.”

## Finding J — metadata is stale

`DTAbstract/42.20/mod.info` still describes the module as only optional remote/radio access even though it now contains standalone simulation code.

## Revised verdict

The initial P0–P7 work is **PARTIAL / REOPENED**.

Current truth:

- projected-position math: implemented and useful;
- bounded settlement registry: implemented, ownership cleanup required;
- server abstract lifecycle: substantial implementation, production persistence/recovery incomplete;
- map marker model: implemented, production Core-host attachment/synchronization incomplete;
- nearby algorithm: implemented, authoritative client projection incomplete;
- Debug Hub registration/helpers: implemented, actual manager UI/result receiver incomplete;
- provider adapters: compatible, production handoff orchestration incomplete;
- smoke suite: 50/50 green, but missing native-equivalent integration contracts.

The correct next work is a **Core Map/Projection Consolidation recovery**, not more isolated marker styling.
