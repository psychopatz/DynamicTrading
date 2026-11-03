# Acceptance — DTAbstract World Simulation & Presentation

## Evidence categories

Report evidence precisely as one of:

- source/static;
- deterministic Lua smoke;
- production-module integration smoke;
- persistence/reload;
- cross-repository regression;
- native SP;
- native MP.

Mocks do not count as native acceptance.

## Baseline preservation

Before changing behavior, retain green coverage for at least:

- `tests/dt_npc_provider_adapter_smoke.lua`;
- `tests/dt_radio_os_abstract_provider_smoke.lua`;
- `tests/dt_mapping_smoke.lua`;
- relevant settlement visit/exchange tests;
- relevant provider hotswap/persistence tests.

Capture exact baseline failures if repository state differs.

## P0 fail-first requirements

Add focused evidence for the currently missing surfaces.

The tests should demonstrate that, before implementation, there is no production path satisfying:

1. standalone DTAbstract server trader creation;
2. standalone settlement name+position resolution;
3. moving trader map projection;
4. nearby detection notification;
5. dedicated DTAbstract Debug Hub spawn path.

Do not satisfy P0 by grep-only assertions after the implementation is already written; retain behavioral tests that become green in later phases.

## Settlement-directory acceptance

At minimum:

- register/load two distinct standalone settlements;
- stable ID/name/position;
- duplicate ID rejected or deterministically replaced according to contract;
- invalid coordinates rejected;
- bounded maximum enforced;
- lookup is indexed;
- Hoomans adapter uses canonical community identity when present;
- market state is not duplicated into directory payload;
- standalone operation has no Hoomans global dependency.

## Actor/journey-position acceptance

At minimum:

- one trader binds one Core actor;
- actor carries DTAbstract provider lease;
- journey origin position is exact;
- midpoint projection is deterministic;
- destination projection is exact;
- arrival and projected position agree;
- zero/short journey is safe;
- invalid/stale journey fails or degrades explicitly;
- map, nearby detection and debug locate consume the same projected-position query.

If Core changes, run Core actor/world/journey/provider suites and static checks.

## Standalone lifecycle acceptance

Flagship scenario:

```text
settlement A
settlement B
no existing trader
       |
DTAbstract creates trader T + actor A
       |
T is at A
       |
DTAbstract selects B
       |
Core journey advances
       |
midpoint is observable
       |
T arrives at B
       |
one MarkSettlementVisit/exchange
       |
merchant stock/market revisions remain coherent
       |
next route/cooldown policy continues
```

Required invariants:

- client cannot create/advance authority;
- duplicate tick/arrival cannot double exchange;
- reopening trade UI does not reroll stock;
- merchant stock remains DTCommon-owned;
- no physical body is required;
- lifecycle work is bounded.

## Debug spawn acceptance

**Spawn Abstract Trader Near Player** must prove:

- debug permission checked;
- server mutation path;
- no DTHoomans spawn call required;
- explicit trader/actor IDs;
- explicit abstract provider state;
- position near but not invalid/on-top according to policy;
- clear rejection reason on failure;
- repeated calls create distinct bounded debug traders or reject deterministically;
- spawn result message is not mistaken for gameplay nearby detection.

## Map acceptance

Deterministic map-model tests must prove:

- two settlement entries;
- one trader entry;
- exact coordinate agreement with simulation state;
- moving trader position changes after journey advancement;
- no duplicate marker after refresh;
- normal visibility vs debug show-all behavior;
- map read path has no market/trader mutation;
- standalone map provider loads without Project Hoomans.

Native SP must later prove the actual vanilla map hook paints and updates correctly.

## Nearby/notification acceptance

At minimum:

- distance outside radius: no detection;
- cross into radius: one detection;
- one known/discovery state transition;
- one notification ID;
- repeated checks inside: no duplicate;
- edge jitter within hysteresis: no flap;
- real exit + cooldown: eligible later according to policy;
- notification queue bounded;
- client UI presentation can fail without corrupting server discovery state.

## Debug Manager acceptance

Exercise every mandatory action through the production debug command/router path:

- list/refresh;
- spawn near;
- optional explicit-position spawn;
- force tick;
- force/advance arrival;
- locate/show;
- teleport;
- discovery reset/mark;
- remove debug trader;
- provider materialize/dematerialize when available.

Each action returns a structured success/failure result.

## Hybrid provider acceptance

At minimum:

- start with DTAbstract lease;
- switch/materialize through DTHoomans;
- same Core actor ID;
- same DT trader ID;
- same merchant stock/version;
- exactly one live body;
- dematerialize persists live actor projection;
- switch back/resume abstract state;
- save/reload;
- no duplicate visit/exchange;
- missing physical provider leaves actor safely abstract.

## Persistence acceptance

Reconstruct from fresh storage/module state where the repository harness supports it.

Do not only reuse the same Lua table reference.

Prove canonical identity, provider lease, journey, settlement context and merchant state survive the intended reload boundary.

## Performance acceptance

Instrument or bound:

- lifecycle evaluations per interval;
- trader count;
- settlement count;
- nearby distance checks;
- map projection rebuild count;
- notifications;
- serialized bytes for new persistent state.

Explicit failures:

- `Events.OnTick`/render callback scanning every trader for simulation;
- full MarketSense registry scan per lifecycle/proximity/map refresh;
- unbounded settlement/trader map arrays;
- one notification per proximity check;
- duplicated journey interpolation logic.

## Static/repository checks

For changed production Lua run applicable:

- `luac -p` or repository Lua parse checks;
- Kahlua compatibility verification where available;
- `git diff --check`;
- focused smoke tests;
- full relevant DynamicTrading suite;
- affected PsychopatzCore/ProjectHoomans suites if those repositories changed.

## Final developer gate

Developer-side acceptance requires all P0–P7 gates green from the exact intended repository revisions.

Native SP/MP may remain explicitly user-owned, but only after all non-native implementation/testing is complete.
