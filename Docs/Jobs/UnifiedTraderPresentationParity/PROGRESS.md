# Progress — Unified Trader Presentation Parity

## Native parity remediation — 2026-11-04

The first remediation chunk is accepted and the next mandatory chunk is the
provider-materialization/animation audit plus full regression validation.

- Fail-first regressions added for Core Kahlua-safe persistence, concrete actor
  appearance/inventory, Core map-hover card metadata, and the DTCommon trader
  map Talk/Trade surface.
- Core now uses concrete base-game clothing for new actors, migrates the old
  `Base.Tshirt`/`Base.Trousers`/`Base.Shoes` aliases, upgrades legacy generated
  appearance payloads, and no longer calls the unavailable Kahlua `next` global.
- Core ActorMap remains the only actor marker renderer; its hover now uses a
  Core-owned 128px portrait card with name, faction/role badges, and
  ABSTRACT/LIVE presence metadata.
- DTCommon adds one trader map interaction context and one non-debug
  `TraderManager.Request` path. DTAbstract/DTHoomans nearby/map conversation
  modes now pass their existing server access checks into the shared
  DTCommon conversation opener.
- Core notifications retain bounded non-blocking queue semantics while
  carrying canonical human clothing and optional Talk actions; nearby and
  spawn feedback submit the shared action payload.

Focused Core and Dynamic Trading regressions pass. The provider-materialization
audit then found a real parity defect: the DTHoomans CoreProvider handoff
created a Project Hoomans body and hydrated inventory, but skipped Hoomans'
canonical live-body presentation sequence. The fail-first
`pnc_core_provider_materialization_presentation_smoke.lua` regression failed
before the repair and passes after it.

The shared handoff now applies live animation setup, human visuals, physical
inventory, equipment, the live-shell identity token, and managed-body state in
the same order as native Project Hoomans materialization. DTAbstract remains
bodyless. The updated Core presentation fixture now asserts the concrete,
valid starter clothing contract.

Full Core, Project Hoomans, Dynamic Trading, bridge, exclusivity,
MarketSense/performance, Kahlua, and source-removal gates remain mandatory
before this remediation can be marked complete.

## Current semantic Talk parity completion (P5 follow-up)

- Closed the observed DTAbstract Talk no-op: the single-player server authorization response now loops back through `OnServerCommand` and reaches the existing Core bridge.
- Added the shared Core actor-conversation input host: bounded text entry, Core session history/response queue, choice restoration, pending guard, and DTCommon result/action hooks.
- DTCommon now owns the semantic trader policy/content and the `dynamictrading.trader` opener contract. DTHoomans owns only registration with the optional Project Hoomans opener registry plus its registered physical authorization/transport adapter.
- Project Hoomans’ native Talk provider now tries registered external openers before its normal Hoomans graph. Trader leaders therefore enter the same DTCommon conversation UI/content used by DTAbstract and DTHoomans; Hoomans-only guard referral/social content remains in ProjectHoomans.
- Removed the superseded DTHoomans trade category/block and the DTCommon Hoomans trade compatibility module. DTCommon trader conversation has no PNC dependency, preserving DTAbstract isolation.
- Removed Project Hoomans’ superseded `projecthoomans:trade` category/block/topic and localized trade graph; Project Hoomans retains only Hoomans-owned conversation families plus the DTHoomans guard-referral contract.
- Fail-first/acceptance coverage: Dynamic Trading **75/75**, focused shared semantic/bridge regressions **pass**, Project Hoomans relevant conversation regressions **8/8**, Core actor-input regression **pass**.
- Remaining full-suite baseline notes are unchanged: Project Hoomans retains five unrelated pre-existing semantic/harness expectation failures; Core’s standalone sweep retains its existing environment/UI fixture failures. Native fresh-save acceptance remains user-owned.

## Parent status

P0–P7 developer implementation is complete. DTAbstract and DTHoomans now share the Core/DTCommon trader presentation, map, faction identity, notification, debug-manager, and conversation contracts. The only remaining work is user-owned fresh-save native acceptance in Project Zomboid.

The accepted foundation remains intact: canonical Core actor identity/projection, DTCommon trader bindings, non-blocking spawning, DTAbstract zero-body semantics, DTHoomans physical materialization, MarketSense catalog authority and bounded stock seeding, and provider exclusivity.

## P0 source-backed parity matrix

Fail-first regressions were added before migration and initially failed for the missing shared primitives:

- Core ActorMap did not retain or render generic icon/badge presentation.
- Core had no compact actor notification queue/toast.
- DTCommon had no shared trader view/decorator, manager, or conversation module.

