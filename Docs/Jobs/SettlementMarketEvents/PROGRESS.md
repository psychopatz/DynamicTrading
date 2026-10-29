# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**DEVELOPER COMPLETE — M0–M10H accepted and reproduced from published repository heads. READY FOR USER LIVE SP/MP TEST.**

The complete developer-side Settlement Market, Events & Trader Mobility objective is accepted. No mandatory implementation chunk remains.

Native Project Zomboid SP/MP behavior is now the sole remaining user-owned acceptance gate.

If live evidence contradicts an accepted invariant, reopen only the smallest owning layer rather than restarting the roadmap.

## Final published dependency graph

### PsychopatzCore

Published `main` / `origin/main`:

`c01daef545fe5a9d2742186eca2bc0aa911f99cc`

Commit:

`feat: add observer relative spatial bearings`

Accepted M10H ownership:

- existing `PsychopatzCore.SpatialRelation.Between(...)` remains the world-cardinal relation authority;
- `SpatialRelation.RelativeToHeading(...)` now owns generic observer-relative geometry;
- 12 o'clock = forward;
- 3 o'clock = right;
- 6 o'clock = behind;
- 9 o'clock = left;
- all twelve deterministic 30-degree sectors;
- canonical `CLOCK_01 ... CLOCK_12`;
- coarse egocentric sectors:
  `AHEAD`, `FRONT_RIGHT`, `RIGHT`, `REAR_RIGHT`,
  `BEHIND`, `REAR_LEFT`, `LEFT`, `FRONT_LEFT`;
- SAME_AREA suppresses misleading clock directions;
- clock/coarse labels remain translation-safe and reusable;
- PZ axis convention remains +X east, +Y south;
- Core has no NPC, zombie, hostile, combat or dialogue dependency.

### Project Hoomans

Published `main` / `origin/main`:

`56b77cf4eeae680cffac277fc416fe6591f95a82`

Commit:

`feat: integrate tactical spatial callouts`

Accepted M10H ownership:

- live NPC heading resolution;
- bounded current-threat spatial projection;
- horde awareness spatial enrichment;
- existing Semantic Interaction Scene integration;
- existing player-heard ambient semantic reaction integration;
- hostile-human target-acquisition callouts;
- semantic clock/coarse presentation policy;
- existing BanterArbiter anti-spam;
- bounded Combat/Scene Observatory diagnostics;
- Semantic Harness explanation fixtures.

### DynamicTrading

M10H adds no DynamicTrading gameplay authority.

Published implementation-validation head used for M10H-H:

`cc3efb837f095dea49759029c70d450d5ab06809`

The unrelated local edit remains preserved and outside all M10H commits:

`Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`

## Accepted foundation — M0 through M10G

Still accepted:

- persistent exact trader stock/budget;
- MarketSense intrinsic-value/taxonomy authority;
- compact settlement market state/profile/pressure/recovery;
- bounded partial settlement exchange;
- server-authoritative market-aware pricing;
- generic typed/scoped market events;
- grounded event presentation;
- production settlement-market provisioning;
- real Hoomans settlement-arrival exchange;
- lazy recovery;
- grounded production event generation;
- resident settlement trader market context;
- generic non-admission commercial visits;
- purpose-agnostic Hoomans community excursions;
- base-less perpetual caravans;
- rare resident commercial excursions;
- exact-home resident return;
- production semantic trader whereabouts;
- authoritative destination settlement names;
- world-cardinal spatial language;
- privacy-aware destination/direction/ETA realization;
- clean published cross-repo dependency graph.

M10H did not reopen or replace these systems.

## M10H acceptance summary

### M10H-A — Core observer-relative relation

Accepted.

Implemented on the existing Core spatial module rather than creating another geometry subsystem.

Verified:

- `CLOCK_12` ahead;
- `CLOCK_03` right;
- `CLOCK_06` behind;
- `CLOCK_09` left;
- `CLOCK_08` rear-left fixture;
- all twelve center sectors;
- deterministic 15-degree boundary behavior;
- arbitrary non-cardinal headings;
- scale-invariant heading vectors;
- observer rotation updates relation;
- invalid/zero heading fails safely;
- SAME_AREA suppresses clock/relative tokens;
- reusable EN/TL clock + relative labels;
- O(1) math.

