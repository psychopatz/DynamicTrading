# Unified Trader Presentation Parity

## Objective

Make DTAbstract and DTHoomans use the same Dynamic Trading presentation, interaction, debug, map, notification, and conversation contracts.

The only intended behavioral difference is presence/materialization:

- DTAbstract: canonical Core actor/trader remains abstract and never creates a visible world NPC body.
- DTHoomans: the same canonical actor/trader may be materialized through ProjectHoomans.

Everything else that is trader-facing should converge on shared systems.

## Native evidence

Fresh-save native testing now proves that DTAbstract trader creation itself can succeed:

- canonical trader:world:* records exist;
- canonical Core actor IDs and real positions are present;
- shared queued spawning completes;
- Core map actor projection exists;
- the previous MarketSense stock-seeding stall has been removed.

Remaining native defects:

1. map presentation is visually/functionally different from ProjectHoomans;
2. trader/faction marker symbols are not presented with Hoomans-style faction identity;
3. DTAbstract still exposes its own Abstract Trader Manager/debug flow;
4. Talk does not complete into the expected shared conversation experience;
5. DTAbstract uses a rectangular modal notification rather than a compact actor/trader notification with portrait;
6. trader-facing behavior is still partially provider-specific.

## Parent completion boundary

This goal is complete only when:

1. one shared DTCommon trader presentation/view-model contract feeds both providers;
2. Core owns provider-neutral actor map, portrait, icon/emblem, notification, conversation-shell and Debug Hub primitives;
3. trader map markers use the same canonical actor and faction presentation under both providers;
4. one shared Dynamic Trading trader debug model/window/actions serves both providers;
5. Talk uses one shared trader conversation path and opens the real shared conversation UI;
6. one shared actor/trader toast shows a circular portrait and compact status feedback;
7. obsolete DTAbstract presentation substitutes are removed;
8. obsolete DTHoomans Dynamic Trading presentation duplicates are removed;
9. provider-specific code is limited to presence/materialization and unavoidable provider transport;
10. regression, Kahlua, source-removal, and native acceptance gates pass.

## Repository scope

Primary:
- /home/psychopatz/Zomboid/Workshop/DynamicTrading

Shared primitive work:
- /home/psychopatz/Zomboid/Workshop/psychopatzCore

Reference adopter / migration surface:
- /home/psychopatz/Zomboid/Workshop/ProjectHoomans

ProjectHoomans is a reference adopter, not a runtime dependency of DTAbstract.

DTAbstract remains mutually exclusive with both ProjectHoomans and DTHoomans.

## Status

PLANNED — native audit complete, implementation not started.

Start with P0 in ROADMAP.md and PROGRESS.md.
