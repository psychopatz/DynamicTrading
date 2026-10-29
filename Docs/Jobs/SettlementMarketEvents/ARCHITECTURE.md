# Architecture — Settlement Market & Events

## 1. Ownership

### MarketSense owns

- intrinsic item value;
- item definition and instance valuation;
- eligibility evidence;
- taxonomy/tags/capabilities used for market categories.

Dynamic Trading must not recreate a manual item price database.

### Dynamic Trading / DTCommon owns

- settlement market profiles;
- local supply/demand pressure;
- market recovery;
- event registry and event effects;
- trader economic specialization/preferences;
- trader merchant stock and budget;
- settlement exchange planning;
- final market quote modifiers;
- stock revisions and commercial transactions;
- market diagnostics and price explanations.

### Project Hoomans owns

- physical NPC identity;
- faction/settlement membership;
- travel and movement;
- arrival/departure;
- body lifecycle;
- schedules/tasks;
- physical settlement presence.

Dynamic Trading reacts to authoritative Hoomans lifecycle events. It must not simulate a second NPC.

### PsychopatzCore owns

- reusable actor identity/contracts;
- generic persistence/inventory/currency primitives;
- reusable Radio OS;
- shared world-knowledge mechanisms.

## 2. Core invariant

> **Trader stock is exact persistent inventory. Settlement markets are compact economic pressure, not giant simulated warehouses.**

Do not store a complete item ledger for every settlement.

## 3. State model

### SettlementMarket

A settlement owns compact category-level state:

```lua
SettlementMarket = {
    schemaVersion = 1,
    settlementID = "...",
    profileID = "farm",
    revision = 12,
    lastUpdateAt = 0,

    wealth = 0.65,

    categories = {
        ["food.fresh"] = { supply = 0.82, demand = 0.25 },
        ["food.preserved"] = { supply = 0.68, demand = 0.35 },
        ["medical"] = { supply = 0.28, demand = 0.82 },
        ["ammunition"] = { supply = 0.18, demand = 0.70 },
    }
}
```

Exact schema may be made more compact, but semantics must remain explicit and versioned.

The M0B contract fixes the first persisted schema version and bounded defaults:

- `settlementID` is required and is the Hoomans `community.id` value;
- `profileID` defaults to `default`, `wealth` defaults to `0.5`, and missing
  category supply/demand defaults to `0.5`;
- supply, demand, and wealth are clamped to `0..1`;
- a market stores at most 32 category records and its envelope stores at most
  256 settlement records;
- `revision` and `lastUpdateAt` are non-negative bounded values;
- unknown fields are dropped during normalization, and future schema versions
  are rejected rather than silently rewritten.

The event schema uses the same data-only boundary with at most 16 modifiers per
event and 128 events per envelope. Event scopes are generic `global`, `region`,
`faction`, or `settlement` records; non-global scopes require an ID. Modifier
values are bounded, event expiry cannot precede its start, and presentation
fields contain localization keys only. These limits bound persistence without
creating an item ledger or hard-coded event branches.

### Trader

A trader keeps existing exact persistent state:

```text
traderID
actorID
factionID
budget
persistent stock
stockVersion
current / last settlement context
market visit policy
specialization / preference policy
```

Do not replace stock on UI open or on every session.

### MarketEvent

```lua
MarketEvent = {
    schemaVersion = 1,
    eventID = "...",
    type = "food_shortage",
    startsAt = ...,
    endsAt = ...,

    scope = {
        kind = "settlement", -- global | region | faction | settlement
        id = "..."
    },

    modifiers = {
        {
            marketTag = "food",
            supplyDelta = -0.30,
            demandDelta = 0.15,
            availabilityMultiplier = 0.70,
            priceMultiplier = 1.20,
        }
    },

    presentation = {
        headlineKey = "...",
        descriptionKey = "...",
        importance = 2
    }
}
```

Events are data. Market code must not contain long event-ID-specific condition chains.

## 4. Settlement profiles

Settlement profiles define **natural baselines**, not current exact state.

Example:

```text
Farm settlement
  food.fresh       high baseline supply
  seeds            high
  medical          low
  ammunition       low-medium

Military settlement
  ammunition       high
  protective gear  high
  food             low
  medical          medium demand
```

Pressure recovers gradually toward these baselines.

Profiles should use MarketSense-derived category/tag vocabulary through one DT market-catalog adapter.

## 5. Market pressure

Use normalized bounded values, not literal region-wide item counts.

Recommended domain:

```text
supply: 0.0 .. 1.0
demand: 0.0 .. 1.0
```

Interpretation is policy-defined. Values must be clamped and deterministic.

### Market writes

