# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**Developer-complete through M10G-E.** M0–M10G is implemented and validated from the published repository heads. Native Project Zomboid SP/MP acceptance remains the sole user-owned gate.

The phase boundary is the full M0–M10 roadmap; completing an individual phase does not by itself complete the parent objective.

## Published validation snapshot

These are the exact published runtime heads used for the final clean-snapshot acceptance. The DynamicTrading revision is the last runtime/documentation baseline before this progress-only update.

```text
PsychopatzCore origin/main  5c5998087b4c7a91d0e57f9667dc911cf1eb061f
ProjectHoomans origin/main  656dddf42acec857a7a58ad55c4228c36250b051
DynamicTrading origin/main  67e1a594f8a628f22e2b4694491e2412a9ee21b9
```

All three validation checkouts were clean, detached/published snapshots. No required module existed only in a developer checkout.

## Repository safeguards

- DynamicTrading uses the existing `main` branch; no branch was created.
- The unrelated local edit in `Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua` remains unstaged and was not included.
- Project Hoomans semantic-scene, spatial-index, combat-awareness, generated-content, and harness history was preserved; the publication reconciliation did not reset, rebase, discard, or overwrite it.
- PsychopatzCore and Project Hoomans published `main` are clean at the heads above.

## Accepted M0–M9 foundation

- Trader merchant stock is exact, persistent inventory; UI open/reopen never rerolls it.
- Settlement visits exchange only a bounded portion of stock instead of replacing inventory.
- MarketSense remains the intrinsic-value and taxonomy authority.
- Dynamic Trading owns settlement market pressure, typed data-driven events, merchant stock/budget, quotes, and settlement exchange.
- Project Hoomans owns NPC/faction/community identity, settlement presence, movement, arrival lifecycle, LOD, failure/retry, and exact-home identity.
- Market provisioning is lazy and idempotent for existing saves; production settlement arrival forwards one authoritative exchange visit.
- Market recovery is bounded and authoritative; production event generation is condition-based with hysteresis/cooldown/duration.
- Resident traders resolve home-market context without fabricating a visit, exchange, or pressure mutation.
- No per-frame economy loop, all-trader event rewrite, or full item-registry scan per quote/visit was introduced.

## Accepted M10 mobility foundation

- Base-less caravans remain independent, perpetual mobile factions with no hidden base or offscreen leader.
- Settlement-owned traders remain members of their original Hoomans community/faction and return to the exact originating `community.id`.
- Generic Hoomans temporary commercial visits and purpose-agnostic excursions own admission-free visitation, abstract travel, encounters, presence/LOD, expiry, failure/retry, save/reload continuation, and public status.
- Dynamic Trading contributes only bounded economic opportunity/policy information; it is not a movement controller.
- Production caravan and resident-trader lifecycles prove destination scoring, commercial visits, exact stock continuity, one exchange per arrival, anti-ping-pong cooldowns, protected-task/Follow Player constraints, and exact-home return.
- Public excursion facts remain privacy-aware and read-only for semantic consumers.

## M10G-A — clean Hoomans publication reconciliation — accepted

- Re-audited Project Hoomans local `main`, `origin/main`, worktrees, dirty state, and ahead history.
- Verified the minimal generic excursion/commercial-mobility/completed-lifecycle dependency graph and reconciled it onto published `origin/main` without blindly publishing unrelated history.
- Published-head loader/test gates were aligned for the actual published module inventory; the final clean Hoomans snapshot contains all required M10 modules.

## M10G-B — PsychopatzCore reusable spatial relation — accepted

Published Core provides `PsychopatzCore.SpatialRelation.Between(fromPoint, toPoint, options)` with:

- finite coordinate validation and `dx`, `dy`, `dz`;
- Euclidean and horizontal distance;
- canonical bearing and configurable same-area/dead-zone threshold;
- `SAME_AREA`, `NORTH`, `NORTHEAST`, `EAST`, `SOUTHEAST`, `SOUTH`, `SOUTHWEST`, `WEST`, and `NORTHWEST`;
- opposite-direction symmetry, bounded optional distance bands, and translation-safe labels.

The Project Zomboid axis convention was verified against decompiled `zombie.iso.IsoDirections`: north `(0,-1)`, east `(1,0)`, south `(0,1)`, west `(-1,0)`. Core has no trader, community, excursion, or semantic-role knowledge.

## M10G-C — Hoomans authoritative place projection — accepted

Hoomans derives destination presentation on demand from `destinationCommunityID` through the live community registry and current community/site/home coordinates. It does not persist copied destination names or computed directions. Rename and relocation therefore affect later semantic output automatically; missing names or coordinates omit the affected presentation instead of exposing IDs or fabricating direction.

## M10G-D — production semantic whereabouts integration — accepted

The real semantic path is:

```text
natural-language question
  → parser IR
  → cognition request/live-fact projection
  → privacy-aware Hoomans role-whereabouts fact
  → authoritative place projection + Core spatial relation
  → normal response catalog/realization
```

`COMMUNITY_ROLE_WHEREABOUTS` with `role = trader` is the first generic consumer. The production path recognizes “Where is your trader?”, “Where's the trader?”, and “Do you know where the trader went?”, supports grounded destination/direction/ETA, refreshes after rename/relocation, remains read-only, and omits privileged route data for outsiders. Deferred multiplayer fact completion is typed separately from gossip and remains bounded.

## M10G-E — published-head acceptance — accepted

Final clean published-head gates passed:

- Project Hoomans full suite: `942/942`.
- Project Hoomans focused excursion, commercial mobility, semantic whereabouts, persistence, bridge, and loader gates: `14/14`.
- DynamicTrading full suite: `41/41`.
- DynamicTrading resident/caravan/market/settlement focused set: `16/16`.
- PsychopatzCore spatial/composition/core/translation regressions: all passed.
- PsychopatzCore translation JSON parse and EN/TL key parity: `8` files, `371` keys.
- Lua parsing: Hoomans `4644` files, DynamicTrading `104` files, Core `457` files.
- Production Kahlua/static verification: Hoomans `35` changed production Lua files and Core spatial module; no errors.
- Translation coverage/model/window/custom-manifest tests: all passed.
- `git diff --check`: clean for all three published snapshots.

## Ownership and performance invariants

- PsychopatzCore owns generic point-to-point spatial mechanics and canonical spatial tokens only.
- Project Hoomans owns community/place identity, canonical names and coordinates, movement, excursions, privacy-aware whereabouts, and semantic reference-place resolution.
- Dynamic Trading owns stock, markets, economic exchange, and commercial policy/scoring; it is never movement authority.
- Semantic/knowledge systems own intent, disclosure, and wording; they never mutate travel.
- Destination names and directions are derived on demand, not duplicated into excursion persistence.
- Long-distance travel remains abstract; nearby NPC behavior remains materialized/live.
- No per-frame global destination solver, all-settlement scan per NPC, full registry scan per route decision, physical full-map pathfinding, unbounded route history, or duplicate public-status persistence was introduced.

## Remaining user-owned acceptance

Native Project Zomboid single-player/multiplayer runtime acceptance is the only remaining gate. No developer-side M0–M10G requirement remains open.
