# Architecture Audit

Analyzer version: `2.1.0`  
Scoring scope: `production`

> Static analysis is triage evidence, not permission to refactor. Low coverage means inspect the source; preserve behavior and choose the smallest coherent ownership/boundary change.

## Project summary

| Metric | Value |
|---|---:|
| Production Health | 98.2/100 |
| Coverage | 66.0% |
| Confidence | 51.3% |
| Max Refactor Pressure | 15.4/100 |
| Production files | 91 |
| Tests indexed | 98 |
| Tooling files indexed | 11 |
| Reference files indexed (excluded from scoring) | 0 |
| Generated files indexed | 2 |
| Production LOC scored | 20274 |
| Logical subsystems | 66 |
| Production findings | 16 |
| Unique cyclic dependency groups | 0 |
| Test findings | 2 |

## Subsystems by refactor pressure

| Subsystem | Pressure | Health | Coverage | Confidence | Files | LOC | Findings | Fan-in | Fan-out |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| (composition) | 15.4 | 98.0/100 | 78.3% | 63.7% | 15 | 2106 | 2 | 0 | 61 |
| Trader | 11.0 | 93.1/100 | 67.0% | 54.1% | 4 | 1938 | 3 | 4 | 2 |
| TraderWorldProvider | 10.4 | 96.8/100 | 73.2% | 59.3% | 2 | 840 | 1 | 2 | 5 |
| TraderConversation | 6.9 | 93.0/100 | 59.6% | 48.5% | 1 | 1064 | 2 | 2 | 1 |
| Caravan | 6.2 | 94.9/100 | 67.0% | 54.1% | 1 | 801 | 2 | 1 | 1 |
| TraderWorld | 5.4 | 100.0/100 | 78.5% | 58.9% | 1 | 699 | 0 | 6 | 2 |
| PreSurvivorWorldImport | 3.9 | 98.2/100 | 78.5% | 62.7% | 2 | 200 | 1 | 2 | 1 |
| TraderPresentation | 3.7 | 100.0/100 | 54.6% | 41.0% | 1 | 372 | 0 | 6 | 0 |
| ProviderRuntime | 3.4 | 98.2/100 | 78.5% | 62.7% | 1 | 497 | 1 | 1 | 1 |
| TraderGeneration | 3.4 | 100.0/100 | 67.0% | 50.2% | 1 | 138 | 0 | 3 | 2 |
| CoreTraderCandidateFactory | 3.3 | 98.2/100 | 62.9% | 51.0% | 1 | 260 | 1 | 1 | 1 |
| ResidentExcursion | 3.3 | 98.2/100 | 78.5% | 62.7% | 1 | 330 | 1 | 1 | 1 |
| SettlementExchange | 3.3 | 98.2/100 | 78.5% | 62.7% | 1 | 190 | 1 | 1 | 1 |
| CoreActorPolicy | 3.2 | 100.0/100 | 54.6% | 41.0% | 1 | 474 | 0 | 5 | 0 |
| SemanticPack | 3.2 | 97.5/100 | 54.6% | 44.8% | 1 | 555 | 1 | 2 | 0 |
| RadioOS | 2.4 | 100.0/100 | 78.5% | 58.9% | 3 | 480 | 0 | 1 | 2 |
| TraderProvider | 2.4 | 100.0/100 | 54.6% | 41.0% | 1 | 115 | 0 | 4 | 0 |
| UI | 2.4 | 100.0/100 | 62.9% | 47.2% | 2 | 511 | 0 | 1 | 2 |
| NearbyDiscovery | 2.3 | 100.0/100 | 71.1% | 53.4% | 1 | 197 | 0 | 1 | 2 |
| TraderRepresentationRuntime | 2.3 | 100.0/100 | 78.5% | 58.9% | 1 | 238 | 0 | 1 | 2 |
| CommonIntegration | 2.2 | 100.0/100 | 78.5% | 58.9% | 2 | 116 | 0 | 1 | 2 |
| TraderMapContext | 2.2 | 100.0/100 | 67.0% | 50.2% | 1 | 81 | 0 | 1 | 2 |
| CoreConversation | 2.1 | 100.0/100 | 78.5% | 58.9% | 1 | 181 | 0 | 2 | 1 |
| TraderNotification | 2.1 | 100.0/100 | 78.5% | 58.9% | 1 | 247 | 0 | 2 | 1 |
| TraderPresets | 2.0 | 100.0/100 | 54.6% | 41.0% | 1 | 486 | 0 | 3 | 0 |
| SettlementTrader | 1.5 | 100.0/100 | 78.5% | 58.9% | 1 | 301 | 0 | 1 | 1 |
| SettlementVisit | 1.5 | 100.0/100 | 78.5% | 58.9% | 1 | 448 | 0 | 1 | 1 |
| TraderStock | 1.5 | 100.0/100 | 67.0% | 50.2% | 1 | 403 | 0 | 1 | 1 |
| WorldMap | 1.5 | 100.0/100 | 60.8% | 45.6% | 1 | 242 | 0 | 1 | 1 |
| CoreSettlementDirectoryProvider | 1.4 | 100.0/100 | 67.0% | 50.2% | 1 | 70 | 0 | 1 | 1 |
| DebugAdapter | 1.4 | 100.0/100 | 78.5% | 58.9% | 1 | 97 | 0 | 1 | 1 |
| SettlementExchangePlan | 1.4 | 100.0/100 | 78.5% | 58.9% | 1 | 87 | 0 | 1 | 1 |
| TraderWorldRuntime | 1.4 | 100.0/100 | 78.5% | 58.9% | 1 | 77 | 0 | 1 | 1 |
| CoreProvider | 1.3 | 100.0/100 | 54.6% | 41.0% | 2 | 236 | 0 | 2 | 0 |
| MarketSenseGateway | 1.3 | 100.0/100 | 54.6% | 41.0% | 1 | 218 | 0 | 2 | 0 |
| SurvivorWorldRuntime | 1.3 | 100.0/100 | 54.6% | 41.0% | 1 | 249 | 0 | 2 | 0 |
| Integration | 1.2 | 100.0/100 | 54.6% | 41.0% | 1 | 103 | 0 | 2 | 0 |
| SettlementDirectory | 1.2 | 100.0/100 | 54.6% | 41.0% | 1 | 150 | 0 | 2 | 0 |
| TraderContacts | 1.2 | 100.0/100 | 54.6% | 41.0% | 1 | 130 | 0 | 2 | 0 |
| Conversation | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 214 | 0 | 1 | 0 |
| MarketEventProducer | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 221 | 0 | 1 | 0 |
| MarketEvents | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 318 | 0 | 1 | 0 |
| MarketPricing | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 351 | 0 | 1 | 0 |
| MarketProfiles | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 163 | 0 | 1 | 0 |
| MarketSchema | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 263 | 0 | 1 | 0 |
| SettlementExchangeCandidates | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 193 | 0 | 1 | 0 |
| SettlementMarket | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 349 | 0 | 1 | 0 |
| SettlementTraderStaffing | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 235 | 0 | 1 | 0 |
| Storage | 0.7 | 100.0/100 | 57.7% | 43.3% | 1 | 200 | 0 | 1 | 0 |
| TradeAudit | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 243 | 0 | 1 | 0 |
| TradePresentation | 0.7 | 100.0/100 | 78.5% | 58.9% | 2 | 166 | 0 | 1 | 0 |
| WorldKnowledge | 0.7 | 100.0/100 | 57.7% | 43.3% | 1 | 337 | 0 | 1 | 0 |
| CommercialMobility | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 129 | 0 | 1 | 0 |
| Constants | 0.6 | 100.0/100 | 49.2% | 36.9% | 1 | 29 | 0 | 1 | 0 |
| Context | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 101 | 0 | 1 | 0 |
| MarketEventDefinitions | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 52 | 0 | 1 | 0 |
| MarketEventPresentation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 130 | 0 | 1 | 0 |
| ModActivationPolicy | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 75 | 0 | 1 | 0 |
| PlacePresentation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 100 | 0 | 1 | 0 |
| SurvivorWorldPresenceAdapter | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 71 | 0 | 1 | 0 |
| TradeAuditPrice | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 128 | 0 | 1 | 0 |
| TradeAuditProfiler | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 66 | 0 | 1 | 0 |
| TradeWindow | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 108 | 0 | 1 | 0 |
| TraderFactionProfile | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 71 | 0 | 1 | 0 |
| TraderSupport | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 16 | 0 | 1 | 0 |
| Translation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 18 | 0 | 1 | 0 |

