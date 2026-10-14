# Dynamic Trading V2 — Ordered Basic-Trading Roadmap

**Mandatory objective:** make existing two-sided trade window actually buy and sell eligible PZ/Workshop items at MarketSense-derived prices, with safe SP/MP settlement. **Complete T0–T6 in order.** One chunk is one bounded responsibility; sub-split when needed, but do not invent larger features.

## T0 — Fresh checkout, reproducible failing baseline

- Inspect branch, HEAD, `git status`, upstream and repository dependencies. Fetch safely; do not overwrite uncertain local changes.
- Identify active checkout locations for DynamicTrading, MarketSense, ProjectHoomans and PsychopatzCore; record versions/build in concise progress.
- Verify October 14 source findings **against current local code**, especially non-stocked Katana $0, fallback 10, inconsistent single/basket sell price, Core currency rollback return mismatch, and missing trade-access/eligibility checks.
- Add minimal failing tests for non-stocked `Base.Katana` sell lookup and rollback contract; document fixture fidelity. Run existing suites as baseline.
- Check actual PZ Lua/Kahlua/API and available headless/live harness facilities. Do not confuse harness mocks with native acceptance.

**Gate:** line-level evidence, reproducing failing tests, and Next Chunk recorded. **Immediately proceed to T1** when safe; do not pause for approval or spend the whole session writing a new audit.

## T1 — MarketSense pricing adapter (no fake prices)

- Create/reuse one narrow DTCommon MarketSense adapter with structured price and status; inspect current API first.
- Sell quote must resolve independently of a trader stock listing. Support actual InventoryItem valuation; definition price for abstract/stock rows.
- Remove hardcoded fallback 10 and ambiguous 0, validate numeric results/rounding, exclude settlement currency from merchandise.
- Consolidate buy/sell multiplier policy (initial buy ×1, sell ×0.5, positive valid-price floor 1 only); prevent divergent single versus basket formula.
- Preserve caches and instance state; never scan all mods on per-row UI refresh.

**Gate:** deterministic tests for non-stocked Katana, bandage, damaged weapon, invalid/unknown full type, arbitrary modded item, unavailable MarketSense, and consistent buy/sell formula. No fallback price is invented.

## T2 — Authoritative quote, identity and eligibility contract

- Build compact bounded quote/snapshot outputs from the server for *both* sides; client drafts only quantities.
- Verify and normalize exact item IDs, source container, item state, native counted stacks and grouped rows, duplicate rows, quantities and selected stock identifiers.
- Reuse/align ProjectHoomans item restriction probes; server independently rejects equipped/worn/attached/favorited, protected IDs, interaction-locked items, non-empty containers and currency-as-merchandise.
- Implement trader access/session checks for physical NPC and optional abstract/radio channels; fail closed on unvalidated access.
- Require observed stock/quote version and a bounded request identity. Return machine-readable rejection codes, no exposed Java objects.

**Gate:** spoofed item, stale quote, duplicate identity, nested bag/counted stack, restricted item and guessed trader ID tests reject without mutations; valid quote totals are deterministic.

## T3 — One safe basket transaction and currency settlement

- Replace duplicate behavioral implementations of `ExecuteTrade` and `ExecuteTradeBasket` with one authoritative execution path (retain compatibility wrappers only when genuinely used).
- Verify PsychopatzCore inventory transfer, currency `RemoveUnits`, restore and MoneyBundle semantics before composition. Correct return-shape mismatch.
- Prevalidate entire basket, funds/budget, stock, destination limits and item transfer capacity. Reconcile physical caravan capacity display with actual commercial stock capacity. Do not presume bags are free storage.
- Stage reversible changes; commit once; restore in exact reverse order on failure; verify restoration. If Core lacks generic primitives, amend Core narrowly with its own tests rather than building DT-only Core clones.
- Server tracks bounded, per-player/session/trader request deduplication. One request means at most one settlement, including retries/reconnects.
- On error, no changes to player items, currency, trader stock/budget or version. On success all move together and result references new revision.

**Gate:** single buy, single sell, multi-row netting, insufficient money/budget/stock/capacity, transfer failure at each step, serialization failure, duplicate request, stale request and MP concurrency simulation. Test exact inventory and monetary conservation.

## T4 — Connect the existing Hoomans trade window

- Modify `PNC_InventoryTransferEndpoint/_Trade.lua`, `InventoryWindow/_Trade.lua`, and trade row builders *minimally* to consume server quote/eligibility instead of guessing player prices from merchant stock.
- Preserve current dark two-sided window and existing action controls: Reset, Accept, Cancel, plus/minus, availability, unit price and net total.
- Fix grouping/draft keys/IDs, distinct unit versus stack totals, price-unavailable display, zero-disabled rows, in-flight pending state, result/request correlation and refresh after item replication.
- Do not change normal NPC inventory, gifts, storage, drag/drop or local-draft modes. No new parallel trade UI; keep existing fallback only if verified necessary.
- Ensure client does not show a successful price/Accept based on fabricated local values.

**Gate:** screenshot/real UI evidence when available; functional quote and Accept; UI/server totals match; normal Hoomans inventory/gift/storage tests remain green.

## T5 — Basic mod-agnostic stock seeding and bounded refresh

- Preserve manually selected *stock items* as optional debug fixtures, but remove any requirement for manually priced/registered item definitions.
- When new trader stock is needed, use MarketSense's available eligible catalog to pick a bounded deterministic assortment (availability/validity checked), then persist compact stock via Core.
- No runtime catalog-wide rescan per trading window. Reuse MarketSense registry and revision-aware caches.
- Keep current trader identity, caravan group and optional DTAbstract paths; do not implement restocking events, trader tastes or market fluctuations.
- Deduplicate type/instance work on snapshots and profile decoding/evaluation; avoid extra global ModData proliferation.

**Gate:** trade vanilla item and at least one previously unregistered eligible Workshop item; restart retains stock and prices remain attributable to MarketSense.

## T6 — Full MVP regression and measured native acceptance

- Run focused and dependent Lua regression suites, Kahlua/static checks and `git diff --check`.
- Run isolated native B42.20+ SP trade loop and dedicated MP/client loop if available, with actual inventory and money assertions. Test buy/sell/mixed basket/reconnect/replay/stale/invalid state and save/reload; preserve raw logs and screenshots.
- Profile real snapshot time, item price cache hit/miss, number of instance evaluations, inventory scan time, quote and commit cost using existing facilities. Optimize only measured hot paths; no per-tick full scan.
- Demonstrate money/item conservation with before/after accounting in SP and MP. Test all entry modes enabled in the installed configuration.
- Update progress with evidence level and remaining limitations. **Do not mark completed** if required native tests were not run; report `native-unverified`.

**Gate:** T0–T5 gates green, native SP + MP acceptance with raw evidence, no critical pricing/access/rollback defects, ordinary Hoomans modes intact. Only then call MVP ready.

## Non-goals / deferred work

Legacy economy and manually configured pricing registry; faction economics, trader personalities, reputation, supply/demand, trading events, haggling, stock replenishment cycles, caravan mobility/combat/escort, LLM dialog integration, generalized changes to game save data, and cosmetic redesign.

## Release rule

No feature-complete claim from static source or Lua stubs. Distinguish `implemented`, `smoke-tested`, `native SP verified`, and `native MP verified`. Keep current mod versions unless separately authorized; avoid speculative migrations before workshop release.
