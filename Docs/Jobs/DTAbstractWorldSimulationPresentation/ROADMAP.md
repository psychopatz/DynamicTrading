# Roadmap — DTAbstract World Simulation & Presentation

## Parent completion boundary

The parent goal is complete only when DTAbstract is a real standalone abstract trader-world provider and all mandatory P0–P7 gates pass.

A phase, commit, smoke test or debug window is not the parent completion boundary.

Developer-side completion requires:

- standalone abstract traders exist and persist;
- authoritative settlement geography exists for standalone routing/presentation;
- abstract traders travel through real Core world/journey state;
- trader and settlement markers work on the vanilla world map;
- moving trader markers use the same projected position as proximity/debug logic;
- nearby trader detection and one-shot/cooldown notification work;
- dedicated DTAbstract spawn/debug tooling works through server authority;
- existing radio/Talk/trade behavior remains intact;
- hybrid DTAbstract ↔ DTHoomans provider handoff preserves one canonical trader/actor;
- persistence/performance/regression gates pass;
- only explicit native SP/MP acceptance may remain user-owned.

## P0 — Ground truth, fail-first coverage and contracts

### P0A — Reproduce the missing product surface

Add focused tests/fixtures that fail for the audited gaps without implementing them yet.

Required fail-first coverage:

- no DTAbstract server lifecycle/director exists;
- no standalone abstract trader can be spawned through a DTAbstract server command;
- no authoritative standalone settlement directory can resolve name + position;
- no production trader/settlement map projection exists;
- no nearby discovery notification path exists;
- no dedicated DTAbstract Debug Hub tool exists.

The tests must exercise production module entry points where possible, not merely assert file names.

### P0B — Settlement and map contract audit

Audit before implementation:

- current DTCommon settlement-market IDs and lifecycle policy;
- current DTHoomans caravan count/cadence/destination policy so standalone mode does not accidentally diverge for arbitrary reasons;
- current Core actor journey/world/provider APIs;
- current Hoomans world-map behavior only as presentation/reference, not as a standalone dependency;
- current vanilla map hooks;
- current persistence/storage ownership;
- installed dependency/mod-info requirements.

Decide and document the smallest implementation for:

1. bounded settlement directory/provider;
2. canonical projected current journey position;
3. generic vs DT-specific vanilla-map overlay seam.

### P0 gate

P0 passes when the failing product gaps are captured, the settlement geography source is explicit, moving-position ownership is explicit, and no implementation depends on copying PNC state or inventing UI-only coordinates.

Then continue immediately to P1.

## P1 — Settlement directory and canonical actor/world bootstrap

### Work

Implement the bounded settlement-directory/provider contract needed by both route planning and map presentation.

Requirements:

- stable settlement ID;
- display name;
- authoritative position;
- provider/source ID;
- enabled/valid state;
- profile/economic context where appropriate;
- bounded indexed enumeration/query;
- Hoomans adapter when available;
- standalone DTAbstract data/provider source when Hoomans is absent;
- no duplicate market-state storage.

Establish one canonical Core actor binding for standalone traders:

```text
DT trader record
  ↔ Core actor ID
  ↔ DTAbstract provider lease
```

Existing compatible trader records must migrate/adopt safely instead of creating duplicate identities.

If Core lacks a reusable current-position projection for an active journey, add the smallest generic Core API and tests there.

### P1 gate

- two standalone settlements resolve distinct stable IDs/names/positions;
- save/reload or registry reconstruction preserves canonical identity semantics;
- one standalone trader binds one Core actor;
- projected position is deterministic at origin/mid-journey/arrival;
- no Hoomans dependency is required for standalone fixtures;
- existing Core provider and DT radio-provider smokes remain green.

## P2 — Standalone server lifecycle and debug-spawn foundation

### Work

Add a real `server/DTAbstract` composition/lifecycle.

The director must:

- ensure a bounded standalone trader population according to explicit shared/configured policy;
- create trader + Core actor + DTAbstract lease coherently;
- choose only valid settlement destinations;
- start Core abstract journeys;
- advance them by authoritative game time at bounded cadence;
- update current/origin/destination settlement context coherently;
- apply exactly one normal DT settlement visit/exchange on arrival;
- choose/queue the next route after the accepted cooldown/policy;
- recover safely when destination/provider data becomes invalid;
- never run a per-frame all-trader scan.

Add the first dedicated debug command:

**Spawn Abstract Trader Near Player**

It must:

- be debug-authorized;
- be server-authoritative;
- create an abstract trader, not a Hoomans body;
- choose a deterministic/safe nearby world position;
- return trader ID, actor ID, position, provider state and explicit reason/status;
- remain distinct from gameplay nearby-detection notification.

### P2 gate

A deterministic standalone scenario proves:

```text
no trader
→ debug/production create
→ canonical Core actor
→ DTAbstract lease
→ journey A → B
→ mid-journey position changes
→ arrival B
→ exactly one settlement exchange
→ next lifecycle state
```

Repeat arrival/tick/reload cannot duplicate the economic mutation.

## P3 — Functional world-map presentation

### Work

Render DTAbstract traders and trading settlements on the vanilla world map.

Mandatory behavior:

- trader markers use canonical projected current position;
- settlement markers use settlement-directory position;
- trader marker moves as the abstract journey advances;
- marker labels/state are data-driven;
- debug mode can show all;
- normal mode respects chosen discovery/visibility policy;
- map rendering never mutates trader/world/market state;
- no Hoomans dependency is required in standalone mode.

