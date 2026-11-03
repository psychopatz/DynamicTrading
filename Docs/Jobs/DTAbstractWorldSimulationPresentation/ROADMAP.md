# Roadmap — DTAbstract World Simulation & Presentation

## Parent completion boundary

The parent goal is complete only when DTAbstract works as a standalone abstract trader-world provider in real production wiring and the shared Core map/presentation migration is clean.

The previous “P0–P7 complete” status is superseded by the 2026-11-03 audit.

## Evidence status of original phases

| Phase | Current status | Reason |
| --- | --- | --- |
| P0 contracts/audit | ACCEPTED FOUNDATION | Useful fail-first tests/contracts exist. |
| P1 settlement/projected position | PARTIAL | Core projected-position math is valid; settlement ownership cleanup remains. |
| P2 standalone lifecycle | PARTIAL | Server lifecycle exists; production actor persistence/recovery is incomplete. |
| P3 world map | REOPENED | Marker model exists; one-Core-map-host integration and client projection are missing. |
| P4 nearby discovery | REOPENED | Algorithm exists; authoritative client world projection is missing. |
| P5 Debug Manager | REOPENED | registration/helpers exist; actual UI/result receiver is missing. |
| P6 hybrid handoff | REOPENED | adapters interoperate synthetically; production orchestration is absent. |
| P7 persistence/integration | REOPENED | codec smoke exists; production save/load and integration proof are missing. |

The recovery phases below replaced the old completion claim.

## Recovery completion status — 2026-11-03

All R0–R7 **developer-side** gates are now accepted. Native SP/MP acceptance remains user-owned and pending.

Cross-repository recovery commits:

- PsychopatzCore `d7a892155e8e890b6af87d4b7a322f0ac3e62ec4`;
- ProjectHoomans `564f3656f09b443dc0c2bcda8b9886905baf7152`;
- DynamicTrading: the commit containing the completed recovery ledger.

| Recovery phase | Status | Developer evidence |
| --- | --- | --- |
| R0 | ACCEPTED | Production gaps covered by new/updated regression contracts. |
| R1 | ACCEPTED | One Core map host; Hoomans and DTAbstract are consumers; both load orders pass. |
| R2 | ACCEPTED | Separate authority/client projection stores, transport/resync, stale rejection. |
| R3 | ACCEPTED | Production GlobalModData save/load hook, orphan quarantine/recovery, settlement adapter boundary. |
| R4 | ACCEPTED | Real manager UI, result receiver, exact Spawn At, centered Locate on Map. |
| R5 | ACCEPTED | Nearby discovery reads synchronized/interpolated client projection. |
| R6 | ACCEPTED | Production proximity handoff, same actor/lease, physical rebase, missing-body recovery. |
| R7 | DEV ACCEPTED | Redundant hooks removed/reduced; cross-repo regression/static/Kahlua gates pass for affected surfaces. |

Final recovery verification:

- DynamicTrading: **57/57** full suite.
- Core affected actor/map/provider/persistence tests: pass.
- Hoomans affected map/command/community tests: pass.
- changed production Lua: `luac -p` pass.
- installed-PZ Kahlua compiler: Core **8/8**, Hoomans **4/4**, DynamicTrading **16/16**.
- `git diff --check`: pass.
- source sweep: the only active `ISWorldMap` lifecycle owner in the three-repo matrix is Core `PsychopatzMapHost`.

Broad-suite unrelated drift is recorded in `PROGRESS.md`; it is not silently treated as recovery acceptance.

The remaining work is the native SP/MP matrix under R7. A native failure reopens only the affected gate.


## R0 — Recovery baseline and fail-first integration tests

Add tests that fail against the current source for the newly verified gaps.

Mandatory fail-first evidence:

1. one Core production world-map host exists and owns the only `ISWorldMap` patch;
2. ProjectHoomans registers its generic layers/tools through Core rather than its own host;
3. DTAbstract registers through Core and has no direct fallback map monkey patch;
4. mixed load order still installs both adopter layers;
5. server actor/world projection reaches a distinct client-side projection store;
6. DTAbstract map/discovery/debug use the client projection rather than a shared in-process server registry;
7. Debug Hub action opens a real manager UI;
8. `TraderDebugActionResult` is received/presented;
9. explicit `Spawn At` coordinates are honored;
10. production save/load restores DTAbstract actor/journey/provider state;
11. production runtime drives hybrid provider handoff.

### R0 gate

No implementation starts until each production gap is represented by a test or an explicit native-only acceptance item that cannot be meaningfully automated.

## R1 — PsychopatzCore map host + Hoomans migration

Implement the missing reusable Core world-map mechanism.

Core responsibilities:

- require/load the vanilla map deterministically;
- own the single production `ISWorldMap` render integration;
- ordered overlay registry with register/unregister;
- generic map tool/toolbar registry where needed;
- safe load-order behavior;
- consumer failure isolation;
- no Hoomans/DT policy in Core.

Migrate ProjectHoomans generic infrastructure:

- PNC map layers become Core registry consumers;
- Hoomans-specific display/debug policy stays in Hoomans;
- old generic PNC host/toolbar monkey patches are removed or reduced to thin compatibility adapters only while needed;
- no duplicate active host remains.

