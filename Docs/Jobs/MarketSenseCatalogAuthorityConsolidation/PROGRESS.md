# Progress — MarketSense Catalog Authority Consolidation

## Parent status

**PLANNED — implementation has not started.**

## Verified current truth

MarketSense currently owns:

- persisted canonical runtime registry;
- availability;
- taxonomy;
- intrinsic pricing;
- price/detail runtime cache;
- registry rebuild/invalidation;
- queued definition pricing.

DynamicTrading currently owns a derived DTCommon_MarketCatalog with:

- byType;
- byCategory;
- stockSeedRows / stockSeedSet;
- dynamicByType;
- independent built/invalidation state;
- MAX_ITEMS = 4096.

Observed native MarketSense catalog size is 4412 items, so the DT cap can produce a different effective universe.

The recent trader-stock performance remediation bounds per-trader price work but still relies on the shadow MarketCatalog. That fix is accepted foundation, not the final architecture.

## Current phase

**M0 — Characterize and freeze contracts**

## Immediate Next Chunk

Start by adding characterization/fail-first coverage before changing production ownership.

Mandatory first work:

1. MarketSense test proving canonical bounded query requirements over >4096 items;
2. DynamicTrading test proving it must not truncate at 4096;
3. revision-change fixture showing DTCommon shadow state can become stale today;
4. baseline counters for GetAllKnownItems(), availability, price evaluation, and repeated trader creation;
5. exact consumer-shape inventory for TraderStock, MarketPricing, and SettlementExchangeCandidates.

Then implement M1 and continue automatically through M6.

## Accepted invariants

Do not regress:

- MarketSense remains the intrinsic item authority;
- DTCommon remains trader/commercial authority;
- trader spawn remains non-blocking;
- no synchronous full-catalog scan in interactive debug callbacks;
- DTAbstract/DTHoomans remain representation adapters;
- no old compatibility shim as final design;
- no persisted duplicate item catalog in DynamicTrading.

## Known affected production modules

DynamicTrading:

- DTCommon_MarketCatalog.lua
- DTCommon_TraderStock.lua
- DTCommon_MarketPricing.lua
- DTCommon_SettlementExchangeCandidates.lua
- related TradeAudit profiling/tests

MarketSense:

- MS_PublicAPI.lua
- ItemsRegistry runtime/state/domain modules as needed for canonical indexes/querying
- RuntimeCache only if public revision/query instrumentation requires it

## Repository state at planning

DynamicTrading main is ahead of origin with existing validated local commits.

MarketSense main is aligned with origin at the audit snapshot.

Before implementation, re-check both worktrees and preserve concurrent user work.

## Remaining phases

- M0 characterize/fail-first;
- M1 MarketSense query API;
- M2 thin DT gateway;
- M3 stock migration;
- M4 pricing/exchange migration;
- M5 shadow catalog removal;
- M6 regression/performance/native handoff.