| Contract | Source-backed gap | Accepted owner and result |
|---|---|---|
| Canonical actor marker | Core `ActorMap` owned the canonical marker; DTAbstract and PNC also had provider-specific presentation paths. | Core `PsychopatzSurvivorWorldActorMap` remains the sole actor-marker renderer. DTCommon registers one `DynamicTrading:Trader` decorator. DTAbstract keeps only non-actor discovery overlays; PNC filters Core projections from its legacy travel dots. |
| Faction identity | Core projections carried faction identity but lacked a provider-neutral display/icon/badge contract; PNC had richer Hoomans-only faction art. | Core `PsychopatzActorFactionPresentation` validates the neutral spec. Core projections carry it, and DTCommon supplies trader identity/icon/badge presentation without importing PNC into DTAbstract. |
| Compact actor/trader notification | Core’s existing notification surface was modal and had no bounded actor queue or portrait/faction payload. | Core `ActorNotifications` owns a bounded non-blocking queue and circular portrait-style toast. DTAbstract, DTHoomans, nearby discovery, and shared debug feedback use it for ordinary trader feedback. |
| Trader manager/debug actions | DTAbstract and DTHoomans each owned a trader window/model/action path. | DTCommon `TraderManager` owns one model, window, Debug-Hub tool, and action contract. Providers register only thin authorization/transport/presence adapters. |
| Trader conversation opening/content | DTAbstract used a hardcoded graph while DTHoomans routed through a separate PNC conversation/trade path. | DTCommon `TraderConversation` owns the shared graph and Core session opening. Both providers authorize/transport and open the same content; Hoomans-only guard referral/social behavior remains in ProjectHoomans. |
| Provider boundary | The two providers differed in more than presence/materialization. | DTAbstract has no PNC/ProjectHoomans runtime dependency and remains bodyless. DTHoomans still requires ProjectHoomans and may materialize a body. |

## Phase log

- **P0 — Characterization/fail-first:** completed the source-backed matrix and focused regressions for map/faction/icon presentation, one-marker behavior, compact notifications, shared debug actions, and shared conversation opening/content.
- **P1 — Core primitives:** added provider-neutral faction presentation, projection enrichment, ActorMap icon/emblem/badge/hover metadata, and the Core actor notification queue/toast.
- **P2 — Shared trader presentation/map:** added `DTCommon.TraderPresentation` view models and the single trader ActorMap decorator; removed DTAbstract’s trader marker path while retaining discovery overlays.
- **P3 — Notifications:** migrated ordinary DTAbstract, DTHoomans, nearby-discovery, and shared debug feedback to Core actor notifications. Detailed reports may still use the separate modal surface.
- **P4 — Trader manager:** added `DTCommon.TraderManager`, one shared Debug-Hub tool, and provider adapters; removed `DTAbstract_DebugTraderWindow` and `DTHoomans_DebugTraderWindow`.
- **P5 — Conversation parity:** added `DTCommon.TraderConversation`; DTAbstract and DTHoomans now authorize/transport and open the same trader graph/Core session. The old `DTCommon_CoreTraderConversation` module was removed.
- **P6 — Cleanup/source audit:** verified one Core actor-marker path, one DTCommon trader decorator, one DTCommon manager, one Core notification widget/queue, and one DTCommon trader conversation content/open path. ProjectHoomans’ Core travel decorator yields to DTCommon trader styling and its legacy renderer excludes Core projections.
- **P7 — Validation/handoff:** focused suites, Dynamic Trading full suite, bridge tests, MarketSense/performance, exclusivity, Core binding scan, provider-materialization presentation regression, Kahlua checks, and diff checks are complete. Native fresh-save acceptance is the only remaining gate.

## Final source-removal audit

- No production references remain to `DTAbstract_DebugTraderWindow`, `DTHoomans_DebugTraderWindow`, `DTCommon_CoreTraderConversation`, `CoreTraderConversation`, `dtabstract:traders`, `dthoomans.traderManager`, or `PNC.Conversation.Open`.
- `DTAbstract_WorldMap.lua` no longer requires/registers an actor-marker or trader-marker renderer.
- `DTCommon_TraderPresentation.lua` contains the only Dynamic Trading trader ActorMap decorator (`DynamicTrading:Trader`).
- `DTCommon_TraderManager.lua` contains the only trader manager window/model/tool; DTAbstract and DTHoomans adapters expose provider actions only.
- `PsychopatzActorNotificationToast.lua` contains the generic compact actor/trader widget and bounded queue; provider modules only submit payloads.
- `DTCommon_TraderConversation.lua` contains the shared trader graph/open path; ProjectHoomans retains only Hoomans-specific referral/social content.
- DTAbstract production Lua has no runtime PNC, ProjectHoomans, or DTHoomans import/reference; remaining mentions are boundary comments.

