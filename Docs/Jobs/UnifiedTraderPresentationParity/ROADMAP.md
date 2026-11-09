# Roadmap — Unified Trader Presentation Parity

## Parent goal

DTAbstract and DTHoomans present and interact with Dynamic Trading traders through the same shared systems. Only presence/materialization differs.

Status: PLANNED.

## P0 — Characterize parity and lock regressions

Add fail-first coverage for:
- one canonical trader actor marker;
- DTCommon trader decorator over Core ActorMap;
- faction/emblem marker spec;
- no duplicate DTAbstract trader marker;
- shared trader presentation under both providers;
- shared trader debug model/actions;
- compact actor notification with portrait;
- Talk end-to-end open success;
- same DTCommon trader conversation definition under both providers;
- provider exclusivity.

Audit Hoomans presentation pieces and classify each as:
1. generic Core candidate;
2. DTCommon trader concern;
3. Hoomans-only concern.

Gate: tests demonstrate each current parity gap.

## P1 — Core map/faction presentation primitives

Extend Core ActorMap decorator style with icon/emblem/badge support.

Add/extract provider-neutral faction presentation if missing.

Preserve Core selection/highlight/tracking/hover/route behavior.

Gate: Core can render canonical actor faction/trader identity without PNC dependency.

## P2 — Shared DTCommon trader presentation + map decorator

Expand DTCommon_TraderPresentation.

Resolve canonical actor portrait/position/faction/community.

Register one DTCommon decorator with Core ActorMap.

Migrate map focus to canonical actor selection/tracking.

Keep non-actor settlement/signal overlays separate.

Cleanup: remove trader-actor rendering from DTAbstract_WorldMap.

Gate: one actor produces one marker and both providers use the same trader decorator.

## P3 — Core compact actor notification/toast

Implement generic compact actor toast:
- circular portrait;
- optional faction badge;
- title/name;
- short message;
- bounded queue;
- non-blocking lifecycle;
- responsive layout.

Migrate successful DTAbstract spawn/nearby/discovered/arrival feedback. Keep
DTHoomans physical lifecycle feedback in the visible NPC and shared manager/log;
do not emit a redundant actor toast.

Keep modal notification for detailed reports.

Gate: harness renders canonical trader portrait through Core actor-toast surface.

## P4 — Shared DTCommon trader debug manager

Create shared trader debug model/window/action controller.

Expose actor/faction/community/journey/provider diagnostics.

Allow bounded provider-specific presence diagnostics.

Register one Debug Hub tool.

Cleanup:
- DTAbstract-specific trader manager/window;
- DTHoomans-specific Dynamic Trading trader window;
- duplicate action wiring.

Gate: same manager/model works under both provider fixtures.

## P5 — Shared trader conversation parity

Trace current physical and abstract trader Talk paths.

Identify provider-neutral trader conversation code already in Core/DTCommon versus remaining PNC-only pieces.

Move only provider-neutral trader content to correct shared authority.

Define one DTCommon.TraderConversation.Open contract.

Both providers resolve authorization/target then call the same content path.

Use canonical actor portrait/faction/community presentation.

Include Trade and current trader semantic/actions.

Cleanup: remove obsolete DTAbstract-only static conversation definition/path.

Gate: both provider fixtures open the same shared conversation definition and real Core conversation UI with working actions.

## P6 — Cross-provider cleanup/source audit

Final production source must not retain provider-owned duplicate Dynamic Trading systems for:
- trader actor map rendering;
- trader debug manager model/window;
- trader notification widget;
- trader conversation content.

Allowed provider code:
- authorization/transport;
- presence/materialization;
- provider-specific physical diagnostics.

Gate: source audit matches ARCHITECTURE.md.

## P7 — Full regression and native handoff

PsychopatzCore:
- preserve full baseline;
- focused actor-map/faction tests;
- actor-toast tests;
- conversation regressions;
- Kahlua;
- diff check.

DynamicTrading:
- full suite;
- DTHoomans bridge;
- DTAbstract map/debug/talk;
- exclusivity;
- MarketSense regressions;
- Kahlua;
- diff check.

ProjectHoomans:
- preserve full baseline;
- relevant map/conversation integration;
- Kahlua if modified;
- diff check.

Native DTAbstract acceptance:
- Spawn Trader responsive;
- compact circular portrait notification;
- trader/faction symbol on canonical actor marker;
- no duplicate marker;
- portrait hover;
- shared Trader Manager;
- Talk functional;
- Trade functional;
- zero visible NPC body.

Native DTHoomans acceptance:
- same shared trader-facing presentation;
- physical body still materializes normally;
- no redundant lifecycle actor toast is shown.

## Stop condition

Do not stop when a helper exists or one phase completes.

Stop only when P0–P7 developer-side work is complete, split presentation paths are removed, and only user-owned native acceptance remains.
