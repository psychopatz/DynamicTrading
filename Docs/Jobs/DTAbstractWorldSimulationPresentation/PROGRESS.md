# Progress — DTAbstract World Simulation & Presentation

## Parent status

**DEVELOPER-SIDE COMPLETE — native SP/MP acceptance pending.**

The 2026-11-03 recovery reopened the earlier P0–P7 claim because production map ownership, client projection, persistence wiring, Debug Manager UI, and provider orchestration were missing. Recovery phases R0–R7 are now implemented and developer-validated.

Do **not** promote this to full/native acceptance until the user-owned in-game matrix at the end of `ROADMAP.md` is exercised.

## Recovery commits

Cross-repository dependency commits:

- PsychopatzCore: `d7a892155e8e890b6af87d4b7a322f0ac3e62ec4`
  - shared production world-map host;
  - bounded actor authority→client projection transport;
  - production actor registry persistence wiring;
  - Core debug map contexts migrated into the shared host.
- ProjectHoomans: `564f3656f09b443dc0c2bcda8b9886905baf7152`
  - Hoomans map layers/tools/commands migrated to Core host adapters;
  - no active Hoomans `ISWorldMap` monkey patch remains.

The DynamicTrading recovery commit is the commit containing this ledger update.

## Implemented recovery

### R0 — Recovery baseline / characterization

Accepted.

The reopened production gaps are now represented by regression coverage or explicit native-only acceptance:

- combined Core map-host load orders;
- split server/client actor projection;
- real Debug Manager construction;
- debug result receiver;
- explicit Spawn At;
- production persistence event path;
- settlement-provider boundary;
- orphan actor reconciliation;
- production handoff orchestration;
- provider missing-body recovery.

### R1 — One Core map host

Accepted.

Current source sweep across PsychopatzCore, ProjectHoomans, and DynamicTrading finds one production `ISWorldMap` owner:

- `PsychopatzCore/UI/Map/PsychopatzMapHost.lua`.

Hoomans retains public `PNC.MapLayers` / `PNC.MapToolbar` compatibility facades, but they register into Core and no longer patch vanilla map lifecycle methods.

DTAbstract registers its overlay through Core and has no direct fallback `ISWorldMap.render` patch.

Core place/teleport debug right-click extensions also register through the same host context-provider registry.

Both combined load orders pass:

- Hoomans first → DTAbstract;
- DTAbstract first → Hoomans.

### R2 — Authoritative client actor presentation

Accepted.

Core now provides a bounded projection contract with:

- actor ID + revision;
- provider / provider state / body ID;
- projected position;
- bounded journey summary;
- source snapshot revision;
- stale snapshot rejection;
- client request/resync path.

DTAbstract map, nearby discovery, and Debug Manager use the separate client projection store rather than a server actor registry assumption.

Journey parameters are projected so clients can interpolate presentation position between authority snapshots without advancing canonical simulation state.

### R3 — Production persistence / settlement boundary

Accepted for developer-side validation.

Core's canonical default actor registry is attached to PZ GlobalModData authority lifecycle:

- `OnInitGlobalModData` → load;
- `OnSave` → save;
- SP/server authority guard;
- actor/journey/provider lease restoration.

The production-path persistence smoke invokes those event hooks rather than calling the registry codec directly.

DTAbstract reconciliation quarantines trader records whose actor link is missing and restores them when the actor becomes available again, preventing orphaned records from consuming the active abstract population.

DTCommon no longer directly references `PNC.Communities`. DTHoomans registers Hoomans community geography through `DTCommon.SettlementDirectory.RegisterProvider`.

Standalone fixed Knox trading hubs and generated Hoomans communities remain distinct providers/concepts.

### R4 — Real Abstract Trader Manager

Accepted.

The Core Debug Hub action now opens a real production manager window with:

- refreshable trader rows;
- ID/name/provider/state;
- current projected position/distance;
- current/destination route state and progress;
- Spawn Near;
- Spawn At Player / exact-position command;
- Force Tick;
- Force Arrival;
- Locate on Map;
- Teleport;
- Mark Seen / Reset Seen;
- Remove;
- Materialize / Dematerialize.

`Locate on Map` uses vanilla `ISWorldMap.ShowWorldMap(playerNum, x, y, zoom)` to center the real world map.

DTAbstract now receives and presents:

- `TraderSpawned`;
- `TraderDebugActionResult`.

Debug command transport uses the local player argument expected by the existing PZ client-command pattern.

### R5 — Nearby discovery over synchronized projection

Accepted.

Nearby discovery consumes the R2 client projection and preserves:

- enter radius;
- exit hysteresis;
- cooldown;
- no repeated in-range spam;
- discovery state.

Map, Debug Manager, and nearby discovery share the same projected actor/journey semantics.

