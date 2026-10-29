# Agent Runbook — Settlement Market, Events & Trader Mobility

## Mission

Implement the full Settlement Market, Events & Trader Mobility parent objective on the existing DynamicTrading `main`, with the smallest required generic cross-repo Project Hoomans and PsychopatzCore changes on their existing `main` branches.

The immediate Next Chunk in `PROGRESS.md` is only the starting responsibility.

> A chunk or phase completing is **not** completion of this job.

Continue automatically through all mandatory M0–M10H roadmap work after each accepted chunk unless a genuine blocker or user-only native acceptance gate remains. M0–M10G is accepted and published; M10H now extends the reusable spatial foundation with observer-relative tactical clock bearings before native handoff.

## Read order

1. repository root `AGENTS.md`;
2. this `AGENT_RUNBOOK.md`;
3. `AUDIT.md`;
4. `ARCHITECTURE.md`;
5. `COMMUNITY_EXCURSIONS.md`;
6. `SPATIAL_LANGUAGE.md`;
7. `ROADMAP.md`;
8. `HARNESS_ACCEPTANCE.md`;
9. `PROGRESS.md` **last**.

Inspect current production source and dependency code as needed.

Legacy branch is behavioral reference only. Do not bulk-read or port it unless the current chunk requires a specific source comparison.

## Source truth

Priority:

1. current production code and actual runtime behavior;
2. current tests/integration/native evidence;
3. this job architecture;
4. roadmap;
5. progress;
6. legacy behavior/docs.

If docs disagree with current code, correct the docs.

## Mandatory ownership rules

- MarketSense owns intrinsic value and taxonomy.
- DTCommon owns market pressure, events, merchant stock, quotes and commercial authority.
- Project Hoomans owns physical NPC identity, movement, settlement presence, faction/community membership, home resolution, generic excursion state, place/community identity, privacy-aware whereabouts projection, and lifecycle.
- PsychopatzCore owns reusable coordinate/spatial-relation mechanics and canonical direction/distance tokens; it must not know traders, communities, or excursions.
- PsychopatzCore owns reusable actors/inventory/currency/radio/world-knowledge infrastructure.
- DTAbstract/DTHoomans are adapters/fronts, not separate market engines.

Do not add a second NPC lifecycle or second intrinsic pricing system.

## Critical behavior rules

1. Trader stock is persistent exact merchant inventory.
2. Opening UI never rerolls stock.
3. Settlement visits partially exchange stock.
4. Price may react immediately to market/event information.
5. Existing stock changes through logistics/transactions, not event-start magic.
6. Settlement markets store bounded category pressure, not every item.
7. Events are data-driven typed modifiers.
8. No all-trader rewrite when an event starts.
9. No full item-universe scan on every quote/visit.
10. Duplicate visit IDs must not double-apply exchange.
11. Commercial temporary visits never transfer members into the destination settlement.
12. Base-less caravans never acquire a fake home community.
13. Resident traders stay members of their original community/faction during excursions and return to that exact home.
14. Long-distance trader travel remains abstract; live behavior remains local.
15. Semantic systems read generic Hoomans public excursion facts and never command movement directly.
16. Destination settlement names come from the current authoritative Hoomans community/base record, not copied excursion text.
17. Direction math is centralized in PsychopatzCore; Hoomans/DT must not reimplement coordinate-sign or compass logic.
18. Semantic privacy applies before destination name/direction/ETA realization.

## Git/concurrency

Follow root `AGENTS.md`.

At start:

- inspect local `main`, HEAD, upstream and worktrees;
- preserve unrelated edits;
- never use destructive reset/rebase/stash/discard;
- never create a new branch;
- do not include unrelated dirty files in a market/event commit.

The planning baseline had an unrelated modification to `DTHoomans_Conversation.lua`. Recheck; do not overwrite or absorb it.

M9/M10 also require Project Hoomans work. Before editing that repository, read its root `AGENTS.md`, inspect local/remote divergence/worktrees, and preserve unrelated semantic work. M10G also requires PsychopatzCore; read its root `AGENTS.md` and inspect local/remote/worktree state before edits. Never blindly push unrelated ahead history merely to publish one dependency.

## Unattended loop

For each chunk:

```text
read current Next Chunk
→ verify current repo/dependency state
→ write/confirm fail-first evidence
→ implement smallest coherent responsibility
→ focused tests
→ integration regressions
→ static/Kahlua/diff checks
→ update PROGRESS
→ commit/push only in-scope validated files when safe
→ continue immediately to next mandatory chunk
```

Do not stop just because one chunk passed.

## Validation

Follow `HARNESS_ACCEPTANCE.md`.

For production Lua changes also run applicable:

- `luac -p`;
- repository Kahlua verification;
- `git diff --check`;
- focused `tests/run_tests.py` suites;
- dependency tests when contracts changed.

Do not claim a product gate from source inspection alone.

## Architecture discipline

Prefer narrow modules under a coherent DTCommon market namespace rather than enlarging `DTCommon_TraderService.lua` into another monolith.

Do not prematurely create dozens of files. Extract responsibilities when ownership/test boundaries justify it.

