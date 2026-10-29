# Audit — Settlement Market & Events

## Baseline

Repository: `psychopatz/DynamicTrading`

- Legacy reference: `legacy` at `ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`
- Current planning baseline: `main` at `f4899384f4cffb2bfaaaa33a0846100e314d2b48`

The current working tree also contains an unrelated local edit to:

`Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`

This job must preserve that work and never fold it into market/event commits unless the change is independently verified as required.

## M0A source-audit result

M0A verified the current lifecycle and guardrails before introducing market
state:

- `DTCommon_TraderService.Snapshot` reloads the persisted trader inventory and
  never seeds stock on UI open or reopen.
- `DTCommon_TraderService.MarkSettlementVisit` is the existing authoritative
  visit seam. The policy now requires an explicit settlement identity and
  records the last canonical settlement while retaining duplicate visit
  protection.
- Project Hoomans' active `community.id` is the canonical settlement identity;
  `factionID` is the owner and `siteID` is the physical location.
- Hoomans' registered arrival handlers are the lifecycle integration point. A
  server-only `dynamic_trading_settlement` adapter resolves the active
  community and arriving trader NPC, then forwards one idempotent visit to DT.
  It does not own movement, staffing, or a second settlement identity.
- MarketSense `GetTags`, `GetItemAvailability`, and `GetPriceDetails*` remain
  the bounded taxonomy and intrinsic-value seams. No DT manual item catalog was
  added.

The M0A contract tests cover persistent snapshots, settlement identity,
duplicate visits, arrival forwarding, and server authority. M0A intentionally
does not add settlement market or event state.

## Legacy behavior used as reference

Legacy Dynamic Trading included a much broader economy:

- trader archetypes and preferences;
- persistent trader stock and budgets;
- factions and reputation;
- global market pressure / heat;
- deflation / recovery;
- seasonal effects;
- market events;
- radio contacts and trader availability;
- supply/demand-style price and stock effects.

This goal intentionally narrows that baseline to:

1. settlement-centered local markets;
2. persistent trader stock;
3. settlement-bound stock exchange/refresh;
4. market-aware pricing;
5. typed market events;
6. logistics-driven propagation between settlements;
7. grounded world-knowledge/radio presentation.

Do **not** revive the legacy DTNPC body/movement/combat/lifecycle runtime, manual item MasterList, legacy intrinsic-price database, or monolithic dialogue system.

## Current implementation seams

### Trader persistence

`DTCommon_TraderRegistry.lua` currently persists stable trader records including:

- trader ID;
- role;
- caravan/settlement-linked identifiers;
- budget;
- stock version;
- faction binding;
- physical trader/NPC binding.

This is the foundation to preserve.

### Trader stock

`DTCommon_TraderStock.lua` currently:

- stores compact persistent stock;
- seeds a bounded initial stock only at trader creation;
- prices definitions/instances through MarketSense-backed quote logic;
- exposes stock snapshots and sell rows.

The current first-time seed is a bootstrap, not the desired ongoing market lifecycle.

### Settlement visit/restock seam

`DTCommon_CoreActorPolicy.lua` already contains the most important lifecycle hooks:

- `Policy.MarkVisit(record, options)` requires `options.atSettlement == true`;
- `Policy.Restock(record, stock, options)` also requires `atSettlement`;
- restock can be `earnedOnly`;
- restock has interval/nextAt/lastAt/count state;
- trader availability and actor/provider state are already compactly persisted.

`DTCommon_TraderService.lua` exposes:

- `Service.Restock(traderID, options)`;
- `Service.MarkSettlementVisit(traderID, options)`;
- `Service.SetCoreActorAvailability(...)`;
- `Service.BindCoreActor(...)`;
- existing server-authoritative stock/settlement transaction paths.

This means the new market should evolve the existing settlement visit/restock seam rather than create a parallel lifecycle.

## Current market limitation

The current MVP intentionally focuses on safe commerce. It does **not** currently implement:

