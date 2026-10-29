# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M9D market/runtime engine work accepted; M9E resident/publication closure and M10 Community Excursions & Commercial Trader Mobility are mandatory before native SP/MP handoff.**

The complete M0–M10 roadmap is the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Planning baseline

DynamicTrading audited `main`:

`9ee65f0be58bdea00a1f1532173ec9fa8afee021`

Legacy behavioral reference:

`ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`

Current Project Hoomans re-audit:

- local `main`: `776c7d07` (`feat: add generic community excursions`);
- remote `origin/main`: `fb5c7566` (`feat: add generic settlement visits`);
- required generic settlement-arrival observer `2200b866` remains contained by `origin/main`;
- local `main` also contains unrelated semantic-runtime commits `b6ab4f49` and `a16a9f3d`, so the M10B commit is not fast-forward-publishable without publishing unrelated history;
- unrelated local semantic adapter work remains uncommitted and is preserved unstaged.

DynamicTrading remains concurrently changing; recheck both repositories before each publication.

DynamicTrading also contains the unrelated pre-existing local edit:

`Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`

Preserve it unless its owner explicitly incorporates it.

## Accepted M0–M8 engine foundation

Accepted and regression-protected:

- stable trader registry and persistent exact merchant stock;
- MarketSense intrinsic-value/taxonomy authority;
- compact settlement market registry/profile/pressure/recovery;
- bounded partial settlement exchange;
- server-authoritative market-aware quote pipeline;
- generic scoped market-event registry and data-only proof events;
- two-settlement logistics propagation through persistent trader stock;
- grounded WorldKnowledge / Talk / Radio market-event presentation;
- schema migration, bounds, cache/profiler hardening;
- replay/stale-version/security protections;
- no per-frame economy, all-trader event rewrite, or per-quote full item scan.

Legacy remains behavioral reference only. Do not restore DTNPC, manual price catalogs, or monolithic legacy dialogue.

## Accepted M9A–M9D runtime activation

M9 closed the earlier "engine exists but gameplay does not drive it" gap.

Accepted behavior:

- production Hoomans mobile-settlement arrival can notify DynamicTrading;
- missing settlement markets are lazily provisioned by canonical Hoomans `community.id`;
- bounded Hoomans metadata resolves a market profile with safe `default` fallback;
- settlement visit drives one idempotent DT exchange;
- elapsed authoritative time drives lazy market recovery;
- production market-condition producer can register/clear Food Shortage / Agricultural Surplus through the generic event registry;
- event production uses raw persisted pressure with hysteresis/cooldown;
- event start affects price/availability/presentation but not exact merchant stock;
- M9 flagship starts with no target DT market/event and drives the public Hoomans arrival lifecycle rather than direct test-only DT setup calls.

Latest accepted evidence:

- full DynamicTrading suite: `929/929`;
- full Project Hoomans suite: `929/929`;
- M9E resident market-context acceptance passed;
- Hoomans arrival-observer diagnostic regression passed;
- changed production Lua passed `luac -p`, Kahlua verification, and `git diff --check`.

These are accepted engine/runtime results. Do not redo M0–M9D unless current source proves a regression.

## Post-M9 trader-lifecycle audit

The claim that native SP/MP was the only remaining step is superseded.

### Two real trader types

**Settlement-owned resident trader**

- ordinary non-mobile Hoomans settlement member with role `trader`;
- has a real home community;
- currently remains at home;
- should leave only rarely for purposeful commercial excursions.

**Base-less roaming trader/caravan**

- independent Hoomans mobile trader faction;
- has no home community or hidden base;
- default state is perpetual roaming/travel;
- should commercially visit settlements without admission/absorption.

### Closed M9E gaps

- staffed resident binding now resolves the active Hoomans `community.id`;
- binding idempotently provisions the local market and stores separate home/current context;
- first snapshot/quote uses the home market without a fake visit, exchange, pressure mutation, or stock/budget change;
- home identity remains distinct from `lastSettlementID` commercial history;
- the generic Hoomans arrival observer is published on `main` and reports bounded clean listener failures without interrupting arrival lifecycle;
- M9E acceptance starts with an active staffed settlement and no pre-created DT market.

## Remaining developer gaps

1. **Roaming caravan destination lifecycle**
   DT generates caravans with `mobileControlMode = strategic` and `mobilePathMode = random`, but production Hoomans still needs a generic commercial-mobility destination-scoring seam for those groups.

