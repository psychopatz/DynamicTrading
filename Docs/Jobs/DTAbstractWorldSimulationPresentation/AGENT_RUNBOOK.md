# Agent Runbook — DTAbstract World Simulation & Presentation

## Mission

Repair and complete the reopened DTAbstract parent objective.

The 2026-11-03 source/native audit supersedes the previous “P0–P7 developer-side complete” status.

After each accepted recovery chunk:

1. update `PROGRESS.md`;
2. select the next mandatory recovery phase;
3. continue automatically;
4. stop only for a genuine blocker or full R0–R7 developer acceptance.

## Read order

1. DynamicTrading root `AGENTS.md`;
2. this runbook;
3. `README.md`;
4. `AUDIT.md`;
5. `ARCHITECTURE.md`;
6. `ROADMAP.md`;
7. `HARNESS_ACCEPTANCE.md`;
8. `PROGRESS.md` last.

Before editing Core/Hoomans, read each repository's root `AGENTS.md` and inspect branch/upstream/worktree state.

## Mandatory recovery rules

- Preserve useful P0–P7 foundation; do not rewrite working economic/provider primitives without evidence.
- PsychopatzCore must own the one generic production world-map host.
- ProjectHoomans and DTAbstract register into that host; neither keeps a parallel generic `ISWorldMap` patch.
- Hoomans-specific layers/policy stay in Hoomans.
- DT-specific marker policy stays in DTAbstract.
- Client map/debug/discovery must consume an authoritative synchronized projection, not assume the server actor registry exists client-side.
- Production persistence must call real save/load lifecycle entry points.
- Debug Hub registration is insufficient; the DTAbstract Trader Manager must be a real usable UI.
- Debug command feedback and gameplay nearby notification remain distinct.
- Provider handoff must be driven by production orchestration.
- DTCommon must not special-case PNC globals when a provider seam exists.
- Merchant stock/budget never move into Core actor personal inventory.
- Do not create a second intrinsic pricing system.
- No per-frame full-world scan.

## Test discipline

Prefer fail-first tests that reproduce actual integration gaps.

Do not claim:

- map integration from direct renderer calls;
- multiplayer/client correctness from one-process shared tables;
- persistence from manual codec invocation;
- UI completion from helper functions;
- handoff completion from handwritten adapter sequencing;
- native success from mocks.

Use split authority/client fixtures where network separation matters.

## Cleanup discipline

Once consumers are migrated, remove obsolete active infrastructure rather than leaving permanent legacy copies.

Before deletion:

- enumerate callers;
- migrate them;
- run focused regressions;
- verify no load-order fallback still references the old seam.

Do not delete adopter-specific behavior just because the generic host moves to Core.

## Git

- existing `main` only;
- preserve unrelated user work;
- no blind pull;
- no force/reset/destructive rebase;
- no automatic stash/discard;
- coherent commits per owner repository;
- no push/publication unless explicitly authorized and safe.

## Final report

Report:

- recovery phases accepted;
- exact production wiring changed;
- legacy files removed/reduced and why;
- split client/server evidence;
- production persistence evidence;
- UI evidence;
- provider orchestration evidence;
- full regression counts;
- repository SHAs/publication state;
- remaining native SP/MP matrix.
