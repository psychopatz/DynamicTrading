# Acceptance — Unified Trader World Runtime

## Status

**Developer acceptance: COMPLETE. Native acceptance: PENDING.**

## Common-domain lifecycle

Evidence: dt_trader_world_common_smoke.lua.

Verified with no DTAbstract, DTHoomans, or PNC globals:

- bounded trader population;
- route selection;
- canonical journey state;
- provider movement observation;
- arrival;
- exactly-once visit;
- cooldown;
- persistence touches;
- open provider registration.

## Provider and representation contract

Evidence includes:

- dt_trader_representation_runtime_smoke.lua;
- dt_provider_runtime_handoff_smoke.lua;
- dt_provider_hotswap_persistence_smoke.lua;
- dt_trader_projection_common_smoke.lua.

Verified:

- origin provider preserved through temporary materialization;
- native physical trader is not auto-dematerialized;
- failed materialization rolls back lease and return-provider metadata;
- missing-body recovery returns to origin provider;
- journey identity survives handoff;
- physical final position rebases resumed journey;
- common projection includes abstract and physical providers;
- live physical position overrides stale abstract projection.

## Single-authority proof

Source audit confirms:

- one commercial lifecycle tick in DTCommon;
- no old DTAbstract or DTHoomans commercial lifecycle files;
- no direct adopter implementation reference in DTCommon;
- no direct DTAbstract and DTHoomans production cross-reference.

Arrival effects route through DTCommon TraderWorld.

## DTAbstract adapter

Verified:

- abstract provider world smoke;
- map smoke;
- nearby discovery smoke;
- Debug Hub smoke;
- radio provider smoke;
- orphan reconciliation;
- persistence and performance bounds.

DTAbstract no longer owns destination selection, commercial arrival, cooldown, or provider handoff policy.

## DTHoomans adapter

Verified:

- caravan creation and flagship smoke;
- commercial mobility;
- resident excursion;
- settlement visit contract;
- settlement logistics;
- physical provider runtime handoff;
- physical radio provider;
- physical trade presentation path;
- Hoomans focused mobile-group, traversal, admission, excursion, and staffing regressions.

DTHoomans retains Hoomans mechanics but does not own a parallel commercial lifecycle.

## Interaction and optional-adopter isolation

Common contact construction, access integration, and trade-presentation registries are covered by DynamicTrading tests.

Source search finds no PNC, DTHoomans, or DTAbstract implementation reference under DTCommon production Lua.

The real ProjectHoomans cross-adopter hot-plug matrix passes all six sequences, including add/remove/re-add, capability isolation, grounded trader whereabouts, excursion lifecycle, persistence reconstruction, semantic pack hot-plug, and repeated-sync idempotence.

## Performance bounds

Verified constants include:

- roaming traders: 2;
- settlement directory: 256;
- provider registry: 16;
- integration adapters: 16;
- contact enumeration: 64;
- contact page: 12;
- Core projection entries: 256;
- Core projection payload: 256 KiB;
- nearby discovery cadence: 2 seconds;
- representation handoff cadence: 2000 ms.

## Developer regression evidence

DynamicTrading:

- 59/59 full suite;
- git diff --check pass;
- 43 changed production Lua files pass luac;
- 43 changed production Lua files pass installed-PZ Kahlua verification.

PsychopatzCore focused matrix:

- actor;
- provider lease;
- runtime store;
- projection sync;
- projection transport;
- map host.

All pass.

ProjectHoomans:

- focused commercial and mobile matrix: pass;
- real cross-adopter hot-plug matrix: pass;
- aggregate: 982/987.

Five aggregate failures remain outside this job and are listed in PROGRESS.md.

## Native acceptance

Still required in Project Zomboid:

- standalone DTAbstract;
- physical DTHoomans trader and caravan;
- approach and materialize;
- physical movement;
- leave and dematerialize;
- resident excursion;
- save and reload abstract;
- save and reload materialized;
- SP;
- MP and reconnect/resync;
- no duplicate body, trader, visit, or exchange;
- map, nearby notification, radio, trade UI, and NPC conversation parity.

Do not publish solely from automated acceptance.
