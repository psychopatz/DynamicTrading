# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**DEVELOPER-COMPLETE — M0–M10 market, event, excursion, and trader-mobility implementation gates pass. Native SP/MP remains the sole user-owned acceptance gate.**

The complete M0–M10 roadmap is the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Planning baseline

DynamicTrading audited `main`:

`9ee65f0be58bdea00a1f1532173ec9fa8afee021`

Legacy behavioral reference:

`ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`

Current Project Hoomans re-audit:

- local `main`: `16d1635e` (`feat: complete community excursion mobility lifecycle`);
- remote `origin/main`: `fb5c7566` (`feat: add generic settlement visits`);
- required generic settlement-arrival observer `2200b866` remains contained by `origin/main`;
- local `main` also contains unrelated semantic-runtime commits and remains ahead of `origin/main`; `16d1635e` is committed locally but is not pushed because publishing that non-fast-forward history would publish unrelated work;
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

## Closed M10 developer gates

1. **Resident excursion production policy**
   A bounded Dynamic Trading policy now evaluates budget, carried stock, home availability, cooldown, meaningful Hoomans opportunity, safety, Follow Player, protected work, and exact-home identity before creating a generic Hoomans participant excursion. The resident remains in its original faction/community, keeps exact merchant stock, and is unavailable for home trade while away.

2. **Semantic/public status and request seam**
   Hoomans exposes privacy-aware generic social facts for home, preparing, away, visiting, returning, and failure states; authorized home-faction viewers may receive bounded destination/ETA while outsiders do not. A bounded commercial request evaluator seam accepts only accept/reject/defer decisions and never commands movement or mutates excursion state.

3. **Flagship/failure hardening**
   Production tests cover the base-less A→B→C caravan and Home A→B→Home A resident lifecycles, exact stock continuity, one exchange per arrival, pressure/logistics, anti-ping-pong history, abstract travel revisions, encounter-delayed arrival, hostile/invalid destinations, duplicate arrivals, retry, save/reload, Follow Player, protected work, and semantic status across all major phases.

## Current phase

**M10F — Flagship, failure, and hardening gates accepted**

## Handoff state

M10D, M10E, and M10F are accepted on the developer side. Native Project Zomboid SP/MP replay remains user-owned acceptance; no further developer roadmap chunk remains.

### Historical M10D acceptance scope

1. Re-audit settlement trader staffing, home identity, facility/work ownership, Follow Player, trader availability, and the generic Hoomans excursion APIs.
2. Add a bounded production policy that can prepare a resident trader for a worthwhile and safe commercial destination without converting the home faction into a mobile group.
3. Reuse generic Hoomans excursion phases, abstract travel, encounters, temporary settlement visits, exact-home return, failure/retry, presence/LOD, and persistence.
4. Keep the original `community.id` and faction membership authoritative throughout; carry the existing merchant stock and make the trader unavailable for home trade while away.
5. Add focused resident lifecycle coverage for policy gates, destination visit, exact-home return, cooldown, protected work, Follow Player, save/reload, and idempotent arrival/exchange.
6. Run focused cross-repository regressions, Lua/Kahlua/static/persistence/diff checks, update this ledger, and commit/push coherent in-scope work only when fast-forward-safe.

### M10D gate

M10D was accepted when:

- a settlement-owned trader leaves only through a bounded purposeful policy;
- original faction/community membership and canonical home identity remain unchanged;
- Hoomans owns the excursion, safety, travel, encounters, exact return, and temporary visit lifecycle;
- the trader carries the exact existing stock, is unavailable at home while away, and restores home availability on return;
- cooldown and protected-task/Follow Player gates prevent unsafe or immediate repeat departure;
- unrelated local work remains preserved.

Do not create another `/goal` for the accepted developer-side roadmap.

## M10C validation ledger — accepted

