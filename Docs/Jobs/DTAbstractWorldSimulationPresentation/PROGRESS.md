# Progress — DTAbstract World Simulation & Presentation

## Parent status

**IN PROGRESS — planning/audit complete; implementation has not started.**

The parent objective is not satisfied by the existing radio/remote DTAbstract adapter.

## Audited baseline

DynamicTrading:

- branch: `main`
- HEAD: `89cfe191e2258e0309ba290db6eeda9931834272`
- upstream matched `origin/main`;
- worktree was clean when these goal docs were created.

Source-verified current DTAbstract foundation:

- Core provider adapter exists;
- Radio OS abstract trader provider exists;
- world-object radio contact option exists;
- existing abstract provider tests cover an already-existing trader;
- no DTAbstract server runtime exists.

Source-verified missing product behavior:

- standalone abstract trader generation/lifecycle;
- standalone settlement geography/directory;
- abstract journey driving;
- moving trader world-map markers;
- settlement world-map markers;
- nearby detection;
- nearby gameplay notification;
- dedicated DTAbstract spawn/debug tooling;
- production provider-handoff orchestration.

## Accepted reusable foundation

Do not rewrite:

- DTCommon trader registry/service/merchant stock;
- MarketSense valuation/taxonomy authority;
- settlement markets/exchange;
- existing Core actor/provider contracts;
- existing DTAbstract Radio OS/Talk/trade adapter behavior;
- DTHoomans physical trader/caravan behavior except for narrow provider integration required by P6;
- existing PsychopatzCore notification UI.

## Current phase

**P0 — Ground truth, fail-first coverage and contracts**

## Immediate Next Chunk — P0A/P0B

1. Re-audit current source at the agent's actual HEAD and dependency revisions.
2. Add behavioral fail-first tests for the five missing product surfaces:
   - standalone DTAbstract server trader creation;
   - settlement name+position directory;
   - moving map projection;
   - nearby discovery notification;
   - dedicated DTAbstract Debug Hub spawn.
3. Audit DTHoomans roaming policy/config so the standalone population policy is deliberate rather than copied accidentally.
4. Audit the actual vanilla map hook and decide whether the smallest reusable solution is:
   - a generic Core marker-overlay host, or
   - a thin DTAbstract map adapter consuming Core/DT data.
5. Lock the settlement-directory contract and the single canonical projected-position contract.
6. Run baseline existing provider/radio/settlement tests.
7. Update this progress file with exact evidence and continue automatically into P1.

## P0 immediate acceptance

P0A/P0B are accepted only when:

- tests capture the current missing behavior and later can become green;
- standalone settlement coordinate ownership is explicit;
- map/proximity/debug share one projected-position contract;
- no PNC/Hoomans dependency is introduced for standalone mode;
- existing provider/radio behavior remains green.

## Remaining mandatory work

- P1 settlement directory + actor/world bootstrap;
- P2 standalone server lifecycle + debug-spawn foundation;
- P3 functional trader/settlement world map;
- P4 nearby discovery + notification;
- P5 dedicated DTAbstract Trader Manager;
- P6 hybrid provider handoff;
- P7 persistence/performance/regression/native handoff.

Do not mark the parent goal complete while any developer-implementable phase above remains.
