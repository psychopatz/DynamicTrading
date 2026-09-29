# Dynamic Trading Rebuild Roadmap

## Exploratory legacy audit

**Status:** audit complete; implementation intentionally not started  
**Audit date:** 2026-09-26  
**Legacy reference:** `legacy` / `ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`  
**Current starting point:** `main` / `58829d2a` (`chore: add Steam Workshop rewrite scaffold`)

This document records what the legacy Dynamic Trading code actually contained and proposes a rebuild order. It is a design and discovery artifact, not a claim that the legacy implementation should be copied wholesale.

## Executive conclusion

The legacy system was two products sharing one economic and trading core:

1. A **non-physical-NPC path** based on radio scanning, saved trader contacts, remote conversations, stock requests, and the common trading window.
2. A **physical-NPC path** in Dynamic Trading V2 based on a custom `DTNPC` runtime, trader dialogue, physical visits, NPC travel, trade cycles, and the same common trading window.

The rebuild should preserve the shared market domain and the first path, but replace the legacy `DTNPC` runtime with Project Hoomans. MarketSense should become the item taxonomy and intrinsic-pricing authority. Dynamic Trading should own the dynamic market overlay: stock, trader budgets, faction/economic modifiers, global heat, events, reputation, and authoritative transactions.

The target relationship is therefore:

```text
MarketSense item facts and intrinsic price
                │
                ▼
Dynamic Trading market domain
(stock, budgets, heat, events, factions, reputation)
                │
       ┌────────┴────────┐
       ▼                 ▼
Remote/radio mode   Project Hoomans NPC mode
contacts + proxy    semantic dialogue + NPC identity
       │                 │
       └────────┬────────┘
                ▼
Common trade session and server-authoritative transaction service
```

## 1. Audit basis and confidence

### Repositories examined

| Repository | Relevant state | Finding |
| --- | --- | --- |
| DynamicTrading | `legacy` at `ee0a8dc6` | Full former implementation: 2,055 tracked files. |
| DynamicTrading | `main` at `58829d2a` | Deliberately cleaned scaffold; no committed Lua implementation remains. |
| MarketSense | current local `main` | Public item, availability, capability, taxonomy, and pricing APIs are present. |
| ProjectHoomans | current local `main` | Semantic dialogue, group conversations, NPC authority, task contracts, and an existing MarketSense adapter are present. |

The DynamicTrading, MarketSense, and Project Hoomans working trees have unrelated local changes. This audit did not modify those changes.

### Evidence limitations

The codebase-memory index was checked first. Its DynamicTrading legacy project excludes the large Project Zomboid `media` subtrees, so the graph could not support negative or exhaustive claims about legacy Lua. The relevant legacy source was therefore read directly from the pinned legacy snapshot. The architecture audit was run against that snapshot with the Project Zomboid framework profile.

The architecture report is useful as a risk signal, not as a reason to reproduce the old structure:

| Scope | Files | LOC | Health | Main signal |
| --- | ---: | ---: | ---: | --- |
| Legacy production total | 1,423 parsed | 126,006 | 35.3/100 | Large, highly coupled system with no indexed tests. |
| DynamicTradingCommon | 923 | 61,411 | 24.3/100 | Core-domain/UI dependency cycles and persistence mixed into UI paths. |
| DynamicTradingV2 | 443 | 55,994 | 39.1/100 | NPC, network, UI, and behavior responsibilities are heavily entangled. |
| UI subsystem | 24 | 3,716 | 76.8/100 | Smaller risk area, but still has large layout and refresh functions. |

The report found 168 production findings, including the Common↔V2/UI dependency cycles, mutable global state, oversized handlers, and UI/persistence mixing. The rebuild should use the legacy behavior as a specification while introducing narrower boundaries.

## 2. What the legacy branch contained

### 2.1 Mod packaging