## Finding counts

| Scope | Rule | Severity | Count |
|---|---|---|---:|
| production | `LARGE_FUNCTION` | MEDIUM | 11 |
| production | `LARGE_MODULE` | MEDIUM | 3 |
| production | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | 1 |
| production | `HOT_PATH_EVENT_RISK` | LOW | 1 |
| test | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | 2 |

## Finding index

Query evidence with `architecture_audit finding <repo> <finding-id> --context 4` before changing code.

| ID | Rule | Severity | Confidence | Subsystem | Summary |
|---|---|---|---:|---|---|
| `ARC-677862BA4F` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | TraderWorldProvider | Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_TraderWorldProvider.lua directly depends on 5 foreign subsystems. |
| `ARC-9FF2923294` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | Trader | Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua has 1041 code lines; review responsibility density. |
| `ARC-C6D10AB1E7` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | TraderConversation | Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua has 1064 code lines; review responsibility density. |
| `ARC-CF92BCD681` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | Caravan | Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua has 801 code lines; review responsibility density. |
| `ARC-0819381ECA` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | ResidentExcursion | onExcursion spans 169 lines. |
| `ARC-57BEC71C99` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Trader | ensureWindowType spans 187 lines. |
| `ARC-5973569898` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | (composition) | onClientCommand spans 126 lines. |
| `ARC-652349FEB5` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | TraderConversation | Conversation.BuildSpec spans 322 lines. |
| `ARC-6EF2127621` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Trader | Service.ExecuteTradeBasket spans 214 lines. |
| `ARC-972930669F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Caravan | finalize spans 147 lines. |
| `ARC-B7B5B47951` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | PreSurvivorWorldImport | Import.Rebind spans 134 lines. |
| `ARC-C00D38EE8C` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | SettlementExchange | Exchange.Execute spans 141 lines. |
| `ARC-EAB1E8BC3F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | ProviderRuntime | Runtime.MaterializeTrader spans 137 lines. |
| `ARC-EACE130D86` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | SemanticPack | registerPack spans 538 lines. |
| `ARC-FE301B810F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | CoreTraderCandidateFactory | Factory.Create spans 157 lines. |
| `ARC-CEFD026ECD` | `HOT_PATH_EVENT_RISK` | LOW | LOW (52%) | (composition) | Contents/mods/DTCommon/42.20/media/lua/server/DTCommon/DTCommon_Server.lua publishes events and contains a recurring hot-path signal. |
| `ARC-9F0FC4E256` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | HIGH (95%) | tests | Repeated test setup appears across 31 tests (~5112 repeated LOC). |
| `ARC-C67528ADBF` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | MEDIUM (72%) | WorldMap | Repeated test setup appears across 4 tests (~36 repeated LOC). |

## Largest maintained modules

Generated artifacts, tooling, and reference sources are indexed but excluded from this table and production scoring.

| ID | File | Code LOC |
|---|---|---:|
| `ARC-C6D10AB1E7` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua` | 1064 |
| `ARC-9FF2923294` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 1041 |
| `ARC-CF92BCD681` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua` | 801 |

## Largest functions

| ID | Function | File | Start | LOC |
|---|---|---|---:|---:|
| `ARC-EACE130D86` | `registerPack` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SemanticPack.lua` | 22 | 538 |
| `ARC-652349FEB5` | `Conversation.BuildSpec` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua` | 767 | 322 |
| `ARC-6EF2127621` | `Service.ExecuteTradeBasket` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 836 | 214 |
| `ARC-57BEC71C99` | `ensureWindowType` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderManager.lua` | 193 | 187 |
| `ARC-0819381ECA` | `onExcursion` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ResidentExcursion.lua` | 183 | 169 |
| `ARC-FE301B810F` | `Factory.Create` | `Contents/mods/DTCommon/42.20/media/lua/server/DTCommon/DTCommon_CoreTraderCandidateFactory.lua` | 130 | 157 |
| `ARC-972930669F` | `finalize` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua` | 623 | 147 |
| `ARC-C00D38EE8C` | `Exchange.Execute` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SettlementExchange.lua` | 62 | 141 |
| `ARC-EAB1E8BC3F` | `Runtime.MaterializeTrader` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ProviderRuntime.lua` | 175 | 137 |
| `ARC-B7B5B47951` | `Import.Rebind` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_PreSurvivorWorldImport.lua` | 47 | 134 |
| `ARC-5973569898` | `onClientCommand` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_Server.lua` | 206 | 126 |

## Recommended workflow

1. Select a high-pressure subsystem with adequate coverage.
2. Inspect grouped findings and individual evidence.
3. Read the smallest relevant production slice and establish ownership/contracts.
4. Save a baseline and refactor one coherent vertical slice.
5. Query affected tests, run them, rescan, and compare the baseline.
