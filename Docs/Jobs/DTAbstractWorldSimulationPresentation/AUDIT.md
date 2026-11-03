# Audit — DTAbstract World Simulation & Presentation

## Baseline

Repository: `/home/psychopatz/Zomboid/Workshop/DynamicTrading`

Audited branch/revision:

- branch: `main`
- HEAD: `89cfe191e2258e0309ba290db6eeda9931834272`
- upstream: `origin/main`
- worktree was clean when this job was authored.

This audit is source/static evidence. It is not native Project Zomboid acceptance.

## Verified current DTAbstract surface

The current DTAbstract runtime contains only shared/client code:

```text
Contents/mods/DTAbstract/42.20/media/lua/
├── shared/DTAbstract/
│   ├── 00_DTAbstract_Init.lua
│   └── DTAbstract_CoreProvider.lua
└── client/DTAbstract/
    ├── 00_DTAbstract_Client_Init.lua
    ├── DTAbstract_Client.lua
    ├── DTAbstract_RadioOS.lua
    └── UI/DTA_RadioOSPreview.lua
```

There is no `server/DTAbstract` implementation.

Its current `mod.info` describes it as:

> Optional remote and radio access to Dynamic Trading traders.

That description matches the implementation.

### What works now

- `DTAbstract_CoreProvider.lua` adapts Core provider operations:
  `Project`, `Acquire`, `Materialize`, `Dematerialize`, `Release`, `Switch`.
- `DTAbstract_Client.lua` lists already-existing eligible trader records and adds radio context actions.
- `DTAbstract_RadioOS.lua` exposes eligible existing abstract traders as Radio OS contacts and delegates Talk/trade to DTCommon.
- `tests/dt_npc_provider_adapter_smoke.lua` proves the Core provider adapter can acquire/release an abstract lease and hand an actor to DTHoomans.
- `tests/dt_radio_os_abstract_provider_smoke.lua` proves an already-existing abstract trader can appear as a radio contact.

These are useful foundations. They do **not** prove that DTAbstract creates, moves, maps or discovers traders.

## Verified missing DTAbstract behavior

The current DTAbstract module has no production implementation for:

- standalone abstract trader generation;
- a server-authoritative abstract trader director/lifecycle;
- world travel progression;
- settlement location/directory ownership;
- trader world-map markers;
- trading-settlement world-map markers;
- nearby trader detection;
- nearby trader discovery notification;
- dedicated DTAbstract Debug Hub tooling;
- server-side DTAbstract debug spawn;
- map-position debug spawn;
- production policy that drives Core provider materialization/dematerialization;
- standalone-to-physical handoff orchestration.

Therefore a player seeing no DTAbstract traders/settlements on the map and no DTAbstract spawn-debug/nearby notification is consistent with the current source.

## DTHoomans is not the missing DTAbstract implementation

DTHoomans already contains the physical-caravan features that can make the absence confusing:

- `DTHoomans_CaravanLifecycle.lua` maintains roaming physical/Hoomans caravans.
- `DTHoomans_Server.lua` contains server-authoritative debug caravan spawn and sends `TraderSpawnStarted`, `TraderSpawned` and `TraderDebugActionResult`.
- `00_DTHoomans_Client_Init.lua` registers a Dynamic Trading **Trader Manager** in the PsychopatzCore Debug Hub.
- the DTHoomans manager can list/locate/teleport/open traders and drive settlement/roaming debug actions.

Those features belong to the physical provider and must not be mistaken for standalone DTAbstract coverage.

The new DTAbstract debug spawn must create/test an **abstract** trader actor and must not simply call the DTHoomans live-caravan spawn.

## Existing Core mechanisms to reuse

PsychopatzCore already provides reusable mechanisms that materially reduce the amount of new architecture required.

### Core actor world/journey

`PsychopatzActorJourney.lua` and `PsychopatzActorWorld.lua` provide:

- serializable journeys;
- origin/destination coordinates;
- abstract mode;
- start/ETA/progress;
- bounded `Advance`;
- arrival state/idempotency support;
- world location state.

One gap matters for the map: current `World.AdvanceJourney` updates the actor's stored location to the destination only when the journey arrives. A moving map marker therefore needs either a reusable Core projected-current-position query or another generic mechanism; DTAbstract must not invent a second journey math implementation.

### Core actor map data

`PsychopatzActorMap.lua` provides:

- actor map projection;
- marker/label/capability metadata;
- visibility modes;
- known-to state;
- bounded registry;
- `QueryNearby`;
- journey summary in map entries.

It is a **data registry**, not a production vanilla `ISWorldMap` renderer.

### Core notification data/UI

`PsychopatzActorNotifications.lua` provides a bounded duplicate-safe notification queue.

`PsychopatzNotificationWindow.lua` provides the reusable client presentation surface through `PsychopatzCore.Notifications.Show(...)`.

### Core provider lease

Core already owns provider lease state and validates acquire/materialize/dematerialize/release/switch transitions. DTAbstract must drive these contracts rather than invent a competing provider flag.

## Map presentation gap

Project Hoomans has mature client world-map layers/markers, but those are PNC/Hoomans presentation code and DTAbstract must remain standalone.

PsychopatzCore currently has debug world-map hooks but no general production actor/consumer marker overlay host.

Implementation must therefore choose the smallest reusable route:

1. prefer a narrow generic PsychopatzCore vanilla-map overlay/marker registration seam if extraction is justified and does not create Hoomans policy in Core; or
2. if a generic Core seam is not viable, implement a thin DTAbstract world-map adapter using Core/DTCommon data while avoiding copied PNC business/state logic.

Do not make DTAbstract depend on Project Hoomans merely to draw its map.

## Settlement geography gap

DTCommon owns settlement markets keyed by settlement/community IDs, but current DTCommon market state does not itself provide a standalone global settlement coordinate registry.

A market ID is not enough to draw a map marker or plan a journey.

The new architecture therefore requires an explicit bounded settlement-directory/provider contract with at least:

- canonical settlement ID;
- display name;
- x/y/z or resolved anchor/position;
- market profile/context where relevant;
- source/provider identity;
- availability/enabled state.

When Hoomans is present, its authoritative community identity/position can be adapted into this contract. Standalone DTAbstract must have its own approved data/provider source and must not fabricate coordinates in the UI.

## Current parent-goal conclusion

The missing behavior is not one broken map callback. DTAbstract currently stops at remote/radio access.

The correct next step is a real standalone abstract-world vertical slice using existing DTCommon economic authority and PsychopatzCore actor mechanisms, followed by map/discovery/debug/handoff integration.

The first implementation chunk must establish fail-first coverage and settle the settlement-directory + moving-position contracts before adding a visual map layer.
