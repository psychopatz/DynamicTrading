# Dynamic Trading V2 — Basic Trading Contract

**Scope:** current `DTCommon`, `DTHoomans`, `DTAbstract` rewrite with MarketSense, PsychopatzCore and Project Hoomans. This document governs basic commerce only.

## Product definition

An eligible vanilla **or unknown Workshop/modded item** can be bought or sold without any manually maintained DynamicTrading item/price definition. MarketSense supplies intrinsic value and classification. DynamicTrading owns only simple buy/sell margins, stock, quotes, access/session validation, and settlement.

Dynamic pricing here means **procedurally valuing the loaded item universe and current item state**. A supply/demand simulation with price fluctuations is not required for this MVP.

## Verified baseline evidence (2026-10-14; recheck on each fresh checkout)

- `DTCommon_TraderStock.lua::MarketPrice` calls MarketSense but silently falls back to `10` and `SnapshotItems` calculates buy/sell only for existing merchant stock.
- Hoomans `PNC_InventoryTransferEndpoint/_Trade.lua::priceFor` looks up player sell prices in `snapshot.items` (merchant stock) and returns `0` when missing. This explains a non-stocked `Base.Katana` showing $0 without proving MarketSense is at fault.
- `DTCommon_TraderService.lua` implements separate `ExecuteTrade` and `ExecuteTradeBasket` with differing sell-price rules (full definition price versus half definition price).
- `PsychopatzPhysicalInventoryAdapter:removeCurrency` returns `true, details`. DTCommon stores the Boolean as `removedMoney` and later calls `restoreRemoved(removedMoney)`; this is a verified return-contract mismatch.
- Basket server paths do not currently enforce all Hoomans client-side equipped/favorite/locked/identity/container restrictions, trade-access proof, request deduplication or instance-aware sell valuation.
- Hoomans trade UI builds draft rows and totals client-side, while the server independently recomputes price. Grouped item IDs, partial native stacks and nested containers need explicit compatibility tests.
- Virtual trader stock is compactly encoded via PsychopatzCore; preserve this.
- Caravan capacity presentation is from Hoomans member inventories, while trader merchandise uses a separate virtual stock; verify and reconcile instead of assuming these weights are equivalent.

These are **code observations**, not a claim that native end-to-end tests have passed.

## Architecture and ownership

```text
PZ item definitions / current concrete InventoryItems
  -> MarketSense classification + intrinsic price
  -> DTCommon.PriceAdapter (structured OK/unavailable/blocked result)
  -> DTCommon.TradeQuote (server owns authoritative quote)
  -> DTCommon.TradeTransaction (one settlement path)
  -> PsychopatzCore inventory/currency transfer, compact stock persistence
  -> trade result + revised snapshot
  -> ProjectHoomans trade-mode UI / optional DTHoomans and DTAbstract fronts
```

### Price contract

- **No manually maintained item-price registry or hardcoded fallback price** in DynamicTrading; a tiny deterministic debug *stock fixture* is permitted.
- For stock/definition rows, use MarketSense definition pricing and cached intrinsic data.
- For actual player items, use `MarketSense.GetPriceDetailsForInstance(fullType, inventoryItem)` if supported; do not price a damaged item as a pristine definition. Verify API contracts in the current MarketSense checkout.
- Treat missing API, nil/invalid, nonfinite, negative, or unverified zero price as **unavailable**; return a typed reason, not a fake dollar number. A deliberate zero-value/trade exclusion requires explicit eligibility policy.
- Interpret prices in **integer currency units** with one deterministic rounding rule. Keep initial policy conservative: player BUY = existing intrinsic MarketSense price; player SELL = floor(0.5 × intrinsic), minimum positive 1 **only for an otherwise valid positive intrinsic price**. Isolate the margin/configuration so it can change without rewriting quote logic.
- Do not double-count MarketSense price adjustments, stack quantities, or content value. Distinguish a unit price from an aggregate stack quote.

### Quote/row contract (proposed shape, adjust to current APIs)

```lua
TradeQuote = {
  traderID = "stable-id", requestID = "session-scoped-unique-id",
  stockVersion = 7, quoteRevision = 11,
  buyRows = { { stockKey = "...", fullType = "Base.Bandage", quantity = 2, unitPrice = 30 } },
  sellRows = { { fullType = "Base.Katana", itemIDs = {123}, quantity = 1, unitPrice = 225 } },
  buyTotal = 60, sellTotal = 225, netTotal = -165,
  status = "OK" -- or precise bounded reason
}
```

