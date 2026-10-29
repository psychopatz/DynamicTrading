# Roadmap — Settlement Market, Events & Trader Mobility

## Parent completion boundary

The parent goal is complete only when the current Dynamic Trading rewrite has a verified settlement-centered market and event system in which:

- persistent traders carry exact stock across sessions;
- settlement visits partially exchange stock instead of rerolling it;
- settlements own bounded local supply/demand state;
- market pressure affects both availability and price;
- typed scoped events affect the same market pipeline;
- events affect prices immediately but stock only through logistics;
- trader travel between two settlements can move market pressure through persistent stock;
- eligible Hoomans settlements automatically provision a DT market without a test/debug fixture;
- the ordinary Hoomans settlement-arrival lifecycle invokes the economic exchange without requiring DT to own or start the journey;
- market pressure actually recovers through a bounded production runtime path;
- at least one grounded production event producer registers and expires real events without manual/test registration;
- a settlement-owned trader is immediately bound to its own canonical settlement market even before any mobile visitor arrives;
- a base-less roaming trader can naturally choose and complete non-admission commercial settlement visits under Hoomans authority;
- a settlement-owned trader may rarely perform a purposeful Hoomans-owned commercial excursion and explicitly return to its exact home community without changing faction/community membership;
- long-distance trader movement remains abstract while nearby/materialized behavior remains live;
- generic excursion/public-status APIs expose authoritative social facts for semantic consumers without coupling them to Dynamic Trading movement internals;
- MarketSense/Core/Hoomans ownership remains clean;
- the system is bounded, persistent, diagnosable, and regression-tested.

A phase completing is not completion of this parent objective.

## M0 — Source audit and contracts

### Work

- Re-audit current DTCommon trader/stock/policy/storage/quote APIs.
- Re-audit the current Hoomans settlement/trader arrival lifecycle that invokes or should invoke `MarkSettlementVisit`.
- Identify the stable settlement ID source already used by Hoomans/Core. Do not invent a competing settlement identity.
- Audit MarketSense taxonomy APIs suitable for category indexing.
- Write fail-first contract tests for persistent stock + settlement visit behavior.
- Finalize versioned compact schemas for settlement markets and events.

### Gate

A documented/tested contract proves the exact integration seams and baseline behavior before production market mutation is added.

## M1 — Settlement Market foundation

### Work

- Add market catalog/category adapter over MarketSense.
- Add settlement market registry/persistence.
- Add profile/baseline definitions.
- Add bounded supply/demand state and revisions.
- Add deterministic recovery toward baseline.
- Add queries/diagnostics without changing trade prices yet.

### Gate

Two settlements can persist distinct market profiles and pressure, recover deterministically, and reload without item-level state explosion.

## M2 — Settlement Exchange

### Work

- Evolve settlement restock into bounded partial exchange.
- Preserve existing trader stock.
- Plan bounded disposal and acquisition operations.
- Use settlement pressure + trader policy + MarketSense catalog.
- Mutate stock/budget/market pressure coherently.
- Increment stock/market revisions and persist once.
- Preserve existing transaction authority and exact stock representation.

### Gate

A trader visiting a farm-surplus settlement changes only part of their inventory, keeps unrelated existing stock, acquires appropriate goods, and produces deterministic market deltas.

## M3 — Market-aware pricing

### Work

- Add effective market context resolution.
- Add local scarcity/abundance modifier.
- Integrate existing trader relationship/policy bias.
- Preserve existing BUY/SELL commercial margins.
- Return structured server-owned price explanation.
- Clamp modifiers and add stale revision invalidation.

### Gate

Identical intrinsic items receive different bounded quotes under different settlement market states, and explanation exactly matches server arithmetic.

## M4 — Generic Market Event Registry

### Work

- Add versioned event registry.
- Support global/region/faction/settlement scopes.
- Add start/end time and expiry.
- Resolve category modifiers without event-specific branches.
- Add event context revision/invalidation.
- Do not mutate every trader at event start.

### Gate

A synthetic scoped event modifies the intended market context only, expires deterministically, and causes no trader stock rewrite by itself.

## M5 — Proof events

Implement at least:

### Food Shortage

- lowers food supply/availability;
- raises food demand/price;
- applies to one settlement scope.

### Agricultural Surplus

- raises food supply/availability;
- lowers relevant pressure/price.

### Gate

Both opposite-direction events use the same generic event pipeline and affect price immediately while persistent trader stock remains unchanged until a settlement exchange.

## M6 — Logistics propagation

### Work

