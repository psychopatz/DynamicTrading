# Progress — Settlement Market & Events

## Parent status

**IN PROGRESS — M0 accepted; M1 is next.**

The complete M0–M8 roadmap remains the parent completion boundary. Finishing
one chunk or phase does not complete the parent objective.

## Planning baseline

Current DynamicTrading `main` baseline: `f4899384f4cffb2bfaaaa33a0846100e314d2b48`

Legacy behavioral reference: `ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`

The working tree contains the unrelated pre-existing edit to:

`Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`

That file remains preserved and is not part of this work.

## Accepted existing foundation

- stable trader registry and persistent exact merchant stock;
- bounded initial MarketSense-backed stock seed;
- MarketSense definition/instance pricing;
- server-authoritative buy/sell basket settlement;
- exact item identity, replay, stale-version, and transaction rollback guards;
- trader budget and stock revisions;
- Core actor policy settlement-gated `MarkVisit` and `Restock`;
- Hoomans physical trader/faction binding;
- DTAbstract remote access;
- Talk, WorldKnowledge, and reusable Radio OS presentation seams.

These foundations are preserved; the market/event work must evolve them rather
than replace them.

## M0A — accepted source-audit contracts

M0A verified the real integration seams before adding settlement market state:

- `DTCommon_TraderService.Snapshot` loads the persisted serialized inventory
  through `TraderStock.SnapshotItems`; it does not call `TraderStock.New`, so
  reopening a trader does not reroll exact stock.
- `DTCommon_TraderService.MarkSettlementVisit` remains the server-authoritative
  visit seam. The Core actor policy now requires an explicit settlement
  identity, records `lastSettlementID`, and retains duplicate visit protection.
- Project Hoomans' active `community.id` is the canonical settlement identity.
  `factionID` identifies the owning faction and `siteID` identifies a physical
  location; neither replaces the community identity.
- Hoomans exposes the authoritative arrival seam through
  `PNC.API.Travel.RegisterArrivalHandler` and `PNC.Travel.Arrivals.Dispatch`.
  The new server-only `dynamic_trading_settlement` adapter resolves the active
  community, resolves the trader from the arriving NPC, and forwards one
  idempotent server visit to DynamicTrading. It does not create movement or
  invent a second settlement lifecycle.
- MarketSense remains the intrinsic-value and taxonomy authority through
  `GetPriceDetails*`, `GetItemAvailability`, `GetAllKnownItems`, and `GetTags`;
  no DynamicTrading item taxonomy or manual intrinsic-price catalog was added.
- No settlement market state, event state, or per-visit item-registry scan was
  introduced in M0A.

## M0B — accepted versioned schemas

M0B added `DTCommon.MarketSchema` as a shared, data-only contract for future
market and event registries. It defines version 1 envelopes and normalizers for
settlement markets, market events, and their bounded stores. It provides
defaults and migration handling for absent/partial records, clamps invalid
numeric values, rejects future schema versions, drops unknown fields, and
preserves generic MarketSense category/tag keys without an item ledger.

The schema boundary does not resolve prices, run recovery, activate events,
scan all items, or mutate trader stock.

## M0B evidence

- `python3 tests/run_tests.py`: `PASS 23/23`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors for all 14 DTCommon shared files,
  all 6 DTHoomans server files, and the schema smoke test.
- `luac -p` and `git diff --check` passed.

## M1A — accepted market registry and catalog

M1A added the first production settlement market foundation:

- `DTCommon.Storage` now owns a separate `DTCommon.SettlementMarkets`
  persistence envelope; trader inventory data remains in its existing key and
  serializer.
- `DTCommon.SettlementMarket` creates, reads, lists, and commits bounded
  category-pressure records through the M0B schema. Creation and commits are
  server-authoritative, increment the envelope revision, preserve stale-revision
  protection, and return normalized copies rather than exposing ModData tables.
- market creation validates an active Hoomans `community.id` when the Hoomans
  community service is available; no faction or site identity is substituted.
- `DTCommon.MarketCatalog` consumes MarketSense category, tag, availability,
  and price facts into a bounded runtime index. It builds once at game start,
  supports explicit invalidation, and exposes deterministic category candidates
  without persisting an item universe.
- M1A does not change trader quotes, exchange behavior, event activation, or
  physical stock.

## M1A evidence

- `python3 tests/run_tests.py`: `PASS 25/25`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors for all 16 DTCommon shared files.
- `luac -p` and `git diff --check` passed.

## M0A evidence

- `python3 tests/run_tests.py`: `PASS 22/22`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- `luac -p` passed for every changed production and contract-test Lua file.
- `git diff --check` passed.
- PZ Verify Kahlua checks reported zero errors for the affected DTCommon and
  DTHoomans server trees and both new contract tests.
- Codebase-memory graph status and coverage were checked first for the
  Project Hoomans and MarketSense source paths. DynamicTrading media paths are
  excluded from the current graph index, so those exact production files were
  verified by direct source inspection as required by the coverage result.

## Current phase

**M1 — Settlement Market foundation**

## Next Chunk — M1B

Add deterministic settlement profiles, baseline category defaults, bounded
pressure mutation, and recovery toward baseline using the accepted registry.

Required work:

1. Define at least two distinct profile fixtures using MarketSense category
   vocabulary without a DT item taxonomy.
2. Apply bounded supply/demand deltas through one server-owned mutation path.
3. Recover deterministically toward each profile baseline and persist revisions.
4. Add two-settlement reload/diagnostic tests; do not change trade quotes or
   stock until the M1 gate is met.

## Remaining gap after M1A

Settlement profiles, pressure mutation/recovery, market-aware availability and
quotes, generic scoped event resolution, bounded partial settlement exchange,
and logistics propagation between settlements remain incomplete. M1A only
provides the persistent registry and catalog foundation.

## Known constraints

- Legacy Dynamic Trading is a behavioral reference only; do not wholesale-port
  its DTNPC runtime, manual item catalog, or monolithic dialogue system.
- Physical NPC identity, movement, settlement presence, and lifecycle remain
  Project Hoomans responsibilities.
- Native Project Zomboid SP/MP acceptance is not yet complete and remains a
  later user-owned/native gate after developer-side work is finished.
- Continue automatically through M0–M8; do not stop for another `/goal` after
  M0A, M0, or an individual phase.
