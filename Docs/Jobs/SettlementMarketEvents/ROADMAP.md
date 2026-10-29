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
- eligible Hoomans settlements automatically provision a DT market without a test/debug fixture;
- the ordinary Hoomans settlement-arrival lifecycle invokes the economic exchange without requiring DT to own or start the journey;
- market pressure actually recovers through a bounded production runtime path;
- at least one grounded production event producer registers and expires real events without manual/test registration;
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

Only after M9 is accepted may the parent goal be handed to the user with native SP/MP as the sole remaining acceptance gate.

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

Do not expand into these until M0–M9 are complete unless a required architecture seam needs a tiny fixture.
