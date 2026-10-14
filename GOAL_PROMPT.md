# Dynamic Trading V2 — Copyable Luna `/goal`

Paste the command below into a Luna/Codex session with access to the current DynamicTrading checkout and its dependency repositories.

```text
/goal

Continue unattended development of the CURRENT Dynamic Trading V2 rewrite (DTCommon + DTHoomans + DTAbstract) on the checked-out source. Focus exclusively on a fully working, MarketSense-driven BASIC trading loop. Do NOT inspect or reuse Dynamic Trading Legacy's manual price/item registry.

Read in this exact order:
1. Docs/trading/DT_TRADING_AGENT_RUNBOOK.md
2. Docs/trading/DT_TRADING_MVP_ROADMAP.md
3. Docs/trading/DT_TRADING_MVP_PROGRESS.md
4. Docs/trading/DT_TRADING_MVP_CONTRACT.md

Follow the current Next Chunk and ordered T0-T6 acceptance gates. Start T0 now, write minimal failing reproductions for the non-stocked Base.Katana $0 sell-price path and PsychopatzCore currency rollback return mismatch, then move directly into T1 and continue safely without asking permission after each coherent chunk.

Non-negotiable rules:
- MarketSense alone supplies intrinsic item classification/valuation; use its definition and concrete-instance APIs. Any eligible installed Workshop item should trade without manual DT price registration. Never invent $10/$1 generic fallback prices.
- DTCommon owns server-side quote, margins, eligibility/access validation, item identity, net basket pricing, atomic settlement, request deduplication and trader stock. Initial BUY ×1, SELL ×0.5, with one consistent integer rounding policy.
- ProjectHoomans owns the existing trade-mode window and player row UI; fix the trade-specific endpoint as needed, preserving normal inventory/gift/storage behavior. PsychopatzCore owns generic inventory and currency primitives.
- Audit actual APIs and latest working trees before modifying them. Do not duplicate Core/MarketSense logic or make broad speculative refactors.
- Preserve exact item state, stack quantities, container source, server-only authority, money/bundle semantics and failure-safe rollback. Reject equipped/locked/protected/invalid/inaccessible/stale/replayed operations with explicit reasons. Do not trust client-supplied prices.
- Prioritize functional buy/sell/mixed basket, singleplayer and multiplayer correctness and measured performance. Defer economic events, supply/demand, factions, restocking cycles, caravan movement, reputation and LLM dialogue.
- Work in small tested chunks, preserve user changes and normal game saves/config, use disposable PZ testing profiles, run relevant smoke/dependency/native tests, git diff --check, update concise progress, commit and push validated fast-forward-safe changes when possible.
- Continue automatically to the next mandatory safe chunk. A passing test or commit is not a stop condition. Ask only on genuine destructive/user-owned-data risk, uncertain Git conflict, missing vital dependency or an unspecified product decision.
- Do not claim native SP/MP success when only mocks passed or testing environment is unavailable; record exact evidence and remaining gate.

At each checkpoint report completed chunk, evidence/tests, commits/push status, remaining defects, and the exact next chunk. Do not declare MVP ready before all T0-T6 acceptance gates pass.
```
