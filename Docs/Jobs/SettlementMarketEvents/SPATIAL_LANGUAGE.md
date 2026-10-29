# Reusable Spatial Relation & Language Foundation

## Purpose

Provide one reusable, dependency-safe mechanism that converts two world points into canonical relative spatial facts suitable for gameplay, semantic dialogue, UI, radio, gossip, quests, debug tools, and future systems.

The first concrete consumer is the community-excursion semantic question:

> "Where is your trader?"

A knowledgeable settlement local should be able to ground an answer with:

- the canonical destination settlement name;
- the destination's relative direction from a meaningful reference point;
- optional coarse distance;
- expected return when known.

Example semantic meaning:

```text
trader = away
reason = trading_run
destination = Riverside Collective
direction = NORTHEAST
distanceBand = MEDIUM
expectedReturn = tomorrow
```

Wording remains semantic realization responsibility.

## Ownership

### PsychopatzCore owns reusable spatial mechanics

Core owns:

- point validation/normalization;
- delta and Euclidean distance;
- canonical bearing/angle representation;
- 8-way cardinal classification;
- same-area/dead-zone classification;
- optional configurable coarse-distance bands;
- localized/presentation-safe direction labels or translation keys;
- deterministic tests for coordinate orientation and opposite-direction symmetry.

Core does **not** know:

- communities;
- factions;
- traders;
- excursions;
- dialogue intents;
- semantic privacy.

### Project Hoomans owns place/reference resolution

Hoomans owns:

- resolving `community.id` to the current authoritative community record;
- canonical settlement/community display name via `community.name`;
- resolving community/site/home coordinates;
- resolving player-colony/base names through their existing authority where applicable;
- choosing the semantic reference point;
- projecting excursion whereabouts into privacy-aware semantic facts.

Do not persist duplicate destination names or directions inside the excursion record.

Persist the stable destination identity. Resolve presentation dynamically.

### Semantic/knowledge systems own disclosure and wording

Semantic/knowledge systems own:

- whether a speaker knows the destination;
- whether the exact settlement name may be disclosed;
- whether direction may be disclosed;
- whether direction should be degraded/coarsened;
- whether ETA may be disclosed;
- localized natural-language realization.

Dynamic Trading must not author a fixed sentence such as "The trader is northeast."

## Core API shape

Exact module/file names should follow PsychopatzCore conventions. Conceptually expose a shared/common module such as:

```lua
PsychopatzCore.SpatialRelation.Between(fromPoint, toPoint, options)
```

Input:

```lua
fromPoint = { x = ..., y = ..., z = ... }
toPoint   = { x = ..., y = ..., z = ... }
```

Output should be data, not only prose:

```lua
{
    dx = ...,
    dy = ...,
    dz = ...,

    distance = ...,
    angleRadians = ...,

    direction8 = "NORTHEAST",
    sameArea = false,

    distanceBand = "MEDIUM", -- optional/configurable
}
```

Safe failure for missing, NaN, infinite, or otherwise invalid coordinates is mandatory.

## Canonical direction tokens

Initial semantic vocabulary:

```text
SAME_AREA
NORTH
NORTHEAST
EAST
SOUTHEAST
SOUTH
SOUTHWEST
WEST
NORTHWEST
```

Eight-way direction is the default for dialogue. Do not force 16-way precision such as east-northeast into ordinary survivor speech.

The numeric angle may remain available so future map/navigation consumers can add higher precision without changing this contract.

## Coordinate orientation

Do not let individual consumers guess Project Zomboid's axis orientation.

During implementation:

1. verify the actual world/map coordinate convention using authoritative engine/existing map behavior;
2. freeze it in Core regression tests;
3. document it in the module;
4. make every caller consume the Core result rather than reimplementing sign logic.

The acceptance suite must explicitly prove all eight directions from known coordinate pairs.

## Same-area dead zone

Tiny coordinate differences should not produce absurd directional language.

The relation API must support a configurable local/dead-zone threshold:

```text
distance <= sameAreaThreshold
→ SAME_AREA
```

Hoomans may choose a threshold appropriate to settlement/site scale.

If two relevant settlement areas overlap or are effectively local, semantic realization can say "nearby" / "around here" rather than a compass direction.

## Coarse distance

Raw PZ tile counts should not normally appear in conversational output.

Provide either a Core helper or a configurable caller policy that maps numeric distance to bounded canonical bands such as:

```text
VERY_NEAR
NEAR
MEDIUM
FAR
VERY_FAR
```

Do not hard-code settlement gameplay thresholds inside the low-level geometry calculation. Thresholds must be supplied/configurable or live in a clearly named presentation policy.