Preserve the current transaction executor. Settlement Exchange prepares merchant state outside the ordinary buy/sell request; it must not bypass transaction invariants.

## Event discipline

The generic registry/resolver and Food Shortage/Agricultural Surplus definitions are already accepted M4–M5 engine work.

M9 must add a **production producer**, not another event registry. The first producer should be bounded and grounded in authoritative market/world state. A deterministic market-condition producer is preferred over a large random event library. Keep named event rules outside the generic registry and prevent threshold flapping with hysteresis/cooldown/duration policy.

Do not add ten bespoke event scripts merely to make events appear.

## Runtime activation discipline

Do not confuse an API that tests can call with a gameplay path that production actually calls.

For M9, prove call sites in production for all four runtime responsibilities:

1. automatic settlement-market provisioning;
2. Hoomans-owned normal settlement arrival → DT visit/exchange;
3. elapsed-time market recovery;
4. at least one real event producer → `MarketEvents.Register`.

The M9 flagship test must begin without manually calling `SettlementMarket.GetOrCreate`, `MarketEvents.Register`, `SettlementExchange.Execute`, `SettlementMarket.Recover`, or `DTHoomans.Settlement.StartTraderTravel` from the test body. It may drive the public Hoomans lifecycle with deterministic engine fixtures.

Do not solve missing arrival wiring by moving travel authority into DynamicTrading. If Hoomans needs a reusable notification/listener seam, make the smallest generic Hoomans change and cover it with Hoomans regressions.

## Community excursion and commercial-mobility discipline

Read `COMMUNITY_EXCURSIONS.md` before mobility work. For M10G/M10H spatial work, read `SPATIAL_LANGUAGE.md`; for M10H production semantic integration, also read `M10H_TACTICAL_SEMANTIC_INTEGRATION.md` before changing Core/Hoomans code.

Mandatory rules:

- first add/reuse a generic Hoomans temporary non-admission settlement visit; do not route traders through refugee-style admission;
- generic excursion state belongs to Hoomans and must remain usable by future non-trader purposes;
- DynamicTrading may provide economic destination scoring but must not own the final target or movement;
- do not simply flip DT caravans from strategic to ambient without proving the resulting production lifecycle and player/local behavior;
- preserve current encounter, pending-arrival, LOD, Follow Player, task/facility, and home-retry safeguards;
- resident trader departure is rare/purposeful, not the default state;
- do not turn a settlement faction into a mobile group merely because its trader leaves;
- exact home return means the originating `community.id`, not "some settlement";
- public semantic excursion state is a projection/query, not a duplicate persistence store;
- destination names/directions are resolved on demand from authoritative place IDs and coordinates, not persisted as stale excursion copies;
- Core spatial math emits canonical data/tokens; semantic realization owns natural-language phrasing/localization;
- world-cardinal and observer-heading reference frames remain explicit; never derive clock time without a trustworthy heading;
- tactical clock bearings are ephemeral and recomputed from current observer/target geometry rather than persisted as durable knowledge;
- Hoomans owns live facing extraction and threat selection; Core owns only generic vector math;
- M10H must enrich the existing combat-awareness `DANGER_CHANGED` → Semantic Scene / ambient semantic-reaction paths; do not create a parallel clock-bark engine;
- reuse current Perception caches, selected targets, group-alert coordinates, and the existing bounded zombie centroid; do not add a dialogue-only zombie scan;
- hostile-human callouts may observe authoritative target-change notifications, but Combat must not depend on Semantics and semantic code must not live inside target mutation;
- reuse existing `CombatBanterArbiter`/cooldowns; no per-tick tactical chatter loop;
- extend existing Combat/Scene Observatory + Semantic Harness for explanation; no transcript persistence;
- future "visit my settlement" requests are requests/suggestions evaluated by faction/trader AI, never direct semantic movement commands.

## Scope discipline

Mandatory M0–M10H only.

Do not expand into:

- player marketplace;
- quests;
- courier system;
- legacy DTNPC;
- full faction macroeconomy;
- full physical settlement warehouse accounting;
- haggling;
- broad reputation restoration;
- full player commercial-invitation UI/dialogue flow (only the generic future request seam is in scope);
- physical full-map caravan walking/pathfinding;
- unrelated Radio OS art/UI work.

A tiny adapter/test fixture needed by the mandatory architecture is allowed.

## Stop conditions

Stop early only for:

- unresolved user-authored Git conflict affecting required files;
- missing required dependency/API with no safe fallback;
- a real product decision not specified by these docs;
- authorization restriction;
- completed developer-side M0–M10H, including clean cross-repo publication, reusable Core world-cardinal + observer-relative clock spatial relations, production semantic whereabouts/tactical callout integration, and both trader flagship lifecycles, with only explicit user-owned native acceptance remaining.

A passing phase is not a stop condition.

## Final handoff

Only report the parent goal developer-complete when all mandatory developer-side gates pass.

Final report must include:

- implemented phases;
- exact tests/evidence;
- persistence/performance evidence;
- commit SHAs and push state;
- any native SP/MP evidence;
- remaining user-owned live acceptance, if any;
- no claim that optional later extensions are required for completion.
