# Harness Acceptance — MarketSense Catalog Authority Consolidation

## Purpose

Define objective evidence that the catalog authority is unified and performant.

## A. MarketSense canonical-query acceptance

Must prove:

- canonical catalog covers >4096 items;
- QueryItems or equivalent returns bounded results;
- category filtering is correct;
- obtainable/eligibility filtering is correct;
- deterministic ordering/cursor behavior where applicable;
- query does not deep-copy the entire registry;
- catalog readiness is observable;
- catalog revision changes when canonical registry content changes;
- pricing revision is observable and independent from catalog membership revision where appropriate;
- query indexes refresh with registry revision.

## B. MarketSense pricing acceptance

Must prove:

- GetPriceDetails uses existing definition cache/registry fast path;
- repeated definition quote hits cache;
- instance quote does not contaminate definition cache;
- RequestPriceDetails remains bounded across ticks;
- duplicate requested types share cache work;
- pricing-policy revision invalidates price cache as intended.

## C. DynamicTrading stock acceptance

With a 4412+ item fixture:

- TraderStock.New performs zero GetAllKnownItems() call;
- DT maintains no full-universe mirror;
- initial candidate query is bounded;
- initial stock remains <= 8 rows;
- only bounded candidate price calls occur;
- second trader performs no catalog/index rebuild in DT;
- Workshop/modded eligible items can appear beyond the former lexical 4096 boundary.

## D. DynamicTrading pricing acceptance

Must prove:

- intrinsic price comes from MarketSense;
- category comes from MarketSense;
- DT settlement pressure modifies the commercial quote only after canonical item facts resolve;
- relationship/event/trader margin remain DT-owned;
- missing MarketSense facts fail explicitly rather than using a DT intrinsic fallback;
- quote-context caches are bounded and request-scoped.

## E. Settlement exchange acceptance

Must prove:

- bounded category candidate query;
- no full-universe scan/copy;
- acquisition/disposal limits unchanged;
- budget accounting unchanged;
- settlement pressure semantics unchanged;
- MarketSense registry revision becomes visible without DT manual invalidation.

## F. Source-removal audit

Final source search must show no DynamicTrading production use of:

- GetAllKnownItems();
- MAX_ITEMS shadow-universe cap;
- MAX_DYNAMIC_FACTS shadow-fact cap;
- byType shadow catalog;
- byCategory shadow catalog;
- stockSeedRows / stockSeedSet;
- dynamicByType / dynamicCount;
- independent Catalog.Build/Ensure/Invalidate lifecycle for item-universe ownership.

Any remaining gateway must be stateless with respect to the item universe.

## G. Performance acceptance

Measure with counters or deterministic harness instrumentation.

Required bounds:

- trader creation: O(bounded candidate count), not O(total MarketSense items);
- settlement acquisition: O(bounded query results), not O(total catalog);
- one item quote: no universe scan;
- repeated trader creation: no registry copy/index rebuild in DT;
- MarketSense queued bulk pricing: <= documented batch/time budget per tick.

Use at least one fixture >= observed 4412 items and one larger growth fixture if practical.

## H. Regression suites

MarketSense:

- full suite;
- focused registry/query/revision/cache tests;
- installed-PZ Kahlua for changed production Lua;
- git diff --check.

DynamicTrading:

- full suite;
- trader stock tests;
- settlement market/exchange tests;
- trade pricing/audit tests;
- trader debug-spawn/non-blocking tests;
- installed-PZ Kahlua for changed production Lua;
- git diff --check.

## I. Native acceptance

Fresh-save native PZ:

- DTAbstract Spawn Trader stays responsive;
- queued and final debug notifications appear;
- trader receives stock;
- no multi-second stall from catalog/stock work;
- map actor dot still appears;
- Talk/trade still work;
- eligible modded items beyond former 4096 boundary can be surfaced over time;
- DTHoomans trader flow remains commercially equivalent.

Native acceptance must not be used to excuse missing developer-side performance evidence.
