# Progress — DynamicTrading Portable Actor Lifecycle & GC Adoption

**Status:** COMPLETE — D0–D5, D4-policy ACCEPTED (**READY FOR USER LIVE TEST**).
**Parent:** PsychopatzCore Docs/portable_actor_lifecycle_gc/.
**Current phase:** D5 complete — all DynamicTrading Portable Actor Lifecycle & GC phases accepted.
**Participant completion:** 6/6 phases accepted (D0, D1, D2, D3, D4, D5).

## Verified D0 Audit Facts (Checkpoint `c5a45962`)

- **Core `ActorRegistry:Remove` callers (2 total):**
  - `DTCommon_TraderGeneration.lua:98-103` (`RemoveCanonicalGroup` on failed caravan creation in `DTHoomans_CaravanService.lua`) -> `rollback-hard-delete`.
  - `DTAbstract_PreSurvivorWorldImport.lua:181-183` (`Import.Rebind`) -> `migration-redirect / superseded-actor` (note: does not yet migrate `oldActor.social` or `DTCommon.WorldKnowledge` before removal).
- **Commercial/projection removal callers:**
  - `DTCommon.TraderService.Remove`: `DTAbstract_Server.lua:322` (`RemoveTrader`, paired with `Provider.releaseTrader`, Core actor kept) -> `debug/admin` + `commercial-role-removal`; `DTAbstract_TraderWorldProvider.lua:275` & `DTHoomans_CaravanService.lua:731,819` -> `rollback-hard-delete`.
  - `DTHoomans_ProviderRuntime.lua:88-101` (`releaseProviderProjection`) -> `rollback-hard-delete` on failed materialization, `dematerialization` on dematerialize / missing-body recovery.
- **Actor retirement:** no true actor death/retirement handling exists yet in DT; `reconcileRecord` leaves missing Core actors indefinitely with `available = false`.
- **Persisted ModData schemas:** only `DTCommon.Traders`, `DTCommon.SettlementMarkets`, `DTCommon.MarketEvents` exist (`DTAbstract`/`DTHoomans` persist zero ModData keys). Debts, contracts, loans, invoices, escrow, orders, bounties, and trade logs **do not exist** in DT code (`quotes` are transient/runtime; trade totals live in Core social extension `"DynamicTrading"`).
- **Core social consumers:** zero DT modules directly inspect per-relationship `memories` arrays (`DTCommon_CoreActorPolicy.lua:373` already routes through `Social.QueryCandidateProjection`).
- **Minor verified gaps for D1-D4:** `DTHoomans_SettlementTrader.lua:243-247` calls nonexistent `Service.SetCoreActorID` (`Service.BindActor`); `DTCommon.WorldKnowledge` (`ModData["DTCommon.Traders"].worldKnowledge`) never prunes retired actors.

## D4-policy — Social Policy Reference Strength Metadata

- Annotated `tools/providers/dt/codebuilder/sources/social_policy/events/commerce.json` with explicit `references` (`commercial_trade` and routine `LONG`/`SHORT` events marked `target = WEAK` so normal trade contacts never pin dead tombstones; `trade.betrayal_or_hostile` marked `target = STRONG`, `source = WEAK`, `anchorMax = 16`, `degradeOnPurge = KEEP_HISTORICAL`).
- Regenerated `DTCommon/SocialPolicy/Events/Commerce.lua` and `Registry.lua` via Core CodeBuilder `reconcile.py --apply` (`clean: true`; Kahlua lint 0 errors; `dt_trade_relationship_event_smoke.lua` and `dt_portable_social_trader_adoption_smoke.lua` PASS).

## D1–D3 — Lifecycle Bridge, Commercial GC Roots & DTAbstract/DTHoomans Continuity

- Created `DTCommon/DTCommon_ActorLifecycle.lua` (required in `00_DTCommon_Init.lua`) providing server-authoritative `RetireTraderActor`, `OnActorRetired`, `HasActiveObligations`, `ClearDeadWorldKnowledge`, and `"DynamicTrading.CommercialRoots"` Core GC provider (`CollectStrongRefs` ONLY for genuine active obligations, `CollectWeakRefs` for retired trader/member refs, `IsOwnedActive` ONLY for non-retired live leases, and `OnBeforePurge` scrubbing `WorldKnowledge`, lingering dead trader records, and surviving `record.m`).
- Updated `DTCommon_CoreActorPolicy.lua` (`Policy.IsAvailable` rejects Core `"RETIRED"` with `"actor_retired"` without rejecting mock `"FORGOTTEN"` records), `DTCommon_TraderGeneration.lua` (`RemoveCanonicalGroup` rollback via Core `HardDelete`), `DTAbstract_PreSurvivorWorldImport.lua` (merges `oldActor.social` + `WorldKnowledge` refs onto canonical replacement preserving `providerLease`, then `HardDelete`s superseded actor with zero tombstones), `DTAbstract_TraderWorldProvider.lua` (`reconcileRecord` transitions Core `RETIRED` to `"actor_retired"` instead of `"core_actor_missing"` and never auto-resurrects), and `DTHoomans_SettlementTrader.lua` (fixed `Service.SetCoreActorID` -> `Service.BindActor`).
- Created `tests/dt_actor_lifecycle_gc_adoption_smoke.lua` covering standalone Core+DTAbstract (rollback, role removal, migration, unreferenced purge vs betrayal anchor & active obligation pinning, external death reconciliation) AND combined `DTHoomans`+`ProjectHoomans` materialize/dematerialize, settlement binding, and physical death retirement.
- Verified full DynamicTrading test suite (`python3 tests/run_tests.py`: `PASS 91/91`) and `pz_verify.py --kahlua --severity ERROR` (`0` errors across all 7 created/modified DT Lua files).

## D4 — Lifecycle-Aware Semantic & Commercial Projections

- Enriched `DTCommon_CoreActorPolicy.lua` (`Policy.QuerySocialProjection`) with O(1) read-only Core `ProjectIdentity` lookups attaching `lifecycleStatus`, `lifecycleRevision`, `targetLifecycleStatus`, and `targetLifecycleRevision` without invoking GC, plus bounded historical projection fallback (`allowHistorical = true`) for `RETIRED` and `FORGOTTEN` (`LABEL_ONLY` `"old_trader"`) traders without retaining dead simulation state.
- Extended `tests/dt_actor_lifecycle_gc_adoption_smoke.lua` (Phase 3 D4) and verified `python3 tests/run_tests.py` (`PASS 91/91`) + Kahlua lint (`0` errors).

## D5 — Scale, GC Soak & Final Acceptance

- Created `tests/dt_actor_lifecycle_gc_scale_soak_smoke.lua` stressing 200 traders across rollback `HardDelete` (20), commercial-role removal (20), superseded `PreSurvivorWorldImport` migration (20), ordinary trader deaths (100), betrayal-anchor pins (20), active obligation pins (20, settled -> purge), Kahlua `_G.next = nil` Core `Save()`/`Load()` roundtrip, and combined `DTHoomans` + `ProjectHoomans` physical death continuity under both PNC-disabled and PNC-enabled modes.
- Verified full DynamicTrading suite (`python3 tests/run_tests.py`: `PASS 92/92`).
- Status: **READY FOR USER LIVE TEST**.

## Next Chunk

Complete — READY FOR USER LIVE TEST (no pending developer phases).