## Validation evidence — 2026-11-04

- Dynamic Trading full smoke suite: **76/76**; native smoke suite: **4/4**.
- Dynamic Trading focused parity/bridge/MarketSense/exclusivity/performance set: all required tests pass, including the 4k+ stock/performance and both native MarketSense/stock checks.
- DTHoomans bridge harness: pass. Provider exclusivity and hotswap/persistence checks: pass.
- PsychopatzCore changed-path presentation/persistence tests: **8/8**; all-file private-helper binding scan: **406/406 files, pass**.
- ProjectHoomans provider/materialization focus: **3/3**; full sweep: **1000 pass, 5 fail**, with the same five unrelated pre-existing semantic/harness expectation failures documented before this work.
- PsychopatzCore standalone full sweep: **148 pass, 7 fail**. The seven failures are unchanged environment/UI or unrelated baseline fixtures (missing ScrollPanel/TimedActions fixtures, image fallback, profiler role/composition, widget sizing, and world-inventory teleport); all changed Core paths pass.
- Installed PZ Kahlua verification: **18/18 changed production Lua files pass**, with zero errors at ERROR severity.
- Source-removal audit: pass; one Core actor-marker renderer, one DTCommon trader decorator/manager/conversation path, one Core notification widget/queue, and no forbidden DTAbstract runtime dependency.
- `git diff --check`: passed in DynamicTrading, PsychopatzCore, and ProjectHoomans.
- Native PZ acceptance was not run from the local Lua harness and remains user-owned.

## Remaining native acceptance

On a fresh save, verify:

- DTAbstract trader map uses the shared canonical faction/trader icon with no duplicate marker.
- Circular portrait trader notifications display correctly and remain non-blocking.
- The shared Trader Manager lists and operates both providers.
- Talk opens and functions through the shared conversation path.
- Trade works.
- DTAbstract creates no visible NPC body.
- DTHoomans presents the same trader-facing systems while retaining physical materialization.

## Proximity/persistence remediation — 2026-11-04

The native follow-up audit reproduced three defects in DTAbstract: nearby actor
notifications expired after the fixed toast duration, nearby Talk lost its
proximity mode and fell back to radio-only authorization, and a newly-created
Core trader group was marked dirty without an immediate world-registry write.

- Core actor notifications now support bounded persistent items, in-place
  updates, explicit dismissal, and non-blocking Talk actions.
- DTAbstract nearby discovery refreshes one canonical notification while the
  player remains inside the contact radius, dismisses it after the hysteresis
  exit radius, and restores it on re-entry.
- DTCommon carries the nearby access mode through provider adapters. DTAbstract
  authorizes nearby Talk from the canonical Core actor position and retains
  radio authorization for remote abstract access; DTHoomans keeps its physical
  body/faction/distance validation.
- Core trader-group and actor-registry creation paths perform an immediate
  authoritative ModData write after marking new debug materialization state
  dirty. Talk failures now surface in the shared Trader Manager notice.

Validation for this chunk: focused remediation tests **3/3** plus the Core
notification smoke pass; Dynamic Trading full suite **76/76**; ProjectHoomans
remains at its documented five unrelated baseline failures; the Core sweep
retains its documented seven baseline failures; installed PZ Kahlua checks
pass for all **12/12** changed production Lua files; and `git diff --check`
passes in all three repositories. The source-removal audit still finds one
Core actor-marker renderer, one DTCommon trader presentation/manager/
conversation path, one Core notification widget, and no DTAbstract runtime
dependency on ProjectHoomans or PNC.

Native fresh-save acceptance remains user-owned: verify proximity persistence
and dismissal, Talk opening/content, save/reload trader persistence, the
DTAbstract bodyless presentation, and DTHoomans physical materialization after
restarting PZ to load the changed Lua.

## GlobalModData recovery remediation — 2026-11-04

The native restart exposed a save-format defect in the Core actor registry.
PZ's installed `GameWindow.StringUTF` stores ByteBuffer string lengths as
signed 16-bit values. The actor registry had reached 44,109 bytes, so loading
the single JSON string overflowed its length and caused `invalid lua table type
123` during `GlobalModData.load`.

