# Progress — Settlement Market & Events

## Parent status

**IN PROGRESS — M0–M8 engine work accepted; M9 Runtime Market Activation is mandatory before native SP/MP handoff.**

The complete M0–M9 roadmap is now the parent completion boundary. Finishing
one chunk or phase does not complete the parent objective.

## Planning baseline

Current audited DynamicTrading `main` baseline: `96303d91a1f44270c43b71581e92e619e2448541`

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
- Hoomans exposes an explicit travel-arrival handler seam through
  `PNC.API.Travel.RegisterArrivalHandler` and `PNC.Travel.Arrivals.Dispatch`.
  The server-only `dynamic_trading_settlement` adapter resolves the active
  community, resolves the trader from the arriving NPC, and forwards one
  idempotent server visit to DynamicTrading. Post-M8 audit later proved this
  explicit DT arrival action is **not** the same as Hoomans' ordinary
  `PNC.MobileSettlementVisitService` lifecycle and has no production caller;
  M9 must close that activation gap without moving travel authority into DT.
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

**M9 — Runtime Market Activation REQUIRED**

M0–M8 are accepted as engine implementation. Parent completion is reopened because production call-site audit found that ordinary gameplay does not yet provision settlement markets, consume the normal Hoomans mobile-settlement arrival lifecycle, advance recovery, or produce events.

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

## M5 — accepted generic proof events

M5 adds data-only food shortage and agricultural surplus definitions through
the M4 registry and connects generic availability to bounded exchange
candidate exposure:

- the shortage and surplus definitions use only typed category modifiers for
  supply, demand, availability, and price; no event-specific pricing branch
  was added;
- identical MarketSense intrinsic food items receive opposite immediate
  commercial quote responses and retain the same intrinsic value;
- exchange candidate selection honors each active category availability factor
  deterministically within its existing operation/unit budget;
- event expiry restores the neutral quote and candidate availability context;
- event registration and planning leave persistent trader state untouched.

## M5 evidence

- `python3 tests/run_tests.py`: `PASS 31/31`.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua checks reported zero errors across the 23-file DTCommon
  shared production tree; `luac -p` and `git diff --check` passed.

## M6 — accepted deterministic two-settlement logistics

M6 proves the complete settlement-centered logistics path through the real
Hoomans arrival adapter and DTCommon visit/exchange seam:

- a persistent trader acquires one MarketSense-backed food unit at a farm
  surplus, keeps unrelated stock, and records the canonical farm settlement;
- the exact stock and farm pressure survive a fresh storage/market reload;
- Hoomans-owned travel delegates the same physical NPC to a military
  settlement, where the carried food is partially disposed and the canonical
  settlement context moves to the destination;
- local farm and military quotes react to their own completed pressure changes;
- stock versions, market revisions, budget, and visit IDs advance only on
  completed exchanges; replaying the same arrival ID does not transact twice.

## M6 evidence

- `python3 tests/run_tests.py`: `PASS 32/32`.
- Focused M6/regression run: `PASS 3/3` for the logistics, arrival-contract,
  and two-settlement exchange harnesses.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua reported zero errors for the 23-file DTCommon shared
  production tree and the new logistics harness; `luac -p` and
  `git diff --check` passed.

## M7 — accepted grounded event presentation

M7 connects authoritative active market events to the existing presentation
seams without creating a second event store or mutating economic state:

- `MarketEventPresentation` exposes bounded active summaries and stable fact
  identities directly from `DTCommon.MarketEvents`, including scope and time;
- on-demand WorldKnowledge synchronization publishes one typed `market.event`
  fact and acquires it only for the trader whose Talk context is being built;
- Talk renders the same fact and returns truthful no-news after expiry or when
  no event matches the trader's settlement context;
- physical and abstract Radio OS contact rows expose the same bounded event
  summaries, while the scanner renders localized event news or explicit no-news;
- event presentation remains read-only with respect to trader stock, budget,
  stock versions, quotes, and settlement market pressure.

## M7 evidence

- `python3 tests/run_tests.py`: `PASS 32/32`.
- Focused M7 event/presentation run: `PASS 4/4` for event registry, proof
  events, WorldKnowledge/Talk, and Radio OS harnesses.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- PZ Verify Kahlua reported zero errors across the 24-file DTCommon shared
  production tree and changed presentation files; Lua parse, translation JSON
  parity, and `git diff --check` passed.

## M8 — accepted performance, migration, and hardening

M8 closes the developer-side correctness and bounded-runtime gate:

- storage migration is exercised through the real market/event envelopes, with
  legacy defaults, unknown-field removal, future-schema rejection, bounded
  records, active event definition reload, expiry timing, and recovery time
  clamping covered by `dt_market_hardening_smoke.lua`;
