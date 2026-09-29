# Dynamic Trading Foundation Plan

## Purpose

This is the adjustable implementation plan for the first Dynamic Trading foundation. It is intentionally smaller than the legacy roadmap.

The first playable target is:

```text
One simple trader caravan
        │
        ├── physical access through Project Hoomans NPCs
        └── optional remote/radio access through DTAbstract
```

The trading rules can be redesigned later without replacing the module boundaries or the trader identity contract.

## Proposed modules

| Module | Role | Optional? |
| --- | --- | --- |
| `DTCommon` | Shared trader identity, market data, trade session, transaction authority, and shared contracts. | No for Dynamic Trading. |
| `DTHoomans` | Project Hoomans integration and the physical NPC trader/caravan experience. | Yes, if remote-only mode is supported. |
| `DTAbstract` | Abstract trader access: radio, contacts, remote conversation, and remote trade access. | Yes. |

### Dependency shape

```text
                 DTCommon
                /         \
               /           \
       DTHoomans          DTAbstract
       physical NPC      remote/radio access
               \           /
                same trader/session data
```

Neither frontend should own a second copy of prices, stock, trader money, or transaction rules.

## First foundation decision

The first caravan should be a **stationary trading encounter**:

- one Project Hoomans NPC;
- one stable Dynamic Trading trader ID;
- one caravan/trader label and simple visual identity;
- a small stock list supplied through the common market layer;
- a simple buy/sell interaction;
- no caravan travel, convoy members, combat, escorting, or advanced faction simulation yet.

“Caravan” initially describes the trader encounter and its identity. Movement can be added later without changing how a trade is validated.

## Module 1 — DTCommon

### Owns

- Stable trader IDs.
- Trader definitions and snapshots.
- Basic trader profile: name, role, caravan identity, and availability.
- Trader stock and stock version.
- Player trade session.
- Buy and sell request contracts.
- Server-authoritative validation and transaction results.
- Shared configuration and debug state.
- MarketSense adapter boundary.
- Common logging and diagnostics.

### Does not own

- NPC body creation or movement.
- Project Hoomans conversation state.
- Radio UI or contact presentation.
- Client-side authoritative prices or inventory mutation.

### Initial common data

```text
TraderDefinition
  traderID
  displayName
  traderRole
  caravanID
  factionID (optional)
  stockProfile
  startingBudget
  accessPolicy

TraderSnapshot
  traderID
  displayName
  status
  stockVersion
  budget
  physicalNpcID (optional)
  abstractAccessEnabled

TradeRequest
  requestID
  traderID
  operation: BUY | SELL
  fullType
  quantity
  itemIDs (for SELL)
  observedStockVersion
  accessMode: NPC | ABSTRACT

TradeResult
  requestID
  traderID
  accepted
  operation
  reason
  quantity
  totalValue
  stockVersion
  updatedTraderSnapshot
```

All persisted and networked data must remain primitive and bounded. Java item objects and NPC objects stay at the runtime edge.

### Initial common behavior

1. Register one debug trader definition.
2. Create or retrieve one stable trader record.
3. Generate a small valid stock list.
4. Open a trade session for a player.
5. Validate buy/sell requests on the authoritative side.
6. Return a bounded result and updated stock version.

MarketSense should provide item identity, classification, eligibility, and base price through one adapter. Dynamic Trading-specific modifiers can be added later without changing either frontend.

## Module 2 — DTHoomans

### Owns

- Project Hoomans load-order integration.
- Mapping a Project Hoomans NPC ID to a Dynamic Trading trader ID.
- Physical trader/caravan presentation.
- Opening a conversation with the trader.
- Opening or requesting the common trade session.
- Physical access validation before a trade.
- NPC-side trade feedback.

### Does not own

- A second economy.
- A second stock list.
- Price calculation.
- Inventory mutation outside the common transaction service.
- A replacement NPC body, behavior, movement, combat, or respawn system.

### Initial physical flow

```text
[Debug] Spawn Trader
        ▼
Project Hoomans creates or exposes the NPC
        ▼
DTHoomans binds npcID → traderID
        ▼
Player talks to the trader
        ▼
Trade option opens the common session
        ▼
DTCommon validates buy/sell
        ▼
Project Hoomans presents the result
```

The first version may use an explicit “Trade” dialogue option. Natural-language trade requests should be added only after the explicit transaction path works.

## Module 3 — DTAbstract

### Owns

- Optional abstract trader access.
- Radio discovery or contact presentation.
- Remote trader contact state.
- Remote conversation entry point.
- Requesting a common trade session without a loaded physical NPC.
- Abstract-mode feedback and availability display.

### Does not own

- A separate trader identity.
- A separate stock list.
- Different prices from the physical trader.
- Physical NPC spawning or movement.
- Transaction authority.

### Initial abstract flow

```text
DTAbstract enabled
        ▼
Trader is discoverable through the abstract/radio channel
        ▼
Player selects the trader contact
        ▼
DTAbstract requests the same traderID/session
        ▼
DTCommon validates the trade
        ▼
Abstract UI or radio response presents the result
```

### Access-mode rules

| Enabled modules | Expected access |
| --- | --- |
| `DTCommon` only | Shared data exists; no player-facing trader channel yet. |
| `DTCommon` + `DTHoomans` | Physical NPC trading. |
| `DTCommon` + `DTAbstract` | Remote/radio trading without a physical NPC. |
| All three | The same trader can be reached physically or through radio/abstract access. |

