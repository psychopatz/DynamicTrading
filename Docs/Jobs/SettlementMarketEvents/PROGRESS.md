# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M10G remains accepted; M10H Observer-Relative Tactical Bearings + Semantic Scene Integration is mandatory before native SP/MP is again the sole remaining gate.**

M10H is a bounded extension of the accepted spatial/semantic foundation. It does not reopen market simulation, trader mobility, or M10G trader whereabouts unless a regression is proven.

## Current repository truth

### DynamicTrading

- local `main` = `origin/main` at `704943d121ddb625586acd9a8f11c9d3fb7778ae`;
- unrelated local `Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua` edit remains preserved and unstaged.

### PsychopatzCore

- local `main` = `origin/main` at `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`;
- published `PsychopatzCore.SpatialRelation.Between(...)` already owns world-cardinal relation, distance, SAME_AREA, optional distance bands, and translation-safe labels;
- observer-relative/clock relation is not yet implemented.

### Project Hoomans

- local `main` = `origin/main` at `ac4fa3f8dae5890057190cfa0694690188010f1f`;
- Semantic Scene Observatory/runtime-acceptance work is now published;
- current Hoomans worktree is clean.

Recheck publication state before every cross-repo commit because concurrent work may advance this head.

## Accepted M0–M10G foundation

Preserve:

- persistent exact merchant stock;
- settlement market pressure/recovery/events/exchange;
- resident + base-less caravan trader lifecycles;
- Hoomans-owned non-admission settlement visits/excursions;
- exact-home resident return;
- production semantic trader whereabouts;
- authoritative settlement names;
- world-cardinal spatial relation;
- privacy-aware destination/direction/ETA realization;
- published dependency discipline.

Do not redo M0–M10G without evidence of regression.

## New audit — current semantic/combat integration

Detailed design: `M10H_TACTICAL_SEMANTIC_INTEGRATION.md`.

The newly accepted Project Hoomans Semantic Interaction Scene Runtime already owns the correct multi-NPC conversation surface.

Current production horde path:

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

The same horde transition also drives the existing nearby-player ambient semantic reaction path.

Therefore:

> **M10H must enrich the existing danger event with an ephemeral tactical spatial descriptor. It must not add another clock-bark engine.**

## Verified reusable Hoomans seams

### Threat geometry

Existing bounded data/helpers already include:

- `record.runtime.target` for selected immediate targets;
- proximity/group-alert target coordinates;
- `CombatTactics.Internal.BuildZombieThreatCentroid(record, radius)`;
- existing Perception frames/candidate caches.

Do not add another zombie scan.

### Heading

Materialized bodies expose:

```lua
body:getForwardDirection()
```

Existing pathing/facing state also has bounded last-facing data.

Centralize one Hoomans-owned facing resolver.

### Existing semantic continuation

The horde Scene already provides:

- `COMBAT_HORDE_ALERT`;
- brave/cautious/steady continuation;
- style/personality-aware speech behavior;
- bounded opportunity admission/cooldowns;
- observer-only nearby players;
- Scene Observatory diagnostics.

M10H grounds the threat direction; it does not replace this conversation model.

### Hostile-human gap

The audit found hostile-human kill reactions, but no equivalent production semantic **hostile acquired/spotted** transition.

`BehaviorCommon.SetCombatTarget(...)` is the authoritative combat-target write seam and already detects target changes.

Do not place semantic dialogue logic inside it.

If no generic target-change notification exists when implementation begins, add the smallest generic observer/listener notification around that authority so semantic combat-awareness can react without Combat depending on Semantics.

## Critical invariants

- 12 = ahead, 3 = right, 6 = behind, 9 = left.
- Twelve deterministic 30-degree sectors.
- Clock bearing requires a trustworthy current heading.
- No heading → no fabricated clock.
- Clock direction is ephemeral; do not persist `CLOCK_08` as durable threat knowledge.
- Recompute from current observer point + current heading + current target/centroid point.
- Core never detects/selects threats.
- Hoomans perception/combat owns target selection/grouping/freshness.
- Reuse existing Perception caches/centroid helper.
- No global zombie scan.
- No semantic per-tick polling loop.
- No third callout transport/presentation engine.
- Scene + ambient semantic reaction consume the same canonical relation snapshot for one event/speaker.
- Callout generation is read-only toward combat target, movement, attack and retreat state.
- Clock vs coarse wording is semantic presentation policy.
- Do not create twelve separate semantic concepts for twelve hours.
- Generated conversation Lua remains CodeBuilder-owned.
- Reuse `CombatBanterArbiter`/existing cooldown semantics for anti-spam.
- Observatory remains bounded/read-only/transcript-free.

## Current phase

**M10H — Observer-Relative Tactical Bearings + Semantic Scene Integration**

## Next Chunk — M10H-A: Core observer-relative relation

Start in PsychopatzCore.

### Required work