Initial scope:

- trader acquisition from settlement: local supply decreases slightly;
- trader delivery/disposal into settlement: local supply increases;
- delivered goods may reduce relevant demand slightly;
- active events contribute modifiers;
- periodic recovery moves current state toward profile baseline.

Do not make one trivial player transaction create global economic instability.

## 6. Settlement exchange

Existing `MarkSettlementVisit` is the lifecycle entry seam.

Target flow:

```text
Hoomans confirms trader arrival at settlement
    ↓
DTCommon.MarkSettlementVisit
    ↓
SettlementMarket.Resolve(settlementID)
    ↓
SettlementExchange.Plan(...)
    ↓
bounded disposal decisions
bounded acquisition decisions
    ↓
mutate persistent trader stock/budget
    ↓
apply bounded pressure deltas to settlement
    ↓
increment stock + market revisions
    ↓
persist once
```

### Critical rule

The exchange must **partially modify** existing stock.

Never:

```text
visit → discard stock → generate entirely new random stock
```

Prefer a bounded number of stock operations per visit, e.g. a small maximum acquisition/disposal count derived from policy. Exact tuning is not part of the contract.

## 7. Acquisition planning

Candidate selection should be category-first and bounded:

```text
settlement supply
+ trader specialization
+ active events
+ trader budget/capacity
    ↓
candidate market categories
    ↓
bounded MarketCatalog item candidates
    ↓
weighted acquisition
```

Never scan the complete installed item universe on every visit.

Cache definition-level MarketSense facts behind a dedicated market catalog/index.

## 8. Disposal planning

A trader may sell/exchange some carried merchant stock into a settlement when:

- the settlement has meaningful demand;
- the trader has compatible stock;
- the settlement can economically absorb it;
- bounded visit policy allows the operation.

Disposal should not empty the trader inventory unless market conditions and bounded policy actually justify it.

## 9. Pricing pipeline

```text
MarketSense intrinsic value
    ↓
Existing BUY/SELL commercial base
    ↓
Settlement market pressure modifier
    ↓
Active event modifier
    ↓
Relationship/policy modifier (existing bounded seam)
    ↓
final authoritative quote
```

Every component should be inspectable.

A quote should be able to explain something conceptually like:

```text
Intrinsic value             100
Settlement scarcity         +18%
Food shortage event         +12%
Trader preference            +4%
Relationship                 -5%
Commercial side margin      ...
Final                         ...
```

Do not expose client-authoritative arithmetic. Breakdown is presentation of server-owned calculation.

### Bounds

Dynamic modifiers must be clamped to prevent runaway multiplicative explosions.

The current DTCommon quote adapter keeps MarketSense's intrinsic price as the
only valuation source. It derives a category from the bounded MarketSense
catalog, maps `demand - supply` through a `0.25` pressure scale, clamps the
result to `-0.25..0.25`, and composes that factor with the existing relationship
bias and BUY/SELL commercial base. Quote explanations include the intrinsic
price, commercial base, effective category pressure, event factor, relationship
factor, rounding input, and final unit price. Settlement and event revisions
are carried with the context so a server trade can reject stale market data
before mutation.

## 10. Price vs stock timing

This distinction is mandatory:

### Price

Price may react immediately when effective market context changes.

### Stock

Existing trader stock changes only through actual lifecycle/logistics:

- trader creation bootstrap;
- validated settlement exchange;
- explicit transaction;
- later approved physical resource provider.

Therefore:

> **Prices respond to information; inventory responds to logistics.**

The proof event definitions use the same generic `marketTag` modifier shape as
all other event producers. Their availability multiplier is surfaced in the
server quote explanation and bounds category candidate exposure during a
settlement exchange; it does not remove or reroll existing exact trader stock.

The M6 logistics proof exercises this boundary end to end: an authoritative
Hoomans arrival resolves the active `community.id`, DTCommon partially
exchanges the trader's existing serialized stock, persists stock and market
revisions, and a later arrival applies the carried goods to a different local
market. Replaying the same bounded visit ID is accepted as handled but cannot
repeat the stock, budget, or pressure mutation.

## 11. Events

Events contribute modifiers through a resolver.

Supported initial scopes:

- global;
- region;
- faction;
- settlement.

Effective context:

```text
global
+ region
+ faction
+ settlement
= effective market modifiers
```

Events must not loop over all traders and rewrite stock when created.

The current registry persists events in a separate bounded event envelope. A
server registration/removal advances the store revision; quote resolution
derives an additional deterministic context revision from the current scope,
active event IDs, and time window. This means an event can invalidate a quote
when it starts or expires without a per-frame loop or a write to every trader.
Matching global, region, faction, and settlement records aggregate generic
category modifiers into a bounded effective context. No event type or event ID
is special-cased by the market or quote code.