### R6 — Production provider handoff

Accepted for developer-side validation.

Production bounded handoff now drives:

`DTAbstract abstract → DTHoomans materialized → DTAbstract abstract`

using the same canonical Core actor and provider lease.

DTHoomans:

- freezes materialization at the actor's current projected journey position;
- adopts a DT-only actor into a provider-owned full Hoomans record before body creation;
- uses existing Hoomans Core-provider/body lifecycle;
- rebases the remaining journey from the physical body's actual final position on dematerialization;
- removes the temporary provider-owned Hoomans projection after returning abstract;
- safely recovers a conclusively bodyless/stale materialized lease back to DTAbstract after Hoomans startup reconciliation.

DTAbstract's bounded proximity orchestrator triggers materialize/dematerialize rather than tests manually sequencing provider adapters.

Absence of DTHoomans leaves the actor abstract.

### R7 — Cleanup / regression / native handoff

Developer cleanup and regression gate accepted.

Removed/reduced active redundancy:

- Hoomans map render/toolbar/input monkey patches removed in favor of Core host adapters;
- DTAbstract map fallback patch removed;
- Core place/teleport debug map monkey patches consolidated into Core map context registry;
- DTCommon direct PNC settlement fallback removed;
- DTAbstract module metadata updated from radio-only wording.

Native SP/MP handoff remains user-owned and pending.

## Verification evidence

### DynamicTrading

Full suite after recovery:

- **PASS 57/57**.

Includes new/updated coverage for:

- explicit performance bounds (2 abstract traders, 256 settlements/projection entries, 256 KiB projection snapshot cap, hourly lifecycle, 2-second nearby/handoff checks);
- map presentation cache proving repeated marker reads do not rescan trader storage every render;
- Core host combined load order;
- split map projection;
- nearby projection;
- production Debug Manager UI;
- explicit-position spawn;
- settlement provider adapter;
- orphan reconciliation;
- production provider runtime handoff;
- proximity handoff orchestration.

### PsychopatzCore

Focused affected tests all pass:

- `psychopatz_map_host_smoke.lua`;
- `psychopatz_actor_projection_sync_smoke.lua`;
- `psychopatz_actor_projection_transport_smoke.lua`;
- `psychopatz_actor_runtime_store_smoke.lua`;
- `psychopatz_npc_journey_task_smoke.lua`;
- `psychopatz_npc_presentation_smoke.lua`;
- `psychopatz_npc_provider_lease_smoke.lua`.

A broad direct Lua sweep reported **126/133**. The seven failing fixtures were observed outside this recovery surface; this run did not establish a pre-change baseline for those exact failures:

- command-hub callback;
- image resolver;
- label layout;
- profiler client composition;
- profiler server composition;
- widget window;
- world inventory.

No affected actor/map/provider/persistence recovery test failed.

### ProjectHoomans

Focused affected map/command/community tests all pass.

The broad Hoomans runner reported **982/987**. The five failures were observed in semantic or harness-expectation areas outside the touched recovery surface; this run did not establish a pre-change baseline for those exact failures:

- `pnc_companion_commands_smoke.lua`;
- `pnc_semantic_harness_worker_modules_smoke.lua`;
- `pnc_semantic_horde_command_ack_smoke.lua`;
- `pnc_semantic_horde_tactical_prompt_smoke.lua`;
- `pnc_semantic_local_route_smoke.lua`.

No migrated map/command/community recovery test failed.

### Syntax / installed-PZ compiler

For all changed production Lua:

- `git diff --check`: pass;
- `luac -p`: pass;
- installed Project Zomboid Kahlua compiler:
  - PsychopatzCore: **8/8 changed production files**;
  - ProjectHoomans: **4/4**;
  - DynamicTrading: **16/16**.

## Current phase

**Native acceptance handoff.**

No further mandatory developer implementation is currently identified by the recovery roadmap.

## Immediate Next Chunk

User-owned native acceptance:

1. standalone DTAbstract:
   - map marker visible;
   - moving marker follows journey;
   - Abstract Trader Manager opens and lists trader;
   - Spawn Near / Spawn At / action-result feedback;
   - nearby gameplay notification;
   - save/reload continuity;
2. Hoomans + DTAbstract:
   - Hoomans map controls/layers still present;
   - DTAbstract overlay present through same Core host;
   - no duplicated map behavior/markers;
3. hybrid provider:
   - approach → one physical trader;
   - leave → returns abstract;
   - route resumes from physical last position;
   - save/reload while abstract and while materialized;
4. MP:
   - client projection/resync;
   - reconnect;
   - authority sanity;
   - no duplicate body/trader.

If native acceptance exposes a defect, reopen only the failing gate with concrete runtime evidence rather than restoring the entire recovery roadmap.
