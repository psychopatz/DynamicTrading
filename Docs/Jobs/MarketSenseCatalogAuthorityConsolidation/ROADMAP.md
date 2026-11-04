# Roadmap — MarketSense Catalog Authority Consolidation

## Parent goal

MarketSense is the single canonical item-universe, availability, taxonomy, intrinsic-pricing, query-index, and revision authority. DynamicTrading consumes bounded MarketSense APIs and owns only commercial/trader economics.

Status: **PLANNED**

## M0 — Characterize and freeze contracts

### Objective

Establish current behavior and fail-first evidence before structural migration.

### Work

- inventory every DynamicTrading MarketSense touchpoint;
- characterize MarketCatalog consumers and exact returned shapes;
- characterize MarketSense registry/query/cache/revision behavior;
- add/extend tests for:
  - >4096 item universe;
  - registry revision change;
  - pricing revision change;
  - category candidate query;
  - obtainable filtering;
  - bounded stock seed;
  - bounded settlement acquisition;
  - no full-catalog scan on second trader;
- capture baseline MarketSense cache/evaluation counters.

### Gate

Tests demonstrate current truncation/staleness risk without requiring native PZ.

## M1 — Add canonical bounded query API to MarketSense

### Objective

Make MarketSense sufficient as the sole catalog/query authority.

### Work

Add public, documented equivalents for:

- catalog readiness;
- catalog revision;
- pricing revision;
- bounded QueryItems();
- deterministic category/eligibility queries;
- small descriptors rather than whole-registry copies.

Use MarketSense's existing registry and internal indexes/caches. Add indexes inside MarketSense if necessary.

### Constraints

- no DynamicTrading-specific names or policy inside MarketSense;
- API must be reusable by other mods/tools;
- query limits must be bounded;
- registry revision owns index invalidation.

### Gate

MarketSense tests prove query correctness, revision invalidation, >4096 coverage, and bounded result size.

## M2 — Introduce thin DynamicTrading MarketSense gateway

### Objective

Give DTCommon one dependency seam without creating state authority.

### Work

- introduce or reshape a small gateway;
- map MarketSense readiness/query failures to DT reason codes;
- expose bounded candidate lookup and canonical fact lookup;
- expose no resident full-catalog indexes.

### Gate

Gateway tests prove no GetAllKnownItems() call and no persistent universe mirror.

## M3 — Migrate trader stock seeding

### Objective

Remove MarketCatalog dependency from TraderStock.New().

### Work

- obtain small canonical candidate pool from MarketSense query API;
- keep INITIAL_STOCK_LIMIT bounded;
- retain deterministic/default-stock preference where valid;
- price only selected/considered candidates;
- use MarketSense queued pricing only if the operation genuinely needs asynchronous bulk pricing.

### Gate

With 4,412+ items:

- zero DT-side full-catalog scan;
- bounded candidate count;
- <= configured initial-stock price requests;
- repeated trader creation does not rebuild item indexes.

## M4 — Migrate pricing context and settlement exchange

### Objective

Remove remaining MarketCatalog consumers.

### Work

- MarketPricing canonical item/category lookup -> MarketSense/gateway;
- SettlementExchangeCandidates category query -> MarketSense/gateway;
- preserve DT-owned settlement/event/relationship/commercial policy;
- add revision-change tests.

### Gate

No production caller requires DTCommon_MarketCatalog's state/indexes.

## M5 — Remove shadow catalog and legacy tests

### Objective

Eliminate split catalog state.

### Work

Delete or reduce to a stateless gateway:

- MAX_ITEMS;
- MAX_DYNAMIC_FACTS;
- byType;
- byCategory;
- stockSeedRows;
- stockSeedSet;
- dynamicByType;
- dynamicCount;
- GetAllKnownItems()-driven Build/Ensure/Invalidate lifecycle.

Prefer deleting DTCommon_MarketCatalog.lua if the gateway supersedes it cleanly.

Update tests to canonical authority rather than compatibility expectations.

### Gate

Source audit finds:

- no DynamicTrading GetAllKnownItems() call;
- no DT full-universe mirror;
- no alternate item count cap;
- no independent catalog invalidation;
- no fallback intrinsic pricing/taxonomy.

## M6 — Full regression, performance and native handoff

### Developer gates

MarketSense:

- full suite passes;
- query/revision/performance tests pass;
- Kahlua/parse gates pass;
- git diff --check clean.

DynamicTrading:

- full suite passes;
- 4,412+ catalog performance regression passes;
- trader spawn remains non-blocking;
- settlement exchange regression passes;
- pricing/audit regression passes;
- Kahlua/parse gates pass;
- source audit passes;
- git diff --check clean.

Cross-repo:

- MarketSense API loaded before DT consumers;
- registry rebuild/revision becomes visible without DT reset;
- pricing policy changes do not require DT catalog rebuild because no DT catalog exists.

### Native acceptance

User-owned fresh-save acceptance:

- DTAbstract trader spawn remains responsive;
- queued/debug notifications appear;
- no long stall from stock seeding;
- trader inventory populated;
- trade UI quotes remain correct;
- settlement market/exchange still functions;
- modded items beyond the previous 4096 boundary can participate when eligible.

## Stop condition

Do not stop merely because M1 API exists or TraderStock is fast.

Stop only when M0–M6 developer gates pass and DynamicTrading no longer owns a shadow item universe. Native acceptance may remain as the final user-owned gate.
