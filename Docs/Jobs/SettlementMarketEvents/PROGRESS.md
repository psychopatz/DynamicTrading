# Progress — Settlement Market, Events & Trader Mobility

## Parent status

**IN PROGRESS — M0–M9D market/runtime engine work accepted; M9E resident/publication closure and M10 Community Excursions & Commercial Trader Mobility are mandatory before native SP/MP handoff.**

The complete M0–M10 roadmap is the parent completion boundary. A chunk or phase completing does not complete the parent objective.

## Planning baseline

DynamicTrading audited `main`:

`9ee65f0be58bdea00a1f1532173ec9fa8afee021`

Legacy behavioral reference:

`ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`

Contemporaneous Project Hoomans audit:

- local `main`: `6768843e`;
- `origin/main`: `8632bc30`;
- required generic settlement-arrival observer commit `2200b866` existed locally but was not contained by any remote branch.

Recheck both repositories before acting because Project Hoomans is concurrently changing.

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

Latest accepted DynamicTrading evidence at the M9 audit:

- full DT suite: `37/37`;
- DTHoomans bridge: `83 checks, 0 failures`;
- affected Hoomans mobile-settlement / abstract-world / composition regressions passed;
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

### Verified developer gaps

1. **Resident market context**
   `DTHoomans_SettlementTrader.EnsureTraderForFaction` binds the staffed trader but does not yet guarantee canonical home market provisioning/current pricing context before any mobile visitor arrives.

2. **Cross-repo publication**
   The generic Hoomans arrival observer used by M9 was local-only at audit time.

3. **Roaming caravan destination lifecycle**
   DT generates caravans with `mobileControlMode = strategic` and `mobilePathMode = random`. Hoomans' ordinary settlement-departure scheduler requires ambient street-roaming groups, so production DT caravans do not naturally use that settlement-to-settlement selector.

4. **Unsafe admission semantics**
   Hoomans currently distinguishes `settlement_admission` and `hostile_contact`, not a generic temporary non-admission settlement visit. AI admission has a configured 35% default member join chance. Commercial visitors must never use that path.

5. **Resident excursion lifecycle**
   Resident traders have no generic PREPARING → OUTBOUND → VISITING → RETURNING_HOME lifecycle and no exact-home commercial return behavior.

6. **Semantic/public absence facts**
   No generic Hoomans public excursion projection yet exposes authoritative "trader is away / trading run / rough destination / ETA" state for semantic consumers.

7. **Stale caravan-base comments**
   Some DT caravan comments still claim a leader "stays at the base" or imply an idle-at-base variant. The approved roaming trader is base-less; do not implement a fake base to match stale comments.

## Current phase

**M9E — Resident Market Context + Cross-Repo Publication Closure**

## Next Chunk — M9E

Start by closing the small existing-runtime gaps before building the broader excursion system.

### Required work

1. Read DynamicTrading root `AGENTS.md` and this job package in runbook order.
2. Inspect DynamicTrading local/remote status, HEAD, dirty files, and worktrees.
3. Before touching Project Hoomans, read its root `AGENTS.md` and inspect its local/remote status, ahead commits, dirty files, and worktrees.
4. Re-audit the current resident settlement-trader binding path and canonical faction→community lookup.
5. During resident binding:
   - resolve active Hoomans `community.id`;
   - idempotently provision its DT market;
   - establish explicit resident home/current market pricing context;
   - do **not** call `MarkSettlementVisit`;
   - do **not** trigger exchange or pressure mutation;
   - keep home identity distinct from last actual commercial visit.
6. Add fail-first acceptance:
   ```text
   brand-new staffed settlement
   + no mobile arrival
   + no DT market
   → bind resident trader
   → exactly one market exists
   → resident snapshot/quote uses local market
   → stock/budget/pressure unchanged by binding
   → repeat/save-reload remains idempotent
   ```
7. Re-audit required Hoomans observer commit `2200b866` against current history. Reconcile/publish safely; never blindly push unrelated unverified intervening work.
8. Make generic arrival-listener clean `false, reason` results observable without allowing a consumer failure to break the Hoomans-owned arrival lifecycle.
9. Run focused DynamicTrading and Project Hoomans regressions, Lua/Kahlua/static/diff checks, update this ledger, and commit/push coherent in-scope work when fast-forward-safe.

### M9E gate

M9E is accepted only when:

- a resident trader has correct local market context from first binding without a fake visit/exchange;
- the required generic Hoomans observer is present in the safely published dependency graph, or a genuine publication blocker is precisely documented;
- unrelated local work remains preserved.

After M9E, continue automatically into M10. Do not stop for another `/goal`.

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
