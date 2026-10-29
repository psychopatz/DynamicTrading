# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M10F implementation is accepted; M10G Publication + Semantic Spatial Integration Closure remains mandatory before native SP/MP handoff.**

The complete M0–M10 roadmap, including M10G, is the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Current repository audit baseline

### DynamicTrading

- local `main`: `dbfc8b9239a3171cbe31ae2bc4fe318b4c071f11`;
- `origin/main`: same;
- unrelated pre-existing local edit remains:
  `Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`.

That edit is preserved unstaged and must not be included in goal commits.

### Project Hoomans

- local `main`: `7df32a633db81f4d74940790f2ae6eb65c42974c`;
- `origin/main`: same;
- published `main` contains the required M10 history interleaved with unrelated semantic-scene commits;
- local worktree has unrelated semantic-scene modifications and untracked generated-adopter fixtures; all remain untouched and unstaged.

### PsychopatzCore

- local `main`: `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`;
- `origin/main`: same;
- clean after publishing the reusable spatial relation foundation.

## Accepted foundation — M0 through M9

Regression-protected and not to be redesigned without evidence:

- persistent exact trader stock and budget;
- MarketSense intrinsic-value and taxonomy authority;
- compact settlement market profiles, pressure, events, persistence, and recovery;
- bounded partial settlement exchange and market-aware server-authoritative pricing;
- real Hoomans settlement-arrival activation and lazy market provisioning;
- production market-condition event producer;
- resident trader home-market context without fabricated visits or stock exchange;
- no per-frame economy loop, all-trader rewrite, or full-item hot loop.

## Accepted trader-mobility foundation — M10A through M10F

### M10A — generic temporary settlement visits

- generic Hoomans `settlement_visit` is distinct from admission;
- commercial intent reuses relationship/hostility, encounters, pending arrivals, expiry, presence/LOD, and abstract travel;
- commercial visits never transfer members into the destination community or use admission join chance.

Published implementation baseline: Hoomans `fb5c7566` (contained by current published `7df32a63`).

### M10B — purpose-agnostic community excursions

- persisted `AT_HOME → PREPARING → OUTBOUND → VISITING → RETURNING_HOME → AT_HOME` lifecycle;
- exact home community/faction identity and bounded participants/itinerary;
- timestamps/revisions, lifecycle notifications, public/social projection, failure/retry, and save/reload continuation;
- long-distance travel remains abstract while nearby behavior remains live/materialized.

Implementation history is contained by current published Hoomans `7df32a63`.

### M10C — generic commercial mobility

- Hoomans owns candidate discovery, reachability, distance, danger, diplomacy/hostility, final destination, travel, encounters, and temporary visits;
- Dynamic Trading contributes only bounded economic opportunity scoring;
- base-less caravans participate in production commercial settlement travel;
- bounded recent-visit memory prevents immediate A↔B ping-pong;
- at most one authoritative Dynamic Trading exchange occurs per commercial arrival.

Implementation history is contained by current published Hoomans `7df32a63`.

### M10D–M10F — resident and caravan production lifecycles

- resident traders remain members of their original community/faction, leave rarely for purposeful commercial excursions, return to the exact home community, and are unavailable for home trade while away;
- base-less caravans have no hidden base or offscreen leader, preserve exact stock, and use ordinary production destination selection and commercial visits;
- Follow Player, protected work/facility ownership, cooldown, danger, failure/retry, duplicate-arrival, save/reload, and semantic public-status behavior are covered;
- no Dynamic Trading movement controller or physical full-map caravan pathfinding was introduced.

Implementation history is contained by current published Hoomans `7df32a63` and current published DynamicTrading `dbfc8b92`.

## M10G-A — clean Hoomans publication reconciliation — accepted

The required Hoomans excursion/commercial-mobility dependency graph was re-audited from clean `origin/main` rather than assumed from the old planning SHAs. The published head contains the generic excursion, commercial mobility, and completed lifecycle modules, including the intervening semantic-scene history. No local-only M10 module remains.

The clean published snapshot used for the focused audit was:

```text
DynamicTrading  c1c16cbdc23678b23d7ef599eb9e38da4f021859
ProjectHoomans  7df32a633db81f4d74940790f2ae6eb65c42974c
PsychopatzCore  ea5a1c7c8ec8c97efe87a2a233cbc61419a7a862
```