Build deterministic two-settlement scenario:

```text
Settlement A: food surplus
Trader: visits A and acquires food
Trader travels
Settlement B: food shortage
Trader visits B and disposes/supplies food
```

Verify:

- trader exact stock carries between visits;
- A and B market pressure change in expected directions;
- later quotes reflect new local conditions;
- no global stock reroll;
- duplicate visit IDs cannot double-apply exchange.

### Gate

The two-settlement scenario passes end-to-end offline/integration acceptance and survives save/reload.

## M7 — Grounded event presentation

### Work

- Publish bounded market-event facts into existing WorldKnowledge seams.
- Expose event/market summary through existing Talk/Radio OS paths where appropriate.
- Preserve simulation authority in Market/Event services.
- Add truthful no-news behavior.
- Avoid duplicate gossip/event stores.

### Gate

A real active event can be surfaced as grounded market information, while no event produces no fabricated shortage/surplus claim.

## M8 — Performance, migration and hardening

### Work

- Add schema migration/default handling.
- Add event expiry/recovery edge cases.
- Add bounded catalog/cache invalidation tests.
- Add quote/visit/exchange profiling.
- Verify no per-frame/all-trader/all-item loops.
- Run full DT focused regressions.
- Verify Hoomans/Core/MarketSense integration boundaries.
- Add native SP/MP acceptance checklist and execute where authorized/available.

### Gate

The M0–M8 market/event engine is bounded, migrated, profiled, and regression-clean. This gate does **not** by itself prove ordinary gameplay activation; M9 is mandatory before native handoff.

## M9 — Runtime Market Activation

M9 closes the verified post-M8 gap between a working engine and an actually driven gameplay system.

### M9A — Automatic market provisioning and real arrival consumption

- Re-audit the current Project Hoomans community/mobile-settlement APIs before editing integration code.
- Use active Hoomans `community.id` as the market key; do not invent a second settlement identity.
- Provision a missing `SettlementMarket` automatically for an eligible active settlement, idempotently and lazily for existing saves.
- Resolve the initial market profile from existing Hoomans community/faction/archetype/tags through a bounded adapter; fall back to `default` when no reliable specialization is present.
- Consume the **existing Hoomans-owned mobile settlement arrival** lifecycle so an arriving bound trader triggers one DT visit/exchange. `DTHoomans.Settlement.StartTraderTravel` may remain as an explicit API/test helper, but normal economy activation must not require it.
- If Project Hoomans lacks a generic observer contract for settlement arrival, add only the smallest reusable non-DT-specific listener/notification seam there; Hoomans must remain movement/lifecycle authority.

#### Gate

Starting with an active Hoomans-style settlement and **no pre-created DT market**, normal binding/arrival provisions exactly one market and invokes at most one exchange. The acceptance path must not call `SettlementMarket.GetOrCreate`, `StartTraderTravel`, or the DT arrival handler directly from the test body.

### M9B — Production recovery runtime

- Wire deterministic market recovery into a bounded production runtime path.
- Recovery may be lazy-on-authoritative-access or a low-frequency bounded scheduler, but never a per-frame all-market simulation.
- Preserve `lastUpdateAt`, revision/stale-quote correctness, profile baselines, and save/reload behavior.
- Do not make client reads authoritative mutations.

#### Gate

After pressure is changed and game time advances, ordinary production entrypoints cause the settlement to move toward its profile baseline without a direct test call to `SettlementMarket.Recover`.

### M9C — Grounded production event producer

- Add one bounded production producer that calls the generic `MarketEvents` registry through normal gameplay.
- Prefer a deterministic market-condition producer for the first proof: e.g. sustained low food supply/high demand can produce `FOOD_SHORTAGE`, while a sufficiently abundant opposite state can produce `AGRICULTURAL_SURPLUS`.
- Evaluate underlying settlement pressure, not event-modified effective pressure, to avoid event self-feedback.
- Use thresholds/hysteresis, duration and/or cooldown so events cannot flap or recreate every tick.
- Keep event definitions data-only and keep the generic registry unaware of named event semantics.
- No random world-event library is required for M9.

#### Gate

A real settlement can enter and later leave a proof market event through the production producer without a direct test/debug `MarketEvents.Register` call. Price/presentation reacts immediately; exact trader stock still changes only through logistics.

### M9D — No-fixture gameplay lifecycle acceptance

Add a flagship integration scenario beginning from no DT market/event setup:

```text
Hoomans community exists
→ DT settlement trader binding discovers it
→ market is provisioned automatically
→ Hoomans-owned mobile trader/group arrives normally
→ exactly one DT exchange occurs
→ trader stock + local pressure persist
→ time advances
→ production recovery moves pressure toward baseline
→ market conditions trigger a proof event through the producer
→ quote and grounded presentation react
→ event expires/clears through normal runtime
→ save/reload preserves coherent state
```

The test may provide deterministic Hoomans/PZ engine fixtures, but it must invoke the same production integration entrypoints used by gameplay. It must not manually create the market, manually register the proof event, directly execute the exchange, or directly call recovery.

#### Gate

The no-fixture lifecycle passes, all M0–M8 regressions remain green, production Lua/Kahlua/static checks pass, and there is no new per-frame/all-trader/all-item hot loop.

M9A–M9D establish the runtime market engine, but later audit found resident-trader and mobility gaps. Native handoff is therefore deferred until M9E and M10 are accepted.

### M9E — Resident market context + cross-repo publication closure

- During settlement-trader binding, resolve the faction's active Hoomans `community.id`.
- Idempotently provision the settlement market and establish the resident trader's home/current settlement pricing context **without** inventing a fake visit or triggering a stock exchange.
- A resident trader must use the local settlement market before any mobile trader has ever visited.
- Preserve the distinction between `homeCommunityID` and the last actual commercial visit.
- Reconcile and publish the generic Hoomans mobile-settlement arrival observer contract required by DynamicTrading.
- At planning time Hoomans commit `2200b866` existed locally but not on a remote branch. Re-audit current history and do not blindly publish unrelated intervening work.
- Make generic arrival-listener diagnostics observable when a listener returns a clean `false, reason`, not only when it throws.

#### Gate

A fresh staffed settlement with no previous mobile arrivals can bind its resident trader, provision exactly one canonical market, and quote through that local market without causing a visit/exchange. A clean checkout/publication graph contains the required Hoomans observer API used by DynamicTrading, or a genuine publication blocker is reported precisely.

## M10 — Community Excursions & Commercial Trader Mobility

Read `COMMUNITY_EXCURSIONS.md` before implementing this phase.

### M10A — Generic non-admission settlement visit

Project Hoomans must support a temporary settlement visit that is semantically distinct from admission.

Required semantics:

- admission may transfer members into the destination community;
- temporary visit never transfers faction/community membership;
- visit intent is extensible, with `commercial` as the first consumer;
- relationship/hostility checks, pending-arrival handling, encounter deferral, visit expiry, LOD, and abstract travel reuse existing Hoomans machinery;
- the existing 35% AI settlement join chance remains admission-only.

Do not special-case Dynamic Trading inside generic Hoomans visit resolution.

#### Gate

A mobile trader can reach an AI or player settlement through the normal Hoomans lifecycle, stay temporarily, and leave without any member admission/absorption.

### M10B — Generic Community Excursion foundation

Add a purpose-agnostic Hoomans-owned temporary excursion model for community members.

Minimum lifecycle:

```text
AT_HOME
→ PREPARING
→ OUTBOUND
→ VISITING
→ RETURNING_HOME
→ AT_HOME
```

Requirements:

- canonical `homeCommunityID` / home faction identity;
- bounded participants and optional bounded itinerary;
- purpose token such as `commercial_run`;
- start/update/return/complete/fail state with revisions/timestamps;
- explicit exact-home resolution;
- lifecycle notifications;
- compact persistence/save-load continuation;
- public/social status projection separate from movement internals;
- no DT-owned travel engine.

Long-distance travel remains abstract; nearby/materialized Hoomans behavior remains live.

#### Gate

A generic settlement member can leave its community for a fixture purpose, travel through production Hoomans movement, and return to the exact home community across save/reload without changing faction/community membership.

### M10C — Base-less roaming commercial caravan

Correct the production DT caravan lifecycle so its ordinary AI can actually participate in commercial settlement travel.

Requirements:

- roaming caravan has no home community, no hidden base, and never enters a return-home state;
- remove/supersede stale DT caravan comments that imply an offscreen leader/base; do not implement a fake base to match old comments;
- do not merely force the existing admission scheduler;
- Hoomans owns candidate discovery, reachability, danger, diplomacy, final selection, travel, encounters, and visit lifecycle;
- Dynamic Trading contributes only a bounded commercial-opportunity score/provider;
- score may use carried stock, destination demand/scarcity, price spread, active market events, specialization, and bounded recent-visit history;
- player settlements compete as commercial markets under the same safety/opportunity contract rather than being selected solely because a player exists;
- recent-visit memory/cooldown prevents A↔B ping-pong;
- each accepted commercial visit triggers at most one DT settlement exchange.