- `DynamicTradingCommon` was the shared library and economic runtime.
- `DynamicTradingV2` was the active Build 42 branch with factions and NPCs.
- `DynamicTradingV1` was explicitly marked **Permanently Disabled**, capped at Build 42.11, and incompatible with V2.
- The legacy README says quest/objective gameplay had moved to a separate Dynamic Objectives addon. Quest/objective code is not part of this rebuild baseline.

The current `main` branch contains only Workshop assets, metadata, and the rewrite scaffold. There is no implementation to preserve in place yet.

### 2.2 Shared market and economy core

The common library implemented a server/host-authoritative economic simulation using versioned ModData and network commands. The main state areas were:

- Global simulation state: hourly and daily ticks, scavenge efficiency, consumption modifiers, global heat, deflation, spectrum/frequency data, and event state.
- Factions and faction wealth/reputation.
- Trader archetypes and archetype-specific trade modes.
- Trader stock, restock timestamps, stock versions, identity, faction, archetype, and availability state.
- Trader sessions with a budget derived from faction wealth and sandbox settings.
- Global and faction events that modified prices, stock, heat, or other market behavior.
- Radio/radar roster information and contact-facing trader state.

The primary legacy evidence is under:

```text
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/Economy/
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/TraderSession/
```

The key state services were `DynamicTrading_Engine`, `DynamicTrading_Stock`, `DT_TraderSession`, the economy pricing/stock generators, and the network server/data handlers.

### 2.3 Legacy pricing and item selection

The old pricing provider reached into `DynamicTrading.Config.MasterList`, price configuration, item tags, archetype modifiers, and faction event modifiers. Stock generation and trade validation also depended on this local catalog.

This is the cleanest replacement point for MarketSense. MarketSense already exposes:

- `GetPriceDetails`, `GetPriceDetailsForInstance`, and `GetPrice`;
- `GetTags`, including primary/category/subcategory and expanded tags;
- `GetItemCapabilities`;
- `GetItemAvailability` and eligibility;
- stock ranges and yield resolution;
- registry access and asynchronous price-detail requests.

Dynamic Trading should consume these through one adapter rather than spreading direct MarketSense calls through the UI, stock generator, NPC bridge, and transaction handlers.

### 2.4 Transaction behavior

The legacy transaction path supported buy, sell, and gift-like transfers. The server:

1. Validated the trader, soul/faction state, archetype trade mode, session, stock, item identity, quantity, and money/budget.
2. Re-resolved inventory items on the server rather than trusting client item objects.
3. Applied condition-aware or bulk pricing as appropriate.
4. Mutated player inventory, trader stock, session budget, faction wealth, deflation, heat, and reputation.
5. Returned a bounded transaction result and synchronized stock/version data.

This server authority is a behavior requirement to preserve. The client may propose a transaction, but it must not decide the price, source item, stock quantity, or final side effects.

### 2.5 Non-physical-NPC gameplay: radio and remote contacts

The common library contained a complete remote-contact experience:

```text
Radio/HAM capability and frequency scan
        ▼
Trader/radar contact roster
        ▼
Per-character contact persistence
        ▼
Remote conversation or visit request
        ▼
Trader proxy/session and common trade window
        ▼
Authoritative stock and transaction commands
```

Important behaviors found in the legacy source:

- Walkie/HAM device capability and Electricity-skill checks gated scanning.
- Contacts were normalized and persisted in per-character player ModData with migrations.
- A contact stored stable IDs plus identity, archetype, faction, reputation, status, position, and visit/return state.
- The contact UI exposed roster status, faction, reputation, and radio-discovered traders.
- Remote or requested visits used stable trader identity and server-side validation; physical visit handling could use the V2 backend.
- The common trading UI used a provider/proxy rather than requiring the UI to know the complete NPC implementation.

This is the non-NPC gameplay mode to rebuild first. It gives us a usable market and transaction vertical slice without making the NPC runtime a prerequisite.

Relevant legacy areas:

```text
DynamicTradingCommon/.../client/DT/Common/UI/RadioScanner/
DynamicTradingCommon/.../client/DT/Common/Contacts/
DynamicTradingCommon/.../client/DT/Common/UI/Trading/
```

### 2.6 Physical-NPC gameplay: Dynamic Trading V2

V2 wrapped the common trade window in a custom NPC system:

```text
DTNPC physical NPC
        ▼
Trader dialogue hub
        ▼
Trade option / stock generation request
        ▼
Common DT trading window through V2 wrapper
        ▼
Common authoritative transaction service
```

The V2 source also included:

- NPC roster souls, identity, status, and trader state;
- scheduled trade cycles and faction dispatch plans;
- physical departure, travel, return, and visit requests;
- trader behavior, mobility, defensive behavior, and post/station logic;
- NPC synchronization, health, stamina, equipment, combat, bandit patches, and respawn/spatial-hash logic;
- dialogue, ambient dialogue, escort/follow interactions, and context menus.

For the rebuild, the first four trading-facing responsibilities are still relevant. The custom body, behavior, movement, combat, lifecycle, and respawn responsibilities belong to Project Hoomans and should not be recreated inside Dynamic Trading.

The most important legacy bridge files were:

```text
DynamicTradingV2/.../client/DT/V2/NPC/DTNPC_TradingHandler.lua
DynamicTradingV2/.../client/DT/V2/NPC/UI/DTNPC_TraderDialogue_Hub.lua
DynamicTradingV2/.../client/DT/V2/UI/TradingWindowWrapper/
DynamicTradingV2/.../client/DT/V2/DynamicTrading_Network_Client.lua
DynamicTradingV2/.../server/DT/V2/NPC/Manager/DTNPC_ManagerRespawn/
DynamicTradingV2/.../server/DT/V2/NPC/ServerCore/ServerCoreCommands/
```

### 2.7 Features advertised versus features evidenced

The legacy Workshop description advertised radio scanning, a living economy, archetypes, seasonal pricing, flash events, wallet/rummage behavior, server synchronization, and sandbox controls. It also listed future ideas such as a player-owned marketplace, deeper faction economics, objectives integration, and physical NPC spawning/couriers.

The source confirms the economic core, radio/contact flow, faction/reputation state, events, and substantial physical NPC trade-cycle behavior. The Workshop text is stale in places; source behavior and explicit tests should be treated as the authority during reconstruction. Future ideas should not be assumed implemented merely because they appear in the description.

## 3. Rebuild boundaries

### Preserve as behavior

- Stable trader identity and versioned stock.
- Hourly/daily global simulation and event hooks.
- Archetype/faction-aware stock and prices.
- Trader session budgets and faction wealth interaction.
- Buy, sell, and economic gift transaction semantics.
- Exact server-side inventory resolution and validation.
- Reputation, heat, deflation, and market-event effects.
- Radio scanning, contacts, remote proxy mode, and common trade presentation.
- Sandbox/configuration controls where they still make sense for Build 42.20.

### Replace with new boundaries

- The legacy MasterList/tag-based item catalog → a Dynamic Trading MarketSense adapter.
- Legacy intrinsic prices → MarketSense price details, with Dynamic Trading modifiers layered above them.
- `DTNPC` identity/soul/body ownership → Project Hoomans NPC identity and presence records.
- `DTNPC` dialogue hub → Project Hoomans conversation and semantic dialogue integration.
- Legacy NPC movement, combat, health, stamina, equipment, lifecycle, and respawn → Project Hoomans.
- Legacy NPC network synchronization → Project Hoomans replication/authority, with only a small trader-state bridge in Dynamic Trading.

### Explicitly out of the initial scope