If a reusable Core overlay host is introduced, it must remain domain-agnostic and have Core-only tests. Do not move trader policy into Core.

### P3 gate

With two settlements and one traveling trader:

- both settlement markers render at their authoritative coordinates;
- trader marker renders at the same position returned by the canonical projected-position query;
- after time advances, the marker moves;
- on arrival it converges to the destination;
- no duplicate marker appears after refresh/reload/provider change;
- map can open/close repeatedly without rebuilding simulation state.

## P4 — Nearby discovery and notification

### Work

Implement bounded nearby trader detection over the same projected position used by the map/debug systems.

Required state behavior:

- outside detection radius;
- one enter transition;
- one discovery/known-state update;
- one notification;
- no repeated notification while remaining inside;
- exit hysteresis/cooldown before re-eligibility;
- no client-authoritative spawn/travel mutation.

Use PsychopatzCore's notification presentation rather than a new DT popup framework.

Notification content must identify the event truthfully without exposing debug internals.

### P4 gate

Tests prove:

- outside → inside triggers exactly once;
- repeated checks inside do not spam;
- inside → partial edge jitter does not flap;
- true exit + cooldown permits a later new detection if policy allows;
- multiple traders are bounded/deterministic;
- map visibility/discovery changes as designed;
- gameplay notification and debug spawn result are independently observable.

## P5 — Dedicated DTAbstract Trader Manager

### Work

Register a DTAbstract-specific tool in the PsychopatzCore Debug Hub.

Minimum read-only inspection:

- trader ID/name;
- actor ID;
- provider/provider state;
- current projected position;
- current/origin/destination settlement;
- journey state/progress/ETA where available;
- distance from player;
- discovered/known state;
- merchant stock/version summary without duplicating the stock owner.

Minimum actions:

- Spawn Abstract Trader Near Player;
- spawn at explicit world/map position where safe;
- force one lifecycle tick;
- force/advance arrival for deterministic testing;
- show/locate on map;
- teleport player to trader;
- reset/mark discovery;
- remove a debug-created abstract trader;
- request materialize/dematerialize only when the physical provider is available.

All mutations go through server commands with explicit action results.

### P5 gate

The Debug Hub can create, inspect and drive a standalone abstract trader without DTHoomans installed, and every action has deterministic success/failure feedback.

Debug actions do not bypass ordinary merchant stock/settlement exchange/provider invariants.

## P6 — Hybrid DTAbstract ↔ DTHoomans provider handoff

### Work

Use the existing Core provider contract to make the same canonical actor switch representation when physical integration is available.

Required behavior:

- DTAbstract remains the far/offscreen abstract representation;
- approved nearby/materialization condition can request physical handoff;
- DTHoomans materializes the same actor identity;
- merchant stock remains the same DTCommon record;
- personal actor state remains Core/Hoomans-owned;
- provider/body uniqueness remains enforced;
- dematerialization persists live state and returns ownership cleanly;
- journey/current position does not reset to origin;
- no duplicate settlement visit/exchange occurs because of provider transition;
- physical-provider absence degrades safely to abstract-only behavior.

Do not create a second physical simulation path inside DTAbstract.

### P6 gate

Standalone, physical and hybrid tests prove one actor/trader identity through:

```text
DTAbstract abstract
→ materialize DTHoomans
→ interact/trade state preserved
→ dematerialize
→ DTAbstract resumes
→ save/reload
```

No duplicate body, stock, identity or arrival mutation is observed.

## P7 — Persistence, performance, regression and native handoff

### Persistence

Prove save/reload for:

- trader ↔ actor binding;
- DTAbstract provider lease;
- world position;
- active journey and progress/timing;
- current/origin/destination settlement context;
- discovery/cooldown state only where durable persistence is actually required;
- settlement-directory provider data/reference as designed;
- debug-only state does not contaminate normal persistent gameplay unnecessarily.

### Performance

Measure or assert bounded behavior for representative trader/settlement counts.

Reject:

- per-frame all-trader scans;
- per-frame all-settlement map rebuilds;
- full MarketSense scans for movement/discovery;
- unbounded notification history;
- duplicate map registries per refresh.

### Regression

Run the full relevant DynamicTrading suite plus affected Core/Hoomans suites when those repositories change.

Mandatory preserved behavior includes:

- `dt_npc_provider_adapter_smoke.lua`;
- `dt_radio_os_abstract_provider_smoke.lua`;
- DT settlement visit/exchange tests;
- DTHoomans caravan/settlement trader tests;
- existing Radio OS/Talk/trade/security tests.

### Native user acceptance

Only after all developer-side gates pass, hand off normal Project Zomboid SP/MP validation for:

- map visuals/interaction;
- live notification presentation;
- Debug Hub buttons;
- standalone DTAbstract world behavior;
- hybrid materialization/dematerialization;
- no duplicate traders or stale markers after save/reload.

Do not claim native acceptance from Lua mocks.

## Optional later work — not part of completion

Do not expand this job into:

- a full new strategic map UI;
- manual player route assignment UI;
- quests/contracts;
- full faction macro-simulation;
- new Radio OS art;
- broad Hoomans map refactor unrelated to the reusable seam;
- full physical long-distance pathfinding;
- an unlimited procedural settlement generator.

Complete P0–P7 first.
