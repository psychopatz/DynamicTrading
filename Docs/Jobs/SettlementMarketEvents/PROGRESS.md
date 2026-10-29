# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M10G is accepted and published; M10H Observer-Relative Tactical Bearings is mandatory before native SP/MP is again the sole remaining gate.**

M10H is a bounded extension of the accepted reusable spatial foundation. It does not reopen trader mobility, markets, or settlement semantics.

## Current repository audit

### DynamicTrading

- local `main` = `origin/main` at `20d59aad7d81116e10fc5a19262e1b1eb3dd186d`;
- unrelated local `DTHoomans_Conversation.lua` edit remains preserved and unstaged.

### PsychopatzCore

- local `main` = `origin/main` at `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`;
- published `PsychopatzCore.SpatialRelation.Between(...)` already owns world-cardinal relation, distance, SAME_AREA, optional distance bands, and translation-safe labels.

### Project Hoomans

- published `origin/main`: `656dddf42acec857a7a58ad55c4228c36250b051`;
- local `main`: `ac4fa3f8dae5890057190cfa0694690188010f1f`;
- local `main` is clean and 2 commits ahead with unrelated semantic-scene observatory/acceptance work:
  - `9231b6a1 feat: add semantic scene observatory`
  - `ac4fa3f8 feat: complete semantic scene runtime acceptance`

Do not blindly publish those commits merely to integrate M10H.

## Accepted M0–M10G foundation

Accepted published behavior includes:

- persistent exact merchant stock;
- settlement market pressure, recovery, typed events, and partial exchange;
- two trader lifecycles: resident and base-less caravan;
- generic non-admission settlement visits;
- purpose-agnostic Hoomans community excursions;
- exact-home return;
- published cross-repo dependency graph;
- production semantic trader whereabouts;
- authoritative destination settlement names;
- world-cardinal spatial language;
- privacy-aware place/direction/ETA realization.

M10G published-head evidence recorded previously:

- Project Hoomans full suite: `942/942`;
- focused Hoomans excursion/mobility/semantic set: `14/14`;
- DynamicTrading full suite: `41/41`;
- focused DynamicTrading resident/caravan/market set: `16/16`;
- Core spatial/composition/core/translation regressions passed;
- Lua/Kahlua/static/translation/diff checks passed.

Do not redo M0–M10G unless current code proves a regression.

## New user-approved extension

The reusable spatial system must also support **observer-relative tactical clock bearings** for immediate local callouts.

Examples:

> "Zombies, eight o'clock!"

> "Hostiles at three o'clock!"

This is distinct from world-cardinal direction:

```text
WORLD_CARDINAL
    used for stable places/world relations
    "Riverside is northeast of us."

OBSERVER_HEADING
    used for immediate egocentric/tactical relations
    "Zombies, eight o'clock!"
```

Clock bearing is relative to the observer's **current facing**, not north.

## Critical invariants

- 12 o'clock = directly ahead.
- 3 o'clock = right.
- 6 o'clock = behind.
- 9 o'clock = left.
- Twelve equal 30-degree sectors.
- Clock direction requires a trustworthy observer heading.
- No heading → no fabricated clock result.
- Clock bearing is ephemeral; do not persist `8 o'clock` as durable threat knowledge.
- Current observer facing and current target position determine the live callout.
- Core does not detect zombies or choose targets.
- Hoomans perception/combat owns target detection, salience, grouping, freshness, and combat eligibility.
- Semantic realization decides whether to use tactical clock wording or coarse civilian wording.
- Abstract/offscreen actors normally do not use clock language without authoritative heading state.

## Existing Hoomans orientation seam

Hoomans already reads the live materialized body's forward vector through:

```lua
zombie:getForwardDirection()
```

Existing pathing/facing code also has bounded last-facing state.

M10H should extract/reuse one authoritative Hoomans-facing adapter rather than copy this logic into every callout consumer.

## Current phase

**M10H — Observer-Relative Tactical Bearings**

## Next Chunk — M10H-A: Core heading-relative clock relation

Start in PsychopatzCore.

### Required work