- Recreating Dynamic Trading’s zombie-backed NPC engine.
- Bandit/combat systems and their patches.
- Escort/follower behavior except where Project Hoomans independently exposes it.
- Quest/objective gameplay from the separate Dynamic Objectives direction.
- A player-owned marketplace or courier system before the base transaction loop is stable.
- A broad refactor solely to improve the architecture score. Boundaries should be introduced where they protect behavior or enable the two modes.

## 4. Target contracts

These contracts are proposed so both gameplay modes use the same server market core.

### MarketSense item quote

The adapter should return a bounded, serializable quote/facts object containing only what Dynamic Trading needs:

```text
fullType
display/category identity
primary, subcategory, tags, expandedTags
availability and market eligibility
intrinsic/base price
instance-sensitive price when a concrete inventory item is supplied
stock range / yield information
capabilities and evidence needed by archetype rules
```

No Java inventory object, world object, function, or unbounded registry row should cross a network or persistence boundary.

### Trader identity and session

```text
traderID       stable server identity
npcID          optional Project Hoomans identity for physical mode
name/archetype/faction/gender/identity seed
status and trade availability
stockVersion/sessionVersion
budget and reputation snapshot
contact/return metadata when remote mode uses it
```

`npcID` is an integration reference, not a replacement for `traderID`. Remote traders must work without a loaded physical NPC.

### Trade request

```text
requestID
traderID
mode: remote | physical
operation: buy | sell | economic_gift
fullType/item key
quantity
stable item IDs for sell/gift resolution
session/stock version observed by the client
conversation/request provenance when originated by Project Hoomans
```

The request is a proposal. The server revalidates identity, proximity/permission when required, stock, money, item ownership, current MarketSense quote, session budget, and all dynamic modifiers.

### Trade result

```text
requestID, traderID, operation
accepted/status/reason
fullType, quantity, total value, reputation delta
updated stock/session version and bounded market summary
```

Responses should be safe for UI and semantic dialogue presentation. They should not expose raw engine objects or require either frontend to understand the other frontend’s implementation.

## 5. Project Hoomans integration direction

Project Hoomans already establishes the shape we need:

- `PNC/Semantics/PNC_SemanticMarketSenseAdapter.lua` is a narrow item-facts boundary rather than a mutation layer.
- Shared composition loads the MarketSense adapter and the semantic task contracts.
- `PNC_SemanticTaskRequest` normalizes bounded, primitive semantic requests.
- `PNC_SemanticTaskAdapter` and `RequestSemanticTask` provide a client transport seam.
- The server semantic task handler and `ActionPlanService` keep admission, persistence, scheduling, and effects authoritative.
- `PNC_ConversationGroup` interprets one group input and coordinates participant responses, with explicit primary-only handling for item-transfer behavior.

Dynamic Trading should follow these conventions:

1. Add a Project Hoomans integration adapter that resolves the current NPC record to a Dynamic Trading `traderID` and bounded trader snapshot.
2. Expose an explicit trade option in the conversation hub first. Add natural-language trade intents after the explicit route is proven.
3. For dialogue-originated requests, use a `REQUEST` semantic IR/action with stable `traderID`, operation, item reference, quantity, and request provenance.
4. Route atomic buy/sell/economic-gift operations to a Dynamic Trading authoritative transaction transport. Do not model a single atomic sale as a long-lived movement/action plan merely because it originated in semantic dialogue.
5. Return a bounded trade result to Project Hoomans for deterministic response presentation and conversation state update.
6. Keep social gifts in the Project Hoomans gift system separate from a market transaction. A player giving an item to an NPC for relationship purposes is not automatically the same as selling or gifting into trader stock.
7. For group conversations, parse once and dispatch at most one economic transaction for the addressed/primary trader unless a future design explicitly supports a multi-trader transaction.
8. Keep LLM output advisory. It may suggest a trade operation or item reference, but it must not bypass deterministic resolution or server validation.

## 6. Proposed implementation roadmap

### Phase 0 — Freeze the contracts and runtime assumptions

Before rebuilding behavior:

- Confirm Build 42.20 load order and the final MarketSense and Project Hoomans mod IDs.
- Decide whether both dependencies are hard requirements or whether remote-only mode can run without Project Hoomans.
- Record legacy sandbox options and decide which are retained, renamed, or removed.
- Define the ModData schema/version and migration policy from the new empty baseline.
- Write the stable-ID and request/result contracts above as small shared modules.
- Keep the two gameplay modes explicit in configuration and diagnostics.

**Exit condition:** a testable contract exists for item facts, trader identity, stock/session state, trade requests, and results.

### Phase 1 — Build the MarketSense adapter

Create one Dynamic Trading adapter around the public MarketSense API. It should provide functions equivalent to:

```text
GetItemFacts(fullType)
GetItemInstanceFacts(fullType, inventoryItem)
IsEligible(fullType)
GetStockRange(fullType)
GetQuote(fullType, traderContext, inventoryItem)
RequestFacts(fullTypes, callback)
```

Responsibilities:

- Normalize MarketSense category/tag/capability output into the Dynamic Trading quote shape.
- Treat MarketSense intrinsic price as the base, then apply dynamic heat, faction, event, archetype, and transaction-side modifiers in Dynamic Trading.
- Use instance pricing only at the authoritative sell/buy validation boundary when condition or vessel state matters.
- Cache bounded definition facts; do not scan the entire registry on every UI refresh.
- Handle unavailable/uncertain MarketSense results explicitly rather than silently treating every item as tradable.
- Keep adapter calls isolated so a MarketSense API change affects one seam.

**Exit condition:** a small adapter test suite can classify items, obtain definition and instance prices, reject ineligible items, and preserve evidence/source metadata.

### Phase 2 — Rebuild the server market core

Recreate the behavior of the legacy common systems with smaller modules:

- global simulation state and tick scheduling;
- factions, wealth, reputation, and event modifiers;
- archetype definitions and trade policies;
- stock generation and stock versioning;
- trader sessions and budgets;
- heat, deflation, consumption, and restock effects;
- server command routing and bounded sync payloads.

The stock generator should consume MarketSense facts and Dynamic Trading archetype policy. It should not reconstruct the old MasterList.

**Exit condition:** server-side tests can create a trader, generate deterministic stock, open a session, apply buy/sell/gift operations, update all economic state, and reject stale or invalid requests.

### Phase 3 — Deliver the non-NPC vertical slice first

Rebuild the remote path end-to-end:

```text
radio capability/scan
  → contact persistence
  → remote trader proxy
  → stock/session request
  → common trade window
  → authoritative buy/sell/economic-gift transaction
  → result, reputation, contact/session refresh
```

Keep the UI thin. It should render provider data and submit stable requests; it should not calculate prices or mutate ModData. Preserve the contact migration/version pattern, but simplify the legacy provider graph where possible.

**Exit condition:** a player with no physical NPC loaded can discover or use a contact and complete buy, sell, and rejected transactions in single-player and multiplayer-authoritative paths.

### Phase 4 — Add Project Hoomans trader identity and dialogue integration

Start with one physical trader scenario:

1. Project Hoomans supplies the NPC record, presence, conversation lease, and identity.
2. Dynamic Trading resolves that record to a stable trader ID and asks the market core for availability/session state.
3. An explicit conversation choice opens the common trade UI or submits a bounded trade request.
4. The transaction result returns to the conversation layer as a deterministic response/update.

Only after this works should semantic phrases such as “buy food,” “sell these rounds,” or “give me two bandages” be added. Natural-language resolution must use stable full types/item IDs and MarketSense facts, not fuzzy client-side item-name mutation.

**Exit condition:** a Project Hoomans NPC can participate in the same trade session and transaction service without any `DTNPC` body, behavior, combat, movement, or respawn code.

### Phase 5 — Reconcile physical visits, schedules, and group dialogue

Once the basic physical trader works:

- map legacy contact visit requests to Project Hoomans presence/task/arrival capabilities where available;
- let Project Hoomans own NPC travel, schedule, and presence state;
- let Dynamic Trading own whether that identity is open for trading and what market state it has;
- use `PNC_ConversationGroup` for one interpreted group turn and explicit primary/ addressed-trader policy;
- ensure a group input cannot duplicate an item transfer for every nearby NPC.

**Exit condition:** remote and physical paths share market outcomes, and group conversation behavior is deterministic under one-turn input.

### Phase 6 — Restore secondary market depth

After both vertical slices are stable, add or reintroduce:

- seasonal and flash events;
- faction demand/background effects;
- richer radio broadcasts and public market information;
- trader travel and temporary unavailability;
- wallet/rummage behavior if still desired;
- additional archetypes and stock policies;
- optional marketplace/courier systems as separate feature slices.

Each feature should identify whether it changes the market domain, remote frontend, Project Hoomans frontend, or only presentation.

### Phase 7 — Hardening and cleanup

- Add ModData migrations and recovery for partial saves.
- Add request idempotency, stale-version handling, timeout recovery, and reconnect refresh.
- Run Kahlua compatibility checks on all Lua.
- Add focused smoke tests before broad integration tests.
- Re-run architecture analysis and address only findings that still affect ownership, load order, authority, or behavior.
- Keep debug/telemetry output bounded and useful for market requests, stock versions, and semantic trade dispatch.

## 7. Verification matrix

### MarketSense adapter

- known, unavailable, excluded, and uncertain item;
- definition price versus instance-sensitive price;
- primary/category/subcategory/tags/capabilities;
- stock range and yield resolution;
- bounded cache and batch request behavior;
- MarketSense unavailable or API-shape mismatch produces an explicit reason.

### Market domain

- stock generation is deterministic for a fixed seed and state;
- restock/version increments are correct;
- buy consumes stock, money, and session budget;
- sell consumes exact server-resolved inventory objects and credits budget/money;
- economic gift changes stock/economy according to policy;
- heat, deflation, reputation, faction wealth, and event modifiers update once;
- duplicate request IDs and stale stock/session versions do not double-apply effects;
- single-player and multiplayer use the same authoritative service path where possible.

### Remote/non-NPC mode

- radio capability and scan gating;
- stable contact creation, migration, deletion, and per-character persistence;
- unavailable/away/returning trader state;
- remote stock request and reconnect refresh;
- common UI does not calculate authoritative prices;
- transaction timeout and late response handling.

### Project Hoomans mode

- physical NPC record resolves to one stable trader ID;
- explicit conversation trade choice works with deterministic dialogue only;
- semantic IR remains a bounded `REQUEST` with primitive trade payload;
- invalid or ambiguous item references require clarification;
- server rejects wrong NPC, wrong trader, wrong proximity/lease, stale stock, or invalid inventory;
- trade result is presented without raw engine objects;
- social gift and economic gift remain distinct;
- one group turn creates one intended transaction and ordered responses;
- LLM fallback cannot execute an unvalidated transaction.

### Project Zomboid runtime

- Build 42.20 load order and optional/required dependency behavior;
- Kahlua 5.1 compatibility;
- save/load and ModData migration;
- host, dedicated server, and client-only behavior;
- no client-side authority over prices, money, stock, reputation, or inventory transfer.

## 8. Open questions for implementation planning

1. Is Project Hoomans a hard dependency for the whole Dynamic Trading package, or only for physical-NPC mode?
2. Should remote traders be purely abstract contacts, or should a successful contact eventually materialize as a Project Hoomans NPC?
3. Does a physical Project Hoomans NPC receive a persistent Dynamic Trading `traderID`, or is the mapping generated from a persistent NPC identity seed?
4. Which legacy sandbox options are still desirable under MarketSense’s current pricing model?
5. Should trader stock be persistent per trader, regenerated from a deterministic seed, or hybridized with MarketSense availability changes?
6. Is “gift” in the rebuilt market intended to mean economic sell-to-stock, social gift, or both with separate UI/actions?
7. Which legacy faction effects are required for the first playable slice, and which can wait until Phase 6?
8. What is the intended behavior when MarketSense says an item is uncertain but the player has a concrete inventory instance?

