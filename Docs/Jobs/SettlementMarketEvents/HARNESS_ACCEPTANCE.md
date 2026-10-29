# Acceptance — Settlement Market, Events & Trader Mobility

## Evidence rule

Passing static Lua parse or a mocked data table is not sufficient for this goal.

Use the strongest available real production modules and current in-repo test harnesses. Preserve exact evidence categories:

- source/static;
- deterministic Lua smoke;
- integration smoke using production DTCommon modules;
- persistence/reload;
- native SP;
- native MP.

Do not claim native acceptance from mocks.

## Required baseline tests

Before changing behavior, capture tests for:

1. trader stock persists across snapshots;
2. reopening a trader does not reroll stock;
3. `MarkSettlementVisit` requires settlement context;
4. duplicate visit IDs are rejected or idempotent;
5. current buy/sell settlement path remains server authoritative;
6. MarketSense intrinsic value remains the base pricing source.

## M1 market tests

At minimum:

- create two settlement profiles;
- set distinct pressure;
- save/reload exact bounded market state;
- deterministic recovery toward baseline;
- clamp invalid/out-of-range values;
- unknown category handling;
- no item-universe persistence.

## M2 exchange tests

At minimum:

- existing trader inventory contains unrelated preserved goods;
- farm settlement exposes food surplus;
- one visit changes only a bounded subset of stock;
- acquisition follows eligible MarketSense-backed category candidates;
- disposal follows local demand;
- stockVersion increments once;
- market revision increments correctly;
- budget remains non-negative;
- save failure leaves coherent pre-operation state or explicit rollback failure;
- duplicate visit cannot double exchange.

## M3 pricing tests

At minimum:

- same intrinsic item, two settlement market contexts, different expected quote;
- shortage raises expected price;
- abundance lowers expected price;
- modifier bounds prevent explosion;
- price breakdown sums/multiplies exactly according to policy;
- relationship modifier remains bounded and does not replace market state;
- unavailable MarketSense price remains unavailable.

## M4/M5 event tests

At minimum:

- settlement-scoped event affects only target settlement;
- global event affects all intended contexts;
- faction/region scopes are either implemented and tested or explicitly deferred by roadmap revision;
- event starts and expires at deterministic timestamps;
- event start does not mutate trader stock;
- food shortage and agricultural surplus use data definitions through the same resolver;
- active event changes price/availability;
- event expiry restores normal context/recovery behavior.

## M6 logistics scenario

This is the flagship acceptance scenario.

### Initial state

Settlement A:
- farm-oriented;
- food surplus.

Settlement B:
- food shortage.

Trader T:
- persistent exact stock;
- bounded budget;
- no magical refresh.

### Sequence

1. Record T stock.
2. T arrives at A.
3. Run one settlement exchange.
4. Verify food acquisition and A pressure change.
5. Persist/reload.
6. Simulate/authorize lifecycle transition to B.
7. T arrives at B.
8. Run one settlement exchange.
9. Verify some food leaves T stock / is supplied to B.
10. Verify B supply improves or demand pressure reduces.
11. Verify B food quote moves in expected direction.
12. Re-run same visit ID and prove no duplicate economic mutation.

### Required invariant

The trader is the logistics carrier between the two markets. No hidden global stock teleport or reroll may satisfy the test.

## M7 world-knowledge tests

- active authoritative market event publishes one bounded fact;
- source/scope/time are inspectable;
- Talk/Radio presentation consumes the same fact;
- no active event yields truthful no-news rather than invented market gossip;
- event presentation cannot mutate price/stock.

## Persistence tests

Save/reload must preserve:

- settlement profile ID;
- compact current pressure;
- revisions;
- active event definitions or references required for continuation;
- event expiry timing;
- trader stock/budget;
- trader visit idempotency state necessary to prevent duplicate exchange.

Do not duplicate MarketSense item definitions into persisted market state.

## Performance tests

Required observations:

- market recovery tick cost;
- event resolution count;
- catalog candidate query count;
- settlement exchange operation count;
- quote market-context resolution;
- serialized market/event bytes for representative settlement counts.

Explicit failures:

- full MarketSense registry scan per quote;
- full registry scan per ordinary settlement visit after cache warmup;
- per-frame economy update;
- all-trader update when event starts;
- unbounded event list;
- unbounded category state.

## Regression suites

Run focused DynamicTrading tests plus any affected Core/Hoomans/MarketSense tests.

Known unrelated failures must be reported precisely rather than silently treated as new regressions.

## M9 runtime activation acceptance

