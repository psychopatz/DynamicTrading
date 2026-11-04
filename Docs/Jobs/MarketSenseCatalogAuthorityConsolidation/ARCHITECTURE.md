# Architecture — MarketSense Catalog Authority Consolidation

## 1. Ownership rule

There must be one canonical item-market knowledge authority.

### MarketSense owns

- item universe;
- item eligibility/availability;
- item taxonomy/category/tags;
- intrinsic definition value;
- instance-aware intrinsic value;
- registry revision;
- pricing revision;
- canonical item-query indexes;
- bounded candidate queries;
- queued bulk price evaluation;
- MarketSense-specific cache invalidation.

### DTCommon owns

- trader inventory records;
- trader stock quantity;
- trader budget;
- buy/sell operation policy;
- trader margin/spread;
- settlement supply/demand;
- market pressure;
- event effects;
- relationship effects;
- settlement exchange/acquisition/disposal;
- trader lifecycle.

### DTAbstract / DTHoomans

No MarketSense catalog ownership.

They consume DTCommon commercial behavior and remain representation adapters.

## 2. Layering model

Canonical flow:

MarketSense registry
  -> MarketSense bounded query API
  -> DTCommon commercial candidate policy
  -> MarketSense intrinsic quote
  -> DTCommon settlement/trader modifiers
  -> final Dynamic Trading quote/action

Never:

MarketSense registry
  -> GetAllKnownItems()
  -> DTCommon rebuilds another catalog
  -> DTCommon serves stale item facts

## 3. MarketSense public query contract

The exact names may be adjusted to fit MarketSense style, but the public surface must provide equivalent behavior.

Required concepts:

### GetCatalogRevision()

Returns a stable registry/catalog revision that changes when canonical item membership or canonical item facts relevant to queries change.

Do not make downstream mods inspect MarketSense.Config internals.

### GetPricingRevision()

Returns the current definition-pricing policy revision.

### IsCatalogReady()

Lets adopters distinguish a loaded canonical catalog from a temporary unavailable/rebuild state.

### QueryItems(options)

Bounded canonical query.

Options should support a subset sufficient for adopters:

- category;
- obtainableOnly;
- tradeableOnly or equivalent eligibility;
- limit;
- optional offset/cursor;
- deterministic ordering.

Return small caller-owned descriptors, not a deep copy of the entire registry.

Useful descriptor fields:

- fullType;
- category;
- primary;
- tags only when requested/needed;
- availability status/obtainable;
- module/origin if useful.

Do not include heavyweight audit/evidence blobs by default.

### Existing pricing API remains canonical

Keep using:

- GetPriceDetails();
- GetPriceDetailsForInstance();
- RequestPriceDetails() for bounded async/bulk work.

## 4. Query indexing

MarketSense may create internal indexes such as:

- category -> item IDs;
- obtainable item IDs;
- category + obtainable subsets.

Those indexes are MarketSense implementation details and must follow the canonical registry revision.

DynamicTrading must not duplicate them as long-lived state.

## 5. DTCommon gateway rule

If DynamicTrading benefits from dependency isolation, a small gateway module may exist.

Allowed gateway behavior:

- validate MarketSense API presence;
- normalize bounded request options;
- map MarketSense errors to DTCommon reason codes;
- expose no persistent thousands-item state;
- expose no alternate category or availability inference;
- expose no fallback intrinsic price.

Not allowed:

- GetAllKnownItems() scan;
- byType/byCategory mirror;
- alternate MAX_ITEMS universe;
- dynamic fact cache;
- independent catalog invalidation.

## 6. Trader stock seeding

Initial stock must remain bounded.

Recommended flow:

1. request a small canonical candidate pool from MarketSense, e.g. 16–32;
2. apply DT commercial selection policy;
3. request/resolve intrinsic prices only for candidates actually considered;
4. stop after INITIAL_STOCK_LIMIT = 8 valid stock rows.

No full-catalog scan per trader.

No cached shadow universe in DTCommon.

If asynchronous price batching is needed, use MarketSense.RequestPriceDetails() rather than implementing another DT queue.

## 7. Market pricing

DTCommon_MarketPricing may cache item context only inside one quote/operation context.

It may combine:

- MarketSense category;
- settlement category supply/demand;
- event modifier;
- relationship modifier.

It must not cache canonical taxonomy across MarketSense registry revisions as a global independent catalog.

## 8. Settlement exchange

Settlement acquisition should request bounded category candidates from MarketSense directly.

DTCommon decides:

- which category is under/over supplied;
- how many units to acquire/dispose;
- budget constraints;
- exchange limits;
- event and settlement pressure.

MarketSense decides which items belong to a category and whether they are canonically eligible.

## 9. Revision behavior

DynamicTrading must not need a manual catalog reset when MarketSense changes.

After a MarketSense registry rebuild:

- next bounded query sees the new universe.

After pricing policy revision:

- MarketSense pricing cache handles definition-price invalidation;
- DTCommon quote contexts continue to apply their own market/event revisions.

Revision responsibilities must remain separate.

## 10. Performance invariants

With a 4k+ item catalog:

- creating a trader performs zero DT-side full-catalog scan/copy;
- settlement exchange performs bounded queries;
- normal quote of one item performs O(1)-style canonical lookup plus bounded DT modifiers;
- bulk price operations use MarketSense queue/bounds;
- no per-frame or per-trader thousands-item traversal in DynamicTrading;
- no unbounded table copy across the MarketSense/DT boundary.

## 11. Persistence

Do not persist a duplicate MarketSense item catalog inside DynamicTrading.

DT persistence may store:

- trader stock records;
- item fullTypes in those records;
- trader budgets;
- settlement category pressure;
- event state.

On load, item facts are resolved through current MarketSense authority.

## 12. Failure behavior

If MarketSense catalog is unavailable/rebuilding:

- fail boundedly with explicit reason;
- do not synthesize taxonomy or intrinsic price;
- do not trigger synchronous universe rebuild from an interactive UI callback;
- retry only through documented bounded runtime behavior.

## 13. Compatibility policy

Do not preserve DTCommon_MarketCatalog as a permanent compatibility shim after all production callers migrate.

Tests should migrate to the canonical API contract. Historical test expectations are not a reason to keep split authority.
