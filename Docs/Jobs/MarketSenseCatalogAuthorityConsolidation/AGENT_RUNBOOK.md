# Agent Runbook — MarketSense Catalog Authority Consolidation

## Mission

Remove DynamicTrading's shadow MarketSense catalog/index and make MarketSense the single canonical item-universe/query authority without moving Dynamic Trading commercial economics into MarketSense.

After each accepted chunk:

1. update PROGRESS.md;
2. select the next mandatory M-phase;
3. continue automatically;
4. stop only for a real blocker or full M0–M6 developer completion.

## Read order

1. DynamicTrading root AGENTS.md;
2. this runbook;
3. README.md;
4. AUDIT.md;
5. ARCHITECTURE.md;
6. ROADMAP.md;
7. HARNESS_ACCEPTANCE.md;
8. PROGRESS.md last.

Before editing MarketSense:

- inspect branch/HEAD/upstream/worktree;
- read any repository-local instruction files if present;
- preserve unrelated work.

MarketSense currently has no root AGENTS.md at the audit snapshot; do not invent one just for this goal.

## Mandatory architecture rules

- MarketSense owns item universe, availability, taxonomy, intrinsic price, revisions, canonical item query indexes, and queued definition pricing.
- DTCommon owns trader stock quantities, budget, commercial margins, settlement pressure, events, exchange policy, and trader lifecycle.
- No DTCommon full-catalog mirror as final architecture.
- No DynamicTrading GetAllKnownItems() universe scan as final architecture.
- No DT fallback taxonomy.
- No DT fallback intrinsic price.
- Do not push settlement/trader gameplay policy into MarketSense.
- MarketSense public query APIs must be generic and adopter-agnostic.
- Query results must be bounded.
- Do not block interactive PZ callbacks on thousands-item work.
- Prefer deletion over permanent compatibility shims after migration.

## Migration discipline

For each consumer:

1. characterize existing observable behavior;
2. add fail-first parity/performance/revision tests;
3. add upstream generic MarketSense capability;
4. migrate one DT consumer;
5. validate;
6. remove its dependency on shadow catalog;
7. continue until no production caller remains;
8. delete obsolete shadow state;
9. source-audit for remnants.

## Performance discipline

The target catalog is 4k+ items and may grow.

Required properties:

- no full-catalog copy per trader;
- no full-catalog copy per settlement exchange;
- no per-frame universe scan;
- bounded result limits;
- definition pricing uses MarketSense cache;
- bulk definition pricing uses MarketSense RequestPriceDetails when appropriate;
- repeated traders reuse MarketSense registry/indexes, not DT-owned indexes.

Use counters/tests, not intuition, to demonstrate bounds.

## Revision discipline

Do not read MarketSense.Config.ItemRegistryRevision directly from DynamicTrading if a public revision API can be added.

MarketSense owns its revision semantics.

DTCommon may include MarketSense catalog/pricing revision in diagnostic/audit output but must not create another independently incremented item-catalog revision.

## Validation discipline

Run focused tests after each chunk, then full suites at phase boundaries.

Required final evidence is defined in HARNESS_ACCEPTANCE.md.

Use installed-PZ Kahlua verification for changed production Lua.

Run git diff --check in both repos.

## Git discipline

- existing main only;
- inspect both repos before edits;
- no blind pull;
- no reset/rebase/stash/discard of uncertain work;
- preserve concurrent user edits;
- coherent commits per repository;
- no push unless explicitly authorized.

Cross-repo API changes should be committed coherently with MarketSense API first or in a sequence that never leaves the documented local stack ambiguous.

## Documentation discipline

Keep active goal state here, not in root AGENTS.md.

Update architecture only when stable ownership/contracts change.

Update PROGRESS after accepted chunks.

Do not keep superseded shadow-catalog behavior as historical executable guidance.

## Final report

Report:

- MarketSense APIs added;
- DT shadow state deleted;
- migrated DT consumers;
- source audit proving no GetAllKnownItems() universe scan;
- revision behavior;
- 4k+ performance evidence;
- MarketSense and DynamicTrading full test counts;
- Kahlua/diff checks;
- remaining native acceptance only.