Core regression evidence:

- spatial relation smoke: PASS;
- Core smoke: PASS;
- Core composition smoke: PASS;
- custom Core translation smoke: PASS;
- translation manifest smoke: PASS.

### M10H-B — Hoomans authoritative facing adapter

Accepted.

Added one reusable Hoomans-facing authority.

Behavior:

1. prefer live materialized body `getForwardDirection()`;
2. allow bounded pathing-facing fallback only while current/trustworthy;
3. expose heading source/age;
4. stale cached facing is rejected;
5. abstract/offscreen actors do not fabricate clock orientation.

### M10H-C — tactical threat spatial projection

Accepted.

The read-only projection consumes:

```text
current observer point
+ authoritative observer heading
+ already-selected/current threat point or centroid
→ Core RelativeToHeading(...)
```

It does not scan for threats and cannot retarget combat.

Reused existing Hoomans inputs:

- `record.runtime.target`;
- proximity/group-alert coordinates;
- `CombatTactics.Internal.BuildZombieThreatCentroid(...)`;
- existing Perception frames/candidates.

The live clock result is ephemeral and is not persisted as durable threat knowledge.

### M10H-D — production horde awareness integration

Accepted.

The existing authority chain remains:

```text
PNC_ZombieObservation
→ SocialEventHooks.ObserveZombieHorde
→ DANGER_CHANGED
→ Interaction Scene / ambient semantic reaction
```

At the authoritative horde transition:

- existing bounded combat centroid supplies current threat geometry;
- current facing is resolved;
- one canonical tactical spatial snapshot is computed;
- the same snapshot is delivered to:
  1. `projecthoomans.scene.combat_horde`;
  2. existing nearby-player ambient semantic reaction.

No third clock-bark transport or polling subsystem was introduced.

Stable horde ticks remain silent through existing episode semantics.

### M10H-E — semantic realization + Scene continuation

Accepted.

The current `COMBAT_HORDE_ALERT` Semantic Interaction Scene remains the multi-NPC conversation owner.

Example supported grounded warning:

> "Zombies, eight o'clock! Fight or fall back?"

The existing semantic continuation remains authoritative:

- brave;
- cautious;
- steady.

No fixed continuation script replaced the current personality/behavior predicates.

Presentation policy reuses grounded role/trait/context information.

Tactical clock preference currently recognizes bounded tactical indicators such as:

- guard/raider/enforcer-style roles;
- veteran;
- disciplined fighter.

Other NPCs consume the same canonical relation as coarse language such as:

> "Zombies behind us, left side!"

CodeBuilder remains the authored-content authority.

Added only four reusable dynamic phrase families:

- zombie clock;
- zombie coarse;
- hostile clock;
- hostile coarse.

There are not twelve duplicated semantic concepts for the twelve hours.

### M10H-F — hostile-human target acquisition + anti-spam

Accepted.

Added a bounded generic combat-target change observer around the existing authoritative `BehaviorCommon.SetCombatTarget(...)` path.

Important boundary:

```text
Combat target authority
→ neutral COMBAT_TARGET_CHANGED notification
→ semantic combat-awareness subscriber
```

Combat does not depend on Semantics.

The semantic subscriber:

- reacts to a newly acquired human NPC hostile target;
- uses the same tactical spatial projection;
- uses the same clock/coarse semantic composer;
- uses existing `CombatBanterArbiter` cooldown/budget policy;
- does not poll every tick;
- does not change target, attack, retreat or movement state.

Accepted fixture:

> "Hostiles at three o'clock!"

for a current hostile target to the observer's right.

Stable identical target writes do not create repeated callouts.

### M10H-G — Observatory + Semantic Harness

Accepted.

Existing Combat Observatory / Scene Observatory now expose bounded canonical diagnostics including:

- target kind/ref;
- target-position source;
- heading source;
- clock token;
- coarse relative sector;
- distance band;
- freshness;
- presentation mode;
- presentation reason;
- suppression reason.

No rendered transcript is stored.

Semantic Harness worker fixtures now explain:

- why a rear-left fixture is `CLOCK_08`;
- why tactical clock wording was selected;
- why civilian/coarse wording was selected;
- why missing heading produces omitted clock data.

Observatory remains read-only and bounded.

### M10H-H — published-head acceptance

Accepted.

Clean archives were created from exact published `origin/main` heads:

```text
PsychopatzCore
c01daef545fe5a9d2742186eca2bc0aa911f99cc

ProjectHoomans
56b77cf4eeae680cffac277fc416fe6591f95a82

DynamicTrading
cc3efb837f095dea49759029c70d450d5ab06809
```

No working-tree-only M10H file was required.

## Final developer verification

### PsychopatzCore

Published archive:

- spatial relation: PASS;
- Core smoke: PASS;
- composition: PASS;
- Core translation: PASS;
- translation manifest: PASS.

Installed Project Zomboid Kahlua compiler:

- published Core changed spatial Lua: **1/1 PASS**.

### Project Hoomans

Final local tree before publication:

- full isolated Lua: **948/948 PASS**;
- focused M10H / tactical spatial / semantic / horde / Scene matrix: **8/8 PASS**;
- real worker Combat + Scene Observatory + Scene Runtime acceptance: **9/9 PASS**;
- CodeBuilder regeneration: **190 generated files / 497 phrase families / 54 patterns / 10 UI definitions**;
- deterministic CodeBuilder regeneration: byte-identical;
- `luac -p`: PASS on affected modules;
- Python worker test `py_compile`: PASS;
- `git diff --check`: PASS.

Installed Project Zomboid Kahlua compiler on the final implementation tree:

- changed Hoomans Lua: **26/26 PASS**;
- game launched: no;
- Lua executed by verifier: no;
- source writes: zero.

Published Hoomans archive reproduced:

- full isolated Lua: **948/948 PASS**;
- Combat + Scene Observatory / Scene Runtime workers: **9/9 PASS**;
- installed-PZ Kahlua changed Lua: **26/26 PASS**.

### DynamicTrading

Clean published archive paired with published Core/Hoomans:

- full DynamicTrading suite: **41/41 PASS**.

The unrelated local `DTHoomans_Conversation.lua` modification was never staged, reset, stashed, overwritten or committed.

## Performance and architecture evidence

M10H preserves the intended runtime shape:

- Core relation math is O(1);
- no global zombie scan was added;
- no dialogue-only threat scan was added;
- existing Perception frames/caches are reused;
- existing zombie centroid helper is reused;
- no full-NPC semantic polling loop was added;
- no per-tick tactical speech loop was added;
- existing horde episode gating is reused;
- existing BanterArbiter is reused;
- no second cooldown registry was added;
- no persisted live clock-bearing cache was added;
- no transcript persistence was added;
- no rendered-text reparsing was added;
- no combat target/movement authority moved into semantics.

## Native user-owned acceptance

No native Project Zomboid SP/MP instance was launched as part of developer acceptance.

User live verification should focus on:

1. a live NPC facing a newly perceived threat produces the expected clock direction;
2. turning the NPC or moving the threat changes the next eligible clock relation;
3. guard/veteran/disciplined speakers use tactical clock wording naturally;
4. ordinary speakers use coarse relative wording naturally;
5. horde Scene opening is spatially grounded while brave/cautious/steady continuation remains coherent;
6. hostile-human acquisition produces one grounded warning rather than per-tick spam;
7. observer-only nearby players hear NPC team warnings without receiving inappropriate interaction buttons;
8. missing/stale heading gracefully falls back without fabricated clock information;
9. no noticeable combat hitch or duplicate warning storm appears in dense scenes;
10. EN/TL dynamic callout labels render correctly in-game.

If live evidence fails, use Combat Observatory + Scene Observatory to identify:

- target source;
- heading source;
- clock token;
- relative sector;
- presentation mode/reason;
- suppression reason;
- semantic admission/cooldown ownership.

Reopen only the smallest failing layer.

## Stop state

There is no mandatory developer-side M10H work remaining.

Do not add optional threat types, formation callouts, radio compass speech, horde-vector prediction, or other spatial consumers merely to continue the roadmap.

**READY FOR USER LIVE SP/MP TEST.**
