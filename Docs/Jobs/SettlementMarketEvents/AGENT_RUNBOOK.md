# Agent Runbook — Settlement Market & Events

## Mission

Implement the full Settlement Market & Events parent objective on the existing DynamicTrading `main`.

The immediate Next Chunk in `PROGRESS.md` is only the starting responsibility.

> A chunk or phase completing is **not** completion of this job.

Continue automatically through all mandatory M0–M9 roadmap work after each accepted chunk unless a genuine blocker or user-only native acceptance gate remains. M0–M8 built the engine; M9 runtime activation is now mandatory before native handoff.

## Read order

1. repository root `AGENTS.md`;
2. this `AGENT_RUNBOOK.md`;
3. `AUDIT.md`;
4. `ARCHITECTURE.md`;
5. `ROADMAP.md`;
6. `HARNESS_ACCEPTANCE.md`;
7. `PROGRESS.md` **last**.

Inspect current production source and dependency code as needed.

Legacy branch is behavioral reference only. Do not bulk-read or port it unless the current chunk requires a specific source comparison.

## Source truth

Priority:

1. current production code and actual runtime behavior;
2. current tests/integration/native evidence;
3. this job architecture;
4. roadmap;
5. progress;
6. legacy behavior/docs.

If docs disagree with current code, correct the docs.

## Mandatory ownership rules

- MarketSense owns intrinsic value and taxonomy.
- DTCommon owns market pressure, events, merchant stock, quotes and commercial authority.
- Project Hoomans owns physical NPC identity, movement, settlement presence and lifecycle.
- PsychopatzCore owns reusable actors/inventory/currency/radio/world-knowledge infrastructure.
- DTAbstract/DTHoomans are adapters/fronts, not separate market engines.

Do not add a second NPC lifecycle or second intrinsic pricing system.

## Critical behavior rules

1. Trader stock is persistent exact merchant inventory.
2. Opening UI never rerolls stock.
3. Settlement visits partially exchange stock.
4. Price may react immediately to market/event information.
5. Existing stock changes through logistics/transactions, not event-start magic.
6. Settlement markets store bounded category pressure, not every item.
7. Events are data-driven typed modifiers.
8. No all-trader rewrite when an event starts.
9. No full item-universe scan on every quote/visit.
10. Duplicate visit IDs must not double-apply exchange.

## Git/concurrency

Follow root `AGENTS.md`.

At start:

- inspect local `main`, HEAD, upstream and worktrees;
- preserve unrelated edits;
- never use destructive reset/rebase/stash/discard;
- never create a new branch;
- do not include unrelated dirty files in a market/event commit.

The planning baseline had an unrelated modification to `DTHoomans_Conversation.lua`. Recheck; do not overwrite or absorb it.

## Unattended loop

For each chunk:

```text
read current Next Chunk
→ verify current repo/dependency state
→ write/confirm fail-first evidence
→ implement smallest coherent responsibility
→ focused tests
→ integration regressions
→ static/Kahlua/diff checks
→ update PROGRESS
→ commit/push only in-scope validated files when safe
→ continue immediately to next mandatory chunk
```

Do not stop just because one chunk passed.

## Validation

Follow `HARNESS_ACCEPTANCE.md`.

For production Lua changes also run applicable:

- `luac -p`;
- repository Kahlua verification;
- `git diff --check`;
- focused `tests/run_tests.py` suites;
- dependency tests when contracts changed.

Do not claim a product gate from source inspection alone.

## Architecture discipline

Prefer narrow modules under a coherent DTCommon market namespace rather than enlarging `DTCommon_TraderService.lua` into another monolith.

Do not prematurely create dozens of files. Extract responsibilities when ownership/test boundaries justify it.

Preserve the current transaction executor. Settlement Exchange prepares merchant state outside the ordinary buy/sell request; it must not bypass transaction invariants.

## Event discipline

The generic registry/resolver and Food Shortage/Agricultural Surplus definitions are already accepted M4–M5 engine work.

M9 must add a **production producer**, not another event registry. The first producer should be bounded and grounded in authoritative market/world state. A deterministic market-condition producer is preferred over a large random event library. Keep named event rules outside the generic registry and prevent threshold flapping with hysteresis/cooldown/duration policy.

Do not add ten bespoke event scripts merely to make events appear.

## Runtime activation discipline

Do not confuse an API that tests can call with a gameplay path that production actually calls.

For M9, prove call sites in production for all four runtime responsibilities:

1. automatic settlement-market provisioning;
2. Hoomans-owned normal settlement arrival → DT visit/exchange;
3. elapsed-time market recovery;
4. at least one real event producer → `MarketEvents.Register`.

The M9 flagship test must begin without manually calling `SettlementMarket.GetOrCreate`, `MarketEvents.Register`, `SettlementExchange.Execute`, `SettlementMarket.Recover`, or `DTHoomans.Settlement.StartTraderTravel` from the test body. It may drive the public Hoomans lifecycle with deterministic engine fixtures.

Do not solve missing arrival wiring by moving travel authority into DynamicTrading. If Hoomans needs a reusable notification/listener seam, make the smallest generic Hoomans change and cover it with Hoomans regressions.

## Scope discipline

Mandatory M0–M9 only.

Do not expand into:

- player marketplace;
- quests;
- courier system;
- legacy DTNPC;
- full faction macroeconomy;
- full physical settlement warehouse accounting;
- haggling;
- broad reputation restoration;
- unrelated Radio OS art/UI work.

A tiny adapter/test fixture needed by the mandatory architecture is allowed.

## Stop conditions

Stop early only for:

- unresolved user-authored Git conflict affecting required files;
- missing required dependency/API with no safe fallback;
- a real product decision not specified by these docs;
- authorization restriction;
- completed developer-side M0–M9, including the no-fixture runtime lifecycle gate, with only explicit user-owned native acceptance remaining.

A passing phase is not a stop condition.

## Final handoff

Only report the parent goal developer-complete when all mandatory developer-side gates pass.

Final report must include:

- implemented phases;
- exact tests/evidence;
- persistence/performance evidence;
- commit SHAs and push state;
- any native SP/MP evidence;
- remaining user-owned live acceptance, if any;
- no claim that optional later extensions are required for completion.
