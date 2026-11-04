# Roadmap — MarketSense Catalog Authority Consolidation

## Parent goal

MarketSense is the single canonical item-universe, availability, taxonomy,
intrinsic-pricing, query-index, and revision authority. DynamicTrading consumes
bounded MarketSense APIs and owns only commercial/trader economics.

**Developer status: COMPLETE. Native fresh-save acceptance remains.**

## M0 — Characterize and freeze contracts

**COMPLETE**

Characterized all DynamicTrading MarketSense touchpoints and established
regressions for the former 4,096-item boundary, repeated trader creation,
category queries, and revision behavior.

## M1 — Add canonical bounded query API to MarketSense

**COMPLETE**

MarketSense now publicly exposes:

- GetCatalogRevision();
- GetPricingRevision();
- IsCatalogReady();
- GetCatalogItem();
- QueryItems().

ItemsRegistry owns lightweight revision-keyed indexes for category, obtainable,
and modded queries. The 4,412-item regression proves coverage beyond the former
DynamicTrading cap and canonical revision invalidation.

## M2 — Introduce thin DynamicTrading MarketSense gateway

**COMPLETE**

DTCommon_MarketSenseGateway is stateless with respect to the item universe. It
normalizes bounded MarketSense requests and applies only DynamicTrading-specific
commercial exclusions such as currency.

The gateway has no Build/Ensure/Invalidate lifecycle and no universe mirror.

## M3 — Migrate trader stock seeding

**COMPLETE**

TraderStock.New() now obtains a bounded canonical MarketSense candidate pool,
preserves valid configured defaults and modded-item preference, and prices only
the candidates needed for the 8-slot initial stock.

The 4,412-item regression proves:

- zero DynamicTrading GetAllKnownItems() use;
- bounded MarketSense query calls;
- at most eight initial price evaluations;
- eligible modded item at position 4,300 can participate.

## M4 — Migrate pricing context and settlement exchange

**COMPLETE**

MarketPricing and SettlementExchangeCandidates now use the stateless gateway.

DynamicTrading continues to own settlement pressure, event effects,
relationship modifiers, budgets, and commercial margins.

Quote contexts capture MarketSense catalog/pricing revisions and are explicitly
invalidated by canonical registry or pricing-policy changes.

## M5 — Remove shadow catalog and legacy tests

**COMPLETE**

Deleted:

- DTCommon_MarketCatalog.lua;
- dt_market_catalog_smoke.lua.

Source audit confirms no DynamicTrading production use of:

- GetAllKnownItems();
- MarketCatalog;
- MAX_ITEMS shadow-universe cap;
- MAX_DYNAMIC_FACTS;
- byType/byCategory shadow indexes;
- stockSeedRows/stockSeedSet;
- dynamicByType/dynamicCount;
- independent catalog Build/Ensure/Invalidate lifecycle.

## M6 — Full regression, performance and native handoff

### Developer gates — COMPLETE

MarketSense:

- full suite: **15/15 pass**;
- 4,412-item bounded query/revision regression: pass.

DynamicTrading:

- full suite: **69/69 pass**;
- stateless gateway regression: pass;
- stock-seed performance regression: pass;
- pricing/revision and settlement-exchange regressions: pass.

Cross-repository static gates:

- installed-PZ Kahlua on changed production Lua: **9/9 pass**;
- git diff --check: pass;
- shadow-authority source audit: pass.

### Native acceptance — PENDING

User-owned fresh-save matrix:

- DTAbstract Spawn Trader stays responsive;
- queued/final notifications appear;
- trader initial stock populates without the former catalog stall;
- Trade/Talk/map remain functional;
- DTHoomans commercial behavior remains equivalent;
- eligible modded items beyond the former 4,096 boundary can participate.

## Stop condition

Developer implementation is complete. Do not add another catalog compatibility
layer. Reopen developer work only for a concrete native defect or an upstream
MarketSense query requirement not covered by the canonical API.