- local settlement supply/demand;
- dynamic scarcity;
- market recovery;
- faction/settlement market profiles;
- typed market events;
- event-driven availability;
- logistics propagation between settlements.

Current buy/sell pricing is primarily MarketSense intrinsic value plus simple trading policy. This job adds a Dynamic Trading-owned market overlay without replacing MarketSense.

## Required preservation

The following current improvements are mandatory foundations and must not regress:

- MarketSense is intrinsic-value and taxonomy authority;
- unknown/modded items can participate without a DT manual price registry;
- trader stock is compact and persistent;
- settlement is server-authoritative;
- exact item identity and state-aware pricing remain enforced;
- replay/stale-version/security protections remain;
- Project Hoomans owns NPC body/movement/lifecycle;
- DTAbstract/DTHoomans remain thin access/provider fronts;
- current Radio OS / Talk / WorldKnowledge integrations remain reusable presentation channels.

## Audit conclusion

The correct next step is **not** to restore the old economy files.

The correct next step is to introduce a compact `SettlementMarket` domain and evolve settlement restock into a bounded `SettlementExchange` that operates on persistent trader stock.

The first proof must be deterministic and small:

- two settlements with different food market profiles;
- one persistent trader;
- trader acquires food in a surplus settlement;
- trader later supplies a shortage settlement;
- local food pressure and price move in the expected directions;
- no stock reroll occurs;
- then a food-shortage event modifies the same pipeline without special-case transaction code.

## Post-M8 runtime activation audit

Audit baseline: `main` at `96303d91a1f44270c43b71581e92e619e2448541`.

M0–M8 implemented and regression-tested the engine, but a repository audit found four production activation gaps that invalidate the claim that only native SP/MP remains:

1. **Settlement markets are not provisioned by gameplay.** `SettlementMarket.GetOrCreate` has no production caller. The two-settlement tests explicitly pre-create their markets, while production exchange resolves with `SettlementMarket.Get` and can therefore return `market_not_found` for an ordinary Hoomans settlement.
2. **The ordinary Hoomans mobile-settlement lifecycle does not drive DT exchange.** `DTHoomans.Settlement.StartTraderTravel` and the `dynamic_trading_settlement` arrival action are exercised by tests, but no production caller starts that DT-specific path. Project Hoomans already owns normal mobile settlement arrival through `PNC.MobileSettlementVisitService`; DT must observe that lifecycle rather than requiring DT-owned journey initiation.
3. **Recovery is an unused engine primitive.** `SettlementMarket.Recover` has no production caller, so changed market pressure does not naturally return toward profile baselines during ordinary gameplay.
4. **Events have no production producer.** `MarketEvents.Register` is called by tests but has no production caller, so Food Shortage/Agricultural Surplus definitions cannot arise on their own in a normal game.

The existing `33/33` DT suite and `83/0` Hoomans bridge results are valid evidence for the engine they cover, but they do not close these runtime call-site gaps because the tests manually create/drive the missing state.

Therefore the parent goal was reopened for mandatory **M9 Runtime Market Activation**. M0–M8 remain accepted engine work and must not be rewritten.

## Post-M9 trader-mobility audit

Audit baseline: DynamicTrading `main` at `9ee65f0be58bdea00a1f1532173ec9fa8afee021` plus the contemporaneous Project Hoomans checkout.

M9 successfully implemented production market provisioning, lazy recovery, event production, and a no-fixture mobile-arrival lifecycle. The remaining product gap is no longer the market engine; it is **trader lifecycle ownership and commercial mobility**.

### Two trader types are real and must remain distinct

1. **Settlement-owned resident trader** — a normal non-mobile Hoomans settlement member with role `trader`. It currently stays at its settlement and has no excursion/return-home lifecycle.
2. **Base-less roaming trader/caravan** — an independent Hoomans mobile faction spawned/maintained by Dynamic Trading. It has no real home settlement and should remain perpetually mobile.

### Resident-trader gap