- Actual wire schema is determined by inspected engine/adapter contracts; the example is not a mandate to transmit live Java objects or prices supplied by a client.
- Player sale prices are **independent of merchant stock membership**.
- Client may draft quantities; price/eligibility/total are ultimately server-derived. Send only bounded primitive identities and quantities. Reject stale quotes/versions rather than silently changing the charge.
- Failures distinguish `PRICE_UNAVAILABLE`, `ITEM_UNAVAILABLE`, `NOT_TRADEABLE`, `STALE_QUOTE`, `TRADER_UNAVAILABLE`, `ACCESS_DENIED`, `INSUFFICIENT_FUNDS`, `INSUFFICIENT_BUDGET`, `INSUFFICIENT_CAPACITY`, `DUPLICATE_REQUEST` and transfer/save failures, mapped to human-readable UI text.
- Resolve grouped/native-counted items by exact physical identity and represented units. For unsupported partial stacks, explicitly disable the option with reason rather than allowing incorrect count/transfer behavior.
- Money/MoneyBundle are **settlement currency**, not ordinary tradable goods. Keep PsychopatzCore currency unit semantics.

### Item/access validation

Server rechecks, just before commit: stable trader and permitted NPC/radio access, player identity, session, version, every selected item ID and full type, ownership and source container, equipped/worn/attached/favorite/locked/identity/protected status, empty-container rule, quantities including stacks, trader stock, player funds, trader budget and destination capacity. **Client filters are never authoritative**. Prevent duplicate row/item identities and quantities exceeding aggregate availability.

A nearby trader cannot be remotely traded with merely by guessing a `traderID`. Preserve a validated remote policy where explicitly supported; otherwise reject.

### Transaction invariant

```text
Either: all selected items, stock, money, budget and revision commit once,
Or: all mutable resources remain as before, with an explicit failure reason.
```

- Prefer shared Core transfer/currency primitives; audit their actual return shapes and rollback capabilities before composing them.
- Stage and validate first; use reversible removal handles, accurately tracked destination additions and rollback in **reverse operation order**. Verify rollback return values; do not label an operation atomic if restoration can silently fail.
- Persist stock/budget/version consistently; stage record changes and avoid publishing a successful result before persistent commit.
- A repeated request ID from the same player/session/trader must not settle twice. Keep deduplication bounded, use proper player/session scoping, and return the existing result or an explicit duplicate rejection.
- Handle SP and dedicated MP authority equally; quote display must be reconciled with server result and the correct open window.
- Preserve item state through physical ↔ virtual transfers via PsychopatzCore; do not flatten to `fullType` when state matters.

### Snapshot and performance

- Reuse one loaded virtual inventory per snapshot instead of serializing/decoding it twice.
- Cache **definition** prices by MarketSense/pricing revision; use bounded state-aware instance quote caching or on-demand evaluation.
- No continuous full-catalog scan, expensive per-frame classifier calls, or duplicated item definitions in persistent trader records.
- Send compact bounded quote/stock rows; coalesce in-flight requests and refresh UI only when relevant player/stock/quote revisions change.
- First trader may use a tiny fixed starter stock fixture. Add a bounded, deterministic, MarketSense-eligible seed generator only after the core path works. New mods must require no manually edited prices or allowlist.

## MVP acceptance scenarios

1. `Base.Katana` not in trader stock gets positive MarketSense-derived player sell quote; changing condition changes the appropriate quote.
2. Bandage x5 shows **unit** price and total correctly; accepts 1 and several units without double-counting.
3. An otherwise eligible previously unknown mod item can be quoted/sold without a DT item record or override.
4. Mixed basket gives exact net and consistent player/trader funds, stock, and item state.
5. Currency bundles and loose money settle by unit value; every forced failure restores unchanged state.
6. Missing/invalid MarketSense price is visibly unavailable; no silent $0/$10 fallback and no mutation.
7. Equipped/locked/favorited/identity item, occupied container, fake item ID, duplicate row, stale version, inaccessible trader, no funds/budget/capacity, and repeated request cannot mutate state.
8. Nested container and counted stack behavior is either correct or explicitly, safely disabled with an explanation.
9. Ordinary NPC inventory, gift, storage, local draft, guard referral and caravan behavior remain intact.
10. Isolated native SP and MP exercise real buy/sell; no unsupported claim of native success if unavailable.

## Non-goals

No Dynamic Trading Legacy manual prices/catalog; no reputation, haggling, scarcity simulation, world market events, seasonal modifiers, caravan movement/spawn redesign, faction economy, new LLM dialogue or UI redesign unrelated to trade correctness.
