# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M10F implementation is accepted; M10G Publication + Semantic Spatial Integration Closure is mandatory before native SP/MP handoff.**

The complete M0–M10 roadmap, including M10G, remains the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Current repository audit baseline

### DynamicTrading

- local `main`: `c1c16cbdc23678b23d7ef599eb9e38da4f021859`;
- `origin/main`: same;
- unrelated pre-existing local edit remains:
  `Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`.

Preserve that edit unless its owner explicitly incorporates it.

### Project Hoomans

- local `main`: `7df32a633db81f4d74940790f2ae6eb65c42974c`;
- `origin/main`: same;
- published `main` contains the required M10 history interleaved with unrelated semantic-scene commits;
- local worktree has unrelated semantic-scene edits; preserve them unstaged.

Planning-time ahead sequence:

```text
7df32a63 feat: add semantic scene opportunity admission
0507d2c8 feat: add semantic scene audience handoff
16d1635e feat: complete community excursion mobility lifecycle
be38dde5 feat: add semantic scene continuation
ca038eec feat: add generic commercial caravan mobility
0cc195d3 feat: add global semantic scene runtime
776c7d07 feat: add generic community excursions
a16a9f3d feat: adapt managed npcs into semantic scenes
b6ab4f49 test: freeze semantic scene runtime baseline
```

Re-audit before acting. Do not blindly push local Hoomans `main`.

### PsychopatzCore

- local `main`: `ea5a1c7c8ec8c97efe87a2a233cbc61419a7a862`;
- `origin/main`: same;
- clean at planning audit.

Read its root `AGENTS.md` before M10G-B edits.

## Accepted foundation — M0 through M9

Accepted and regression-protected:

- persistent exact trader stock/budget;
- MarketSense intrinsic-value/taxonomy authority;
- compact settlement market state/profiles/pressure/recovery;
- bounded partial settlement exchange;
- market-aware server-authoritative pricing;
- generic scoped market events and grounded event presentation;
- real Hoomans settlement-arrival activation;
- lazy market provisioning/recovery;
- production market-condition event producer;
- resident settlement trader market context;
- no per-frame economy/all-trader/full-item hot loops.

Do not redo these phases without evidence of regression.

## Accepted trader-mobility foundation — M10A through M10F

Accepted implementation/evidence:

### M10A

- generic Hoomans `settlement_visit` distinct from admission;
- commercial intent reuses relationship/hostility/encounter/pending-arrival/expiry/LOD machinery;
- commercial visits never invoke admission member-transfer behavior.

Published Hoomans baseline containing M10A:

`fb5c7566`

### M10B

- purpose-agnostic `CommunityExcursionService`;
- persisted AT_HOME → PREPARING → OUTBOUND → VISITING → RETURNING_HOME → AT_HOME lifecycle;
- exact home/faction identity;
- bounded itinerary/participants;
- lifecycle notifications, public/social projection, failure/retry;
- long-distance abstract / local-live boundary preserved.

Implementation commit:

`776c7d07` — local Hoomans history, not yet on published `origin/main`.

### M10C

- generic `CommercialMobilityService`;
- Hoomans owns candidate discovery, danger/diplomacy, final target, travel and encounters;
- optional bounded commercial opportunity scoring;
- base-less caravan can enter real commercial settlement travel;
- recent-visit anti-ping-pong behavior.

Implementation commit:

`ca038eec` — local Hoomans history, not yet on published `origin/main`.

### M10D–M10F

- rare resident-trader commercial excursions;
- exact-home return;
- resident faction/community membership preserved;
- away resident unavailable at home;
- exact merchant stock carried through visits;
- base-less caravan A→B→C production mobility;
- no admission/home/base for perpetual caravan;
- privacy-aware social/excursion status;
- bounded future commercial request/evaluator seam;
- replay/failure/save-load hardening.

Hoomans implementation commit:

