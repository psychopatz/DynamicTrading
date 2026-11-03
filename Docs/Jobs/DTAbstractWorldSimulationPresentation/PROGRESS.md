# Progress — DTAbstract World Simulation & Presentation

## Parent status

**REOPENED — developer-side work remains.**

The previous status “DEVELOPER-SIDE COMPLETE — P0–P7” is superseded by the 2026-11-03 audit and native screenshot evidence.

## Current repository state at re-audit

DynamicTrading:

- branch: `main`
- HEAD: `57140979111109ba620a690811484b17cbab34e2`
- ahead of `origin/main` by 9
- worktree clean before this documentation update

PsychopatzCore:

- branch: `main`
- HEAD: `23be8741ad3298ed02332a1cc40df257905fc122`
- ahead of `origin/main` by 1
- worktree clean before this documentation update

ProjectHoomans:

- branch: `main`
- HEAD: `a68dd50e3c2ec7d127cb86de02b85c2505b410aa`
- matched `origin/main`
- worktree clean at audit time

DynamicTrading full smoke suite rerun: **PASS 50/50**.

That green suite is retained as foundation evidence, not final integration acceptance.

## What is genuinely implemented

- Core canonical projected journey position.
- DTCommon bounded settlement directory.
- DTAbstract server lifecycle.
- exactly-once settlement visit path in focused tests.
- DTAbstract map marker model/render helper.
- nearby discovery/hysteresis algorithm.
- server debug command helpers.
- Core Debug Hub tool registration.
- compatible abstract/physical provider adapters.
- codec-level registry persistence proof.
- bounded population/performance smoke.

## Reopened gaps

### Map ownership/integration

- Core has no production `PsychopatzCore.MapOverlayRegistry`.
- ProjectHoomans still owns active `PNC.MapLayers` + `PNC_MapToolbar` world-map host.
- DTAbstract has its own fallback `ISWorldMap.render` patch.
- this violates the earlier one-Core-registry migration contract.
- DTAbstract fallback installation depends on `ISWorldMap` already existing at module load.

### Client authority projection

- server actor/journey registry is not production-synchronized to a separate client presentation store.
- current map/discovery/debug tests share one in-process registry and therefore hide this gap.

### Debug Manager

- Debug Hub registration exists.
- `DebugHub.Open()` only returns `true`.
- no actual manager window/list/buttons exist.
- server debug results have no DTAbstract client receiver/presentation.

### Persistence

- registry codec works.
- no production DTAbstract/Core save/load lifecycle was found for these standalone actor records.

### Handoff

- adapters can be manually sequenced.
- no production runtime orchestration drives materialization/dematerialization.

### Settlement integration

- DTCommon directly special-cases `PNC.Communities` instead of using only the provider seam.
- standalone defaults are fixed Knox trading hubs; generated Hoomans settlements are a separate concept and need explicit adapter/policy.

### Debug action mismatch

- `SpawnAt` routes through near-player spawn while the server ignores supplied explicit position.

## Phase status

- Original P0: accepted foundation.
- Original P1: partial foundation.
- Original P2: partial.
- Original P3–P7: reopened.
- Active recovery roadmap: **R0–R7**.

## Current phase

**R0 — Recovery baseline and fail-first integration coverage**

## Immediate Next Chunk

1. Re-verify current source/SHAs and preserve the clean baseline.
2. Add fail-first tests for:
   - one Core production map host;
   - no parallel DTAbstract/Hoomans map monkey patches;
   - mixed load-order registration;
   - split server/client actor projection;
   - real Debug Manager UI construction;
   - debug result receiver;
   - explicit Spawn At;
   - production persistence entry points;
   - production provider-handoff orchestration.
3. Audit all ProjectHoomans map-host callers before moving generic host/toolbar responsibilities.
4. Define the minimal Core map overlay/tool registration API.
5. Define the minimal bounded Core actor presentation sync contract.
6. Update this ledger with exact failing evidence.
7. Continue automatically into R1.

## Remaining mandatory work

- R1 Core map host + Hoomans/DTAbstract migration.
- R2 authoritative actor presentation sync.
- R3 production persistence + settlement-provider cleanup.
- R4 real DTAbstract Trader Manager + debug result presentation.
- R5 nearby discovery over synchronized projection.
- R6 production provider-handoff orchestration.
- R7 legacy cleanup + cross-repo regression + native handoff.

Do not mark this parent goal developer-side complete until all R0–R7 gates pass.
