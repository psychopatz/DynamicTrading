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

1. **Resident excursion production policy**
   Generic excursion persistence now exists, but resident traders still need a rare purposeful commercial excursion policy, exact-home travel integration, and home availability restoration.

2. **Semantic/public absence integration**
   Hoomans now exposes generic public excursion state, but semantic context still needs privacy-aware consumption and truthful trader-location presentation.

3. **Flagship/failure hardening**
   The two production lifecycles still need end-to-end replay, save/reload, encounter, retry, protected-task, and semantic-status acceptance coverage.

## Current phase

**M10D — Resident Trader Commercial Excursions**

## Next Chunk — M10D

M10C is accepted. Continue with rare purposeful commercial excursions for settlement-owned traders.

### Required work

1. Re-audit settlement trader staffing, home identity, facility/work ownership, Follow Player, trader availability, and the generic Hoomans excursion APIs.
2. Add a bounded production policy that can prepare a resident trader for a worthwhile and safe commercial destination without converting the home faction into a mobile group.
3. Reuse generic Hoomans excursion phases, abstract travel, encounters, temporary settlement visits, exact-home return, failure/retry, presence/LOD, and persistence.
4. Keep the original `community.id` and faction membership authoritative throughout; carry the existing merchant stock and make the trader unavailable for home trade while away.
5. Add focused resident lifecycle coverage for policy gates, destination visit, exact-home return, cooldown, protected work, Follow Player, save/reload, and idempotent arrival/exchange.
6. Run focused cross-repository regressions, Lua/Kahlua/static/persistence/diff checks, update this ledger, and commit/push coherent in-scope work only when fast-forward-safe.

### M10D gate

M10D is accepted only when:

- a settlement-owned trader leaves only through a bounded purposeful policy;
- original faction/community membership and canonical home identity remain unchanged;
- Hoomans owns the excursion, safety, travel, encounters, exact return, and temporary visit lifecycle;
- the trader carries the exact existing stock, is unavailable at home while away, and restores home availability on return;
- cooldown and protected-task/Follow Player gates prevent unsafe or immediate repeat departure;
- unrelated local work remains preserved.

Continue automatically into M10D. Do not stop for another `/goal`.

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

Immediate next chunk: M10D resident trader commercial excursions. Continue automatically through M10F.