The DynamicTrading change from `c1c16cbd` to current `dbfc8b92` is documentation-only and was published after that snapshot audit. Focused published-pair M10/M9 resident, caravan, and no-fixture lifecycle regressions passed `3/3`; Hoomans mobility/excursion regressions passed `3/3`; DynamicTrading full suite passed `41/41`. The published Hoomans full suite also reported two unrelated semantic-scene baseline failures (server-file inventory count and missing generated conversation registry); their dirty semantic-scene source and fixtures remain preserved and were not staged.

## M10G-B — PsychopatzCore reusable spatial relation — accepted

Published Core commit: `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`.

Added dependency-safe shared `PsychopatzCore.SpatialRelation.Between(fromPoint, toPoint, options)` with:

- finite x/y/z validation and safe failure reasons;
- `dx`, `dy`, `dz`, horizontal and Euclidean distance;
- canonical angle in PZ world-axis coordinates and compass bearing;
- `SAME_AREA`, all eight cardinal/diagonal direction tokens, and opposite mapping;
- configurable same-area threshold and bounded optional distance bands;
- translation/presentation-safe Core direction keys and labels;
- no Hoomans, Dynamic Trading, trader, community, or semantic dependencies.

The PZ axis convention was verified against the refreshed decompiled `zombie.iso.IsoDirections` source (`N(0,-1)`, `E(1,0)`, `S(0,1)`, `W(-1,0)`) and frozen in the Core module comments and regression test.

Focused validation passed:

- `lua tests/psychopatz_spatial_relation_smoke.lua`;
- `lua tests/psychopatz_core_composition_smoke.lua`;
- `lua tests/psychopatz_core_smoke.lua`;
- `lua tests/psychopatz_custom_core_translation_smoke.lua`;
- EN/TL catalog JSON parsing and key parity (`371` keys);
- `pz_verify` Kahlua scan for the new spatial module;
- `git diff --check`.

Downstream Hoomans code may now depend on the published Core module.

## Remaining mandatory M10G work

### M10G-C — Hoomans authoritative place projection

- resolve `destinationCommunityID` through the live `PNC.Communities.Get(...)` record;
- derive the current community name and home/site coordinates on demand;
- use the speaker/home community as the normal semantic origin;
- call Core spatial relation rather than reimplementing axis signs;
- resolve player-base names through authoritative Hoomans/Base services when available;
- omit untrusted names/directions instead of exposing IDs or fabricating coordinates;
- prove rename and relocation affect later semantic output without rewriting excursion persistence.

### M10G-D — production semantic whereabouts

Wire the real semantic/NLU/fact-provider/realization path for generic `COMMUNITY_ROLE_WHEREABOUTS`, with `role = trader` as the first consumer. The production path must recognize:

- “Where is your trader?”;
- “Where’s the trader?”;
- “Do you know where the trader went?”

For an informed local, authoritative destination `Riverside Collective`, and destination northeast of home, the grounded semantic result must support an equivalent response containing the destination name, northeast direction, away/visiting status, and ETA when known. Privacy must remove privileged destination, direction, and ETA facts for less-informed or outsider speakers. Tests must enter through the real semantic path; a direct `GetSemanticContext` call is not acceptance evidence. Semantic queries remain read-only.

### M10G-E — published-head acceptance

The final gate must use clean snapshots of exactly:

```text
PsychopatzCore origin/main
ProjectHoomans origin/main
DynamicTrading origin/main
```

It must reproduce Core spatial, Hoomans excursion/commercial-mobility and production whereabouts, DynamicTrading resident/caravan/market, cross-repository bridge, persistence, Lua/Kahlua/static, translation, and `git diff --check` validation. Exact published SHAs must be recorded here. No required module may exist only in a local checkout.

## Ownership and performance invariants

- PsychopatzCore owns generic spatial mechanics and canonical spatial tokens only.
- Project Hoomans owns community/place identity, coordinates, movement, excursions, privacy-aware public whereabouts, and semantic reference-place resolution.
- Dynamic Trading owns stock, markets, economic exchange, and commercial policy/scoring; it is never movement authority.
- Semantic/knowledge systems own intent, disclosure, and wording; they never mutate travel.
- Destination names and directions are derived on demand, not duplicated into excursion persistence.
- Long-distance travel remains abstract; nearby NPC behavior remains materialized/live.
- No per-frame global destination solver, all-settlement scan per NPC, full registry scan per route decision, physical full-map pathfinding, unbounded route history, or duplicate public-status persistence.

## Stop conditions

Do not report developer completion until M10G-A through M10G-E pass from published repository heads. Native Project Zomboid SP/MP may become the sole remaining user-owned gate only after that published-head acceptance.