1. Read Core root `AGENTS.md`.
2. Recheck branch/HEAD/upstream/worktrees before edits.
3. Extend existing `PsychopatzCore.SpatialRelation`, not a second spatial module.
4. Add a generic public observer-heading relation API.
5. Normalize valid non-zero headings.
6. Emit:
   - relative angle;
   - `clockHour`;
   - `CLOCK_01 ... CLOCK_12`;
   - coarse egocentric sector;
   - distance/same-area;
   - optional existing distance-band behavior where appropriate.
7. Preserve verified PZ axis convention.
8. Keep clock/direction labels translation-safe and centralized.
9. Add fail-first tests for:
   - 12/3/6/9 axes;
   - all twelve sectors/boundaries;
   - `CLOCK_08`;
   - arbitrary/scaled headings;
   - observer rotation;
   - invalid/zero heading;
   - same-area suppression;
   - coarse-sector agreement.
10. Run Core spatial/composition/translation/static checks.
11. Publish Core before Hoomans depends on the new API.

### M10H-A gate

Published Core supplies one dependency-safe O(1) service for both world-cardinal and observer-heading relations.

After acceptance, update this ledger and continue automatically to M10H-B. Do not stop for another `/goal`.

## Remaining mandatory work

### M10H-B — Hoomans authoritative facing adapter

- centralize live `getForwardDirection()`;
- expose heading source/trustworthiness;
- use cached/last-facing state only when current/trustworthy;
- no reliable heading → omit clock;
- abstract/offscreen NPCs do not fabricate orientation.

### M10H-C — tactical threat spatial projection

- consume already-selected/current threat geometry;
- reuse immediate target, group alert and existing zombie centroid;
- no new scan;
- emit bounded target/position/heading/freshness + Core relation data;
- do not mutate gameplay.

### M10H-D — existing combat-awareness event enrichment

For horde production flow:

```text
ZombieObservation
→ ObserveZombieHorde
→ DANGER_CHANGED
→ existing scene/ambient semantic surfaces
```

Attach one bounded ephemeral spatial descriptor at the authoritative event boundary.

The existing `projecthoomans.scene.combat_horde` and ambient semantic reaction paths must consume the same canonical relation snapshot.

### M10H-E — semantic realization + Scene continuation

Support grounded output equivalent to:

> "Zombies, eight o'clock! Fight or fall back?"

while preserving existing brave/cautious/steady semantic continuation.

Reuse current `CombatReactionProfile`, `SpeechStyleContext`, traits, urgency and authoritative role/archetype context.

Non-tactical context may realize the same fact as:

> "Zombies behind us, left side!"

Use dynamic translated arguments, not twelve independent hour concepts.

### M10H-F — hostile-human + anti-spam coverage

If no target-transition observer exists, add the smallest generic notification around authoritative target acquisition/change.

Requirements:

- Combat does not depend on Semantics;
- newly acquired hostile human can ground a semantic callout;
- stable repeated target ticks do not spam;
- reuse existing `CombatBanterArbiter`/cooldowns;
- no per-tick semantic polling.

### M10H-G — Observatory + Semantic Harness

Expose bounded canonical diagnostics:

- target kind/ref;
- target-position source;
- heading source;
- clock token;
- coarse sector;
- distance band;
- freshness;
- clock/coarse/omitted presentation mode;
- suppression reason.

Add deterministic worker fixtures capable of explaining `CLOCK_08`, coarse fallback and omitted-clock cases without transcript storage.

### M10H-H — published-head acceptance

From exact published heads:

- Core clock suite passes;
- Hoomans heading/threat projection passes;
- production horde Scene + ambient integration passes;
- hostile-human/anti-spam coverage passes;
- Scene/Combat Observatory + Semantic Harness passes;
- M10G trader/cardinal regressions pass;
- DynamicTrading market/mobility regressions pass;
- deterministic CodeBuilder/translation checks pass if content changed;
- Lua/Kahlua/static/diff checks pass.

Record exact SHAs and publication state.

## Ownership

### PsychopatzCore

Owns generic spatial math/tokens/translation-safe labels.

### Project Hoomans perception/combat

Owns current target/group selection, geometry source, visibility/freshness, target change and live heading source.

### Project Hoomans semantic runtime

Owns opportunity admission, Interaction Scene, ambient semantic reaction, continuation, style/trait presentation, anti-spam arbitration and observability.

### DynamicTrading

No new M10H gameplay authority. Its role is regression validation because this goal/job remains the cross-repo parent.

## Completion boundary

M10H is **not** complete when Core math passes alone.

M10H is **not** complete when a formatter fixture can print "eight o'clock."

M10H is developer-complete only when the real production danger/combat transition feeds observer-relative facts into the existing semantic system, the Semantic Harness can explain the decision, and the exact published dependency graph passes regressions.

Only then may native SP/MP again be the sole remaining user-owned gate.

## Stop conditions

Stop early only for:

- genuine Git/publication conflict affecting required files;
- missing required engine orientation/target API with no safe fallback;
- authorization boundary;
- unspecified product decision that prevents safe implementation.

A completed chunk is not a stop condition.
