# DTAbstract World Simulation & Presentation

## Parent objective

Turn **DTAbstract** into a real standalone abstract trader-world provider while preserving DTCommon economic authority, PsychopatzCore actor authority, and optional DTHoomans physical representation.

## Current status

**REOPENED — native testing on 2026-11-03 exposed developer-side integration gaps.**

The initial P0–P7 implementation added useful foundations and the DynamicTrading smoke suite currently passes, but the parent goal is **not** developer-side complete. The current source still violates the intended one-Core-map-host architecture and several tests prove isolated helper behavior rather than production client/server integration.

See `AUDIT.md` and `PROGRESS.md` for the current evidence.

## Completion boundary

The job is complete only when all of the following are true in production wiring, not merely direct Lua helper calls:

- DTAbstract creates and maintains bounded standalone abstract traders.
- Canonical trader/Core actor identity and journey state survive real save/reload.
- Server-authoritative actor/world projections required by clients are actually synchronized to clients.
- One generic PsychopatzCore vanilla-world-map host owns the `ISWorldMap` integration.
- ProjectHoomans and DTAbstract register map layers/tools through that Core host; no parallel map monkey patches remain.
- DTAbstract traders and settlement markers render from authoritative synchronized state.
- Nearby detection uses the same synchronized projected position as map/debug presentation and produces bounded notifications.
- A real DTAbstract Trader Manager UI exists and exposes the documented actions.
- Debug command results are received and shown to the user separately from gameplay discovery notifications.
- `Spawn At` honors the requested position.
- Hybrid DTAbstract ↔ DTHoomans handoff is driven by production orchestration, not only by a synthetic adapter test.
- Merchant stock/budget remains DTCommon-owned and physical bodies remain Hoomans-owned.
- No legacy duplicate map host/toolbar ownership remains after migration.
- Performance remains bounded and no per-frame full-world scan is introduced.

## Ownership summary

```text
PsychopatzCore
  generic actor/world/provider state
  generic synchronized client projection
  one generic world-map overlay/tool host
  generic notifications/debug host
        |
        +--------------------+
        |                    |
ProjectHoomans           DynamicTrading
Hoomans-specific         DT-specific
map layers/tools         trader/settlement layers
physical bodies          abstract trader policy
        |                    |
        +---- shared actor/provider identity ----+
```

DTAbstract must still work without ProjectHoomans/DTHoomans.

## Document map

- `AUDIT.md` — current source-backed findings and reopened gaps.
- `ARCHITECTURE.md` — stable ownership and migration invariants.
- `ROADMAP.md` — mandatory recovery phases and gates.
- `HARNESS_ACCEPTANCE.md` — evidence required before completion can be claimed again.
- `AGENT_RUNBOOK.md` — continuous execution and repository safety.
- `PROGRESS.md` — current phase, exact evidence, and immediate Next Chunk.

The conversational `/goal` bootstrap remains outside the repository.