Then migrate DTAbstract:

- register its layer through Core;
- remove the direct `ISWorldMap.render` fallback;
- keep DT-specific marker construction in DTAbstract.

### R1 gate

Static/source test proves exactly one production map render hook in the intended mod matrix.

Core-only + Hoomans-only + DTAbstract-only + combined map registration tests pass.

## R2 — Authoritative actor presentation sync

Add the smallest reusable Core authority→client projection mechanism required by map/debug/discovery.

Requirements:

- bounded actor presentation snapshot/delta;
- actor ID + revision;
- provider/provider state;
- current projected position;
- bounded journey summary;
- server authority;
- client read-only application;
- stale/out-of-order rejection;
- disconnect/reconnect/resync path;
- no full private actor dump if unnecessary.

DTAbstract map, nearby discovery and debug list must stop reading an unsynchronized server registry assumption.

### R2 gate

A split server/client harness proves:

```text
server journey advances
-> projection emitted
-> separate client store applies
-> map/debug/discovery all observe same revision/position
```

No shared Lua registry object is permitted in this acceptance test.

## R3 — Production persistence and recovery

Wire canonical actor registry persistence into the actual production save/load lifecycle used by Core/DTAbstract.

Requirements:

- save actor registry/projection state through the real storage owner;
- load before DTAbstract lifecycle relies on actor links;
- preserve provider lease/journey/current position;
- deterministic recovery for trader record with missing actor;
- no duplicate actor creation on delayed load;
- save/reload in SP and server-authoritative MP design remains coherent.

Clean settlement-directory ownership in the same phase:

- remove direct PNC special-case lookup from DTCommon;
- provide an optional Hoomans/DTHoomans settlement provider adapter;
- document whether standalone defaults are fixed trading hubs, generated settlements, or both.

### R3 gate

Fresh-process persistence test must call production save/load entry points, not manually call `registry:Save()` from the test.

## R4 — Real DTAbstract Trader Manager + result presentation

Build the actual player-facing Debug Hub manager.

Required UI:

- trader list + refresh;
- ID/name/provider/state;
- position/distance;
- current/origin/destination settlement;
- journey progress;
- Spawn Near;
- Spawn At;
- Force Tick;
- Force Arrival;
- Locate on Map;
- Teleport;
- discovery reset/mark;
- Remove;
- Materialize/Dematerialize when available.

Implement client `OnServerCommand` handling for:

- `TraderSpawned`;
- `TraderDebugActionResult`.

Show clear action result/status without conflating it with gameplay nearby notification.

Fix `Spawn At` so explicit coordinates are actually respected.

### R4 gate

UI construction test must instantiate the production manager surface and verify controls/actions are reachable.

A helper API test alone is insufficient.

## R5 — Nearby discovery over synchronized authority

Refactor nearby discovery to consume the R2 client presentation projection.

Preserve:

- enter radius;
- exit hysteresis;
- cooldown;
- no spam;
- one discovery transition;
- existing Core notification UI.

Add server/client separation tests and reconnect/resync behavior.

### R5 gate

Distinct server/client fixture proves movement into range becomes visible to the client without sharing actor registry tables.

## R6 — Production provider-handoff orchestration

Implement the real runtime policy that drives the already-compatible provider adapters.

Requirements:

- approved proximity/materialization condition;
- DTAbstract relinquishes according to Core lease rules;
- DTHoomans materializes the same actor;
- no duplicate body/trader/stock;
- physical exit/dematerialization returns updated projection;
- DTAbstract resumes from the correct world state;
- save/reload/reconnect during each provider state is coherent;
- absence of DTHoomans leaves actor abstract safely.

### R6 gate

The test calls production orchestration entry points, not a handwritten sequence of adapter calls.

## R7 — Cleanup, regression and native handoff

### Legacy/redundancy cleanup

Audit and remove/reduce obsolete active infrastructure after migrations:

- duplicate `ISWorldMap` patches;
- obsolete generic PNC map host/toolbar files;
- stale fallback code;
- stale compatibility routes that are no longer required;
- stale DTAbstract module metadata/description.

Do not delete Hoomans-specific layers/policy merely because their host moved to Core.

### Regression

Mandatory:

- full DynamicTrading suite;
- Core map/actor/provider/persistence suites;
- Hoomans map/discovery/travel/debug suites;
- DTHoomans lifecycle/provider suites;
- Kahlua/Lua parse checks;
- `git diff --check`.

### Native handoff

R0–R7 developer gates have passed; the job is now at user-owned native acceptance.

Native matrix:

- standalone DTAbstract map markers;
- moving trader marker;
- actual Abstract Trader Manager UI;
- spawn result feedback;
- nearby gameplay notification;
- save/reload;
- Hoomans map controls still present through Core host;
- combined Hoomans + DTAbstract map without duplicate hooks/markers;
- hybrid materialize/dematerialize;
- MP reconnect/authority sanity.

## Stop conditions

Do not stop after:

- Core map registry creation;
- one green mock;
- Debug Hub registration;
- actor snapshot transport;
- a commit.

Stop only when R0–R7 are developer-side accepted or a genuine blocker prevents further work.
