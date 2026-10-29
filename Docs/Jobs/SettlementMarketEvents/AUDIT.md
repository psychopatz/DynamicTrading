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