#### Gate

A production-configured base-less caravan can naturally perform A→B→C commercial visits through Hoomans, preserve exact stock, modify each local market once, and never enter settlement admission or acquire a home community.

### M10D — Rare resident-trader commercial excursions

A settlement-owned trader remains home by default and leaves only through a rare, purposeful commercial-run policy.

Requirements:

- remain a member of the original settlement faction/community for the whole excursion;
- do not make the entire settlement faction mobile;
- derive home from canonical Hoomans community/site/home data;
- gate departure on home presence, cooldown, safety, meaningful economic opportunity, stock/budget, and protected task/follow state;
- preserve exact merchant stock;
- commercial stops use the generic temporary visit lifecycle and DT settlement exchange;
- returning targets the exact home community, not a fuzzy "any settlement" score;
- while away, the resident trader is not physically tradeable at home;
- on completion, home availability/status is restored and an optional final home-market exchange may occur through the same bounded contracts.

#### Gate

A resident trader performs Home A → commercial visit B → Home A, survives save/reload and abstract/live transitions, keeps its original faction/community membership and exact stock, and does not become a perpetual caravan.

### M10E — Semantic/public excursion facts + future request seam

Expose generic Hoomans public/social excursion queries and semantic context.

The semantic layer must be able to learn authoritative facts such as:

- trader is at home / preparing / away / visiting / returning;
- public reason is a trading run;
- rough destination when known;
- expected return when known.

Knowledge/privacy rules decide how much a speaker knows. Do not hard-code a fixed trader sentence inside the excursion service.

First proof:

> Asking a settlement local where its trader is can receive authoritative excursion context suitable for semantic realization, without querying Dynamic Trading travel internals.

Also preserve an agnostic future route-request/suggestion seam so a later semantic action such as "Can your trader visit our settlement?" can submit a request for faction/trader AI evaluation rather than directly commanding movement. A full invitation UI/dialogue flow is not required in M10.

#### Gate

Semantic/knowledge fixtures consume Hoomans public excursion state, return truthful absence/home/ETA context, and cannot mutate movement. The future request seam is bounded and decision-authoritative on the faction/trader side.

### M10F — Flagship lifecycle, failures, and hardening

Required flagship scenarios:

1. **Perpetual caravan:** A→B→C commercial visits, no admission, no home, no stock reroll.
2. **Resident trader:** Home A→B→Home A, rare departure, exact home return, membership preserved.
3. **Interruption/failure:** encounter deferral, invalid/hostile destination, duplicate arrival, active Follow/protected task, and save/reload do not corrupt lifecycle or stock.
4. **Semantic status:** locals see appropriate public excursion state during PREPARING/AWAY/RETURNING/HOME.

Run affected Project Hoomans, DynamicTrading, Core, MarketSense, semantic, Lua/Kahlua/static, persistence, and performance regressions.

#### Gate

Both trader types behave according to their distinct lifecycles through production entrypoints. No commercial visit can trigger member admission, no DT-owned movement authority is introduced, and long-distance travel remains abstract.

This gate proves lifecycle implementation, not final publication/semantic integration. M10G remains mandatory.

### M10G — Publication + Semantic Spatial Integration Closure

Read `SPATIAL_LANGUAGE.md` before implementation.

M10G closes two verified post-M10F gaps:

1. the required Hoomans M10 implementation is locally committed but not fully present on published `origin/main`;
2. generic excursion semantic APIs exist, but the production semantic question/fact/realization pipeline does not yet consume them.

It also introduces one reusable Core spatial-language primitive rather than trader-specific direction math.

#### M10G-A — Clean cross-repo publication

Re-audit DynamicTrading, ProjectHoomans, and PsychopatzCore local/remote state first.

Planning snapshot:

- DynamicTrading local/main = origin/main at `447cc27a`;
- ProjectHoomans local `main` was clean at `7df32a63` and 9 commits ahead of `origin/main` `fb5c7566`;
- the ahead Hoomans history interleaves required M10 commits with unrelated semantic-scene commits;
- PsychopatzCore local/main = origin/main at `ea5a1c7c`.

Do not blindly push Hoomans local `main`.

Safely reconcile/publish the minimal required M10 dependency graph from the current verified source. A detached clean worktree or equivalent repository-safe method is acceptable if it does not create a new branch or disturb the user's local main. Re-run tests against the exact publishable commit graph before pushing.

