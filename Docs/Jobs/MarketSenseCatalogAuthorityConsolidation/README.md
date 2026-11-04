# MarketSense Catalog Authority Consolidation

## Objective

Remove DynamicTrading's shadow item-universe/catalog authority and make MarketSense the single canonical source for:

- known item universe;
- availability/obtainability;
- taxonomy/category/tags;
- intrinsic definition pricing;
- registry revision and invalidation;
- bounded item candidate queries;
- bulk/queued definition-price evaluation.

DTCommon remains the DynamicTrading commercial-domain authority for trader stock records, trader budgets, buy/sell margins, settlement supply/demand, market events, exchange policy, and trader lifecycle.

## Why this goal exists

Native DTAbstract trader-spawn testing exposed severe stalls while a new trader seeded initial stock. The immediate bounded-stock fix removed the worst per-trader 4k-item price loop, but audit found a deeper architecture issue: DTCommon still maintains a derived shadow catalog over MarketSense.

Current DTCommon catalog state includes:

- byType;
- byCategory;
- stockSeedRows / stockSeedSet;
- dynamicByType;
- a 4,096-item scan cap;
- independent runtime lifetime/invalidation.

The installed MarketSense registry currently contains more than 4,096 known items, so DTCommon can observe a different item universe from MarketSense. DTCommon also does not follow MarketSense registry/pricing revisions automatically.

## Parent completion boundary

This goal is complete only when:

1. MarketSense exposes bounded canonical query APIs sufficient for DynamicTrading consumers;
2. DynamicTrading no longer calls GetAllKnownItems() to rebuild its own item universe;
3. DTCommon no longer maintains long-lived duplicated byType/byCategory/stock-seed/dynamic-fact catalog state;
4. trader stock seeding, settlement acquisition, and market pricing consume MarketSense's canonical registry/query surface;
5. MarketSense registry/pricing changes become visible to DynamicTrading without manual DT catalog invalidation;
6. spawning many traders performs no DT-side full-catalog scan/copy;
7. no second intrinsic pricing, availability, or taxonomy authority exists in DTCommon;
8. regression and performance gates pass in both repositories.

## Repository scope

Primary job documentation lives in:

- DynamicTrading: /home/psychopatz/Zomboid/Workshop/DynamicTrading

Upstream API work is allowed and expected in:

- MarketSense: /home/psychopatz/Zomboid/Workshop/MarketSense

Do not move trader economics into MarketSense. Do not move MarketSense intrinsic item intelligence into DynamicTrading.

## Status

**PLANNED — audit complete, implementation not started.**

Start with M0 in ROADMAP.md and PROGRESS.md.

## Document map

- AUDIT.md — current duplication, correctness/performance findings, affected modules.
- ARCHITECTURE.md — final ownership and API contracts.
- ROADMAP.md — ordered M0–M6 implementation phases.
- HARNESS_ACCEPTANCE.md — regression/performance/native acceptance matrix.
- AGENT_RUNBOOK.md — execution, validation, Git, and cross-repo discipline.
- PROGRESS.md — current truth and immediate Next Chunk.

The executable /goal bootstrap remains conversational unless explicitly requested.
