# DTAbstract World Simulation & Presentation

## Parent objective

Turn **DTAbstract** from a remote/radio access adapter into a real standalone abstract trader-world provider while preserving the existing Dynamic Trading economy and the optional DTHoomans physical representation.

The completed developer-side system must make the following true:

- DTAbstract can create/maintain abstract trader actors without requiring Project Hoomans or DTHoomans.
- Abstract traders have authoritative world positions and bounded travel between valid trading settlements.
- Standalone trading settlements have authoritative IDs, names and coordinates through a data/provider contract rather than UI-only hard-coding.
- The vanilla world map can show DTAbstract traders and trading settlements using their real simulation coordinates.
- A moving trader marker represents current journey progress rather than remaining frozen at the origin.
- Nearby trader discovery is bounded, marks the trader known as appropriate, and produces a one-shot/cooldown notification through the existing PsychopatzCore notification surface.
- DTAbstract has a dedicated Psychopatz Debug Hub tool, including a server-authoritative **Spawn Abstract Trader Near Player** action and explicit spawn-result feedback.
- Debug controls can inspect, locate/show, teleport to, advance, force-arrive and remove/test abstract traders without calling the DTHoomans live-caravan debug path.
- When the physical Hoomans integration is available, one canonical trader/actor can hand off between DTAbstract and DTHoomans without duplicate identities, stock, journeys or bodies.
- Existing DTCommon merchant stock, MarketSense pricing, settlement markets, radio/Talk, persistence and transaction authority do not regress.
- Work remains bounded and event/interval driven; no per-frame all-trader/world scan is introduced.

## Product interpretation

DTAbstract currently means "abstract access." This job makes it a genuine **abstract simulation provider**.

The target relationship is:

```text
                  DTCommon
        trader / market / commerce authority
                     |
          canonical trader + Core actor
                     |
          +----------+----------+
          |                     |
      DTAbstract             DTHoomans
  abstract representation   physical representation
  world travel + map        bodies / live interaction
          |                     |
          +------ provider handoff
```

DTAbstract must still work when DTHoomans/Project Hoomans are absent.

## Document map

- `AUDIT.md` — source-verified baseline and missing behavior.
- `ARCHITECTURE.md` — ownership, identities, settlement directory, simulation, map/discovery and handoff contracts.
- `ROADMAP.md` — complete mandatory implementation phases and gates.
- `HARNESS_ACCEPTANCE.md` — deterministic, integration, persistence, performance and native acceptance requirements.
- `AGENT_RUNBOOK.md` — execution order, repository safety and continuous-roadmap rules.
- `PROGRESS.md` — current evidence and immediate starting chunk.

The conversational `/goal` bootstrap is intentionally not checked into the repository.
