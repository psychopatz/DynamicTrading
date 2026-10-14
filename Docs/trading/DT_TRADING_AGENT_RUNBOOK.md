# Dynamic Trading V2 — Agent Runbook

**Audience:** unattended Luna/Codex agent working on the **current rewrite**, not Dynamic Trading Legacy.
**Mission:** make MarketSense-backed basic trading correct, secure, performant, and reproducible in Project Zomboid B42.20+, including SP and MP.

## Read order (small context first)

1. `Docs/trading/DT_TRADING_AGENT_RUNBOOK.md` (this document)
2. `Docs/trading/DT_TRADING_MVP_ROADMAP.md` (ordered acceptance gates)
3. `Docs/trading/DT_TRADING_MVP_PROGRESS.md` (current Next Chunk)
4. `Docs/trading/DT_TRADING_MVP_CONTRACT.md` (stable contracts and ownership)

Read existing `Docs/DYNAMIC_TRADING_FOUNDATION_PLAN.md` and `Docs/DYNAMIC_TRADING_TRADING_UI_CARAVAN_AUDIT_PLAN.md` only when relevant to the active chunk. They are historical planning inputs, not permission to expand this MVP. Inspect exact source files and dependency code as needed; do not load the whole legacy codebase.

## Source-of-truth precedence

1. Fresh checked-out code, tests, actual PZ/runtime output and verified engine APIs.
2. The MVP contract in this directory.
3. Ordered roadmap and acceptance gates.
4. Progress ledger (correct it if stale).
5. Older Dynamic Trading plans, comments, screenshots and hypotheses.

The October 14 audit is the starting hypothesis, **not** a substitute for re-verifying current branches. A test using fake Lua/PZ APIs does not prove a native game transaction.

## Unattended execution loop

Repeat until all mandatory gates pass or a genuine safety blocker occurs:

```text
read Next Chunk -> inspect repo/dependency state -> reproduce/prove one defect
-> implement smallest coherent change -> focused tests
-> relevant cross-repo regressions -> native acceptance when gate requires it
-> git diff --check -> update concise progress -> safe commit/push
-> continue automatically to next safe chunk
```

- Do not ask for permission to read files, inspect the PZ installation, run non-destructive tests, build temporary fixtures, create/update these goal docs, edit in-scope mod code, or commit and publish **validated fast-forward-safe** coherent work. This /goal is authorization for those ordinary repository tasks.
- Use isolated/disposable PZ profiles, test saves and bounded test actions; preserve ordinary saves, settings, Workshop subscriptions and mod selection.
- Never overwrite, reset, clean, force push, or discard uncertain user-authored work. Inspect `git status`, branch/upstream, `git fetch` and changes before editing; do not run ambiguous `git pull`. Fast-forward only if safe. Stop the affected repo on unresolved user conflicts, but continue independent safe tasks.
- If push credentials are missing, keep validated local commits and report it; do not treat that alone as a blocker.
- Do not install unrelated packages, perform destructive game/world operations, change credentials, or bypass technical access controls. If required tests need a non-disposable save or a destructive action, stop and request that specific authorization.
- Do not claim gameplay acceptance from mocks, static search, or screenshots alone; label evidence `source`, `Lua smoke`, `native SP`, `native MP`, or `not run`.
- Run the relevant in-repo test runner (`python3 tests/run_tests.py`) and applicable dependency tests. If source files in another repository are required, discover its checkout; do not create shadow copies of the other mod or modify the wrong checkout.

## Code ownership boundaries

| Repository/module | Owns | Must not own |
| --- | --- | --- |
| MarketSense | Item classification, intrinsic value, definition/instance pricing, eligibility evidence, cache | Trader buy/sell margin, currency settlement, merchant stock |
| DynamicTrading/DTCommon | Price adapter, quote/settlement policy, trader stock, session/access contract, server-side trade validation | Second item pricing heuristic database; NPC inventory UI |
| ProjectHoomans | Existing player inventory row/UI primitives and trade-mode presentation/endpoint, NPC identity and inventory constraints | Independent trade economy or server-side commercial settlement |
| PsychopatzCore | Generic inventory transfers, portable serialization, currency semantics and transaction primitives | DynamicTrading-specific trader pricing/rules |
| DTHoomans / DTAbstract | Physical or remote entry/access adapters | Separate copies of quotes, stock or settlement |

Minimal changes in companion repositories are allowed when required by an **actual integration defect**, with their own focused regressions. Prefer DTCommon-owned pricing/session/quote logic; keep Hoomans' trade endpoint thin. Do not add a DynamicTrading dependency to MarketSense or PsychopatzCore.

## Chunk discipline

- One responsibility per chunk; no mass renaming or unrelated module extraction.
- Preserve public APIs and currently working caravan/conversation/guard/referral code unless a verified defect requires a change.
- Do not use or port Dynamic Trading Legacy's manually maintained catalog or prices. Legacy economy events, faction modifiers, demand, seasons and negotiation are **out of scope**.
- Do not add `$10`, `$1` or generic nonzero fallbacks on price failure; separate price unavailable from legitimate policy rejection.
- Start with **T0**, then advance automatically. A completed chunk, passing suite or fresh commit is not completion of the /goal.

## Required validation

1. Reproduce the failing behavior first (especially non-stocked `Base.Katana` sell quote and currency rollback).
2. Unit/Lua smoke tests for the changed contract and a regression reproducing each fixed bug.
3. Broader dependent suites if shared Core, MarketSense or Hoomans contracts changed.
4. Native B42.20+ isolated SP acceptance for real sale, purchase, basket and rejection paths, when available.
5. Native dedicated MP/client acceptance for authoritative access, exact item identity, replay, stale stock and reconnect when available.
6. Performance evidence: inspect existing profiling surfaces, record count/time for snapshot decode, price requests, inventory scans and quote/commit; avoid arbitrary new OnTick scans.
7. `git diff --check`, no residual isolated game processes, clean temporary artifacts, preserve ordinary saves.

When native facilities are unavailable, continue safe non-native chunks, leave the specific native gate **unverified**, record exact missing prerequisites, and do not declare the total goal complete.

## Progress ledger discipline

Edit `DT_TRADING_MVP_PROGRESS.md` with implementation commits. Keep only: **Current phase; Implemented; Latest verification; Known issues; Next Chunk**. Historical detail belongs in Git history/test artifacts. Do not inflate the ledger with a transcript of every command.

## Stop conditions and final reporting

Stop only on unsafe user-data mutation, unresolved user-authored Git conflict, missing essential external dependency that blocks *that* chunk, an actual product decision not specified here, or an environmental restriction that prevents the required verification. Continue independent safe work where possible.

At end of each working session report concise completed chunks, tests and evidence levels, commits/push status, remaining gates, exact Next Chunk and blockers. **Do not declare done until T0–T6 gates are satisfied; do not invent extra feature phases.**
