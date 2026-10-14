# Dynamic Trading V2 — Basic-Trading Progress

**Role:** concise authoritative checkpoint ledger. Detailed history remains in Git and test artifacts.

## Current state

T0 is complete. T1/T3 implementation slices, the T4 server/UI bridge, and the T5 MarketSense seed are committed. The MVP is **not ready**: native SP/MP player settlement and T6 acceptance remain open.

## Checked-out inputs

Validated 2026-10-14 after a safe fetch of `origin/main`; all four repositories were clean and at the fetched remote tip before editing.

| Repository | HEAD | Evidence scope |
|---|---|---|
| DynamicTrading | `c9d5f8c8f88d5dd8c6230b6d53a67e74b76d6634` | current V2 rewrite |
| MarketSense | `32a73836a2bf7de52cb36d75bd1f368ffbd445a5` | public definition/instance pricing APIs |
| ProjectHoomans | `00f33efd417b9959978e7049c4453f22403200fd` | trade-mode window and inventory rows |
| PsychopatzCore | `473b1eebb7c13181045f08dbdbd79912d43ba0fd` | inventory/currency primitives |

## T0 — complete

- Added minimal reproductions for the non-stocked `Base.Katana` sell quote and the Core currency rollback return-shape mismatch.
- Baseline before fixes: `dt_trading_t0` failed 2/2 (Katana quote was `0`; rollback `pcall` failed).
- Current focused result: both T0 reproductions pass.
- Native facilities were audited. Real Build 42.21.0 / Steam build `25485521` is available through the disposable PZ headless harness.

## T1 — implemented; smoke-tested and native adapter-tested

- `DTCommon.TraderStock` now uses only MarketSense `GetPriceDetails` for definitions and `GetPriceDetailsForInstance` for concrete items.
- Invalid, missing, zero, currency, and non-finite prices are unavailable; no generic fallback price remains.
- Buy is `intrinsic × 1`; sell is `floor(intrinsic × 0.5)` with a minimum of 1 only after a valid positive intrinsic price.
- Focused price-adapter smoke and the real native quote fixture pass. The native fixture made 5 assertions against the real server and MarketSense; it is not a player trade.

## T3 — implemented; host settlement coverage is green, native player settlement remains open

- Single-row requests now route through the authoritative basket executor.
- Added exact identity, concrete quote revalidation, access/version/replay checks, protected-item and counted-stack rejection, reversible Core transfer handles, currency rollback, budget/version conservation, and one-save settlement.
- Basket smoke covers mixed buy/sell netting, same-type items with different concrete quotes, duplicate replay, stale revision, favorite rejection, later transfer failure, and save failure. Core reversible/currency tests pass.
- No client-supplied prices are trusted and no Legacy registry is used.

## T4 — functional host coverage; native UI evidence open

- Hoomans trade endpoint consumes authoritative `sellRows`, hides unavailable sell prices, preserves item identities, rejects counted stacks in trade rows, and submits only the identities selected from an aggregate row.
- Hoomans trade/storage/transaction focused tests pass, including aggregate-row identity trimming. The standalone UI smoke remains harness-limited because it has no native `ISUI/ISPanel` module.
- Real UI screenshot and end-to-end SP/MP player evidence are not claimed.

## T5 — implemented; native seed smoke passes

- Trader creation now seeds at most 8 compact Core records from MarketSense’s public known-item and availability APIs. Configured defaults are only preferred fixture types after the same availability and quote validation; they do not provide prices.
- Non-`Base` installed candidates are preferred when available, so eligible Workshop items do not require DT registration. Currency and unavailable/invalid-price entries are excluded.
- A force-rebuild retry occurs only when the public catalog is empty during first-time creation; snapshots never rebuild or rescan the catalog.
- Host seed smoke and the real native seed fixture pass (9 assertions, zero actionable errors). Restart retention of a created trader’s persisted stock still needs a dedicated native restart check.

## Next Chunk

T6 — use the disposable real PZ facilities to attempt the native SP player trade loop and a restart-persistence check, then measure the seed/snapshot/commit boundaries. If the player/MP path is unavailable in the harness, record the exact gate as native-unverified and keep the focused host evidence separate.

## T6 — open

The native server boot, MarketSense adapter, and bounded seed fixtures pass with activation order `PsychopatzCore → MarketSense → DTCommon → DTAbstract → ProjectHoomans → DTHoomans` and zero actionable errors. This proves loading, quote-boundary, and first-time seed behavior only. Native SP player settlement, native MP settlement/reconnect/replay, save/reload trade conservation, and measured snapshot/commit performance remain unverified.

## Remaining defects and evidence limits

- The full DynamicTrading suite still has one unrelated/pre-existing `dt_caravan_contract_smoke.lua` text-contract failure (`groupSize = GROUP_SIZE`); focused V2 and seed tests pass.
- Native runs report optional missing `AnimSets/actiongroups` directories for several staged mods, but the harness reports zero actionable errors and a clean server exit.
- Test-only `package.preload` lines are intentionally rejected by `pz_verify` as PZ sandbox violations; changed production files have zero Kahlua errors.

**Completion status: NOT COMPLETE.**
