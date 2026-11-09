# Architecture Audit

Analyzer version: `2.0.0`  
Scoring scope: `production`

> Static analysis is triage evidence, not permission to refactor. Low coverage means inspect the source; preserve behavior and choose the smallest coherent ownership/boundary change.

## Project summary

| Metric | Value |
|---|---:|
| Production Health | 90.0/100 |
| Coverage | 62.1% |
| Confidence | 50.5% |
| Max Refactor Pressure | 17.5/100 |
| Production files | 88 |
| Tests indexed | 92 |
| Tooling files indexed | 7 |
| Generated files indexed | 0 |
| Production LOC scored | 19315 |
| Logical subsystems | 3 |
| Production findings | 12 |
| Test findings | 2 |

## Subsystems by refactor pressure

| Subsystem | Pressure | Health | Coverage | Confidence | Files | LOC | Findings | Fan-in | Fan-out |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| DTCommon | 17.5 | 86.7/100 | 62.9% | 51.1% | 53 | 11810 | 7 | 0 | 0 |
| DTHoomans | 7.0 | 94.6/100 | 61.6% | 50.0% | 19 | 4864 | 3 | 0 | 0 |
| DTAbstract | 4.5 | 96.4/100 | 59.7% | 48.6% | 16 | 2641 | 2 | 0 | 0 |

## Finding counts

| Scope | Rule | Severity | Count |
|---|---|---|---:|
| production | `LARGE_FUNCTION` | MEDIUM | 11 |
| production | `LARGE_MODULE` | MEDIUM | 1 |
| test | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | 2 |

## Finding index

Query evidence with `architecture_audit finding <repo> <finding-id> --context 4` before changing code.

| ID | Rule | Severity | Confidence | Subsystem | Summary |
|---|---|---|---:|---|---|
| `ARC-24E0A53EDF` | `LARGE_MODULE` | MEDIUM | HIGH (92%) | DTCommon | Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua has 1056 code lines; review responsibility density. |
| `ARC-038A8AEEC5` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | Exchange.Execute spans 141 lines. |
| `ARC-0BE0E5BA88` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | ensureWindowType spans 187 lines. |
| `ARC-1F04E0BF6E` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTHoomans | Runtime.MaterializeTrader spans 136 lines. |
| `ARC-235121A4EC` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTHoomans | finalize spans 146 lines. |
| `ARC-348D600EAB` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | Conversation.BuildSpec spans 259 lines. |
| `ARC-39A525192F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTHoomans | onExcursion spans 169 lines. |
| `ARC-9C6FE1F52F` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | registerPack spans 522 lines. |
| `ARC-A8C4917C5E` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | Factory.Create spans 146 lines. |
| `ARC-ACEB783607` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTCommon | Service.ExecuteTradeBasket spans 214 lines. |
| `ARC-CE5CDDC4A8` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTAbstract | onClientCommand spans 126 lines. |
| `ARC-D9F88DB710` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | DTAbstract | Import.Rebind spans 134 lines. |
| `ARC-8AE0C9974B` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | MEDIUM (72%) | DTAbstract | Repeated test setup appears across 4 tests (~36 repeated LOC). |
| `ARC-D6C1190880` | `TEST_HARNESS_EXTRACTION_CANDIDATE` | LOW | HIGH (95%) | tests | Repeated test setup appears across 29 tests (~4896 repeated LOC). |

## Largest maintained modules

Generated artifacts and tooling are indexed but excluded from this table and production scoring.

| ID | File | Code LOC |
|---|---|---:|
| `ARC-24E0A53EDF` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 1056 |

## Largest functions

| ID | Function | File | Start | LOC |
|---|---|---|---:|---:|
| `ARC-9C6FE1F52F` | `registerPack` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SemanticPack.lua` | 13 | 522 |
| `ARC-348D600EAB` | `Conversation.BuildSpec` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderConversation.lua` | 558 | 259 |
| `ARC-ACEB783607` | `Service.ExecuteTradeBasket` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 855 | 214 |
| `ARC-0BE0E5BA88` | `ensureWindowType` | `Contents/mods/DTCommon/42.20/media/lua/client/DTCommon/DTCommon_TraderManager.lua` | 193 | 187 |
| `ARC-39A525192F` | `onExcursion` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ResidentExcursion.lua` | 183 | 169 |
| `ARC-A8C4917C5E` | `Factory.Create` | `Contents/mods/DTCommon/42.20/media/lua/server/DTCommon/DTCommon_CoreTraderCandidateFactory.lua` | 97 | 146 |
| `ARC-235121A4EC` | `finalize` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua` | 602 | 146 |
| `ARC-038A8AEEC5` | `Exchange.Execute` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_SettlementExchange.lua` | 62 | 141 |
| `ARC-1F04E0BF6E` | `Runtime.MaterializeTrader` | `Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_ProviderRuntime.lua` | 175 | 136 |
| `ARC-D9F88DB710` | `Import.Rebind` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_PreSurvivorWorldImport.lua` | 47 | 134 |
| `ARC-CE5CDDC4A8` | `onClientCommand` | `Contents/mods/DTAbstract/42.20/media/lua/server/DTAbstract/DTAbstract_Server.lua` | 206 | 126 |

## Recommended workflow

1. Select a high-pressure subsystem with adequate coverage.
2. Inspect grouped findings and individual evidence.
3. Read the smallest relevant production slice and establish ownership/contracts.
4. Save a baseline and refactor one coherent vertical slice.
5. Query affected tests, run them, rescan, and compare the baseline.
