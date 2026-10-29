# Acceptance — Settlement Market & Events

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

## Native acceptance

When normal Project Zomboid SP/MP is authorized/available:

- trader stock continuity through close/reopen;
- settlement arrival triggers one exchange;
- travel to another settlement preserves stock;
- event changes visible quote without magical stock mutation;
- save/reload continuity;
- MP server is authoritative;
- reconnect does not double-apply visit/exchange.

If native testing is user-owned, Luna must finish every developer-side gate first and leave only the explicit native evidence pending.