The first M10G semantic consumer may use direction without distance if distance-band tuning is not yet trustworthy, but the reusable API should preserve numeric distance so later phrasing can add it safely.

## Localization / English labels

Simulation truth uses tokens, not hard-coded English.

A reusable presentation helper may expose localized labels/translation keys:

```text
NORTH      → north
NORTHEAST  → northeast
EAST       → east
...
```

English is the first required language presentation, but the contract must allow the existing translation system to provide other languages without changing spatial math.

Do not hard-code English strings throughout Hoomans or Dynamic Trading.

## Settlement destination presentation

For a community destination:

```text
destinationCommunityID
    ↓
PNC.Communities.Get(...)
    ↓
community.name
community.home / community.site.home
```

Use the current authoritative `community.name`; do not persist a copied destination name in excursion state.

If a destination is a player colony/base rather than a community record, resolve its canonical user-facing name through the existing Base/Settlement authority. If no trustworthy human-readable name exists, omit the name rather than leaking an internal ID.

## Semantic reference point

For the first trader-whereabouts question, the preferred relation is:

```text
speaker/home community
        ↓
destination community
```

This produces stable statements such as:

> "Riverside Collective is northeast of us."

It should not normally use the player's exact current tile as the origin, because that makes the same settlement local change directions depending on where the player stands.

Reference policy:

1. speaker's authoritative home/current community when answering about its own absent member;
2. otherwise a named/known reference place if the semantic query provides one;
3. otherwise a safe fallback such as speaker current position only when appropriate;
4. if no trustworthy origin exists, omit direction.

## Generic semantic fact

Do not create a trader-only fundamental fact.

Use a generic concept such as:

```text
COMMUNITY_ROLE_WHEREABOUTS
```

with:

```text
role = trader
```

The first provider result may conceptually contain:

```lua
{
    known = true,
    role = "trader",

    locationState = "away",
    activity = "trading_run",
    phase = "visiting",

    destinationCommunityID = "...",
    destinationName = "Riverside Collective",

    spatial = {
        direction = "NORTHEAST",
        distance = ...,
        distanceBand = "MEDIUM",
        originCommunityID = "...",
    },

    expectedReturnAt = ...,
}
```

Later the same fact model can serve:

- "Where is your medic?"
- "Where did your scout go?"
- "When will your envoy be back?"

## Privacy / knowledge degradation

Authoritative coordinates are not automatically public knowledge.

The spatial utility computes truth. Hoomans/semantic knowledge policy decides disclosure.

Examples:

### Leader / highly informed local

May know:

- exact destination settlement;
- direction;
- ETA.

### Ordinary local

May know:

- trader is away on a trading run;
- rough destination or direction;
- approximate return.

### Outsider

May know only:

- trader is unavailable / away.

The semantic layer may later deliberately degrade exact truth, for example:

```text
NORTHEAST → EAST
```

for uncertain knowledge.

Do not implement that degradation in Core geometry.

## Production semantic integration

M10G must wire the generic excursion status into the **real production semantic fact/question path**.

The acceptance cannot be satisfied by calling:

```lua
CommunityExcursionService.GetSemanticContext(...)
```

directly from a test.

The proof must drive the same semantic/NLU/fact-provider entrypoints used by player conversation.

Required intent example:

```text
"Where is your trader?"
"Where's your trader?"
"Do you know where the trader went?"
```

The semantic system should resolve this to the generic role-whereabouts fact, then obtain privacy-aware Hoomans excursion state and spatial/place presentation.

## First grounded response capability

Given:

```text
Home community:
  name = Oakridge Camp
  home = A

Trader:
  phase = VISITING
  purpose = commercial_run

Destination:
  name = Riverside Collective
  home = B

SpatialRelation(A, B):
  direction8 = NORTHEAST
```

an authorized local's semantic context must be sufficient for realization equivalent to:

> "Our trader is at Riverside Collective, northeast of here."

If ETA is known, the context may support:

> "She's at Riverside Collective, northeast of us. She should be back tomorrow."

The exact sentence is not an acceptance requirement. Grounded fact availability and correct privacy are.

## Reuse targets

The Core spatial service must remain generic enough for later consumers such as:

- "The raiders were west of town."
- "There's another settlement southeast of us."
- "The horde is approaching from the southwest."
- "Your base is east of here."
- radio/world-knowledge reports;
- quest/objective hints;
- debug tooling;
- map annotations.

Do not add those consumers during M10G unless a tiny fixture is required to prove genericity.

## Performance

- O(1) spatial math per relation;
- no world scans;
- no persisted direction cache required;
- settlement name/location lookup uses existing indexed authorities;
- no semantic query may mutate excursion/movement state;
- no raw-coordinate leak is required for ordinary dialogue output.
