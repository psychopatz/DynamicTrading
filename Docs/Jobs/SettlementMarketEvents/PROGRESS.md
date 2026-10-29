# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M10F implementation is accepted; M10G Publication + Semantic Spatial Integration Closure remains mandatory before native SP/MP handoff.**

The complete M0–M10 roadmap, including M10G, is the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Current repository audit baseline

### DynamicTrading

- local `main`: `2c8830ad5e328a4693ac6ae807a20845503ac2b5`;
- `origin/main`: same;
- unrelated pre-existing local edit remains:
  `Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`.

That edit is preserved unstaged and is not included in goal commits.

### Project Hoomans

- local `main`: `510634b1d55304fb96d101731bbc8b25687a9545`;
- `origin/main`: same published head;
- worktree still contains unrelated semantic-scene, spatial-index, combat-awareness, generated-content, and harness changes; all remain untouched and unstaged.

### PsychopatzCore

- local `main`: `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`;
- `origin/main`: same;
- clean published reusable spatial foundation.

## Accepted foundation — M0 through M9

Regression-protected and not redesigned without evidence:

- persistent exact trader stock and budget; UI open/reopen never rerolls stock;
- MarketSense remains intrinsic-value and taxonomy authority;
- bounded settlement markets, pressure, typed data-driven events, persistence, and recovery;
- bounded partial settlement exchange with market-aware server-authoritative pricing;
- real Hoomans settlement-arrival activation and lazy market provisioning;
- production market-condition event producer;
- resident home-market context without fabricated visits, exchange, or pressure mutation;
- no per-frame economy loop, all-trader event rewrite, or full item-registry scan per quote/visit.

## Accepted M10 implementation

- Hoomans owns generic community excursions, temporary commercial visits, participant identity, travel, encounters, presence/LOD, failure/retry, and exact-home return;
- resident traders remain members of the original community/faction, leave rarely for purposeful commercial excursions, become unavailable at home while away, and return to the exact home community;
- base-less caravans have no hidden base or offscreen leader and participate in production commercial settlement travel;
- Hoomans owns candidate discovery, reachability, distance, danger, diplomacy/hostility, final destination, travel, encounters, and temporary visits;
- Dynamic Trading contributes only bounded economic opportunity scoring and one authoritative exchange per commercial arrival;
- bounded recent-visit memory prevents immediate A↔B ping-pong;
- save/reload, duplicate-arrival, invalid/hostile destination, delayed encounter, failure/retry, Follow Player, and protected-task behavior are covered;
- no Dynamic Trading movement controller or physical full-map pathfinding was introduced.

## M10G-A — clean Hoomans publication reconciliation — accepted

The Hoomans excursion/commercial-mobility dependency graph was re-audited from the then-current clean `origin/main`. The required generic excursion, commercial mobility, and completed lifecycle modules were verified in the published graph, including the interleaved semantic-scene history. No required M10 module remains local-only.

The prior clean published snapshot audit passed the focused M10/M9 resident, caravan, and no-fixture lifecycle regressions (`3/3`), Hoomans mobility/excursion regressions (`3/3`), and DynamicTrading full suite (`41/41`). The two Hoomans full-suite failures at that baseline were unrelated semantic-scene inventory/loader regressions; the dirty semantic-scene work was preserved.

## M10G-B — PsychopatzCore reusable spatial relation — accepted

Published Core commit: `5c5998087b4c7a91d0e57f9667dc911cf1eb061f`.

`PsychopatzCore.SpatialRelation.Between(fromPoint, toPoint, options)` provides finite coordinate validation, `dx`/`dy`/`dz`, Euclidean distance, canonical bearing, `SAME_AREA`, all eight cardinal/diagonal directions, opposites, bounded same-area thresholds, optional distance bands, and translation-safe direction labels. Core has no trader, community, excursion, or semantic-role knowledge.

The PZ axis convention was verified against decompiled `zombie.iso.IsoDirections`: north `(0,-1)`, east `(1,0)`, south `(0,1)`, west `(-1,0)`. Core regression coverage includes all directions, reverse/opposite symmetry, same-area behavior, distance, invalid/NaN/infinite input, and translation fallback.

Focused Core tests passed:

- `lua tests/psychopatz_spatial_relation_smoke.lua`;
- `lua tests/psychopatz_core_composition_smoke.lua`;
- `lua tests/psychopatz_core_smoke.lua`;
- `lua tests/psychopatz_custom_core_translation_smoke.lua`;
- EN/TL catalog JSON parsing and key parity (`371` keys);
- Kahlua/static verification and `git diff --check`.

## M10G-C — Hoomans authoritative place projection — accepted

Published Hoomans commit: `510634b1d55304fb96d101731bbc8b25687a9545`.

Added a dependency-safe live place projection that resolves `destinationCommunityID` through `PNC.Communities.Get(...)`, derives the current community name and current home/site coordinates, and calls Core spatial relation logic. Names and directions are not copied into excursion persistence. Missing names or coordinates omit presentation data rather than exposing internal IDs or fabricating a direction. Speaker/home community is the default semantic origin; player exact tiles are not used.

Added bounded server live-fact projection for generic community roles. It consumes the existing privacy-aware excursion social-status contract, does not call `GetSemanticContext` from acceptance tests, and emits route name/direction/ETA only for an informed viewer.

## M10G-D — production semantic whereabouts — accepted

The real semantic path is wired for the reusable `COMMUNITY_ROLE_WHEREABOUTS` concept with `role = trader` as the first consumer:

`natural question → parser IR → cognition request/live fact projection → privacy-aware fact resolver → response catalog/realization`.

Recognized natural forms include “Where is your trader?”, “Where's the trader?”, and “Do you know where the trader went?”. The production path supports destination rename/relocation on later queries, Core-derived direction, grounded ETA, read-only behavior, and outsider omission of privileged name/direction/ETA. MP/deferred fact completion is typed separately from gossip and remains bounded.

Focused Hoomans semantic tests passed:

- `pnc_semantic_whereabouts_request_smoke`;
- `pnc_semantic_whereabouts_production_smoke`;
- existing NLU, local-response, cognition-client, cognition-service, and fact-provider regressions (`6/6` combined);
- Lua parse for all changed/new modules;
- targeted Kahlua verification with no errors;
- `git diff --check`.

## M10G-E — published-head acceptance — pending

Run the final acceptance from clean exact published heads:

```text
PsychopatzCore origin/main  5c5998087b4c7a91d0e57f9667dc911cf1eb061f
ProjectHoomans origin/main  510634b1d55304fb96d101731bbc8b25687a9545
DynamicTrading origin/main  2c8830ad5e328a4693ac6ae807a20845503ac2b5
```

The final gate must reproduce Core spatial, Hoomans excursion/commercial-mobility and production whereabouts, DynamicTrading resident/caravan/market, cross-repository bridge, persistence, Lua/Kahlua/static, translation, and `git diff --check` validation. No required module may exist only in a developer checkout.

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
