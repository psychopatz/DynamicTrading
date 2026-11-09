# Architecture Audit

Analyzer version: `2.0.0`  
Scoring scope: `production`

> Static analysis is triage evidence, not permission to refactor. Low coverage means inspect the source; preserve behavior and choose the smallest coherent ownership/boundary change.

## Project summary

| Metric | Value |
|---|---:|
| Production Health | 96.9/100 |
| Coverage | 66.2% |
| Confidence | 51.7% |
| Max Refactor Pressure | 35.0/100 |
| Production files | 88 |
| Tests indexed | 94 |
| Tooling files indexed | 7 |
| Generated files indexed | 0 |
| Production LOC scored | 19643 |
| Logical subsystems | 63 |
| Production findings | 20 |
| Test findings | 2 |

## Subsystems by refactor pressure

| Subsystem | Pressure | Health | Coverage | Confidence | Files | LOC | Findings | Fan-in | Fan-out |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| (composition) | 35.0 | 85.2/100 | 78.3% | 65.9% | 15 | 2082 | 6 | 0 | 58 |
| Trader | 11.0 | 93.1/100 | 67.0% | 54.1% | 4 | 1953 | 3 | 4 | 2 |
| TraderWorldProvider | 10.4 | 96.8/100 | 75.9% | 61.5% | 2 | 841 | 1 | 2 | 5 |
| Caravan | 6.2 | 94.9/100 | 67.0% | 54.1% | 1 | 800 | 2 | 1 | 1 |
| TraderConversation | 6.0 | 93.0/100 | 54.6% | 44.8% | 1 | 837 | 2 | 2 | 0 |
| TraderWorld | 5.4 | 100.0/100 | 78.5% | 58.9% | 1 | 699 | 0 | 6 | 2 |
| PreSurvivorWorldImport | 3.9 | 98.2/100 | 78.5% | 62.7% | 2 | 200 | 1 | 2 | 1 |
| TraderPresentation | 3.7 | 100.0/100 | 54.6% | 41.0% | 1 | 372 | 0 | 6 | 0 |
| ProviderRuntime | 3.4 | 98.2/100 | 78.5% | 62.7% | 1 | 495 | 1 | 1 | 1 |
| ResidentExcursion | 3.3 | 98.2/100 | 78.5% | 62.7% | 1 | 330 | 1 | 1 | 1 |
| SettlementExchange | 3.3 | 98.2/100 | 78.5% | 62.7% | 1 | 190 | 1 | 1 | 1 |
| CoreActorPolicy | 3.2 | 100.0/100 | 54.6% | 41.0% | 1 | 474 | 0 | 5 | 0 |
| CoreTraderCandidateFactory | 2.7 | 98.2/100 | 62.9% | 51.0% | 1 | 223 | 1 | 0 | 1 |
| TraderGeneration | 2.7 | 100.0/100 | 67.0% | 50.2% | 1 | 209 | 0 | 3 | 1 |
| SemanticPack | 2.6 | 97.5/100 | 54.6% | 44.8% | 1 | 534 | 1 | 1 | 0 |
| RadioOS | 2.4 | 100.0/100 | 78.5% | 58.9% | 3 | 480 | 0 | 1 | 2 |
| TraderProvider | 2.4 | 100.0/100 | 54.6% | 41.0% | 1 | 115 | 0 | 4 | 0 |
| UI | 2.4 | 100.0/100 | 62.9% | 47.2% | 2 | 511 | 0 | 1 | 2 |
| NearbyDiscovery | 2.3 | 100.0/100 | 71.1% | 53.4% | 1 | 197 | 0 | 1 | 2 |
| TraderRepresentationRuntime | 2.3 | 100.0/100 | 78.5% | 58.9% | 1 | 238 | 0 | 1 | 2 |
| CommonIntegration | 2.2 | 100.0/100 | 78.5% | 58.9% | 2 | 116 | 0 | 1 | 2 |
| TraderMapContext | 2.2 | 100.0/100 | 67.0% | 50.2% | 1 | 81 | 0 | 1 | 2 |
| CoreConversation | 2.1 | 100.0/100 | 78.5% | 58.9% | 1 | 178 | 0 | 2 | 1 |
| TraderNotification | 2.1 | 100.0/100 | 78.5% | 58.9% | 1 | 247 | 0 | 2 | 1 |
| TraderPresets | 2.0 | 100.0/100 | 54.6% | 41.0% | 1 | 481 | 0 | 3 | 0 |
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
| SurvivorWorldRuntime | 1.3 | 100.0/100 | 54.6% | 41.0% | 1 | 243 | 0 | 2 | 0 |
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
| Storage | 0.7 | 100.0/100 | 57.7% | 43.3% | 1 | 200 | 0 | 1 | 0 |
| TradeAudit | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 243 | 0 | 1 | 0 |
| TradePresentation | 0.7 | 100.0/100 | 78.5% | 58.9% | 2 | 166 | 0 | 1 | 0 |
| WorldKnowledge | 0.7 | 100.0/100 | 57.7% | 43.3% | 1 | 337 | 0 | 1 | 0 |
| CommercialMobility | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 124 | 0 | 1 | 0 |
| Constants | 0.6 | 100.0/100 | 49.2% | 36.9% | 1 | 19 | 0 | 1 | 0 |
| Context | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 101 | 0 | 1 | 0 |
| MarketEventDefinitions | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 52 | 0 | 1 | 0 |
| MarketEventPresentation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 130 | 0 | 1 | 0 |
| ModActivationPolicy | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 75 | 0 | 1 | 0 |
| PlacePresentation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 100 | 0 | 1 | 0 |
| TradeAuditPrice | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 128 | 0 | 1 | 0 |
| TradeAuditProfiler | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 66 | 0 | 1 | 0 |
| TradeWindow | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 108 | 0 | 1 | 0 |
| TraderSupport | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 16 | 0 | 1 | 0 |
| Translation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 18 | 0 | 1 | 0 |