`DTHoomans_SettlementTrader.EnsureTraderForFaction` binds the DT merchant record to the staffed settlement trader, but at the audited baseline it does not provision/bind the resident trader's canonical `community.id` market context. A resident can therefore be traded with before any mobile visitor has provisioned that settlement and receive neutral/unresolved market context.

Resident traders also have no purposeful excursion lifecycle. If this is added, the trader must remain a member of the original settlement faction/community and must return to that exact home community rather than converting the whole settlement faction into a mobile group.

### Roaming-caravan gap

Dynamic Trading currently creates caravans with `mobilePathMode = random` and `mobileControlMode = strategic`. Project Hoomans' ordinary settlement-departure pump only admits ambient street-roaming groups, so DT caravans bypass the generic settlement-to-settlement selector under normal production configuration.

The accepted M9 arrival tests prove that the economy reacts correctly **if** a trader reaches a settlement; they do not prove that a production DT caravan naturally chooses and reaches commercial settlements.

### Admission is unsafe for commercial travel

Current Hoomans settlement travel purposes are `settlement_admission` and `hostile_contact`. Neutral AI-settlement admission may transfer visiting members into the destination settlement; the default configured AI join chance is 35%.

That is valid for refugees and invalid for commercial caravans. Enabling trader settlement hopping through the admission path could dissolve a caravan into the destination faction.

A generic non-admission temporary settlement-visit purpose is therefore mandatory before commercial trader routing is enabled.

### Abstract/live split is already correct

Project Hoomans deliberately abstracts materialized mobile members when beginning long-distance settlement travel. `AbstractTraversal` owns cross-map travel/encounter progression, while live Hoomans behavior owns nearby roaming, interaction, combat, and local activity. Preserve this scalability boundary.

### Existing failsafes to reuse

Hoomans already protects or models:

- active travel rejection;
- active settlement-visit gating;
- encounter-delayed arrival and pending-arrival retry/cancel;
- invalid destination recovery;
- Follow Player and protected facility/activity ownership;
- LOD repair/materialization;
- bounded departure scheduling;
- home-return retry semantics through `PNC.HomeDutyService` for player-colony residents.

Do not recreate these in Dynamic Trading.

### Semantic/public-state requirement

The desired dialogue capability — e.g. a faction local truthfully answering that its trader is away on a trading run — should consume a **generic Hoomans excursion/public-status projection**, not inspect DT travel internals or hard-code trader-specific sentences.

The foundational Hoomans excursion model should be purpose-agnostic so future medics, envoys, scouts, couriers, recruiters, rescue parties, or commercial visit requests can use the same lifecycle.

### Cross-repo publication gap

At audit time Project Hoomans commit `2200b866` (`feat: expose mobile settlement arrival observers`) existed locally but was not contained by any remote branch, while the local Hoomans `main` also contained unrelated newer semantic-combat commits. The required observer contract must be reconciled/published safely; do not blindly publish unrelated local work merely to satisfy Dynamic Trading.

The parent goal therefore remains developer-active for **M9E Resident/Publication Closure** and **M10 Community Excursions & Commercial Trader Mobility**.

## Post-M10F publication + semantic-spatial audit

Audit baseline:

- DynamicTrading local/main = origin/main at `447cc27a65c9c7aca413eff77b5fc8e57d2fded5`;
- ProjectHoomans local `main` = `7df32a633db81f4d74940790f2ae6eb65c42974c`, clean but 9 commits ahead of `origin/main` `fb5c75664cae94889798de8e51fe5e8ad2abfa33`;
- PsychopatzCore local/main = origin/main at `ea5a1c7c8ec8c97efe87a2a233cbc61419a7a862`.

M10D–M10F implementation itself is credible: the clean committed Hoomans snapshot at `16d1635e` paired with pushed DynamicTrading `447cc27a` reproduced the reported full Hoomans suite (`936/936`), and DynamicTrading's full suite passed `41/41`.

However, developer completion is still blocked by two verified gaps.

### Published dependency graph is incomplete

A clean published-pair audit using DynamicTrading `origin/main` + ProjectHoomans `origin/main` fails the M10 resident/caravan tests because published Hoomans does not yet contain:

- `PNC_CommunityExcursionService.lua`;
- `PNC_CommercialMobilityService.lua`.

The local Hoomans ahead history interleaves required M10 commits with unrelated semantic-scene commits. Therefore "implemented locally and tested" is not equivalent to "published dependency graph complete".

M10G must reconcile/publish the minimal required Hoomans implementation safely and prove the exact published repository heads together.

### Excursion semantic API is not wired into production dialogue

Hoomans now exposes privacy-aware generic APIs such as:

- `GetSocialStatus`;
- `GetNPCSocialStatus`;
- `GetCommunityAbsences`;
- `GetSemanticContext`.

At the audited baseline, production semantic code does not call `GetSemanticContext`; the relevant callers are the service itself and tests. Therefore "Where is your trader?" is still an API-level proof, not a production semantic/NLU/fact/realization feature.

M10G must wire a generic role-whereabouts fact into the real semantic pipeline.

### Settlement names are already authoritative in Hoomans

Communities already carry a generated/renamable human-facing `community.name` and authoritative home/site coordinates. Destination presentation should resolve those current records on demand from `destinationCommunityID`.

Do not persist copied settlement names into excursion state.

### No reusable Core compass/spatial-language service exists yet

PsychopatzCore has generic world/actor/location infrastructure and isolated direction math in UI/event-marker code, but no reusable shared point-to-point semantic spatial service.

M10G therefore adds a reusable Core spatial relation/language foundation per `SPATIAL_LANGUAGE.md`, then makes Hoomans the first consumer.

The parent goal remained developer-active for **M10G Publication + Semantic Spatial Integration Closure** at that audit point.

## Post-M10G tactical spatial extension audit

Current accepted/published foundation:

- PsychopatzCore now provides `PsychopatzCore.SpatialRelation.Between(...)`;
- the PZ axis convention is frozen in Core: +X east, +Y south;
- Core already provides world-cardinal direction, distance, SAME_AREA, optional distance bands, and translation-safe labels;
- Project Hoomans production semantics already consumes world-cardinal place facts for trader whereabouts;
- Hoomans live bodies expose actual forward orientation through `getForwardDirection()`, and existing pathing/facing code already reads this vector with bounded last-facing fallback.

The user-approved new capability is observer-relative tactical direction suitable for immediate callouts such as:

> "Zombies, eight o'clock!"

or:

> "Hostiles at three o'clock!"

This is a **second reference frame**, not a replacement for world-cardinal direction.

### Why this belongs in Core

The math is generic:

```text
observer position
+ target position
+ observer forward vector
→ relative angle
→ clock hour / coarse egocentric sector
```

Core must remain unaware of zombies, hostiles, NPC traits, dialogue, or combat.

### Why live facing belongs to Hoomans

Clock position is meaningful only relative to an observer heading.

Hoomans already owns materialized NPC bodies and their engine forward vector. It should expose/reuse one authoritative facing adapter rather than duplicate `getForwardDirection()` extraction in each semantic/combat consumer.

### Clock bearings are ephemeral

Do not store `8 o'clock` as durable knowledge.

The observer can turn and the target can move. Persist/retain target identity/location/fact as appropriate, then recompute the clock relation at callout time from current geometry.

For abstract/offscreen actors with no trustworthy heading, omit clock bearing rather than invent it.

### Threat selection remains outside Core

Hoomans perception/combat/awareness continues to decide:

- which zombie/hostile is perceived;
- current visibility/freshness;
- salient target or cluster;
- combat/alert context.

Core only converts chosen geometry into reusable spatial tokens.

### Semantic style remains downstream

Clock language should be available to tactical/military/guard/raider or urgent coordinated speech, while ordinary NPCs may prefer coarse egocentric wording such as:

> "Zombies behind us, left side!"

The same canonical relation supports both.

Therefore the parent goal is reopened for bounded **M10H Observer-Relative Tactical Bearings**. M0–M10G remain accepted and must not be reworked without evidence of regression.
