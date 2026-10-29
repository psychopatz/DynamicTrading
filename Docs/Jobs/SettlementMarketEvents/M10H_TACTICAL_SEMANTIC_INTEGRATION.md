# M10H — Tactical Bearing + Semantic Scene Integration

## Purpose

Extend the accepted reusable spatial system with observer-relative tactical bearings and connect those facts to the **current Project Hoomans semantic runtime**.

This phase must not create a parallel combat-bark engine.

The production integration target is:

```text
authoritative combat/perception transition
        ↓
ephemeral tactical spatial projection
        ↓
existing semantic opportunity / Interaction Scene
        ↓
existing semantic realization / ambient presentation
```

The same authoritative danger fact may be presented to an NPC team through the Interaction Scene Runtime and to nearby players through the existing ambient semantic-reaction surface.

## Audited production seams

Audit baseline:

- PsychopatzCore local/main = origin/main at `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`;
- Project Hoomans local/main = origin/main at `ac4fa3f8dae5890057190cfa0694690188010f1f`; the Semantic Scene Observatory/runtime-acceptance work is published and the worktree is clean;
- DynamicTrading local/main = origin/main at `704943d121ddb625586acd9a8f11c9d3fb7778ae`, with the unrelated local `DTHoomans_Conversation.lua` edit preserved.

### Existing semantic danger path

Production horde awareness already follows:

```text
PNC_ZombieObservation
    ↓
SocialEventHooks.ObserveZombieHorde
    ↓
InteractionSceneAdopters.OnHordeTransition
    ↓
DANGER_CHANGED
    ↓
projecthoomans.scene.combat_horde
    ↓
COMBAT_HORDE_ALERT
    ↓
Semantic Interaction Scene
```

The same authoritative horde transition also feeds the existing player-heard ambient semantic reaction path through `emitZombieAwareness(...)`.

Therefore M10H must enrich this event flow rather than introducing a third presentation system.

### Existing multi-NPC behavior

The current Scene Runtime already provides:

- local combat-cohort participant selection;
- event-driven opportunity admission;
- cooldown/dedupe;
- semantic continuation;
- brave/cautious/steady responses;
- observer-only player audience;
- bounded Scene Observatory diagnostics.

M10H should preserve those semantics.

The first line becomes more grounded; the conversation model does not change.

### Existing threat geometry

Do not add another zombie scan.

Hoomans already has reusable bounded geometry/selection data including:

- `record.runtime.target` for an acquired immediate combat target;
- proximity/group-alert target coordinates;
- `PNC.CombatTactics.Internal.BuildZombieThreatCentroid(record, radius)` for a current zombie cluster/horde;
- existing Perception candidate caches and visible-zombie frames.

For horde callouts, prefer the already-bounded threat centroid when it is current and non-empty.

For a single selected zombie, use the authoritative selected target.

For hostile humans, use the authoritative combat target/transition once a generic target-acquisition semantic notification seam exists.

### Existing facing seam

Materialized Hoomans bodies expose live facing through:

```lua
body:getForwardDirection()
```

Existing pathing/facing state also contains bounded last-facing information.

M10H must centralize one Hoomans-owned facing resolver rather than allowing combat/semantic consumers to repeat engine-facing extraction.

## Reference frames

Keep the two spatial reference frames explicit.

```text
WORLD_CARDINAL
    stable world/place relation
    "Riverside is northeast of us."

OBSERVER_HEADING
    immediate egocentric/tactical relation
    "Zombies, eight o'clock!"
```

Do not convert a world-cardinal bearing into a clock hour without a trustworthy observer heading.

## Core contract

PsychopatzCore extends the existing `PsychopatzCore.SpatialRelation` module.

Conceptual API:

```lua
SpatialRelation.RelativeToHeading(
    observerPoint,
    targetPoint,
    headingVector,
    options
)
```

Required output includes:

```text
dx / dy / dz
distance
sameArea
relativeAngle
clockHour
clockToken = CLOCK_01 ... CLOCK_12
relativeSector8
optional distanceBand
```

Clock convention:

- 12 = forward;
- 3 = right;
- 6 = behind;
- 9 = left;
- twelve equal 30-degree sectors;
- deterministic boundary behavior.

Core does not know NPCs, zombies, hostiles, Scene Runtime, or speech style.

