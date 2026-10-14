# Dynamic Trading V2 — Basic-Trading Progress

**Role:** short authoritative current-state ledger for Luna. Detailed history stays in Git/test artifacts.

## Current phase

**T0 — Fresh checkout and reproducible failing baseline (NEXT).**

Audit starting point: DynamicTrading `main` commit `15a75c5246edfe0d0d2db7462dd31395732467e0` observed 2026-10-14. **Refresh against actual local HEAD before editing.**

## Implemented before this goal

- Current rewrite modules `DTCommon`, `DTHoomans`, `DTAbstract`.
- Compact trader stock serialization via PsychopatzCore; versioned trader records.
- MarketSense definition-price calls, but broken failover/ownership in trading.
- Existing ProjectHoomans two-sided trade-mode window and basket request/response plumbing.
- Single/basket server transfer code that must be hardened before trusted commerce.

## Latest verification

- **Source audit only**, 2026-10-14, across connected GitHub repos: DynamicTrading, MarketSense, ProjectHoomans and PsychopatzCore.
- Confirmed in source: player sell-price lookup is limited to trader stock, $10 MarketSense fallback, currency rollback return mismatch, different single/basket sell policies, unverified server-side access and eligibility.
- Existing smoke tests inspected; real native trade, atomic rollback and SP/MP acceptance **not run** as part of this goal creation.

## Known issues

- Non-stocked player Katana shows $0 through trader-stock price lookup.
- Missing/invalid MarketSense prices are disguised by the $10 fallback.
- Currency rollback and multi-row reversal logic do not satisfy the required atomicity contract.
- Server does not fully validate item protection, trader access, duplicate requests and instance-specific prices.
- Grouped/nested/stacked item semantics and caravan capacity need real contract tests.
- Runtime performance and SP/MP correctness are unmeasured.

## Next Chunk

**T0:** refresh the checked-out code/dependency versions, reproduce the Katana sell-quote failure and the currency-restore mismatch as failing tests, record baseline evidence; then advance automatically to **T1 MarketSense pricing adapter**. Do not stop after writing T0 notes.

## Gate tracking

- [ ] T0 — Baseline reproduced and tests added
- [ ] T1 — MarketSense adapter/valid prices
- [ ] T2 — Quote/identity/access/eligibility
- [ ] T3 — Atomic settlement/replay safety
- [ ] T4 — Existing Hoomans UI integrated
- [ ] T5 — Eligible modded item stock seeding
- [ ] T6 — Native SP/MP and measured regression

**Completion status:** NOT COMPLETE.