Event start:

```text
register event
→ increment event/market context revision
```

Trader stock responds later when a relevant settlement exchange occurs.

## 12. Event sources

The Event Registry must accept events from multiple producers without coupling:

- procedural scheduler;
- season adapter;
- faction/world systems;
- admin/debug tools;
- future grounded settlement outcomes.

The event consumer does not care who produced the event.

## 13. World knowledge / radio integration

A market event may publish a grounded WorldKnowledge fact.

Example:

```text
Food shortage reported at Settlement B.
```

Radio/Talk/NPC dialogue may present only authoritative published facts.

Dialogue must not invent market events.

Presentation is downstream of simulation truth.

The M7 presentation adapter reads active events from the registry and projects
them into Core WorldKnowledge as bounded `market.event` facts. The fact keeps
the event producer, settlement scope, start/expiry window, localization keys,
and stable identity inspectable. WorldKnowledge acquisition happens on demand
for the trader being presented, so event activation never rewrites every
trader. Talk consumes the fact for grounded gossip/no-news behavior; Radio OS
contact projections consume the same event summary for localized news/no-news
status. Neither path writes trader stock, budget, quotes, or market pressure.

## 14. Physical settlement resources — future-compatible seam

Initial implementation uses abstract market pressure.

Define a supply-provider contract so a future Hoomans settlement storage integration can replace/augment abstract supply:

```text
SettlementSupplyProvider
    GetAvailableSupply(...)
    Acquire(...)
    Deliver(...)
```

Initial provider:

`AbstractMarketSupplyProvider`

Potential later provider:

`HoomansSettlementStorageProvider`

Do not block this goal on full physical settlement-storage accounting.

## 15. Performance invariants

- no per-frame economy simulation;
- no all-NPC economy loop;
- no full item registry scan per quote or visit;
- no event-time rewrite of every trader;
- bounded category set per settlement;
- bounded event set and modifier resolution;
- bounded acquisition/disposal operations per visit;
- cache MarketSense definition facts;
- event/market/stock revisions drive invalidation;
- persist once per coherent market exchange.

The runtime hardening boundary keeps the primary MarketSense catalog scan
game-start/cache-driven and caps uncatalogued taxonomy facts at 256 entries.
The optional Core profiler feature measures quote-context resolution, event
resolution/presentation, catalog candidate queries, market recovery, the
authoritative settlement visit seam, and settlement exchange execution. It is
installed only when Core performance capture is active, so disabled gameplay
does not pay for timing or storage. Schema normalization is applied at every
market/event envelope load, while representative persistence remains category
and modifier data rather than item definitions.

## 16. Runtime activation

M0–M8 establish the market/event engine. Production gameplay must also drive that engine without test-only setup.

### 16.1 Settlement market provisioning

An eligible active Hoomans settlement must acquire a DT market lazily/idempotently when it becomes economically relevant.

```text
Hoomans active community.id
    ↓
bounded market-profile resolver
    ↓
SettlementMarket.GetOrCreate
```

The resolver may consume existing community/faction/archetype/tags, but it must not create a parallel settlement identity or duplicate Hoomans state. Unknown/unsupported specialization resolves to the DT `default` profile.

Existing saves must not require a destructive migration pass: first binding/access can provision the missing market once.

### 16.2 Real Hoomans arrival ownership

Normal trader logistics must originate from Project Hoomans' existing movement/mobile-settlement lifecycle.

```text
Hoomans chooses/travels/arrives
    ↓
generic arrival notification/listener
    ↓
DTHoomans resolves bound DT trader + community.id
    ↓
MarkSettlementVisit(exchange=true)
```

`DTHoomans.Settlement.StartTraderTravel` may remain as an explicit API/debug/test helper, but ordinary gameplay must not depend on DT starting the journey. If Hoomans lacks an observer API, add the smallest reusable non-DT-specific observer seam there rather than making DT own movement.

### 16.3 Recovery runtime

`SettlementMarket.Recover` is an engine primitive, not a complete runtime by itself. Production must invoke recovery through a bounded authoritative path based on elapsed game time.

Acceptable shapes include lazy advance on authoritative market access or a low-frequency bounded scheduler. Forbidden shapes include per-frame recovery, full-world all-market scans, and client-authoritative mutation.

### 16.4 Production event producer

`MarketEvents.Register` is the generic registry boundary. At least one production producer must drive it.

The first proof producer should be deterministic and grounded. For example, sustained underlying food shortage pressure can instantiate the existing `FOOD_SHORTAGE` definition, while sufficiently abundant opposite pressure can instantiate `AGRICULTURAL_SURPLUS`.

