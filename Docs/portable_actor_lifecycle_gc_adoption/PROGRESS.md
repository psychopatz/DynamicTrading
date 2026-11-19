# Progress — DynamicTrading Portable Actor Lifecycle & GC Adoption

**Status:** IN_PROGRESS (D0 ACCEPTED — awaiting Core L1-L4 contracts).
**Parent:** PsychopatzCore Docs/portable_actor_lifecycle_gc/.
**Current phase:** D0 complete; next D1 (pending Core L1-L4).
**Participant completion:** 1/6 phases accepted.

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

## Next Chunk

Wait for Core L1-L4 acceptance, then implement **D1** (distinguish Core `HardDelete` rollback, commercial-role removal, superseded migration, and true Core `Retire` handling, and reconcile trader records cleanly on Core actor death/retirement).