- `MarketCatalog.Get` now keeps uncatalogued MarketSense facts in a separate
  bounded 256-entry runtime cache. The primary registry index remains bounded
  and explicit invalidation still permits only one new MarketSense scan;
- the optional Core profiler feature exposes quote-context, event-resolution,
  event-presentation, catalog-query, market-recovery, settlement-visit, and
  settlement-exchange timers. The feature is inactive unless Core performance
  capture is enabled, and cleanup restores the original functions;
- representative JSON observations cover 64 settlement market records and 32
  event records without item definitions: 31,442 market bytes and 19,066 event
  bytes in the deterministic harness;
- direct source audit confirms no market/event per-frame hook, all-trader event
  rewrite, or per-quote/per-visit `GetAllKnownItems` scan. Exchange and event
  state remain bounded by the existing schema/operation limits.

## M8 evidence

- `python3 tests/run_tests.py`: `PASS 33/33`.
- Focused M8/regression run: `PASS 9/9` for hardening, schema, catalog,
  events, pricing, pressure, exchange, baseline, and two-settlement paths.
- `env DT_MODS_ROOT=.../Contents/mods lua tests/dt_hoomans_bridge_harness.lua`:
  `83 checks, 0 failures`.
- Dependency-boundary regressions passed: PsychopatzCore profiler/inventory
  `3/3`, Project Hoomans travel/presence/staffing `3/3`, and MarketSense API,
  availability-budget, and market-modifier `3/3`.
- PZ Verify Kahlua reported zero errors across the 24-file DTCommon shared
  production tree; the new test's two `package.path` findings are
  harness-only because Project Zomboid supplies those paths automatically.
  Full `luac -p`, translation JSON parity, and `git diff --check` passed.
- Native SP/MP acceptance was not executed because repository policy leaves
  native driving and live acceptance user-owned/authorization-gated.

## Post-M8 audit correction

The previous statement that only native SP/MP remained was incorrect. Repository inspection at `96303d91` found four developer-side activation gaps:

1. `SettlementMarket.GetOrCreate` has no production caller; ordinary settlements can reach exchange with no market and fail `market_not_found`.
2. `DTHoomans.Settlement.StartTraderTravel` / `dynamic_trading_settlement` are test/API paths with no production caller; the normal Hoomans `PNC.MobileSettlementVisitService` arrival lifecycle does not currently notify DT.
3. `SettlementMarket.Recover` has no production caller; pressure recovery is test-driven only.
4. `MarketEvents.Register` has no production caller; proof events are test/debug-driven only.

The existing `33/33` DT suite and `83/0` bridge evidence remain accepted for M0–M8, but they manually create/drive the missing runtime state and therefore do not close M9.

## Next Chunk — M9A Automatic provisioning + real Hoomans arrival

Start with the production lifecycle, not another market algorithm.

1. Re-audit the current Project Hoomans `PNC.MobileSettlementVisitService` and community/faction public APIs.
2. Identify whether Hoomans already exposes a reusable observer/listener for normal settlement arrival. If not, add the smallest generic non-DynamicTrading-specific notification contract in Project Hoomans with focused Hoomans regressions.
3. Add a bounded DTHoomans adapter that consumes that real arrival notification, resolves the arriving bound DT trader and canonical active `community.id`, and invokes one idempotent `MarkSettlementVisit(..., exchange=true)`.
4. Before exchange, provision a missing settlement market idempotently through `SettlementMarket.GetOrCreate` using a bounded profile resolver over existing Hoomans community/faction/archetype/tags. Unknown mappings must use `default`.
5. Preserve existing-save compatibility through lazy provisioning; do not perform a destructive world migration.
6. Add a fail-first integration test that starts with an active Hoomans-style community and **no DT market**, then drives the public Hoomans arrival lifecycle. The test body must not call `SettlementMarket.GetOrCreate`, `StartTraderTravel`, the DT arrival handler, or `SettlementExchange.Execute` directly.
7. Prove duplicate/replayed arrival cannot provision twice or transact twice.

### M9A acceptance

A normal Hoomans-owned settlement arrival from zero DT market state creates exactly one market and applies at most one exchange through production integration entrypoints. Hoomans remains movement/lifecycle authority.

After M9A, continue automatically to M9B recovery runtime, M9C grounded production event producer, and M9D no-fixture lifecycle acceptance. Do not stop for another `/goal`.

## Known constraints

- Legacy Dynamic Trading is a behavioral reference only; do not wholesale-port
  its DTNPC runtime, manual item catalog, or monolithic dialogue system.
- Physical NPC identity, movement, settlement presence, and lifecycle remain
  Project Hoomans responsibilities.
- Native Project Zomboid SP/MP acceptance is not yet complete and remains a
  later user-owned/native gate **after M9 developer-side activation is accepted**.
- Continue automatically through M0–M9; do not stop for another `/goal` after
  M9A, M9B, M9C, or an individual phase/chunk.