The producer must:

- read underlying persisted market pressure, not event-modified effective values;
- use bounded evaluation;
- use duration/cooldown/hysteresis to avoid flapping;
- remain separate from the generic event registry;
- never rewrite trader stock when an event starts.

### 16.5 Runtime activation invariant

A test/manual API call is not proof of gameplay activation. Parent completion requires production call sites for provisioning, real arrival exchange, recovery, and event production.

## 17. Trader mobility and community excursions

The market engine now has two distinct trader lifecycle consumers.

### 17.1 Trader-type derivation

Do not create a separate DT-owned NPC identity hierarchy.

Derive the two behaviors from Hoomans ownership:

```text
non-mobile faction + active community + role=trader
    = settlement-owned resident trader

mobile faction + trader archetype/dynamicTrading ownership + no home community
    = base-less roaming trader/caravan
```

The DT trader record may persist bounded commercial/home context, but Hoomans remains authoritative for faction/community membership, movement, presence, and travel.

### 17.2 Commercial visit is not admission

A commercial stop must use a generic Hoomans temporary settlement visit distinct from membership-seeking admission.

```text
settlement_admission
    → may transfer members

settlement_visit + intent= commercial
    → temporary visit only
    → never transfers membership
```

The current AI join chance must never apply to commercial visitors.

### 17.3 Community excursion authority

Temporary purposeful absence of a settlement member is a generic Hoomans social/movement concept.

Hoomans owns:

- home community;
- excursion identity/phase;
- participants;
- itinerary/destination;
- exact-home return;
- abstract/live travel transition;
- encounters/failure/retry;
- public/social status;
- lifecycle notifications.

Dynamic Trading owns only commercial policy/economics layered onto that excursion.

### 17.4 Distinct lifecycle defaults

```text
Roaming caravan
    default = mobile
    home = none
    return-home = never
    commercial visits = normal lifecycle

Resident settlement trader
    default = home
    home = exact Hoomans community
    commercial excursion = rare/purposeful exception
    return-home = mandatory after route
```

Do not make a whole settlement faction mobile merely because its trader is away.

### 17.5 Destination-scoring seam

Hoomans must own the final destination decision.

A generic scoring/provider seam may accept bounded contributions from optional systems.

Dynamic Trading may contribute commercial opportunity using:

- trader-carried stock;
- local settlement demand/scarcity;
- price opportunity;
- market events;
- specialization;
- recent-visit penalty.

Hoomans continues to own:

- candidate discovery;
- relation/hostility;
- reachability;
- distance;
- danger;
- recent threat;
- travel and encounter state.

Project Hoomans must remain functional when Dynamic Trading is absent.

### 17.6 Long-distance simulation

Keep cross-map commercial travel abstract.

Materialized Hoomans are for nearby gameplay:

- conversation;
- trade;
- local roaming;
- combat;
- player interaction.

Do not add physical full-map caravan pathfinding.

### 17.7 Public semantic projection

Movement state and semantic/social state are separate contracts.

The generic excursion service should expose a stable projection such as:

```text
status = away
reason = trading_run
phase = visiting
destinationKnown = true
expectedReturnAt = ...
```

The semantic/knowledge layer decides what a specific speaker knows and how to say it.

Dynamic Trading movement code must not author fixed dialogue.

### 17.8 Future commercial requests

Future semantic/player systems may request or suggest a destination, but never directly mutate travel.

```text
request/suggestion
    ↓
faction/trader policy evaluation
    ↓
accept / reject / defer
    ↓
normal Hoomans excursion/travel lifecycle
```

The current phase only requires a stable bounded extension seam, not a complete player invitation UI.

### 17.9 Failsafes

Commercial mobility must preserve existing Hoomans protections:

- encounter-delayed arrival;
- stale pending-arrival cancellation;
- invalid destination recovery;
- Follow Player ownership;
- protected facility/work ownership;
- duplicate/replayed arrival idempotence;
- LOD reconciliation;
- exact-stock persistence.

Excursion or travel failure must never reroll merchant stock.

## 18. Non-goals

This job does not require:

- legacy DTNPC runtime;
- player-owned marketplace;
- courier system;
- quest/objective system;
- full autonomous faction-vs-faction macroeconomy;
- literal simulation of all settlement residents consuming goods;
- giant per-settlement item inventories;
- full Hoomans settlement storage integration;
- haggling;
- full player-facing commercial invitation UI/dialogue flow;
- authored dialogue library for every excursion phase;
- physical full-map caravan pathfinding;
- restoration of every legacy UI or reputation feature.