2. **Resident excursion production policy**
   Generic excursion persistence now exists, but resident traders still need a rare purposeful departure policy, exact-home travel integration, and home availability restoration.

3. **Semantic/public absence integration**
   Hoomans now exposes generic public excursion state, but semantic context still needs privacy-aware consumption and truthful trader-location presentation.

4. **Stale caravan-base comments**
   Some DT caravan comments still claim a leader "stays at the base" or imply an idle-at-base variant. The approved roaming trader is base-less; do not implement a fake base to match stale comments.

## Current phase

**M10C — Base-less Roaming Commercial Caravan**

## Next Chunk — M10C

M10B is accepted. Continue with production commercial mobility for base-less DT caravans.

### Required work

1. Re-audit Hoomans mobile-group departure, destination, reachability, encounter, arrival, and abstract-travel APIs before modifying either repository.
2. Add/reuse a generic Hoomans commercial-mobility/destination-scoring seam in which Hoomans owns candidate discovery, reachability, distance, danger, diplomacy/hostility, and final destination selection.
3. Let Dynamic Trading register only a bounded economic opportunity score using carried stock, local supply/demand, scarcity, price opportunity, events, specialization, and bounded recent-visit history.
4. Make production-configured base-less DT caravans participate through the generic seam without a Dynamic Trading-specific branch in Hoomans; player settlements use the same safety/opportunity contract.
5. Add bounded recent-visit/cooldown memory to avoid immediate A↔B ping-pong, and preserve one authoritative DT exchange per commercial arrival.
6. Correct stale DT comments that imply a caravan base or leader remaining at base; keep the roaming faction base-less with perpetual mobility.
7. Add the flagship production test for caravan A→B→C, including non-admission visits, stock continuity, pressure logistics, save/reload, replay idempotence, and anti-ping-pong behavior.
8. Run focused cross-repository regressions, Lua/Kahlua/static/persistence/diff checks, update this ledger, and commit/push coherent in-scope work only when fast-forward-safe.

### M10C gate

M10C is accepted only when:

- a production-configured base-less DT caravan enters the generic Hoomans commercial mobility lifecycle;
- Hoomans owns final destination, safety, travel, encounters, and temporary visit lifecycle;
- the Dynamic Trading contribution is bounded economic opportunity scoring only;
- commercial visits never transfer members or invoke admission join chance;
- one authoritative exchange occurs per arrival and recent-visit memory prevents immediate ping-pong;
- unrelated local work remains preserved.

Continue automatically into M10D. Do not stop for another `/goal`.

## M10 — Community Excursions & Commercial Trader Mobility

Read `COMMUNITY_EXCURSIONS.md` before implementation.

Mandatory order:

1. **M10A — generic non-admission settlement visit**
   - temporary visit distinct from admission;
   - extensible visit intent, commercial first;
   - no membership transfer;
   - reuse Hoomans relationship/encounter/pending-arrival/expiry/LOD behavior.

2. **M10B — generic Community Excursion foundation**
   - Hoomans-owned, purpose-agnostic;
   - AT_HOME → PREPARING → OUTBOUND → VISITING → RETURNING_HOME → AT_HOME;
   - exact home community;
   - compact persistence, notifications, public/social projection;
   - long-distance abstract / local live boundary preserved.

3. **M10C — base-less roaming commercial caravan**
   - no home/base/return phase;
   - production AI naturally selects commercial settlements;
   - Hoomans owns final destination/movement;
   - DT provides bounded economic opportunity score only;
   - recent-visit anti-ping-pong memory;
   - player settlement treated as another safe/opportune market;
   - commercial visit never admission;
   - remove stale imaginary-base comments.

4. **M10D — rare resident-trader commercial excursions**
   - home by default;
   - rare purposeful departure;
   - remain member of original faction/community;
   - no whole-faction mobility conversion;
   - protected Follow/task/home cooldown gates;
   - exact-home return;
   - away trader unavailable for physical home trade;
   - exact merchant stock carried through visits.

5. **M10E — semantic/public excursion facts + future request seam**
   - generic public status: home/preparing/away/visiting/returning;
   - public reason can be trading run;
   - destination/ETA only when known/allowed;
   - semantic knowledge layer consumes facts, not movement internals;
   - first proof supports truthful "where is your trader?" context;
   - future "visit my settlement" is a request/suggestion evaluated by faction/trader AI, never a direct movement command;
   - full player invitation UI/dialogue is not required.