## Finding counts

| Scope | Rule | Severity | Count |
|---|---|---|---:|
| production | `LARGE_FUNCTION` | MEDIUM | 11 |
| production | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | 5 |
| production | `LARGE_MODULE` | MEDIUM | 3 |
| production | `HOT_PATH_EVENT_RISK` | LOW | 1 |
| test | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | 2 |

## Finding index

Query evidence with `architecture_audit finding <repo> <finding-id> --context 4` before changing code.

| ID | Rule | Severity | Confidence | Subsystem | Summary |
|---|---|---|---:|---|---|
| `ARC-1F5442E978` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | (composition) | Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/00_DTHoomans_Server_Init.lua directly depends on 8 foreign subsystems. |
| `ARC-677862BA4F` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | TraderWorldProvider | Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_TraderWorldProvider.lua directly depends on 5 foreign subsystems. |
| `ARC-C4057496FD` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | (composition) | Contents/mods/DTHoomans/42.20/media/lua/client/DTHoomans/00_DTHoomans_Client_Init.lua directly depends on 6 foreign subsystems. |
| `ARC-DDC38DC568` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | (composition) | Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/00_DTCommon_Init.lua directly depends on 31 foreign subsystems. |
| `ARC-E6537E53BA` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | (composition) | Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/00_DTCommon_Client_Init.lua directly depends on 9 foreign subsystems. |
| `ARC-2E137C1562` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | TraderConversation | Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua has 837 code lines; review responsibility density. |
| `ARC-5C387D05B9` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | Caravan | Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua has 800 code lines; review responsibility density. |
| `ARC-E84637E6F0` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | Trader | Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua has 1056 code lines; review responsibility density. |
| `ARC-0819381ECA` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | ResidentExcursion | onExcursion spans 169 lines. |
| `ARC-2B1958BB34` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Caravan | finalize spans 146 lines. |
| `ARC-394BA5CAE1` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | SemanticPack | registerPack spans 522 lines. |
| `ARC-57BEC71C99` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Trader | ensureWindowType spans 187 lines. |
| `ARC-5973569898` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | (composition) | onClientCommand spans 126 lines. |
| `ARC-65EA7D1FBC` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Trader | Service.ExecuteTradeBasket spans 214 lines. |
| `ARC-8B6CB650FD` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | TraderConversation | Conversation.BuildSpec spans 271 lines. |
| `ARC-B7B5B47951` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | PreSurvivorWorldImport | Import.Rebind spans 134 lines. |
| `ARC-C00D38EE8C` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | SettlementExchange | Exchange.Execute spans 141 lines. |
| `ARC-C0E640D300` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | CoreTraderCandidateFactory | Factory.Create spans 148 lines. |
| `ARC-EAB1E8BC3F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | ProviderRuntime | Runtime.MaterializeTrader spans 136 lines. |
| `ARC-CEFD026ECD` | `HOT_PATH_EVENT_RISK` | LOW | LOW (52%) | (composition) | Contents/mods/DTCommon/42.20/media/lua/server/DTCommon/DTCommon_Server.lua publishes events and contains a recurring hot-path signal. |
| `ARC-4158991D77` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | MEDIUM (72%) | WorldMap | Repeated test setup appears across 4 tests (~36 repeated LOC). |
| `ARC-4A66D13B34` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | HIGH (95%) | tests | Repeated test setup appears across 29 tests (~4896 repeated LOC). |

## Largest maintained modules

Generated artifacts and tooling are indexed but excluded from this table and production scoring.

| ID | File | Code LOC |
|---|---|---:|
| `ARC-E84637E6F0` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 1056 |
| `ARC-2E137C1562` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua` | 837 |
| `ARC-5C387D05B9` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua` | 800 |

## Largest functions

| ID | Function | File | Start | LOC |
|---|---|---|---:|---:|
| `ARC-394BA5CAE1` | `registerPack` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SemanticPack.lua` | 13 | 522 |
| `ARC-8B6CB650FD` | `Conversation.BuildSpec` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua` | 591 | 271 |
| `ARC-65EA7D1FBC` | `Service.ExecuteTradeBasket` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 855 | 214 |
| `ARC-57BEC71C99` | `ensureWindowType` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderManager.lua` | 193 | 187 |
| `ARC-0819381ECA` | `onExcursion` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ResidentExcursion.lua` | 183 | 169 |
| `ARC-C0E640D300` | `Factory.Create` | `Contents/mods/DTCommon/42.20/media/lua/server/DTCommon/DTCommon_CoreTraderCandidateFactory.lua` | 97 | 148 |
| `ARC-2B1958BB34` | `finalize` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua` | 618 | 146 |
| `ARC-C00D38EE8C` | `Exchange.Execute` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SettlementExchange.lua` | 62 | 141 |
| `ARC-EAB1E8BC3F` | `Runtime.MaterializeTrader` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ProviderRuntime.lua` | 175 | 136 |
| `ARC-B7B5B47951` | `Import.Rebind` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_PreSurvivorWorldImport.lua` | 47 | 134 |
| `ARC-5973569898` | `onClientCommand` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_Server.lua` | 206 | 126 |

## Recommended workflow

1. Select a high-pressure subsystem with adequate coverage.
2. Inspect grouped findings and individual evidence.
3. Read the smallest relevant production slice and establish ownership/contracts.
4. Save a baseline and refactor one coherent vertical slice.
5. Query affected tests, run them, rescan, and compare the baseline.
