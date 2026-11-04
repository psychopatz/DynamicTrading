# Progress — Unified Trader Presentation Parity

## Parent status

PLANNED — native audit complete, implementation not started.

## Verified current truth

Fresh-save DTAbstract native testing now proves:
- canonical traders spawn successfully;
- canonical Core actor IDs are present;
- positions are projected;
- queued spawn completes;
- map actor projection exists;
- MarketSense stock-seeding performance is no longer the blocker.

Current native parity defects:
- map trader presentation differs from ProjectHoomans;
- faction/trader symbol presentation is incomplete;
- provider-specific trader debug manager still exists;
- Talk does not produce the expected functional shared interaction;
- spawn/nearby feedback uses the rectangular modal notification surface;
- DTAbstract still contains presentation paths that should be shared.

## Current phase

P0 — Characterize parity and lock regressions.

## Immediate Next Chunk

Start with a source-backed parity matrix before moving code.

Mandatory first chunk:
1. compare Core ActorMap vs PNC MapLayer_Travel and identify only generic capabilities missing from Core;
2. compare DTAbstract and DTHoomans trader debug windows/models/actions;
3. trace both Talk paths from button to authorization to conversation definition to action execution;
4. trace current notification calls and portrait inputs;
5. add fail-first tests for:
   - trader actor icon/emblem decorator;
   - one-marker invariant;
   - compact actor notification with portrait;
   - shared trader debug model;
   - shared conversation definition/open contract.

Then continue automatically through P1–P7.

## Accepted foundation — do not reopen without regression evidence

- canonical Core actor identity/projection;
- DTCommon trader binding;
- non-blocking shared trader debug spawn;
- DTAbstract zero-body provider semantics;
- DTHoomans physical provider semantics;
- MarketSense canonical catalog authority;
- provider exclusivity.

## Known production surfaces

PsychopatzCore:
- PsychopatzSurvivorWorldActorMap.lua
- PsychopatzSurvivorWorldClient.lua
- actor/faction presentation modules
- PsychopatzNotificationWindow.lua
- Core conversation UI/session
- Core Debug Hub

DynamicTrading:
- DTCommon_TraderPresentation.lua
- DTCommon_TraderDebug.lua
- DTCommon_CoreTraderConversation.lua
- DTAbstract_WorldMap.lua
- DTAbstract_CoreConversation.lua
- DTAbstract/UI/DTAbstract_DebugHub.lua
- DTAbstract/UI/DTAbstract_DebugTraderWindow.lua
- DTHoomans/DTHoomans_DebugTraderWindow.lua
- DTHoomans conversation bridge/integration

ProjectHoomans reference:
- PNC_MapLayer_Travel.lua
- faction/emblem presentation
- conversation definition/lifecycle/semantic extensions
- Hoomans debug models/windows.

## Remaining phases

- P0 characterization/fail-first;
- P1 Core map/faction primitives;
- P2 shared trader presentation/map;
- P3 actor notification/toast;
- P4 shared trader debug manager;
- P5 conversation parity;
- P6 cleanup/source audit;
- P7 full validation/native handoff.
