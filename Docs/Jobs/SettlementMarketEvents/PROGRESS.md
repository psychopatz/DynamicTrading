# Progress — Settlement Market & Events

## Parent status

**IN PROGRESS — M4 accepted; M5 is next.**

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

## M1B — accepted profiles, pressure, and recovery

M1B added data-driven profile baselines and the bounded market mutation path:

- `default`, `farm`, and `military` profiles provide distinct normalized
  MarketSense category baselines without defining item identities.
- `SettlementMarket.ApplyDelta` is the single server-owned bounded supply,
  demand, and wealth mutation path. It advances market and storage revisions,
  records update time, and rejects stale revisions.
- `SettlementMarket.Recover` moves category pressure and wealth toward the
  selected profile in one deterministic bounded calculation, with no periodic
  or per-frame loop.
- the registry returns normalized copies and persists/reloads two-settlement
  state through the separate market envelope; trader inventory remains
  untouched.

## M1B evidence

- `python3 tests/run_tests.py`: `PASS 26/26`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors for all 17 DTCommon shared files
  and the M1B pressure smoke test.
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

**M4 — Generic market events**

## M2A — accepted bounded settlement exchange

M2A adds a narrow exchange facade, planner, and MarketSense-backed candidate
adapter over the existing persistent virtual inventory:

- disposals inspect only exact trader stock and acquisitions use bounded
  `MarketCatalog` category candidates; unrelated records are preserved;
- plans cap operations and units, carry stock/market revisions and budget,
  and apply pressure deltas only for completed disposal/acquisition units;
- execution preflights stock and market revisions, saves the exact inventory
  once, applies one expected-revision market mutation, and restores stock,
  budget, and version on save or market failure;
- `MarkSettlementVisit` can invoke the exchange after the authoritative
  settlement seam, while the Hoomans arrival adapter forwards the explicit
  exchange intent and the policy keeps a bounded recent visit-ID ledger;
- no UI snapshot calls `TraderStock.New`, no event-start stock mutation, and
  no per-quote item-universe scan were introduced.

## M2A evidence

- `python3 tests/run_tests.py`: `PASS 27/27`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors across 20 DTCommon shared files,
  6 DTHoomans server files, and the exchange smoke test; exchange modules also
  passed the token-bloat threshold check.
- `luac -p` and `git diff --check` passed.

## M2B — accepted travel wiring and two-settlement propagation

M2B wires the exchange through the real Hoomans travel ownership boundary:

- `DTHoomans.Settlement.StartTraderTravel` validates the active canonical
  community, resolves the physical trader NPC, and delegates movement to
  `PNC.API.Travel.Start`;
- the serialized arrival action is strict, carries the canonical settlement
  and DT trader identity, and defaults to `exchange=true` while allowing an
  explicit opt-out;
- the two-settlement integration moves food through a surplus farm visit and
  a shortage military visit, changes each local market in the expected
  direction, preserves unrelated exact stock, and reloads both markets and
  trader stock from persistence.

## M2B evidence

- `python3 tests/run_tests.py`: `PASS 28/28`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors across the DTCommon and
  DTHoomans production trees and the M2B contract/integration tests.
- `luac -p` and `git diff --check` passed.

## M3 — accepted market-aware commercial pricing

M3 adds the server-owned quote context and pricing adapter over the existing
MarketSense boundary:

- `DTCommon.MarketPricing` resolves a trader's canonical last settlement,
  bounded category pressure, optional active event modifiers, and revision
  context without storing or scanning an item universe per quote;
- `TraderStock.Quote` preserves the existing intrinsic valuation and BUY/SELL
  commercial bases, then composes bounded settlement pressure, event price
  factors, and the existing relationship policy bias;
- stock snapshots, sell rows, basket results, and exchange plans carry
  structured quote explanations plus market/event revisions;
- basket settlement rejects an observed stale market revision before any
  player, stock, budget, or version mutation, and rechecks the context before
  transfer; exchange planning uses the same market-aware quote boundary;
- opposite surplus/shortage settlements, relationship composition, event
  reaction, immediate revision invalidation, reloaded quote reaction, and
  existing transaction regressions are covered without changing persistent
  trader stock on quote or event context changes.

## M3 evidence

- `python3 tests/run_tests.py`: `PASS 29/29`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors across the 21-file DTCommon
  shared production tree. Test sources retain the repository's existing
  harness-only `package`/`dofile` sandbox findings; `luac -p` passed for all
  changed production and test Lua files.
- `git diff --check` passed.

## M4 — accepted generic market event registry

M4 adds the generic event persistence and effective-context resolver:

- `DTCommon.Storage` persists a separate versioned `DTCommon.MarketEvents`
  envelope, leaving trader stock and settlement market envelopes independent;
- `DTCommon.MarketEvents` supports server-authoritative register, replace,
  list, remove, diagnostics, and deterministic active-context resolution for
  global, region, faction, and settlement scopes;
- start/end windows are deterministic and end-exclusive; matching category
  modifiers aggregate into bounded supply, demand, availability, and price
  factors without event-specific branches;
- event store writes and active-set/time-window changes produce context
  revisions consumed by the M3 quote invalidation seam;
- event registration/removal only changes event state: it does not loop over
  traders, rewrite stock, or create magical inventory.

## M4 evidence

- `python3 tests/run_tests.py`: `PASS 30/30`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors across the 22-file DTCommon
  shared production tree; `luac -p` and `git diff --check` passed.

## Next Chunk — M5

Add proof fixtures through the generic event pipeline:

1. Add data definitions for a settlement-scoped food shortage and an
   agricultural surplus using the same typed modifier schema.
2. Make active availability factors affect bounded candidate availability and
   make both opposite events react immediately in commercial quotes.
3. Verify event start/expiry changes prices and availability while exact
   persistent trader stock remains unchanged until settlement logistics.

## Remaining gap after M4

Proof event fixtures, market-aware availability, grounded presentation, and
the later roadmap phases remain incomplete.

## Known constraints

- Legacy Dynamic Trading is a behavioral reference only; do not wholesale-port
  its DTNPC runtime, manual item catalog, or monolithic dialogue system.
- Physical NPC identity, movement, settlement presence, and lifecycle remain
  Project Hoomans responsibilities.
- Native Project Zomboid SP/MP acceptance is not yet complete and remains a
  later user-owned/native gate after developer-side work is finished.
- Continue automatically through M0–M8; do not stop for another `/goal` after
  M0A, M0, or an individual phase.
