# Audit — MarketSense Catalog Authority Consolidation

## Audit date

2026-11-04

## Verdict

**MarketSense remains the intrinsic pricing/availability/taxonomy authority, but DTCommon currently owns a shadow catalog/index that can diverge from MarketSense.**

This is not yet a second pricing engine, but it is a split catalog-state system.

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

## DTCommon shadow catalog

DTCommon_MarketCatalog.lua currently derives and retains:

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

DTCommon_MarketCatalog.MAX_ITEMS is currently 4096.

Observed MarketSense known-item count during native testing was 4412.

Therefore category queries and stock candidate selection can exclude valid MarketSense items solely because they sort beyond the DTCommon cap.

This is a different effective catalog universe.

## Correctness defect: revision/invalidation split

MarketSense updates registry/pricing revisions and invalidates its own snapshots/caches when:

- active-mod state changes;
- registry rebuilds;
- runtime rules change;
- pricing policy/modifiers change.

DTCommon's derived catalog has its own built flag and manual Invalidate() path. It does not currently track MarketSense registry revision as its source-of-truth invalidation key.

A DTCommon fact/category candidate can therefore outlive the MarketSense state from which it was derived.

## Memory duplication

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

The immediate remediation now bounds per-trader seed work, but it still depends on DTCommon's duplicate catalog.

The final design should remove the need for that shadow catalog instead of preserving it as a permanent optimization layer.

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

## Missing upstream API

The main reason DTCommon grew its own index is that MarketSense exposes GetAllKnownItems() but not yet a sufficiently expressive bounded query surface.

Required upstream API should support at least:

- catalog readiness;
- registry revision;
- pricing revision;
- lookup by fullType;
- bounded query by category;
- obtainable/tradeable filtering;
- deterministic ordering or cursor/offset semantics where needed;
- bounded candidate query suitable for initial trader stock;
- no caller requirement to scan/copy the whole registry.

## Source audit summary

Current DTCommon production MarketSense usage is concentrated in:

- DTCommon_MarketCatalog.lua;
- DTCommon_TraderStock.lua;
- DTCommon_MarketPricing.lua;
- DTCommon_SettlementExchangeCandidates.lua.

Direct raw MarketSense calls outside MarketCatalog and TraderStock were not found in DTCommon production Lua during this audit.

## Desired deletion/removal result

By the end of this goal, DTCommon should not retain:

- MAX_ITEMS as an alternate item-universe boundary;
- MAX_DYNAMIC_FACTS as a shadow fact cache bound;
- byType;
- byCategory;
- stockSeedRows;
- stockSeedSet;
- dynamicByType;
- GetAllKnownItems()-driven catalog rebuild.

DTCommon_MarketCatalog.lua should either be deleted or reduced to a thin stateless gateway with no thousands-item resident state. Prefer deletion if callsites can use a small DTCommon_MarketSenseGateway with no data ownership.

## Native risk

The goal must preserve the recent non-blocking trader-spawn work. Do not regress into synchronous whole-catalog scans or large client-command callback work.

## Evidence status

Verified from current source:

- MarketSense runtime registry and price cache exist;
- MarketSense RequestPriceDetails() is cooperative/batched;
- DTCommon shadow indexes exist;
- MAX_ITEMS = 4096;
- native catalog count observed at 4412;
- DTCommon catalog has independent built/invalidation lifetime.

Implementation has not started.