6. **M10F — flagship/failure/hardening**
   - perpetual caravan: A→B→C commercial visits, no admission/home/stock reroll;
   - resident trader: Home A→B→Home A, exact home and membership preserved;
   - encounter, invalid destination, duplicate arrival, Follow/protected task, save/reload failsafes;
   - semantic status through all phases;
   - no per-frame route solver, full-market scan per NPC, or physical full-map pathfinding.

## Ownership invariants

- **Project Hoomans:** NPC/faction/community identity, movement, long-distance abstract travel, local live behavior, encounters, presence/LOD, generic temporary visits, generic excursions, exact-home resolution, public excursion social truth.
- **Dynamic Trading:** merchant stock/budget, settlement market, exchange, market events, commercial scoring/policy, economic consequences.
- **MarketSense:** intrinsic value and taxonomy.
- **Semantic/knowledge systems:** consume authoritative public facts and knowledge visibility; never mutate movement directly.

## Known constraints / stop conditions

- Preserve the unrelated local `DTHoomans_Conversation.lua` edit.
- Preserve unrelated Project Hoomans semantic-combat work.
- Never route a commercial trader through admission member-transfer semantics.
- Never invent a base/home for the perpetual caravan.
- Never make DynamicTrading the movement/encounter/LOD authority.
- Native SP/MP remains user-owned **only after M9E and M10 developer gates pass**.
- Continue automatically through M9E and M10A–M10F.
- Stop early only for a genuine repository conflict/publication blocker, missing required dependency with no safe fallback, authorization boundary, or unspecified product decision that prevents safe implementation.

## M9E validation ledger — accepted

- Hoomans re-audit: local/remote `main` is `f0eb0384`; `2200b866` is published in `origin/main`.
- Resident acceptance: `tests/dt_m9e_resident_market_context_smoke.lua` starts with an active staffed settlement and no DT market, then provisions one canonical `community.id` market through `EnsureTraderForFaction`.
- Resident binding writes separate home/current context; snapshot and quote use the local farm profile while `lastSettlementID`, visit count, stock, budget, and pressure remain unchanged.
- Hoomans observer diagnostics record clean listener `false, reason` results and continue the authoritative arrival lifecycle.
- Full verification: DynamicTrading `929/929`; Project Hoomans `929/929`; focused M9A/M9D/M9E and Hoomans admission regressions pass; applicable Kahlua and diff checks pass.
- Unrelated DynamicTrading conversation work and unrelated Hoomans semantic-document work were not staged, committed, or pushed.

## M10A validation ledger — accepted

- Hoomans published generic `settlement_visit` purpose and bounded extensible `intent` field; `commercial` is data preserved by the generic service, not a Dynamic Trading branch.
- Non-admission visits reuse Hoomans relationship/hostility checks, encounter deferral, pending arrival, expiry, public visit projection, and abstract arrival lifecycle.
- Commercial-style arrival never invokes the configured AI admission join chance, transfers no member, and rejects admission actions.
- Duplicate arrival revisions are idempotent; the focused Hoomans regression and full `929/929` suite pass.
- Published Hoomans commit: `fb5c7566`.

## M10B validation ledger — accepted

- Hoomans now owns a purpose-agnostic `CommunityExcursionService` persisted on the authoritative faction record.
- The service enforces `AT_HOME → PREPARING → OUTBOUND → VISITING → RETURNING_HOME → AT_HOME`, with explicit `FAILED` and bounded retry transitions.
- Canonical home faction/community identity, bounded participants/itinerary, purpose, timestamps, revisions, exact-home resolution, public status, and lifecycle notifications are persisted and normalized across reload.
- Hoomans WorldDirector runs bounded reconciliation on an hourly scheduler job; no per-frame movement or economy loop was added.
- Focused lifecycle, composition, MP loader, and settlement-arrival regressions pass; full Project Hoomans suite passes `932/932`.
- Hoomans M10B commit: `776c7d07` (local `main` only; not published because unrelated local semantic-runtime commits are ahead of `origin/main`).
- Hoomans changed Lua passed Kahlua checks; the pre-existing MP inventory test's `io.popen` warning remains outside this chunk.
- Unrelated Hoomans semantic adapter work and the unrelated DynamicTrading conversation edit remain preserved and unstaged.

Immediate next chunk: M10C base-less roaming commercial caravan. Continue automatically through M10F.