#### Gate

Fresh published snapshots of the required repositories contain `PNC_CommunityExcursionService`, `PNC_CommercialMobilityService`, resident excursion integration, and their required dependencies. DynamicTrading M10D/M10F tests no longer fail because published Hoomans files are missing.

#### M10G-B — PsychopatzCore reusable spatial relation

Add a portable shared/common Core module per `SPATIAL_LANGUAGE.md`.

Required capabilities:

- validate finite point coordinates;
- compute dx/dy and Euclidean distance;
- compute a canonical angle/bearing representation;
- classify `SAME_AREA` plus all eight cardinal/intercardinal directions;
- preserve numeric distance;
- support configurable same-area threshold;
- optionally classify configurable coarse distance bands;
- expose canonical tokens independent of English prose;
- integrate with existing translation/presentation conventions for English labels without duplicating hard-coded strings across consumers.

Verify Project Zomboid's actual world-axis orientation and freeze it in tests. Do not let Hoomans or DynamicTrading guess sign conventions independently.

#### Gate

Core regression proves all eight directions, exact opposites, same-area behavior, invalid-coordinate safety, distance correctness, and the frozen PZ coordinate orientation. The module has no Hoomans/DynamicTrading dependency and performs O(1) work.

#### M10G-C — Hoomans destination/place presentation

Extend Hoomans' generic excursion semantic projection using authoritative place data.

Requirements:

- resolve destination `community.id` to the current `community.name`;
- resolve destination coordinates from authoritative community/site/home state;
- resolve the semantic origin primarily from the speaker/home community when answering about its own absent member;
- use Core spatial relation for direction/distance;
- for player colony/base targets, resolve the existing canonical user-facing name if trustworthy;
- omit a name/direction when authoritative data is unavailable rather than leaking an internal ID or fabricating location text;
- do not persist copied destination names or computed directions in excursion state.

#### Gate

Renaming or relocating a destination changes later semantic presentation automatically without rewriting the excursion record. Hoomans tests prove canonical name + spatial relation from live authoritative state.

#### M10G-D — Production semantic whereabouts provider + realization

Wire the generic excursion/whereabouts facts into the **real production semantic pipeline**, not a direct API-only test.

Use a generic fact/intent such as `COMMUNITY_ROLE_WHEREABOUTS` with `role=trader` as the first consumer.

Support natural input variants including at least:

- "Where is your trader?"
- "Where's the trader?"
- "Do you know where the trader went?"

The production flow must resolve:

```text
semantic/NLU question
→ generic role-whereabouts fact
→ Hoomans privacy-aware excursion status
→ authoritative destination place
→ Core spatial relation
→ semantic realization
```

For an authorized local, context/realization must be able to include:

- actual destination settlement name;
- relative direction from the meaningful origin;
- ETA/return time when known.

For an outsider or poorly informed speaker, privacy may omit destination name, direction, and ETA.

Do not hard-code one fixed trader sentence inside movement/excursion services. Reuse the semantic realization/localization system and provide variants where that system expects them.

#### Gate

A production semantic test—not a direct `GetSemanticContext` call—can answer an informed local with grounded content equivalent to:

> "Our trader is at Riverside Collective, northeast of here."

when the authoritative fixtures support that fact.

The same test suite proves home/preparing/away/returning states, outsider privacy, and that semantic queries cannot start/cancel/redirect an excursion.

#### M10G-E — Published-pair acceptance

After publication, validate from clean/fresh snapshots of the published repository heads rather than only the local combined checkout.

At minimum:

- Core spatial tests;
- Hoomans excursion/commercial mobility/semantic tests;
- DynamicTrading resident/caravan/market suites;
- cross-repo bridge tests;
- Lua/Kahlua/static/translation/diff checks;
- no missing-module failures from published `origin/main` heads.

#### Gate

The published repository graph reproduces the accepted developer behavior. Only then may native SP/MP be the sole remaining user-owned acceptance gate.

M10G is accepted and remains the published foundation.

### M10H — Observer-Relative Tactical Bearings

M10H extends the accepted Core spatial relation service with a second explicit reference frame for immediate local/tactical speech.

Read the observer-relative sections of `SPATIAL_LANGUAGE.md` before implementation.

#### M10H-A — Core heading-relative clock relation

Extend `PsychopatzCore.SpatialRelation` with a generic public observer-heading relation API.

Required behavior:

- caller supplies observer point, target point, and a world-space forward/heading vector;
- normalize valid non-zero heading vectors;
- compute target angle relative to forward;
- 12 o'clock = forward;
- 3 o'clock = right;
- 6 o'clock = behind;
- 9 o'clock = left;
- expose all 12 deterministic 30-degree clock sectors;
- expose canonical tokens `CLOCK_01` … `CLOCK_12`;
- expose a coarse egocentric sector such as `AHEAD`, `FRONT_RIGHT`, `RIGHT`, `REAR_RIGHT`, `BEHIND`, `REAR_LEFT`, `LEFT`, `FRONT_LEFT`;
- preserve distance/same-area information;
- zero/invalid heading fails safely;
- same-area targets do not emit misleading tactical bearings;
- no Hoomans/zombie/combat dependency in Core.

Add translation/presentation-safe clock labels without scattering hard-coded strings through consumers.

#### Gate

Core tests prove all principal clock axes, representative intermediate hours including `CLOCK_08`, deterministic boundaries, arbitrary/scaled heading vectors, observer rotation, invalid heading safety, same-area behavior, and O(1) operation.

#### M10H-B — Hoomans authoritative live heading adapter

Expose/reuse one Hoomans-owned way to obtain a trustworthy live actor forward vector.

Requirements:

- prefer the materialized body's engine `getForwardDirection()`;
- reuse existing Hoomans pathing/facing state only when considered current/trustworthy;
- do not duplicate facing extraction in individual semantic/combat callout modules;
- no trustworthy heading means no clock bearing;
- abstract/offscreen actors normally omit clock bearing unless an explicit authoritative heading exists.

#### Gate

Hoomans tests prove live forward-vector extraction, invalid/missing fallback behavior, and that no fabricated clock hour is produced for an actor without reliable orientation.

#### M10H-C — Tactical threat spatial projection

Add/reuse a generic Hoomans tactical spatial projection for an already-selected perceived target.

Hoomans perception/combat remains responsible for:

- which zombie/hostile/object is perceived;
- salience/target selection;
- grouping/centroid policy for multiple threats;
- freshness of perception;
- combat/alert eligibility.

The spatial projection consumes only:

```text
observer position
observer heading
selected target position
```

and produces canonical clock/coarse-relative spatial facts through Core.

Clock bearing is ephemeral: derive it from current observer/target state at callout time. Do not persist `8 o'clock` as durable knowledge when observer/target motion can invalidate it.

#### Gate

A live observer seeing a target at the appropriate geometry receives `CLOCK_08`/rear-left facts; rotating the observer or moving the target updates the result without rewriting persisted knowledge.

#### M10H-D — Semantic tactical-callout realization

Wire the relative facts into the existing semantic/conversation/combat-callout surface as reusable presentation data.

The system must support grounded realization equivalent to:

> "Zombies, eight o'clock!"

or:

> "Hostiles at three o'clock!"

without hard-coding one universal sentence.

Clock-face speech is a style choice, not universal NPC speech. Tactical/military/guard/raider or urgent coordinated contexts may prefer clock wording; other speakers may use coarse observer-relative wording such as:

> "Zombies behind us, left side!"

Do not make Core responsible for combat vocabulary, personality, traits, or sentence selection.

#### Gate

Production semantic/callout tests prove a current perceived zombie/hostile can be described with the correct clock hour for an eligible tactical speaker, while a non-tactical style can consume the same fact using coarse relative wording. The query/callout remains read-only with respect to movement/combat target state.

#### M10H-E — Published-head acceptance

Publish Core before downstream Hoomans depends on the new API.

Then validate clean published snapshots of required repos:

- Core clock-bearing tests;
- Hoomans heading/tactical spatial tests;
- semantic/combat callout tests;
- existing M10G trader whereabouts/cardinal tests remain green;
- DynamicTrading market/mobility regressions remain green;
- Lua/Kahlua/static/translation/diff checks pass.

#### Gate

Published heads reproduce both spatial reference frames:

```text
WORLD_CARDINAL
    → settlement/place direction

OBSERVER_HEADING
    → tactical clock/coarse-relative direction
```

Only after M10H is accepted may native SP/MP again be the sole remaining user-owned acceptance gate.

## Optional later extensions — not part of completion

- winter/season adapter;
- military surplus;
- medical crisis;
- fuel shortage;
- route disruption;
- grounded settlement destruction events;
- physical Hoomans settlement-storage supply provider;
- deeper trader archetypes/reputation;
- faction macroeconomy.

Do not expand into these until M0–M10 are complete unless a required architecture seam needs a tiny fixture.