`16d1635e` — contained by published `origin/main` through `7df32a63`.

DynamicTrading implementation:

`447cc27a` — published on `origin/main`.

Verified developer evidence:

- DynamicTrading full suite: `41/41`;
- focused resident/caravan cross-repo regressions: `3/3`;
- clean published Hoomans `origin/main` paired with DynamicTrading `origin/main`: focused M10/M9 regressions `3/3`; DynamicTrading full suite `41/41`.

These results prove the local committed implementation, not the published dependency graph.

## Post-M10F audit — remaining developer gaps

### 1. Published Hoomans dependency graph — closed by M10G-A

A clean published-pair audit now uses:

```text
DynamicTrading origin/main = c1c16cbd
ProjectHoomans origin/main = 7df32a63
```

contains the required Hoomans excursion/commercial modules and dependencies. Published-pair M10 resident/caravan and M9 bridge regressions pass with no missing M10 module failures. The full published Hoomans suite still has two unrelated semantic-scene failures: the MP server-file inventory count and the generated conversation registry import. Those files are outside this goal and remain preserved.

### 2. Production semantics does not consume excursion whereabouts

Hoomans exposes:

- `GetSocialStatus`;
- `GetNPCSocialStatus`;
- `GetCommunityAbsences`;
- `GetSemanticContext`.

But production semantic code does not currently call `GetSemanticContext`.

The existing "where is the trader?" evidence is API/test-level, not an actual production semantic/NLU/fact/realization path.

### 3. Destination settlement name is not yet projected into production semantic facts

Hoomans already owns authoritative:

- `community.id`;
- human-facing `community.name`;
- `community.home` / site-home coordinates.

M10G must resolve the current name/location on demand from the stable destination ID. Do not persist copied destination names.

### 4. No reusable Core coordinate→direction service exists

PsychopatzCore has no shared semantic spatial-relation module yet.

M10G must add one reusable Core primitive for:

- point validation;
- dx/dy;
- distance;
- angle/bearing;
- SAME_AREA;
- 8-way cardinal direction;
- optional configurable coarse distance band;
- reusable localized/presentation labels.

See `SPATIAL_LANGUAGE.md`.

## Current phase

**M10G-B — PsychopatzCore reusable spatial relation**

## M10G-A validation ledger — accepted

- Exact published heads are DynamicTrading `c1c16cbdc23678b23d7ef599eb9e38da4f021859`, ProjectHoomans `7df32a633db81f4d74940790f2ae6eb65c42974c`, and PsychopatzCore `ea5a1c7c8ec8c97efe87a2a233cbc61419a7a862`.
- Published ProjectHoomans contains `PNC_CommunityExcursionService.lua`, `PNC_CommercialMobilityService.lua`, resident excursion integration, and required generic travel/arrival dependencies; no local-only M10 module is needed.
- Clean published-pair focused regressions pass DynamicTrading M10/M9 resident/caravan/no-fixture `3/3` and ProjectHoomans commercial mobility/excursion `3/3`; DynamicTrading full suite passes `41/41`.
- The published Hoomans full runner reports only the two unrelated semantic-scene failures recorded above; no dirty semantic-scene file was staged or changed.

## Next Chunk — M10G-B: PsychopatzCore reusable spatial relation

Start with publication truth before adding new downstream dependencies.

### Required work

1. Read DynamicTrading root `AGENTS.md` and this job package in runbook order.
2. Recheck DynamicTrading status/HEAD/upstream/worktrees.
3. Read Project Hoomans root `AGENTS.md`.
4. Recheck Hoomans local/remote status, ahead history, dirty files, and worktrees.
5. Determine the **minimal required publishable dependency graph** for M10B–M10F.
   - Candidate implementation commits include `776c7d07`, `ca038eec`, and `16d1635e`;
   - do not assume they are independent of intervening commits;
   - verify dependencies from source/tests.