1. Read PsychopatzCore root `AGENTS.md`.
2. Recheck Core local/remote status and worktrees.
3. Extend the existing published `PsychopatzCore.SpatialRelation` rather than creating a second spatial module.
4. Add a public generic observer-heading relation API, conceptually:
   ```lua
   SpatialRelation.RelativeToHeading(
       observerPoint,
       targetPoint,
       headingVector,
       options
   )
   ```
5. Normalize valid non-zero heading vectors.
6. Compute a clockwise relative angle from observer forward to target.
7. Emit:
   - `clockHour`;
   - `clockToken = CLOCK_01 ... CLOCK_12`;
   - coarse `relativeSector8`;
   - distance/same-area data.
8. Preserve the already-verified Project Zomboid world coordinate convention.
9. Add translation/presentation-safe clock tokens/labels.
10. Add fail-first tests for:
    - 12/3/6/9 principal axes;
    - representative intermediate hours including 8;
    - all twelve sectors/boundaries;
    - arbitrary/scaled heading vectors;
    - observer rotation;
    - invalid/zero heading;
    - same-area suppression;
    - coarse-sector agreement.
11. Run Core spatial/composition/translation regressions and static checks.
12. Publish Core before downstream Hoomans depends on the new API.

### M10H-A gate

Published Core provides one dependency-safe O(1) spatial service supporting both world-cardinal and observer-heading relations, with complete deterministic clock geometry tests.

After M10H-A, continue automatically to M10H-B. Do not stop for another `/goal`.

## Remaining mandatory M10H work

### M10H-B — Hoomans live heading authority

- read/reuse actual materialized body `getForwardDirection()`;
- centralize one Hoomans-facing resolver/adapter;
- only use cached facing when Hoomans considers it trustworthy/current;
- no reliable heading → omit clock relation;
- abstract/offscreen actors do not fabricate heading;
- preserve unrelated local semantic-scene commits/work.

### M10H-C — tactical target spatial projection

For an already-selected perceived target:

```text
observer position
+ authoritative observer heading
+ current target position
→ Core observer-relative relation
```

Hoomans perception/combat remains authority for:

- perceived zombies/hostiles;
- target salience;
- multiple-threat grouping/centroid choice;
- visibility/freshness;
- combat/alert eligibility.

Do not add threat scanning to Core.

Do not persist the live clock hour as durable knowledge.

### M10H-D — semantic tactical callouts

Expose reusable facts so production semantic/combat callout realization can support:

> "Zombies, eight o'clock!"

> "Hostiles at three o'clock!"

Clock wording is not universal.

Tactical/guard/military/raider/urgent coordinated contexts may prefer clock-face speech.

Other speakers may consume the same fact as:

> "Zombies behind us, left side!"

The style system decides wording. Core provides no zombie/hostile/personality sentence.

Callout generation is read-only and must not retarget, move, or change combat authority.

### M10H-E — published-head acceptance

From clean published repository heads:

- Core clock-bearing tests pass;
- Hoomans heading adapter tests pass;
- Hoomans threat spatial projection tests pass;
- production semantic/combat callout tests pass;
- existing M10G trader-place cardinal tests remain green;
- DynamicTrading full/focused market/mobility tests remain green;
- Lua/Kahlua/static/translation/diff checks pass.

Record exact published SHAs.

## Ownership

### PsychopatzCore

Owns:

- point/vector validation;
- world-cardinal relation;
- heading-relative angle;
- clock sectors/tokens;
- coarse egocentric sectors;
- generic labels/translation keys.

Does not own threat detection, NPC state, combat, or wording.

### Project Hoomans

Owns:

- live NPC facing;
- perceived threat selection/freshness;
- target position;
- tactical spatial fact projection;
- semantic/combat context.

### Semantic realization

Owns:

- whether clock style is appropriate;
- "zombie" vs "hostile" vocabulary;
- urgency/personality/faction phrasing;
- clock vs coarse-relative wording.

## Stop conditions

Do not return to native-only handoff until M10H-A through M10H-E pass from published heads.

Stop early only for a genuine Git/publication conflict, missing required engine-facing orientation API with no safe fallback, authorization boundary, or an unspecified product decision that prevents safe implementation.

Native SP/MP becomes the sole remaining user-owned gate again **only after M10H is accepted**.
