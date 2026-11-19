# Audit — DynamicTrading Portable Social State Adoption (DT0)

**Scope:** Source-verified P0 (`DT0`) audit across `DTCommon`, `DTAbstract`, and `DTHoomans`. No production schema changes made.

## Verified source inventory

- **Canonical Trader Records (`DTCommon.Traders` -> `data.t[traderID]`)**: `DTCommon_TraderRegistry.lua` (`L36-196`) & `DTCommon_CoreActorPolicy.lua` (`L88-177`).
  - DT-owned commerce fields: `b` (budget), `v` (stockVersion), `i` (virtual `PsychopatzInventory`), `s` (`READY`/`AWAY`), `a` (radio flag), `c` (`caravanID`), `r` (`traderRole`), `ca` commercial policy (`available`, `relationshipPricing`, `priceBias`, `restock`, visit/journey scheduling).
  - Core identity link & cache: `ca.actorID`, `ca.returnProviderID`, and derived lease cache (`ca.provider`, `ca.providerState`, `ca.providerLeaseID`, `ca.providerBodyID`, `ca.providerRevision`).
- **Actor Creation & Provider Continuity**:
  - `DTCommon_TraderGeneration.lua` (`L62-160`) & `DTCommon_CoreTraderCandidateFactory.lua` (`L130-286`) allocate canonical Core `actorID`s via `SurvivorWorld`.
  - `DTAbstract_TraderWorldProvider.lua` (`L188-298`) & `DTAbstract_CoreProvider.lua` (`L42-47`) run bodyless abstract/radio/nearby contact with `PNC` absent.
  - `DTHoomans_CaravanService.lua` (`L410-490`, `623-769`) & `DTHoomans_ProviderRuntime.lua` (`L175-542`) coordinate `DTAbstract <-> DTHoomans` materialization and dematerialization.
- **Social Read/Write & Pricing**:
  - `DTCommon_CoreActorPolicy.PriceContext` (`L309-337`) computes `relationshipModifier` from Core `approval * 0.0015 + respect * 0.00075 + familiarity * 0.00025` clamped to `[-0.25, 0.25]`, consumed by `DTCommon_MarketPricing.lua` (`L180-190`) and `DTCommon_TraderStock.lua` (`L173-203`).
  - `DTCommon_TraderService.ExecuteTradeBasket` (`L1021-1028`) invokes `DTCommon_CoreActorPolicy.RecordTradeEvent` (`L343-442`), writing `dt:trade:<requestID>` to Core `SocialAuthority.RecordAuthorizedEvent` and updating `rel.extensions.DynamicTrading` (`totalTrades`, `lastTradeValue`, `commercialReliability`).
- **Trader Conversation**:
  - Canonical ConvoEngine sources under `tools/providers/dt/codebuilder/sources/conversation/` compile into `DTCommon/ConvoEngine/*` and load in `DTCommon_SemanticPack.lua`.
  - `DTCommon_TraderConversation.lua` (`L1-1242`) drives shared conversation UI for both `DTAbstract` and `DTHoomans`.

## Continuity & Adoption Gaps Identified for DT1–DT5 (Parent P3, P5, P6, P7)

1. **`DTHoomans_SettlementTrader` missing `actorID`**: `EnsureTraderForFaction` (`L251-269`) and `DTCommon_TraderRegistry.BindFaction` (`L144-164`) do not set `record.ca.actorID`, leaving resident settlement traders without Core relationship pricing or trade social events.
2. **`DTAbstract_PreSurvivorWorldImport.Rebind` partial update**: `L136-167` updates `policy.actorID` without syncing `record.l`, `record.g`, `record.m`.
3. **`DTHoomans_ProviderRuntime.DematerializeTrader` social sync gap**: `L388-406` commits `{ providerLease, personalInventory }` to Core without ensuring dirty Hoomans social state was synced first.
4. **Hardcoded flat trade social deltas**: `DTCommon_CoreActorPolicy.RecordTradeEvent` (`L402-417`) uses flat `+1 approval, +0 respect, +1 familiarity` rather than CodeBuilder-compiled Social Policy with consolidation and retention.
5. **Conversation social projection gaps**: `DTCommon_TraderConversation.lua` `contextFor` (`L658-703`) omits `relationship`, `BuildSpec` (`L911-922`) assumes singular `projection.relationship`, and `responseFor` (`L537-614`) returns static strings independent of relationship history/personality.
6. **Market pricing context revision**: `DTCommon_MarketPricing.ContextRevision` (`L239-245`) omits `relationshipRevision`.
