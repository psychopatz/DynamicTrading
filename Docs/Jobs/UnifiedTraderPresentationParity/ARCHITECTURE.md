# Architecture — Unified Trader Presentation Parity

## Core rule

DTAbstract and DTHoomans represent the same logical Dynamic Trading trader system.

Only presence differs:

- DTAbstract: canonical Core actor and trader exist, but no visible body is materialized.
- DTHoomans: the same shared contracts apply, but the provider may materialize a ProjectHoomans body.

Presentation, identity, map, debug, notification payload, and trader conversation
content must not fork by provider. Visibility policy may still follow presence:

- DTAbstract uses compact actor notifications because no world NPC body exists.
- DTHoomans relies on the visible, interactable NPC plus manager/log feedback and
  does not emit a redundant trader lifecycle toast.

## Ownership

### PsychopatzCore owns generic primitives

Core owns reusable provider-neutral primitives for:

- canonical actor projection;
- portrait spec;
- actor-map rendering;
- selection/highlight/tracking;
- route rendering;
- generic marker icon/emblem rendering;
- canonical faction presentation spec when generic;
- generic conversation UI/session shell;
- generic actor notification/toast;
- Debug Hub host and shared UI components.

Core must not contain Dynamic Trading business policy.

### DTCommon owns trader presentation and interaction policy

DTCommon owns:

- trader-to-actor binding view;
- trader display identity;
- commercial/trader badge;
- faction/community presentation lookup through Core;
- trader map decorator;
- trader notification payload builder;
- shared trader debug model/actions;
- shared trader conversation extension/content;
- Trade action entry;
- destination/origin/news commercial content;
- trader discovery/commercial state.

DTCommon must not own a second canonical actor/faction registry.

### DTAbstract owns only abstract-provider behavior

Allowed:
- provider state;
- remote authorization;
- abstract spawn/travel logic;
- zero-body presence semantics.

Not allowed as final architecture:
- its own trader map renderer;
- its own trader debug manager;
- its own notification widget;
- its own trader conversation definition.

### DTHoomans owns only physical-provider behavior

Allowed:
- materialization;
- physical interaction anchor;
- provider-specific body diagnostics;
- ProjectHoomans integration.

Not allowed as final architecture:
- separate trader conversation content;
- separate Dynamic Trading trader manager;
- separate trader marker identity model.

### ProjectHoomans

ProjectHoomans remains reference evidence and a consumer.

Generic actor/faction primitives found there move to Core only if truly provider-neutral.

PNC-specific social, combat, companion, animation and Hoomans gameplay remain in ProjectHoomans.

## Shared trader presentation model

Expand DTCommon_TraderPresentation into a read-only model containing:

- traderID;
- actorID;
- provider/providerState;
- displayName;
- portraitSpec;
- factionID/factionName;
- faction presentation/emblem spec;
- community ID/name;
- role/commercial status;
- position/distance;
- route/journey;
- seen/discovery state;
- talkAvailable;
- tradeAvailable;
- bounded debug diagnostics.

This is derived from canonical Core actor/faction state plus trader state. It is not persisted as another NPC record.

## Map architecture

There must be exactly one actor marker per canonical actor.

Core ActorMap remains the renderer.

Extend its decorator style to optionally support:
- icon texture or generic icon spec;
- emblem/glyph;
- badge;
- label;
- color;
- size;
- visibility;
- hover subtitle/metadata.

DTCommon registers one trader decorator against Core ActorMap.

For trader-bound actors it may add:
- trader label;
- commercial icon/badge;
- canonical faction emblem/symbol;
- trader-specific hover subtitle.

DTAbstract_WorldMap may retain non-actor discovery overlays such as settlements/signals, but must stop drawing trader actors after migration.

## Faction icon/emblem architecture

Core SurvivorWorld owns canonical faction identity.

If a generic faction presentation spec is missing, add one to Core rather than importing PNC into DTAbstract.

Generic spec may include:
- factionID;
- displayName;
- archetypeID;
- symbol/glyph/icon key;
- optional color;
- optional badge shape.

ProjectHoomans may enrich this with Hoomans-specific palette/art.

DTCommon consumes only the Core-safe generic spec.

## Notification architecture

Add a compact Core actor notification/toast.

Required:
- circular portrait/avatar from canonical portrait spec;
- title/name;
- short message;
- optional faction/emblem badge;
- optional secondary status;
- bounded queue;
- non-blocking display;
- compact dismiss/auto-dismiss behavior.

Keep the existing modal notification window for detailed system reports.

Dynamic Trading uses the compact actor toast for DTAbstract spawned/arrived/nearby/
discovered feedback. DTHoomans keeps the same payload contract available but
does not show lifecycle toasts when a physical trader is present.

## Conversation architecture

There must be one Dynamic Trading trader conversation model.

Core owns:
- conversation UI;
- generic session lifecycle;
- provider-neutral semantic/runtime primitives already migrated there.

DTCommon owns:
- trader content and actions;
- Trade entry;
- destination/origin/news;
- commercial identity;
- faction/community presentation;
- trader-specific semantic/actions.

Provider adapters resolve only authorization and target anchoring.

DTAbstract and DTHoomans both call the same DTCommon trader conversation-open contract.

Do not keep a DTAbstract-only static graph if DTHoomans uses a different content path.

If ProjectHoomans contains provider-neutral trader conversation pieces, move them to DTCommon or Core according to ownership. Do not migrate Hoomans-only companion/social/combat behavior.

## Debug architecture

Create one shared Dynamic Trading Trader Manager in DTCommon using Core Debug Hub/UI components.

Common actions:
- refresh;
- spawn near;
- spawn at player;
- force tick;
- map/focus;
- teleport;
- talk;
- force arrival;
- mark/reset seen;
- remove;
- inspect actor;
- inspect faction/community/journey;
- inspect provider/presence.

Provider extensions may add bounded presence-specific diagnostics.

After acceptance remove provider-specific Dynamic Trading manager windows and duplicate action wiring.

## Performance

Parity must not add significant overhead.

- map decorators operate only on projected actors;
- no per-frame full trader/faction scan beyond bounded projected actor list;
- cache presentation rows by relevant revisions;
- notification uses existing portrait projection;
- debug expensive work runs only while debug UI is open;
- conversation model builds only on interaction.

## Exclusivity

Keep:
- DTAbstract + DTHoomans forbidden;
- DTAbstract + ProjectHoomans forbidden;
- DTHoomans requires ProjectHoomans.

## Cleanup rule

Do not finish with old and new presentation paths both active.

After shared replacements pass:
- remove abstract-only trader actor-map rendering;
- remove provider-specific trader debug windows;
- remove obsolete DTAbstract-only conversation definition/path;
- stop using the modal trader notification for ordinary spawn/nearby feedback;
- update tests to shared contracts.
