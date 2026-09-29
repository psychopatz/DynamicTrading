# Architecture Audit

Analyzer version: `2.0.0`  
Scoring scope: `production`

> Static analysis is triage evidence, not permission to refactor. Low coverage means inspect the source; preserve behavior and choose the smallest coherent ownership/boundary change.

## Project summary

| Metric | Value |
|---|---:|
| Production Health | 98.3/100 |
| Coverage | 63.6% |
| Confidence | 50.2% |
| Max Refactor Pressure | 14.1/100 |
| Production files | 25 |
| Tests indexed | 7 |
| Tooling files indexed | 0 |
| Generated files indexed | 0 |
| Production LOC scored | 2864 |
| Logical subsystems | 12 |
| Production findings | 2 |
| Test findings | 0 |

## Subsystems by refactor pressure

| Subsystem | Pressure | Health | Coverage | Confidence | Files | LOC | Findings | Fan-in | Fan-out |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| (composition) | 14.1 | 96.8/100 | 76.8% | 62.3% | 13 | 1151 | 1 | 0 | 11 |
| Trader | 2.5 | 97.5/100 | 54.6% | 44.8% | 2 | 434 | 1 | 1 | 0 |
| Caravan | 0.8 | 100.0/100 | 54.6% | 41.0% | 1 | 573 | 0 | 1 | 0 |
| DebugTraderWindow | 0.7 | 100.0/100 | 54.6% | 41.0% | 1 | 229 | 0 | 1 | 0 |
| Constants | 0.6 | 100.0/100 | 49.2% | 36.9% | 1 | 17 | 0 | 1 | 0 |
| Context | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 101 | 0 | 1 | 0 |
| DebugSpawnMenu | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 59 | 0 | 1 | 0 |
| Storage | 0.6 | 100.0/100 | 57.7% | 43.3% | 1 | 77 | 0 | 1 | 0 |
| TradeWindow | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 108 | 0 | 1 | 0 |
| TraderStock | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 81 | 0 | 1 | 0 |
| TraderSupport | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 16 | 0 | 1 | 0 |
| Translation | 0.6 | 100.0/100 | 54.6% | 41.0% | 1 | 18 | 0 | 1 | 0 |

## Finding counts

| Scope | Rule | Severity | Count |
|---|---|---|---:|
| production | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | 1 |
| production | `LARGE_FUNCTION` | MEDIUM | 1 |

## Finding index

Query evidence with `architecture_audit finding <repo> <finding-id> --context 4` before changing code.

| ID | Rule | Severity | Confidence | Subsystem | Summary |
|---|---|---|---:|---|---|
| `ARC-2A2289843D` | `CROSS_SUBSYSTEM_COUPLING` | MEDIUM | HIGH (82%) | (composition) | Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/00_DTCommon_Init.lua directly depends on 6 foreign subsystems. |
| `ARC-4C3AD29CFE` | `LARGE_FUNCTION` | MEDIUM | HIGH (90%) | Trader | Service.ExecuteTradeBasket spans 138 lines. |

## Largest maintained modules

Generated artifacts and tooling are indexed but excluded from this table and production scoring.

| ID | File | Code LOC |
|---|---|---:|

## Largest functions

| ID | Function | File | Start | LOC |
|---|---|---|---:|---:|
| `ARC-4C3AD29CFE` | `Service.ExecuteTradeBasket` | `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua` | 197 | 138 |

## Recommended workflow

1. Select a high-pressure subsystem with adequate coverage.
2. Inspect grouped findings and individual evidence.
3. Read the smallest relevant production slice and establish ownership/contracts.
4. Save a baseline and refactor one coherent vertical slice.
5. Query affected tests, run them, rescan, and compare the baseline.