## 9. Recommended first implementation slice

The safest first build target is deliberately narrow:

```text
MarketSense adapter
  → one archetype trader
  → one stock/session service
  → remote contact mode
  → buy and sell only
  → server-authoritative transaction result
  → common trade window
```

Then add one Project Hoomans physical trader using the same trader/session/transaction contract. This order proves the economic core and both frontend shapes before adding NPC travel, group dialogue, event richness, or legacy compatibility layers.

## 10. Audit evidence index

### Legacy DynamicTrading

```text
Contents/mods/DynamicTradingCommon/42.16/mod.info
Contents/mods/DynamicTradingV1/42.16/mod.info
Contents/mods/DynamicTradingV2/42.16/mod.info
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/DynamicTrading_Engine.lua
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/DynamicTrading_Stock.lua
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/TraderSession/DT_TraderSession.lua
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/Economy/
Contents/mods/DynamicTradingCommon/42.16/media/lua/shared/DT/Common/Faction/TradingSys/NetworkServer/
Contents/mods/DynamicTradingCommon/42.16/media/lua/client/DT/Common/UI/Trading/
Contents/mods/DynamicTradingCommon/42.16/media/lua/client/DT/Common/Contacts/
Contents/mods/DynamicTradingCommon/42.16/media/lua/client/DT/Common/UI/RadioScanner/
Contents/mods/DynamicTradingV2/42.16/media/lua/client/DT/V2/NPC/
Contents/mods/DynamicTradingV2/42.16/media/lua/client/DT/V2/UI/TradingWindowWrapper/
Contents/mods/DynamicTradingV2/42.16/media/lua/server/DT/V2/NPC/
```

### MarketSense

```text
Contents/mods/MarketSense/common/media/lua/shared/MarketSense/MS_PublicAPI.lua
Contents/mods/MarketSense/common/media/lua/shared/MarketSense/MS_ItemsRegistry.lua
Contents/mods/MarketSense/common/media/lua/shared/MarketSense/MS_Pricing.lua
Contents/mods/MarketSense/common/media/lua/shared/MarketSense/MS_ItemCapabilities.lua
Contents/mods/MarketSense/common/media/lua/shared/MarketSense/MS_ItemAvailability.lua
```

### Project Hoomans

```text
Contents/mods/ProjectHoomans/42.20/media/lua/shared/PNC/Composition/PNC_SharedComposition.lua
Contents/mods/ProjectHoomans/42.20/media/lua/shared/PNC/Semantics/PNC_SemanticMarketSenseAdapter.lua
Contents/mods/ProjectHoomans/42.20/media/lua/shared/PNC/Semantics/PNC_SemanticTaskRequest.lua
Contents/mods/ProjectHoomans/42.20/media/lua/client/PNC/Semantics/PNC_SemanticDialogueInput.lua
Contents/mods/ProjectHoomans/42.20/media/lua/client/PNC/Semantics/PNC_SemanticTaskAdapter.lua
Contents/mods/ProjectHoomans/42.20/media/lua/client/PNC/Conversation/PNC_ConversationGroup.lua
Contents/mods/ProjectHoomans/42.20/media/lua/server/PNC/Networking/Handlers/PNC_ServerSemanticTaskCommandHandler.lua
Contents/mods/ProjectHoomans/42.20/media/lua/server/PNC/Semantics/PNC_SemanticActionPlanService.lua
Contents/mods/ProjectHoomans/42.20/media/lua/server/PNC/Semantics/PNC_SemanticTaskRequestService.lua
```
