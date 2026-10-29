# Roadmap — Settlement Market & Events

## Parent completion boundary

The parent goal is complete only when the current Dynamic Trading rewrite has a verified settlement-centered market and event system in which:

- persistent traders carry exact stock across sessions;
- settlement visits partially exchange stock instead of rerolling it;
- settlements own bounded local supply/demand state;
- market pressure affects both availability and price;
- typed scoped events affect the same market pipeline;
- events affect prices immediately but stock only through logistics;
- trader travel between two settlements can move market pressure through persistent stock;
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

No unresolved developer-side correctness/performance/security regression remains. Native user-owned acceptance may remain explicitly pending only after all implementable work is complete.

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

Do not expand into these until M0–M8 are complete unless a required architecture seam needs a tiny fixture.
