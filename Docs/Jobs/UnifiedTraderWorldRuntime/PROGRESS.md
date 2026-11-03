# Progress — Unified Trader World Runtime

## Parent status

**DEVELOPER COMPLETE — native SP/MP acceptance remains user-owned.**

The U0–U7 implementation is complete in the DynamicTrading worktree. DTCommon now owns one canonical trader-world/commercial lifecycle. DTAbstract and DTHoomans are provider/presentation adapters rather than parallel commercial simulations.

Native Project Zomboid acceptance is still required before release or publish.

## Implemented truth

### DTCommon authority

DTCommon now owns:

- bounded roaming commercial population and lifecycle cadence;
- commercial destination intent;
- compact commercial journey/location metadata (not world geometry);
- exactly-once settlement arrival, visit, and exchange;
- cooldown and scheduling;
- provider registry and representation switching policy;
- commercial trader binding/presentation metadata;
- common trader contact and action construction;
- optional-adopter seams for display name, capacity, access, geography, and trade presentation.

Primary modules are DTCommon_TraderWorld, TraderWorldRuntime, TraderProviderRegistry, TraderRepresentationRuntime, TraderPresentation, TraderContacts, IntegrationRegistry, and TradePresentationRegistry.

> 2026-11-04 SurvivorWorld S9 cleanup: generic actor/world projection moved fully to PsychopatzCore SurvivorWorld. The former DTCommon_TraderProjectionServer was removed; TraderPresentation now exposes commercial record bindings only.

### DTAbstract adapter

DTAbstract now owns abstract representation execution plus map, nearby discovery, radio, and debug presentation.

Deleted obsolete production ownership:

- DTAbstract_Lifecycle.lua
- DTAbstract_Handoff.lua
- DTAbstract_ProjectionServer.lua
- DTAbstract_PresentationClient.lua

### DTHoomans adapter

DTHoomans retains Hoomans-specific caravan, faction, member, body, mobile-group, resident-excursion participant travel, physical access, and trade presentation mechanics. Canonical community geography is supplied by PsychopatzCore SurvivorWorld.

Commercial destination, location, arrival, visit, exchange, and cooldown state route through DTCommon.

Deleted obsolete production ownership:

- DTHoomans_CaravanLifecycle.lua

## Verified invariants

- no direct DTAbstract to DTHoomans production references;
- no direct DTHoomans to DTAbstract production references;
- no PNC, DTHoomans, or DTAbstract implementation references under DTCommon production Lua;
- one commercial lifecycle tick: DTCommon_TraderWorldRuntime;
- representation maintenance is a separate bounded DTCommon tick;
- native physical caravans are not auto-dematerialized;
- temporary physical projections preserve a return provider and rebase/resume the same Core journey;
- failed materialization clears return-provider metadata and rolls the lease back;
- physical projection uses live physical position and suppresses stale abstract interpolation;
- resident excursions use DTCommon commercial state while Hoomans keeps participant travel;
- exactly-once arrival is covered through common fake-provider and Hoomans visit paths.

## Developer validation — 2026-11-03

DynamicTrading:

- full suite: **59/59**;
- git diff --check: pass;
- changed production Lua luac parse: **43 files**, pass;
- installed-PZ Kahlua verification: **43 files**, pass.

PsychopatzCore focused regressions:

- actor smoke: pass;
- provider lease: pass;
- runtime store: pass;
- projection sync: pass;
- projection transport: pass;
- map host: pass.

ProjectHoomans:

- focused commercial mobility, excursion, mobile-group, traversal, admission, and staffing matrix: pass;
- real cross-adopter hot-plug matrix: all six sequences pass;
- aggregate suite: **982/987 pass**.

The five remaining ProjectHoomans failures are unrelated semantic or harness expectation mismatches:

1. pnc_companion_commands_smoke.lua
2. pnc_semantic_harness_worker_modules_smoke.lua
3. pnc_semantic_horde_command_ack_smoke.lua
4. pnc_semantic_horde_tactical_prompt_smoke.lua
5. pnc_semantic_local_route_smoke.lua

The trader-world-specific cross-adopter failure found during implementation was fixed and no longer appears.

## Repository safety

Two unrelated unstaged edits remain preserved and must not be included in this goal commit:

- Contents/mods/DTAbstract/42.20/mod.info
- Contents/mods/DTHoomans/42.20/mod.info

## Remaining acceptance

User-owned native Project Zomboid validation:

- standalone DTAbstract;
- DTHoomans physical traders and caravans;
- approach, materialize, move, leave, dematerialize;
- resident trader excursion;
- save and reload while abstract and materialized;
- SP;
- MP, reconnect, and resync;
- no duplicate trader, body, visit, or exchange;
- map, nearby, radio, and NPC interaction parity.

No developer-side blocker remains.