6. Build/test an exact publishable Hoomans state without disturbing or rewriting the user's local `main`.
   - no new branch;
   - a detached clean worktree or equivalent repository-approved method is acceptable;
   - no destructive reset/rebase/stash/discard.
7. Pair that publishable Hoomans snapshot with published DynamicTrading `447cc27a`.
8. Run the M10 resident/caravan tests and required Hoomans regressions.
9. Push only a verified fast-forward-safe Hoomans `main` update when the resulting history contains the required M10 implementation without unintentionally publishing unrelated unaccepted work.
10. Update this ledger with exact published Hoomans SHA/evidence.

### M10G-A gate

Fresh published Hoomans + DynamicTrading snapshots contain all required M10 modules and pass the relevant M10 tests with no missing-module failures.

After M10G-A, continue automatically to M10G-B. Do not stop for another `/goal`.

## Remaining mandatory M10G work

### M10G-B — PsychopatzCore spatial relation

Read PsychopatzCore root `AGENTS.md` first.

Implement the reusable contract in `SPATIAL_LANGUAGE.md`:

- shared/common dependency-safe module;
- finite coordinate validation;
- dx/dy + Euclidean distance;
- verified PZ axis convention;
- canonical angle/bearing;
- SAME_AREA + all 8 directions;
- configurable same-area threshold;
- optional configurable distance bands;
- translation/presentation-safe English direction labels;
- no Hoomans/DT dependency.

Tests must freeze all directions, opposites, invalid inputs, distance, dead zone, and PZ orientation.

Publish Core before downstream code depends on the new module.

### M10G-C — Hoomans authoritative place projection

- destination `community.id` → current `community.name`;
- resolve destination home/site coordinates;
- prefer speaker/home community as semantic origin for its own absent member;
- use Core spatial relation;
- resolve player-base name through existing authority where available;
- omit unavailable name/direction rather than leaking IDs/fabricating;
- rename/relocation changes later projection without rewriting excursion persistence.

### M10G-D — production semantic whereabouts

Wire the real semantic/NLU/fact-provider/realization pipeline.

Use a generic role-whereabouts fact, with trader as first consumer.

Required user inputs include:

- "Where is your trader?"
- "Where's the trader?"
- "Do you know where the trader went?"

For an informed local and authoritative fixture where the trader is at Riverside Collective northeast of home, the real semantic path must have enough grounded data to realize an answer equivalent to:

> "Our trader is at Riverside Collective, northeast of here."

ETA may be included when known.

Privacy must remove destination name/direction/ETA for unauthorized/poorly informed speakers.

The acceptance must not substitute a direct `GetSemanticContext` call for production semantic flow.

### M10G-E — published-head acceptance

After all required publication:

```text
PsychopatzCore origin/main
+ ProjectHoomans origin/main
+ DynamicTrading origin/main
```

must reproduce the accepted developer behavior from clean snapshots.

Required:

- Core spatial tests;
- Hoomans excursion/mobility/semantic tests;
- DynamicTrading full/focused tests;
- cross-repo bridges;
- Lua/Kahlua/static/translation/diff checks;
- exact published SHAs recorded;
- no required local-only modules.

## Ownership invariants

- **PsychopatzCore:** reusable geometry/spatial tokens/presentation primitives only.
- **Project Hoomans:** community/place identity, movement/excursions, privacy-aware whereabouts facts, semantic place/reference resolution.
- **Dynamic Trading:** merchant stock, market/economics, commercial policy/scoring.
- **Semantic/knowledge:** intent/fact selection, disclosure, natural-language realization; never movement authority.

## Stop conditions

Do not hand back as developer-complete until M10G-A through M10G-E pass.

Stop early only for a genuine Git/publication conflict, missing required dependency with no safe fallback, authorization boundary, or unspecified product decision that prevents safe implementation.

Native SP/MP becomes the sole remaining user-owned gate **only after M10G passes from published repository heads**.