The same trader ID must resolve to the same stock, budget, and transaction state regardless of access mode.

## Exact debug feature

The first debug entry must be named exactly:

```text
[Debug] Spawn Trader
```

### Planned behavior

- Add the entry to the appropriate world/NPC context menu.
- Show it only in debug mode or behind the project’s debug setting.
- Use the clicked square or player position as the spawn location.
- Request authoritative creation of the debug trader/NPC.
- Create or reuse the common trader record.
- Bind the spawned NPC to that trader ID.
- Return a clear success or failure message.
- Prevent duplicate trader records when the same debug trader is spawned again.

### Ownership proposal

- `DTHoomans` registers the physical spawn action because it knows how to create or expose a Project Hoomans NPC.
- `DTCommon` owns the trader record creation/retrieval and trader ID.
- `DTAbstract` may register a separate debug action later for abstract-only discovery, but it should not duplicate `[Debug] Spawn Trader`.

### Debug acceptance criteria

- The context menu contains the exact label `[Debug] Spawn Trader`.
- Selecting it produces one usable trader NPC.
- The NPC has one stable trader ID.
- Talking to the NPC exposes a trade action.
- A buy or sell request reaches DTCommon.
- Invalid requests are rejected without changing inventory or stock.
- Reopening or reconnecting does not create a second trader record accidentally.

## Foundation implementation phases

### Phase 1 — Module packaging

- [ ] Decide final folder names and mod IDs for `DTCommon`, `DTHoomans`, and `DTAbstract`.
- [ ] Create Build 42.20 module manifests.
- [ ] Define dependency and load order.
- [ ] Define whether `DTHoomans` and `DTAbstract` are optional addons or required modules.
- [ ] Add minimal shared/client/server entry points.
- [ ] Confirm the three modules load without gameplay code.

**Stop point:** all three modules are recognized by Project Zomboid and load in the intended order.

### Phase 2 — DTCommon contracts and debug trader record

- [ ] Add the trader definition and snapshot contracts.
- [ ] Add stable trader ID generation.
- [ ] Add one debug trader profile.
- [ ] Add stock and stock-version state.
- [ ] Add session and request/result contracts.
- [ ] Add server-side trader lookup.
- [ ] Add MarketSense adapter seam without redesigning all pricing yet.

**Stop point:** a server-side debug trader record can be created, retrieved, and inspected without an NPC.

### Phase 3 — DTHoomans physical caravan slice

- [ ] Add the Project Hoomans integration bootstrap.
- [ ] Implement the `[Debug] Spawn Trader` context-menu entry.
- [ ] Spawn or expose one simple Project Hoomans NPC.
- [ ] Bind the NPC identity to the common trader ID.
- [ ] Add an explicit Trade dialogue option.
- [ ] Open a minimal common trade interaction.
- [ ] Add buy/sell request handling.
- [ ] Present success and failure results through the NPC conversation/UI.

**Stop point:** the debug-spawned NPC can complete a basic buy and sell transaction.

### Phase 4 — DTAbstract optional access

- [ ] Add the abstract/radio feature flag.
- [ ] Expose the same debug trader through a contact or radio entry.
- [ ] Resolve the contact to the same trader ID used by the NPC.
- [ ] Open the same common trade session.
- [ ] Show the same stock, budget, and results.
- [ ] Verify behavior when no physical NPC is loaded.

**Stop point:** the trader is accessible by NPC, radio, or both without duplicating market state.

### Phase 5 — Foundation verification

- [ ] Test host/single-player behavior.
- [ ] Test dedicated server/client behavior.
- [ ] Test duplicate spawn attempts.
- [ ] Test stale stock versions.
- [ ] Test invalid item, quantity, money, and inventory requests.
- [ ] Test module combinations: common only, common + Hoomans, common + abstract, all three.
- [ ] Run Kahlua compatibility checks.
- [ ] Add focused smoke tests for trader identity and transaction contracts.

## Delayed features

These should not block the first caravan foundation:

- Caravan movement and scheduled routes.
- Multiple NPCs in one caravan.
- Caravan guards or combat.
- Escort and companion behavior.
- Advanced faction simulation.
- Reputation depth and relationship effects.
- Seasonal and flash market events.
- Negotiation and haggling.
- Quest/objective systems.
- Player-owned marketplaces and couriers.

## Decisions to adjust before implementation

### Module naming

- Final module directory names:
- Final mod IDs:
- Display names:
- Required dependencies:

### Caravan definition

- Is one stationary NPC acceptable for the first slice?
- Should a caravan include a visible wagon/vehicle/prop immediately?
- Should the trader be friendly and invulnerable during debugging?
- Should multiple debug caravans be allowed?

### Trade scope

- First supported operation: buy, sell, or both?
- Fixed starter stock or MarketSense-derived stock?
- Fixed prices or MarketSense base prices?
- Should money and inventory be fully authoritative in the first slice?

### Abstract access

- Should DTAbstract be enabled by default?
- Is radio discovery required, or can the first version use a debug contact?
- Should abstract access work when the physical NPC is absent, or only when it is away?
- Should NPC and radio access share one session at the same time?

## First implementation target

```text
DTCommon
  one trader record
  one stock list
  one buy/sell contract

DTHoomans
  one Project Hoomans NPC
  [Debug] Spawn Trader
  explicit Trade option

DTAbstract
  feature-flagged
  same trader ID and stock
  radio/contact access when enabled
```

No files should be implemented until the decisions above are reviewed.