- PsychopatzCore now keeps actor-registry strings below a 30,000-byte safety
  boundary and writes larger registries as UTF-8-safe nested `registryChunks`.
- Loading accepts both the existing single-string format and the new chunked
  format; malformed chunks fail explicitly instead of being treated as an
  empty registry.
- Added `psychopatz_actor_runtime_store_chunk_smoke.lua` covering chunk size,
  byte-preserving reassembly, and reload behavior.

Validation: chunk/runtime-store/notification Core smokes pass; Core sweep is
**148/155** with the same seven documented baseline UI/environment failures;
Dynamic Trading remains **76/76**; Kahlua verification passes for the changed
runtime-store file; and `git diff --check` passes. The current Apocalypse
`global_mod_data.bin` is already malformed on disk and was not overwritten;
restore a backup or use a fresh save after this fix before native acceptance.

## Shared faction-generation contract remediation — 2026-11-04

The provider audit confirmed that Project Hoomans' existing
`MobileGroupDirector.GenerateForFaction` supports an `abstract` presence hint,
but that hint still creates a Project Hoomans record and permits later body
materialization. DTAbstract therefore must not call that optional-adopter API.

- Added the single DTCommon `TraderGeneration.GenerateForFaction(spec)` seam.
- `presenceMode = "abstract"` delegates to the Core canonical candidate factory
  and never imports or calls Project Hoomans/PNC.
- `presenceMode = "live"` and `"auto"` delegate through a registered
  DTHoomans adapter, which is the only layer that transports the native
  Project Hoomans generation spec to `MobileGroupDirector`.
- Added fail-first coverage for abstract/live/auto dispatch, invalid modes,
  missing providers, and the DTAbstract/DTHoomans source boundary.

Validation for this chunk: the focused generation/caravan/provider regressions
pass; Dynamic Trading full smoke suite is **77/77**; the DTHoomans bridge
harness passes; installed-PZ Kahlua verification passes for all **4/4** changed
production Lua files; and `git diff --check` passes.

Final source-removal/exclusivity audit, repository status review, coherent
commit (`f568bf7a`), and post-commit smoke/bridge gates are complete. The only
remaining work is user-owned fresh-save native acceptance.

## Canonical trader/guard preset remediation — 2026-11-04

- Added Dynamic Trading-authored presets instead of copying Project Hoomans
  archetype loadouts: one caravan trader with formal clothing and a
  `Base.Bag_DuffelBag`, plus dedicated shotgun and sidearm guard presets with
  explicit ammunition and authored identity/appearance data.
- Added fail-first parity smokes in DynamicTrading, PsychopatzCore, and
  ProjectHoomans. The tests now pass for preset selection, Core authored-slot
  expansion, exact Core starter inventory, PNC member-spec transport, and the
  canonical inventory branch.
- Core now expands authored appearance policy slots into concrete portrait
  specs and accepts member-specific identity/appearance/starter inventory data
  during survivor-world commits.
- DTAbstract and DTHoomans both use the shared DTCommon preset planner. The
  physical provider creates the same Core actor projections before invoking
  Project Hoomans `MobileGroupDirector`, then transports the exact Core
  inventory payload into PNC records and native materialization.
- Removed the superseded DTHoomans guard-weapon override/diagnostic path so
  provider code remains role/transport glue and cannot overwrite the shared
  guard presets.

Focused validation for this chunk: DynamicTrading preset/caravan tests pass;
Core preset/runtime tests pass; ProjectHoomans canonical-member test passes;
the DTHoomans bridge harness passes with **78/78** checks; `luac -p` passes for
all changed production Lua; installed-PZ Kahlua verification reports zero
issues for all changed production Lua; and `git diff --check` passes.

Full regression update: DynamicTrading full suite **78/78**; required
provider-exclusivity, MarketSense gateway, stock, and 4k+/performance checks
**11/11**; ProjectHoomans **1000/1005**, matching the five documented unrelated
baseline failures; PsychopatzCore **149/156**, matching the seven documented
unrelated baseline failures. The final ownership audit finds one Core
actor-map renderer, one shared DTCommon trader presentation/manager/conversation
path, one Core notification widget, no DTAbstract runtime dependency on
ProjectHoomans or PNC, and no provider-owned duplicate trader actor-marker,
debug-manager, notification, or conversation-content path.

Next mandatory chunk: make the coherent repository commits and leave only
user-owned fresh-save native acceptance: verify trader/guard appearance and
equipment, proximity persistence, Talk opening/content, save/reload persistence,
DTAbstract bodyless presentation, and DTHoomans physical materialization.
