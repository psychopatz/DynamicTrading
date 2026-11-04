# Progress — MarketSense Catalog Authority Consolidation

## Parent status

**DEVELOPER COMPLETE — native fresh-save acceptance remains user-owned.**

M0–M6 developer work is complete. MarketSense is now the single canonical
item-universe/query authority and DynamicTrading no longer owns a shadow item
catalog.

## Implemented truth

### MarketSense canonical authority

MarketSense now exposes bounded public catalog APIs:

- GetCatalogRevision();
- GetPricingRevision();
- IsCatalogReady();
- GetCatalogItem();
- QueryItems().

The canonical query index is owned by MarketSense ItemsRegistry and keyed to the
existing ItemRegistryRevision. It indexes lightweight fullType references for
category, obtainable, and modded queries and rebuilds automatically when the
canonical registry revision changes.

Query results are bounded and return small descriptors rather than a full
registry snapshot.

### DynamicTrading consumer boundary

DTCommon now uses DTCommon_MarketSenseGateway, a stateless dependency seam.

The gateway:

- performs bounded MarketSense exact/query calls;
- exposes MarketSense catalog/pricing revisions;
- applies only DynamicTrading-specific exclusions such as currency;
- owns no persistent item universe.

TraderStock initial seeding uses bounded canonical candidate queries and prices
only the candidates it actually considers for the 8-slot initial stock.

MarketPricing resolves canonical taxonomy through the gateway and includes
MarketSense catalog/pricing revisions in quote-context validity.

SettlementExchangeCandidates uses bounded canonical category queries.

### Removed shadow authority

Deleted:

- DTCommon_MarketCatalog.lua;
- dt_market_catalog_smoke.lua.

Removed production state/limits:

- MAX_ITEMS shadow universe;
- MAX_DYNAMIC_FACTS;
- byType;
- byCategory;
- stockSeedRows / stockSeedSet;
- dynamicByType / dynamicCount;
- DT-owned Build/Ensure/Invalidate item-catalog lifecycle;
- DynamicTrading production GetAllKnownItems() use.

## Phase status

- M0 — characterize/fail-first: **COMPLETE**
- M1 — MarketSense bounded query API: **COMPLETE**
- M2 — stateless DT MarketSense gateway: **COMPLETE**
- M3 — trader stock migration: **COMPLETE**
- M4 — pricing/exchange migration: **COMPLETE**
- M5 — shadow catalog removal: **COMPLETE**
- M6 — developer regression/performance gates: **COMPLETE**

## Developer validation — 2026-11-04

MarketSense:

- full suite: **15/15 pass**;
- 4,412-item canonical query test: pass;
- canonical revision invalidation: pass;
- modded item beyond former 4,096 boundary: pass.

DynamicTrading:

- full suite: **69/69 pass**;
- stateless gateway contract: pass;
- 4,412-item trader-stock performance regression: pass;
- zero GetAllKnownItems() production use: verified;
- eligible modded item at item 4,300 can seed trader stock: pass;
- MarketSense catalog/pricing quote-context invalidation: pass.

Static gates:

- changed production Lua installed-PZ Kahlua: **9/9 pass** across both repos;
- git diff --check: pass in both repos;
- source audit: no DynamicTrading shadow catalog symbols remain.

## Performance result

With a 4,412-item fixture:

- DynamicTrading requests no full MarketSense catalog;
- stock seeding uses bounded canonical queries;
- initial stock remains capped at 8 rows;
- at most 8 initial price evaluations are required per trader in the regression;
- a second trader performs no DT-side catalog build or universe copy.

## Remaining acceptance

User-owned native fresh-save Project Zomboid validation:

- DTAbstract Spawn Trader remains responsive;
- queued/final debug notifications remain visible;
- trader receives stock without the prior MarketSense-related stall;
- map actor dot, Talk, and Trade continue to work;
- DTHoomans commercial behavior remains equivalent;
- eligible modded items beyond the former DT 4,096 boundary can participate.

No developer-side blocker remains.
