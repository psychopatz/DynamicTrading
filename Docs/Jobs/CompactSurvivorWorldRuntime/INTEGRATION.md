# DynamicTrading Integration — Compact Survivor World Runtime

Authoritative parent goal: PsychopatzCore `Docs/survivor_world_runtime/`.

DynamicTrading remains the economic domain adopter.

## DynamicTrading responsibilities retained

DTCommon owns:

- trader role mapping;
- stock/budget;
- pricing/quotes/trades;
- settlement market/exchange;
- trader commercial policy.

DTAbstract remains a lightweight interaction/representation adapter.

## Migration responsibilities

- stop using static Kentucky settlement defaults as active survivor-world authority once Core Survivor World is available;
- bind traders to canonical Core actors/groups/communities/factions;
- consume shared Core per-actor map/discovery/debug presentation;
- preserve UnifiedTraderWorldRuntime exactly-once commercial invariants;
- keep merchant stock separate from actor personal inventory;
- do not add ProjectHoomans as a required DTAbstract dependency.

## Repository safety

Preserve the two unrelated unstaged mod.info edits currently present in DTAbstract and DTHoomans.

## Execution

Read DynamicTrading root AGENTS.md, then the authoritative Core job docs. Parent phase/progress truth stays in Core. Do not recreate a second world-model roadmap here.
