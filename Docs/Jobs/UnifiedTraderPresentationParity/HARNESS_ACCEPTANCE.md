# Harness Acceptance — Unified Trader Presentation Parity

## A. One-marker invariant

For each canonical trader actor:
- exactly one actor marker is rendered;
- marker identity is the canonical actorID;
- trader decoration does not create a second marker;
- DTAbstract actor marker comes from Core ActorMap;
- DTHoomans uses the same Core actor marker where canonical projection exists.

## B. Map presentation

Must prove:
- Core decorator supports optional icon/emblem/badge;
- fallback dot remains when no icon exists;
- trader decorator supplies shared label/icon/faction presentation;
- selected/tracked color and route behavior still works;
- hover portrait uses canonical actor portrait;
- faction/community metadata respects discovery policy;
- non-actor settlement/signal overlays remain separate.

## C. Notification/toast

Generic Core actor toast must render:
- circular portrait/avatar;
- actor/trader name;
- short message;
- optional faction badge;
- queue ordering;
- duplicate suppression;
- bounded auto-dismiss/dismiss;
- no modal details panel requirement.

Dynamic Trading uses it for successful trader spawn/nearby feedback.

Failure/debug diagnostics may use Debug Hub/logs.

## D. Shared trader debug

Same model/window under both providers supports:
- list traders;
- refresh;
- spawn near/player;
- force tick;
- map/focus;
- teleport;
- talk;
- force arrival;
- seen/reset seen;
- remove;
- actor/faction/community/journey diagnostics.

Provider extension may report abstract presence or physical materialization/body state.

No second provider-specific trader manager remains after cleanup.

## E. Talk/conversation

Must prove end-to-end:
- Talk request authorized;
- canonical actor projection resolved;
- canonical portrait resolved;
- one shared DTCommon trader conversation model built;
- real Core conversation UI opens;
- Trade action works;
- destination/origin/news work;
- faction/community presentation resolves;
- goodbye/close lifecycle works;
- DTAbstract and DTHoomans use the same trader content definition.

If Core semantic response infrastructure is available, shared trader semantic actions must use it rather than a parallel hardcoded selector.

## F. Provider boundary

DTAbstract:
- no PNC import;
- no ProjectHoomans dependency;
- no body materialization;
- same shared presentation contracts.

DTHoomans:
- ProjectHoomans required;
- materialization allowed;
- same shared trader presentation contracts.

Mutual-exclusion tests remain green.

## G. Source-removal audit

Final production source must not retain provider-owned duplicate Dynamic Trading systems for:
- trader actor marker rendering;
- trader debug manager model/window;
- trader notification widget;
- trader conversation content.

Any retained provider module must be a thin adapter.

## H. Performance

- no full actor/trader/faction scan per rendered frame beyond Core projected actors;
- map decorator does no server/storage mutation;
- notification portrait uses existing projection;
- debug expensive work is inactive while debug UI closed;
- conversation build occurs only on interaction;
- no regression in non-blocking trader spawn;
- MarketSense 4k+ catalog regression stays green.

## I. Full suites

PsychopatzCore:
- full baseline preserved;
- focused map/toast/conversation tests;
- Kahlua;
- diff check.

DynamicTrading:
- full suite;
- DTHoomans bridge;
- DTAbstract map/debug/talk;
- exclusivity;
- MarketSense gateway/stock regressions;
- Kahlua;
- diff check.

ProjectHoomans:
- full baseline preserved;
- relevant map/conversation integration tests;
- Kahlua if modified;
- diff check.

## J. Native acceptance

Fresh-save DTAbstract:
- Spawn Trader responsive;
- compact circular portrait notification;
- trader/faction symbol on canonical actor marker;
- portrait hover;
- shared Trader Manager;
- Talk functional;
- Trade functional;
- no duplicate marker;
- no visible body.

Fresh-save DTHoomans:
- same trader-facing presentation;
- physical materialization preserved.
