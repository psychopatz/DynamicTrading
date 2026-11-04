# Progress — Unified Trader Presentation Parity

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
- **P7 — Validation/handoff:** focused suites, Dynamic Trading full suite, bridge tests, MarketSense/performance, exclusivity, Core binding scan, Kahlua checks, and diff checks are complete. Native fresh-save acceptance is the only remaining gate.

## Final source-removal audit

- No production references remain to `DTAbstract_DebugTraderWindow`, `DTHoomans_DebugTraderWindow`, `DTCommon_CoreTraderConversation`, `CoreTraderConversation`, `dtabstract:traders`, `dthoomans.traderManager`, or `PNC.Conversation.Open`.
- `DTAbstract_WorldMap.lua` no longer requires/registers an actor-marker or trader-marker renderer.
- `DTCommon_TraderPresentation.lua` contains the only Dynamic Trading trader ActorMap decorator (`DynamicTrading:Trader`).
- `DTCommon_TraderManager.lua` contains the only trader manager window/model/tool; DTAbstract and DTHoomans adapters expose provider actions only.
- `PsychopatzActorNotificationToast.lua` contains the generic compact actor/trader widget and bounded queue; provider modules only submit payloads.
- `DTCommon_TraderConversation.lua` contains the shared trader graph/open path; ProjectHoomans retains only Hoomans-specific referral/social content.
- DTAbstract production Lua has no runtime PNC, ProjectHoomans, or DTHoomans import/reference; remaining mentions are boundary comments.

## Validation evidence — 2026-11-04

- Dynamic Trading full smoke suite: **73/73**.
- Dynamic Trading focused parity/bridge/MarketSense/exclusivity/performance set: **10/10**.
- PsychopatzCore changed-path tests: **6/6**; all-file private-helper binding scan: **406/406 files, pass**.
- ProjectHoomans Core travel-directory/map tests: **3/3**. Its full suite still stops at the preserved pre-existing `pnc_companion_commands_smoke.lua:291` assertion (`missing=safe`); this is outside the changed map path.
- PsychopatzCore’s standalone full sweep retains unrelated baseline/environment failures in teleport, widget sizing, profiler-role composition, missing UI fixtures, image fallback, label layout, and profiler-client composition tests; all changed Core paths pass.
- Installed PZ Kahlua verification: **21/21 changed production Lua files pass**, with zero errors or warnings at ERROR severity.
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
