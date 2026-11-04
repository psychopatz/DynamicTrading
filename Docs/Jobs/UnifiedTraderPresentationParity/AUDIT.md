# Audit — Unified Trader Presentation Parity

## Audit date

2026-11-04

## Verdict

The trader runtime is substantially unified, but the presentation/interaction layer is still partially split.

Native DTAbstract now shows canonical trader records, actor IDs and positions. The remaining product gap is that DTAbstract does not yet feel or behave like the same NPC/trader system exposed through DTHoomans/ProjectHoomans.

## Verified working foundation

PsychopatzCore already owns PsychopatzSurvivorWorldActorMap.lua with provider-neutral actor dots, selection, tracking, route drawing, hover integration and decorator registration.

DTCommon_TraderPresentation.lua already exposes read-only trader bindings over canonical Core actor IDs.

Core owns the generic conversation UI/session shell.

DTAbstract currently opens Core conversation UI through DTAbstract_CoreConversation.lua and DTCommon_CoreTraderConversation.lua.

Core also owns PsychopatzNotificationWindow.lua, but that surface is a rectangular modal with message/details and no actor portrait/avatar presentation.

## Remaining split systems

### DTAbstract map overlay remains separate

DTAbstract_WorldMap.lua still owns trader/discovery map presentation in addition to Core actor map responsibilities.

Final architecture must have Core render canonical actor presence once and DTCommon decorate trader actors. Provider modules must not render another trader actor marker.

### Core actor-map decorator is too limited

Core decorators currently control label, color, size and visibility. They do not provide a generic icon/emblem/badge presentation contract.

ProjectHoomans can render richer marker icons. Generic icon/emblem support must move to Core rather than making DTAbstract depend on ProjectHoomans.

### Faction presentation remains adopter-specific

Core SurvivorWorld owns canonical faction IDs/names/archetypes, but reusable faction symbol/emblem presentation is incomplete.

Only provider-neutral faction presentation should move to Core. Hoomans-specific palette/role enrichment stays in ProjectHoomans.

### Debug presentation is split

Current Dynamic Trading surfaces include DTAbstract_DebugHub/DebugTraderWindow, DTHoomans_DebugTraderWindow, and shared DTCommon_TraderDebug.

Shared commands exist, but manager/window/model presentation is still provider-specific.

### Talk is still behaviorally split

DTCommon_CoreTraderConversation.lua currently creates a small hardcoded graph: trade, destination, origin, road news and goodbye.

ProjectHoomans has richer conversation/semantic lifecycle and presentation.

Because DTAbstract cannot depend on ProjectHoomans, the fix is not to import PNC. Audit what trader-relevant semantic/conversation authority is already in Core/DTCommon, then move only remaining provider-neutral trader interaction pieces to shared authority.

Both providers must use one DTCommon trader conversation contract.

### Notification presentation is incomplete

DTAbstract debug/nearby feedback uses PsychopatzCore.Notifications.Show(), producing the large rectangular modal shown in native testing.

Required native behavior is a compact actor/trader toast:
- circular portrait/avatar;
- trader name;
- short status message;
- optional faction/emblem badge;
- bounded queue;
- non-blocking lifecycle.

This belongs in Core as a generic actor notification primitive.

## Explicit non-goals

- no DTAbstract dependency on ProjectHoomans or PNC;
- no simultaneous DTAbstract + DTHoomans;
- no second actor registry;
- no second actor-dot system;
- no second conversation UI;
- no duplicated faction identity in DTCommon;
- no old-save repair in this goal;
- no reopening MarketSense catalog authority unless a regression requires it.