M9 exists because M0–M8 proved the engine with fixtures but did not prove that ordinary gameplay drives it.

### No-manual-fixture rule

The flagship M9 lifecycle test must begin with:

- an eligible active Hoomans community/faction;
- a bound/eligible trader or mobile trading group;
- **no pre-created DT settlement market** for the target community;
- **no pre-registered DT proof event**.

The test body must not directly call:

- `SettlementMarket.GetOrCreate`;
- `SettlementExchange.Execute`;
- `SettlementMarket.Recover`;
- `MarketEvents.Register`;
- `DTHoomans.Settlement.StartTraderTravel`;
- the private DT arrival handler.

It may drive the public/authoritative Hoomans lifecycle using deterministic PZ/Hoomans fixtures.

### Required M9A evidence

- settlement trader/community binding or first authoritative economic access provisions exactly one market;
- provisioning is idempotent across repeated sweeps/accesses and save/reload;
- the canonical key is Hoomans `community.id`;
- profile selection reads bounded existing Hoomans metadata and safely falls back to `default`;
- a **normal Hoomans-owned mobile settlement arrival** reaches DT exactly once and produces one visit/exchange;
- no DT-owned journey is required for the production path;
- duplicate/replayed Hoomans arrival cannot double-apply exchange.

### Required M9B recovery evidence

- mutate a market away from baseline through a normal economic action;
- advance authoritative game time;
- invoke the normal production runtime path;
- verify pressure moves toward the profile baseline without a direct `Recover` test call;
- verify revisions/timestamps advance coherently;
- verify client/read-only paths do not become mutation authority;
- verify recovery remains bounded and is not per-frame/all-market work.

### Required M9C event-producer evidence

- create market conditions that satisfy the producer using normal market mutation;
- invoke the normal production producer/runtime path;
- verify a proof event is registered without direct `MarketEvents.Register` from the test body;
- verify the event uses the existing generic registry and data-only definition;
- verify price/availability and WorldKnowledge/Radio presentation react;
- verify exact trader stock does not mutate merely because the event starts;
- verify expiry/clear/cooldown behavior prevents immediate flapping or duplicate recreation;
- verify producer evaluation uses underlying persisted market pressure rather than its own event-modified effective pressure.

### Flagship sequence

```text
Hoomans community exists
→ DT binding/first access provisions market
→ Hoomans-owned mobile trader/group arrives normally
→ one DT partial exchange occurs
→ stock and pressure persist/reload
→ game time advances
→ production recovery runs
→ grounded market conditions trigger proof event
→ quote + event presentation react
→ event expires/clears normally
→ duplicate arrival/producer pass causes no duplicate mutation
```

### M9 gate

M9 passes only when the above no-fixture lifecycle is green with production integration entrypoints, all previous DynamicTrading regressions remain green, affected Project Hoomans/Core/MarketSense regressions pass, and production Lua/Kahlua/static/diff checks remain clean.

M9A–M9D satisfy runtime market activation, but later audit found resident/publication and trader-mobility gaps. Native handoff is deferred until M9E and M10.

## M9E resident/publication acceptance

Required evidence:

- begin with a fresh active Hoomans settlement staffed with a resident trader;
- no mobile trader has visited and no DT market exists yet;
- run the production resident binding path;
- exactly one canonical market is provisioned from that settlement's `community.id`;
- resident trader home/current market context resolves immediately;
- snapshot/quote applies the local market;
- binding does not call a fake settlement visit, does not change market pressure, and does not mutate merchant stock/budget;
- repeat binding and save/reload remain idempotent;
- the generic Hoomans arrival observer used by DynamicTrading is present in the safely published dependency graph;
- observer callbacks that return `false, reason` are diagnostically visible without breaking the Hoomans-owned arrival lifecycle.

## M10 Community Excursions & Commercial Trader Mobility acceptance

### M10A non-admission visit

Prove through production Hoomans APIs:

- temporary settlement visit is a distinct purpose from admission;
- commercial intent can reach AI and player settlements;
- relationship/hostility checks still apply;
- encounter/pending-arrival behavior is reused;
- visit expiry returns the visitor to ordinary mobility;
- no visitor member is transferred to the destination faction/community;
- admission fixtures still retain their existing configured join behavior;
- commercial visit outcome is unaffected by the 35% admission join chance.

### M10B generic excursion foundation

Using a non-DynamicTrading fixture purpose:

- community member starts at exact home community;
- PREPARING → OUTBOUND → VISITING → RETURNING_HOME → AT_HOME transitions are inspectable;
- participant remains a member of the original faction/community;
- exact home is the originating `community.id`, not merely any settlement;
- save/reload during OUTBOUND/VISITING/RETURNING resumes coherently;
- lifecycle notifications are emitted once per accepted transition;
- failure/invalid destination becomes a bounded failed/recovery state rather than teleporting or deleting the member;
- public/social status is a projection of authoritative state rather than separate persistence.

### M10C perpetual caravan flagship

Start with a production-configured DT roaming caravan — do not manually set its destination.

Required sequence:

```text
base-less caravan
→ Hoomans/DT commercial scoring chooses settlement A
→ abstract travel
→ commercial visit A
→ one DT exchange
→ leave
→ choose B
→ visit/exchange B
→ choose C
→ visit/exchange C
```

Verify:

- caravan has no `homeCommunityID`, hidden base, or offscreen home leader assumption;
- it never enters settlement admission;
- it never joins/gets absorbed by A/B/C;
- exact trader stock carries across all legs;
- each visit mutates the destination market at most once;
- recent-visit memory prevents immediate A↔B ping-pong under deterministic scoring;
- player settlement candidates use the same safety/opportunity contract rather than an unconditional player preference;
- long-distance legs are abstract;
- local/materialized trade/conversation remains available when relevant;
- save/reload and duplicate arrival are idempotent.

### M10D resident-trader flagship

Start with a resident trader at Home A.

Drive the production rare-excursion policy deterministically through fixtures rather than directly starting travel.

Required sequence:

```text
HOME A
→ PREPARING
→ OUTBOUND
→ commercial visit B
→ RETURNING_HOME
→ HOME A
```

Verify:

- trader remains a member of Home A faction/community for the entire run;
- the whole settlement faction is never converted into a mobile group;
- the trader is unavailable for physical home trading while away;
- exact stock survives all legs;
- B visit performs one bounded exchange;
- return target is exactly Home A;
- home status/availability is restored on completion;
- home cooldown prevents immediate repeat departure;
- Follow Player/protected task can block automatic departure;
- invalid/hostile destination triggers alternate/return/failure policy without stock reroll;
- save/reload in every major phase remains coherent.

### M10E semantic/public status

At minimum:

- AT_HOME yields truthful home/available public status;
- PREPARING yields a bounded preparing/trading-run fact;
- OUTBOUND/VISITING yields away/trading-run fact;
- rough destination/ETA are exposed only when public/known;
- RETURNING_HOME yields returning status;
- a settlement local's semantic context can answer a "where is the trader?" fixture from Hoomans public/knowledge state;
- an outsider fixture receives no privileged route information;
- semantic/public queries cannot start, cancel, redirect, or mutate an excursion;
- no fixed DynamicTrading movement sentence is authored inside the excursion service.

### Future request seam

Prove only the extension contract:

- an external/semantic caller can submit a bounded commercial destination request/suggestion;
- request does not directly mutate travel;
- faction/trader policy returns accept/reject/defer or equivalent;
- accepted request still enters the normal Hoomans excursion/route planner.

A full player-facing invitation flow is not required.

### M10 performance/regression failures

Explicit failures:

- per-frame global route solving;
- full settlement-market scan for every NPC;
- full MarketSense registry scan per route decision;
- physical full-map caravan pathfinding requirement;
- unbounded recent-route history;
- duplicate excursion/public-state persistence;
- DynamicTrading becoming the travel/encounter/LOD authority.

### M10 final gate

M10 is accepted only when both flagship lifecycles pass through production entrypoints, generic Hoomans non-admission/excursion contracts pass independently of DT, affected semantic tests consume public facts correctly, all previous market/event regressions remain green, and required cross-repo commits are safely published or a genuine blocker is documented.

Only after M9E + M10 may native SP/MP be the sole remaining user-owned gate.

## Native acceptance

When normal Project Zomboid SP/MP is authorized/available:

- trader stock continuity through close/reopen;
- settlement arrival triggers one exchange;
- travel to another settlement preserves stock;
- event changes visible quote without magical stock mutation;
- save/reload continuity;
- MP server is authoritative;
- reconnect does not double-apply visit/exchange;
- roaming caravan can naturally complete non-admission commercial settlement hops;
- resident trader can leave on a rare commercial excursion, be absent at home, and return to the exact home settlement;
- faction/community membership remains correct for both trader types;
- local semantic status truthfully reflects home/preparing/away/returning phases.

If native testing is user-owned, Luna must finish every developer-side gate first and leave only the explicit native evidence pending.
