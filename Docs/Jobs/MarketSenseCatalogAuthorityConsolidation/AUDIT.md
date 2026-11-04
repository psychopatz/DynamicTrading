# Audit — MarketSense Catalog Authority Consolidation

## Audit date

2026-11-04

## Verdict

**RESOLVED. MarketSense is now the single canonical item-universe/query
authority and DTCommon no longer owns a shadow catalog/index.**

MarketSense owns bounded canonical indexes keyed to its existing registry
revision. DynamicTrading consumes them through a stateless gateway and retains
only commercial/trader policy.

## MarketSense already owns

MarketSense already provides and/or maintains:

- persisted runtime item registry;
- canonical known-item rows;
- intrinsic score/price snapshots;
- taxonomy/category/tags;
- availability/obtainability;
- active-mod-aware registry loading/rebuild;
- runtime rule application;
- pricing-policy invalidation;
- ItemRegistryRevision;
- pricingRevision;
- bounded runtime price cache;
- cooperative RequestPriceDetails() batching across ticks;
- GetRegistryDetails();
- GetAllKnownItems();
- GetItemAvailability();
- GetItemAvailabilitySummary();
- GetPriceDetails();
- GetPriceDetailsForInstance().

MarketSense's normal definition-level price path already finalizes from its persisted intrinsic registry when possible instead of recomputing all evidence.

## Pre-fix DTCommon shadow catalog

At the audit snapshot, DTCommon_MarketCatalog.lua derived and retained:

- byType;
- byCategory;
- stockSeedRows;
- stockSeedSet;
- dynamicByType;
- dynamicCount.

Its consumers include:

- DTCommon_TraderStock.lua;
- DTCommon_MarketPricing.lua;
- DTCommon_SettlementExchangeCandidates.lua.

## Correctness defect: item-universe truncation

At the audit snapshot, DTCommon_MarketCatalog.MAX_ITEMS was 4096.

Observed MarketSense known-item count during native testing was 4412.

Therefore category queries and stock candidate selection can exclude valid MarketSense items solely because they sort beyond the DTCommon cap.

This is a different effective catalog universe.

## Correctness defect: revision/invalidation split

MarketSense updates registry/pricing revisions and invalidates its own snapshots/caches when:

- active-mod state changes;
- registry rebuilds;
- runtime rules change;
- pricing policy/modifiers change.

The pre-fix DTCommon derived catalog had its own built flag and manual Invalidate() path and did not track MarketSense registry revision as its source-of-truth invalidation key.

A DTCommon fact/category candidate could therefore outlive the MarketSense state from which it was derived.

## Pre-fix memory duplication

MarketSense keeps:

- canonical registry/catalog;
- a caller-safe known-item snapshot;
- bounded runtime pricing/details cache.

DTCommon then builds another:

- item-fact table;
- category index;
- stock-seed index;
- dynamic fact cache.

The intent is performance, but the result is duplicated thousands-item state.

## Performance defect that triggered this audit

Before the bounded-stock fix, TraderStock.New() iterated the whole MarketSense known-item registry for each trader and performed availability/price evaluation across the universe before selecting eight items.

The immediate remediation bounded per-trader seed work but still depended on DTCommon's duplicate catalog.

The completed consolidation removes that shadow catalog rather than preserving it as a permanent optimization layer.

## Legitimate DTCommon ownership

The following are not MarketSense responsibilities and must remain in DTCommon:

- trader inventory records and quantities;
- trader budget;
- trader buy/sell policy;
- commercial margin/spread;
- relationship modifier;
- settlement supply/demand;
- market pressure;
- market events and event multipliers;
- settlement exchange/acquisition/disposal policy;
- trader lifecycle and provider behavior.

MarketSense should provide item facts and intrinsic values. DTCommon decides how Dynamic Trading uses them.

## Legitimate MarketSense ownership

MarketSense should own:

- canonical item registry;
- market eligibility/availability;
- taxonomy;
- intrinsic price;
- canonical category/eligibility indexes;
- item-registry revision;
- pricing revision;
- bounded canonical item queries;
- queued/batched definition pricing.

## Upstream API gap identified by the audit

The main reason DTCommon grew its own index was that MarketSense exposed GetAllKnownItems() but did not yet provide a sufficiently expressive bounded query surface.

The implemented upstream API now supports the required concepts:

- catalog readiness;
- registry revision;
- pricing revision;
- lookup by fullType;
- bounded query by category;
- obtainable/category/modded filtering, with DT-specific tradeability exclusions remaining downstream;
- deterministic ordering or cursor/offset semantics where needed;
- bounded candidate query suitable for initial trader stock;
- no caller requirement to scan/copy the whole registry.

## Pre-fix source audit summary

At the audit snapshot, DTCommon production MarketSense usage was concentrated in DTCommon_MarketCatalog, TraderStock, MarketPricing, and SettlementExchangeCandidates.

## Required deletion/removal result

The completed goal removes:

- MAX_ITEMS as an alternate item-universe boundary;
- MAX_DYNAMIC_FACTS as a shadow fact cache bound;
- byType;
- byCategory;
- stockSeedRows;
- stockSeedSet;
- dynamicByType;
- GetAllKnownItems()-driven catalog rebuild.

DTCommon_MarketCatalog.lua was deleted. Callers now use DTCommon_MarketSenseGateway, which owns no thousands-item resident state.

## Native risk

The goal must preserve the recent non-blocking trader-spawn work. Do not regress into synchronous whole-catalog scans or large client-command callback work.

## Post-implementation evidence

Verified from current source and tests:

- MarketSense runtime registry and price cache remain canonical;
- MarketSense owns the bounded revision-keyed query indexes;
- MarketSense exposes catalog/pricing revisions and bounded exact/query APIs;
- DTCommon_MarketCatalog.lua is removed;
- DynamicTrading production contains no GetAllKnownItems() call;
- DynamicTrading contains no shadow byType/byCategory/stock-seed/dynamic-fact universe state;
- 4,412-item tests cover the full catalog and an eligible modded item beyond the former 4,096 boundary;
- quote contexts invalidate on MarketSense catalog/pricing revision changes.

Implementation is complete and developer-validated. See PROGRESS.md and HARNESS_ACCEPTANCE.md for current evidence and native handoff.
