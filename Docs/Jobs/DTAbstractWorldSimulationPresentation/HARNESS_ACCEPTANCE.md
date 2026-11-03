# Acceptance — DTAbstract World Simulation & Presentation

## Evidence rule

The 2026-11-03 audit showed that green helper-level smokes can coexist with broken production integration.

Use these evidence classes explicitly:

- source/static;
- unit/helper smoke;
- production composition smoke;
- split authority/client integration;
- production persistence/reload;
- cross-repository regression;
- native SP;
- native MP.

Do not promote a weaker class into a stronger claim.

## Existing foundation to preserve

Keep green where still relevant:

- `dt_npc_provider_adapter_smoke.lua`;
- `dt_radio_os_abstract_provider_smoke.lua`;
- `dt_abstract_settlement_directory_smoke.lua`;
- `dt_abstract_lifecycle_smoke.lua`;
- `dt_abstract_map_smoke.lua`;
- `dt_abstract_nearby_discovery_smoke.lua`;
- `dt_abstract_debug_hub_smoke.lua`;
- `dt_abstract_hybrid_handoff_smoke.lua`;
- `dt_abstract_persistence_performance_smoke.lua`.

These are foundation tests, not sufficient final acceptance.

## One-map-host acceptance

Required source/composition evidence:

- PsychopatzCore owns one generic production `ISWorldMap` integration.
- DTAbstract contains no direct production `ISWorldMap.render` monkey patch after migration.
- ProjectHoomans generic map host no longer owns a parallel patch.
- Hoomans-specific layers register through Core.
- DTAbstract layer registers through Core.
- unregister works.
- consumer render failure does not suppress other layers.
- load order permutations do not change registration.
- combined Hoomans + DTAbstract produces one render pass host, not nested adopter hooks.

A direct call to `WorldMap.Render(mockMap)` does not satisfy this gate.

## Client projection acceptance

Use **separate server and client stores**.

Required scenario:

```text
server actor at A
server starts journey A -> B
server projection revision N
client receives N
server advances
server emits N+1
client applies N+1
map/debug/discovery read N+1
stale N is rejected
```

No shared actor registry table/object may be injected into both sides.

Test reconnect/full resync and bounded payload size.

## Persistence acceptance

The test must exercise production persistence lifecycle entry points.

Required:

- save;
- destroy module/registry state;
- reconstruct/load through production path;
- trader actorID resolves to an actual actor;
- journey/provider lease preserved;
- lifecycle continues;
- missing actor linkage follows explicit repair/quarantine path;
- no duplicate actor on retry.

Manual `registry:Save()` + `registry:Load()` in the test is codec evidence only.

## Debug Manager UI acceptance

The Core Debug Hub action must open a real production UI object.

Test:

- window/panel instantiates;
- trader list renders/refreshes;
- each mandatory action is reachable;
- selected trader binding is correct;
- action result area/message updates on server result;
- error results are visible;
- close/reopen is stable.

`DebugHub.Open() == true` is not acceptance.

## Debug transport acceptance

Server command:

- validates debug authorization;
- mutates authority only;
- returns structured result.

Client:

- has registered `OnServerCommand` handler;
- filters module/command correctly;
- renders/records result;
- does not confuse result with gameplay notification.

## Spawn At acceptance

Request explicit coordinates and assert the created actor/projected position matches the requested position subject only to documented safe normalization.

Reusing the near-player offset path while ignoring coordinates fails this gate.

## Nearby discovery acceptance

Run against synchronized client projection.

Required:

- outside: no notification;
- enter: one detection;
- remain inside: no spam;
- hysteresis: no flap;
- true exit + cooldown: later re-entry can notify;
- server movement reflected through projection can cause detection even if the client never had the server registry;
- reconnect/resync does not duplicate notification unexpectedly.

## Provider handoff acceptance

The test invokes production orchestration.

Required:

- DTAbstract abstract state;
- materialization condition becomes true;
- production runtime requests provider transition;
- DTHoomans materializes same actor;
- one body;
- same trader stock/budget;
- leave condition;
- production runtime dematerializes/releases;
- DTAbstract resumes;
- save/reload/reconnect in transition-safe states;
- no duplicate settlement exchange.

A test that manually calls adapter `Acquire/Release/Materialize/Dematerialize` in sequence is adapter compatibility only.

## Settlement directory acceptance

Preserve bounded registry/index validation.

Additionally:

- DTCommon does not directly reference `PNC.Communities`;
- Hoomans geography arrives through a registered optional provider;
- standalone default-settlement policy is documented;
- generated Hoomans settlements and fixed Knox trading hubs cannot silently collide by ID;
- map labels/positions use the same directory contract as routing.

## Cleanup acceptance

Search all three repositories for:

- `ISWorldMap.render` patches;
- generic map registries;
- toolbar registries;
- world-discovery debug host registrations;
- stale `MapOverlayRegistry` assumptions;
- old compatibility shims.

For every remaining implementation, document why it still owns a unique responsibility.

No “legacy” copy may remain active merely for convenience after all callers have migrated.

## Performance acceptance

Measure/bound:

- actor projection payload count/bytes;
- update cadence/revision churn;
- nearby checks;
- map renders;
- lifecycle ticks;
- trader count;
- settlement count.

Reject:

- full actor registry broadcast every frame;
- full trader/world scan every render solely for synchronization;
- multiple map-host patches;
- duplicate notifications;
- unbounded debug/history state.

## Final developer gate

Developer-side completion requires all R0–R7 gates in `ROADMAP.md`.

Only then return to native SP/MP user acceptance.