- Hoomans now exposes a generic, scheduled `CommercialMobilityService`; it discovers bounded settlement candidates, applies location danger and existing relationship/hostility eligibility, scores distance, and owns final destination selection and abstract travel.
- `settlement_visit` with extensible `commercial` intent is reused for arrivals; no admission join chance or membership transfer is invoked, and the existing observer/exchange seam remains authoritative and idempotent.
- DT caravans persist `mobilityIntent = commercial`, retain `mobilePathMode = random` and `mobileControlMode = strategic`, and lazily repair older DT caravan records without recreating factions, stock, or NPCs.
- DT registers only one bounded read-only economic scorer over compact settlement market/event state; it does not scan the MarketSense registry, rewrite all traders, mutate pressure, or change stock at event/travel start.
- Player settlements without a pre-existing base compete under the same Hoomans safety/relationship contract; bounded canonical-community visit history prevents immediate A↔B ping-pong.
- Stale base/leader comments were corrected; the roaming caravan remains a base-less independent faction with no hidden home or offscreen leader.
- Focused M10C tests pass in both repositories; full current smoke suites pass DynamicTrading `39/39` and Project Hoomans `934/934`; changed M10C Lua passed Kahlua verification and `git diff --check`.
- Hoomans M10C commit: `ca038eec` on local `main`, not pushed because local `main` also contains unrelated semantic-runtime commits ahead of `origin/main` (`fb5c7566`). The DynamicTrading conversation edit and Hoomans semantic work remain unstaged.

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

## M10D validation ledger — accepted

- Dynamic Trading now registers a bounded resident policy with Hoomans `CommunityExcursionService`; policy selection uses the existing trader budget/stock and home availability, cooldown, Hoomans opportunity/safety, Follow Player, and protected-work gates.
- Hoomans keeps the resident faction non-mobile and preserves the original faction/community membership. The participant travel request carries `commercial` intent, while the Dynamic Trading listener only changes trader availability, current/home context, and the authoritative bounded settlement exchange.
- Visiting performs one idempotent exchange with the exact merchant stock; outbound/visiting/returning states make the trader unavailable to home trade; `AT_HOME` restores exact home context and availability.
- Focused resident coverage passes for no-precreated home market, policy-driven departure, duplicate arrival, exact-home return, cooldown, Follow Player, protected work, and save/reload in outbound/visiting/returning phases.

## M10E validation ledger — accepted

- Hoomans exposes generic privacy-aware `GetSocialStatus`, `GetNPCSocialStatus`, `GetCommunityAbsences`, and `GetSemanticContext` projections with authoritative phase/state, public reason, bounded purpose/intent, and destination/ETA disclosure only for an authorized home-faction viewer.
- The Hoomans request seam accepts bounded commercial destination suggestions and returns evaluator decisions (`accepted`, `rejected`, or `deferred`) without directly starting or mutating travel. Excursion wording remains semantic-layer responsibility.
- Listener failures from both thrown callbacks and clean `false, reason` returns remain diagnostic and cannot interrupt the Hoomans-owned arrival lifecycle.
- Focused Hoomans participant/social/request coverage passes, including truthful local route context and outsider route/ETA privacy.

## M10F validation ledger — accepted

- Base-less DT caravan production coverage drives Hoomans destination selection and abstract travel through settlement A, B, and C while retaining no home/base, avoiding admission, preserving exact stock, and applying at most one exchange per destination.
- Bounded recent-visit cooldown and monotonic travel revisions prevent A↔B replay/ping-pong; hostile/invalid targets, encounter-delayed arrivals, duplicate arrivals, save/reload, retry, and pressure/logistics consequences are covered.
- Resident and caravan focused tests pass DynamicTrading `3/3`; the affected Hoomans excursion/mobility regressions pass `3/3`; DynamicTrading's full suite passes `41/41`; and a clean committed Hoomans snapshot at `16d1635e` passes `936/936`. The live Hoomans worktree's full runner is currently blocked only by preserved unrelated semantic/MP edits (three failures in those dirty files), which were neither staged nor changed by this chunk.
- Hoomans M10D–M10F implementation is committed locally as `16d1635e` but is not pushed because local `main` contains unrelated ahead history. DynamicTrading scoped implementation commit `d9a6a8cd` is pushed to `origin/main`; unrelated local work remains unstaged.