## Hoomans facing authority

Create/reuse one public Hoomans-facing projection.

Conceptually:

```lua
PNC.ActorFacing.Resolve(record, options)
```

The exact module/API name should follow current Hoomans conventions.

Result should distinguish at least:

```text
heading vector
source
trustworthy/current status
```

Preferred source:

1. live materialized body `getForwardDirection()`;
2. existing bounded cached/last-facing state only when its owner considers it current enough;
3. otherwise unavailable.

No trustworthy heading means no clock result.

Abstract/offscreen actors normally omit clock-face language unless explicit authoritative heading state exists.

## Tactical spatial projection

Add one reusable Hoomans semantic/combat projection for an already-selected perceived threat.

Conceptual input:

```text
observer record
threat kind/ref
target point or current centroid
freshness metadata
```

The projection resolves:

```text
observer current point
+ authoritative observer heading
+ current selected threat point
→ PsychopatzCore observer-relative relation
```

Conceptual result:

```text
targetKind
targetRef
positionSource
headingSource
clockHour
clockToken
relativeSector8
distance
distanceBand
observedAt / freshness
```

This is ephemeral presentation context.

Do not persist `CLOCK_08` as durable knowledge.

## Horde integration

`PNC_ZombieObservation` remains the canonical pressure/count observer.

`SocialEventHooks.ObserveZombieHorde` remains the horde-episode transition owner.

On the authoritative horde transition:

1. resolve a current horde target/centroid through existing bounded perception/tactics data;
2. resolve current speaker heading;
3. compute observer-relative facts through Core;
4. attach a bounded spatial projection to the danger event/context;
5. feed the same projection into both existing semantic presentation surfaces.

Conceptual event shape:

```text
danger.kind = zombie_horde
danger.pressureBand = horde
danger.nearbyCount = 8
danger.phase = started

danger.spatial.targetKind = zombie_group
danger.spatial.clockToken = CLOCK_08
danger.spatial.relativeSector8 = REAR_LEFT
danger.spatial.distanceBand = NEAR
danger.spatial.headingSource = live_body
```

If geometry/facing is unavailable, the horde alert still works but omits clock data.

## Interaction Scene integration

Do not add a new Scene Runtime provider solely for clock callouts.

Reuse:

```text
projecthoomans.scene.combat_horde
COMBAT_HORDE_ALERT
```

The initial horde warning should consume the dynamic tactical spatial arguments.

Existing continuation remains:

```text
grounded horde warning
    ↓
COMBAT_HORDE_REPLY
    ↓
brave / cautious / steady semantic response
```

Example:

> "Zombies, eight o'clock! Fight or fall back?"

followed by existing personality/behavior-driven responses such as:

> "Fuck yeah. We take them."

or:

> "Fuck... too many. Back."

M10H must not turn those continuations into fixed scripts.

## Ambient semantic reaction integration

The existing `emitZombieAwareness(...)` path remains valid for nearby player-heard semantic speech.

Feed the same bounded spatial fact into its existing context / semantic event facts.

Do not independently recalculate a contradictory bearing in the presentation layer.

The ambient path and Scene path should therefore agree on the canonical threat relation for the same event/speaker snapshot.

## Hostile-human integration

The audit found no equivalent production semantic "hostile acquired/spotted" transition for human combat targets.

Do not insert dialogue logic directly inside target mutation.

If implementation confirms no generic target-transition notification already exists, add the smallest reusable observer/listener seam around the existing authoritative target write path:

```text
BehaviorCommon.SetCombatTarget
    ↓
generic target-acquired/changed notification
    ↓
semantic combat-awareness adopter
```

The notification should carry only bounded target identity/kind/current coordinates/source/freshness needed by observers.

It must not make Combat depend on Semantics.

Semantic consumers then decide whether the newly acquired target deserves a callout.

This should support:

```text
zombie
human hostile
future threat types
```

without target-type branches in Core spatial math.

## Semantic realization policy

Do not make one universal "military NPC" boolean.

Reuse existing semantic context:

- `CombatReactionProfile`;
- `SpeechStyleContext`;
- traits such as veteran/disciplined fighter where relevant;
- current combat/urgency context;
- relationship/team context;
- existing faction/archetype role information when authoritative.

Clock-face wording is a presentation preference.

Possible realization from one canonical fact:

```text
TACTICAL/CLOCK
"Zombies, eight o'clock!"

COARSE
"Zombies behind us, left side!"

URGENT/MINIMAL
"Behind us!"
```

Core owns none of those sentences.

## Dynamic content composition

Do not create twelve separate semantic concepts for twelve hours.

Use one semantic threat-alert concept with dynamic arguments such as:

```text
threatLabel
clockLabel
relativeLabel
distanceLabel
```

CodeBuilder/translation source may provide bounded phrase families such as:

```text
"{threat}, {clock}!"
"{threat} at {clock}!"
"{threat} {relative}!"
```

The existing generated-content pipeline remains authoritative; do not hand-edit generated Lua.

Clock labels remain canonical translation-safe Core tokens/labels.

## Anti-spam and opportunity policy

Do not speak on every perception/combat tick.

Reuse the current event-driven and `CombatBanterArbiter` infrastructure.

A tactical spatial callout may be admitted only on a meaningful transition such as:

- initial horde episode start;
- material horde escalation when the existing event path already emits;
- newly acquired/visible immediate threat;
- newly acquired hostile human;
- materially changed coarse sector after a suitable cooldown when a live alert policy explicitly allows it.

Do not add:

- per-tick chatter;
- per-NPC full-world scans;
- a second cooldown registry;
- a second speaker arbiter.

## Read-only gameplay invariant

Semantic callout generation may inspect:

- current observer geometry;
- current target/centroid;
- current perception freshness;
- current semantic/personality/style state.

It must not:

- choose a new combat target;
- retarget an actor;
- mutate movement;
- change attack/retreat policy;
- alter target ownership;
- modify horde episode truth.

## Observatory and harness contract

Extend current bounded observability rather than adding transcript logging.

The Combat/Scene observability surfaces should make the tactical decision explainable with canonical data such as:

```text
targetKind
targetRef
targetPositionSource
headingSource
clockToken
relativeSector8
distanceBand
spatialFreshness
presentationMode = clock | coarse | omitted
suppressionReason
```

Do not store/render transcript text in the Observatory.

Semantic Harness acceptance should support deterministic fixtures for:

- observer point;
- observer heading;
- target/centroid point;
- target kind;
- speaker traits/style;
- perceived/freshness state.

The harness must be able to explain why a fixture resolved to `CLOCK_08`, why it chose clock vs coarse wording, or why clock data was omitted.

## Performance invariants

- Core spatial math is O(1).
- Reuse Perception frames/candidate caches.
- Reuse the existing bounded zombie centroid helper.
- No global zombie scan.
- No full NPC scan beyond existing bounded SpatialIndex queries already used by Scene admission.
- No persistent clock-direction cache.
- No new per-frame semantic polling loop.
- No new transcript persistence.

## Phase order

### M10H-A — Core observer-relative relation

Implement/test/publish Core heading-relative clock and coarse-sector math.

### M10H-B — Hoomans facing authority

Centralize trustworthy live facing resolution and test safe omission.

### M10H-C — tactical threat spatial projection

Reuse existing selected targets / group alerts / horde centroid; no new scan.

### M10H-D — combat-awareness event enrichment

Attach bounded ephemeral spatial facts to the existing authoritative danger event and reuse them across Scene + ambient semantic reaction.

### M10H-E — semantic realization integration

Compose clock/coarse tactical language through current semantic/content/style infrastructure and preserve existing horde continuation.

### M10H-F — hostile-human + anti-spam transition coverage

Add/reuse a generic target-change notification only if production lacks one; admit human-hostile/smaller-threat callouts through existing arbiter/cooldown rules.

### M10H-G — Observatory + Semantic Harness

Expose canonical spatial decisions/suppression reasons and deterministic worker fixtures without transcript storage.

### M10H-H — published-head acceptance

Validate Core, Hoomans, Semantic Harness and DynamicTrading regressions from the exact published dependency graph.

## Completion boundary

M10H is developer-complete only when the **production semantic system** consumes observer-relative spatial facts through the existing danger/Scene/reaction paths.

A unit test that calls Core geometry directly is not sufficient.

A fixture that manually bypasses production danger/semantic integration is not sufficient.

Only after M10H-A through M10H-H pass may native SP/MP again be the sole remaining user-owned acceptance gate.
