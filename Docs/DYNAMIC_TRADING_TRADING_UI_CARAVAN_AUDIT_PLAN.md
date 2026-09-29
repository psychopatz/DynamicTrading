# Dynamic Trading Trading UI and Caravan Audit Plan

Status: exploratory plan only. No runtime behavior was changed by this audit.

## Goal

Repurpose the Project Hoomans inventory presentation into a RimWorld-like trading window while preserving the existing inventory, gift, storage, local-draft, NPC, radio, and abstract paths.

The first target is a real caravan encounter:

```text
[Debug] Spawn Trader
        |
        +-- merchant NPC
        +-- armed guard NPCs
        +-- one Project Hoomans faction/mobile group
        +-- one Dynamic Trading trader identity and stock
        +-- one shared trade session opened from NPC dialogue or abstract/radio
```

## Audit conclusion

The current failure is caused by two separate systems being connected only at the interaction label:

1. DynamicTrading opens its own small `DTCommonTradeWindow`.
2. Project Hoomans opens `ISPNCInventoryWindow` for normal item transfer.
3. Neither window has a trade-mode contract or a trade-specific endpoint.
4. The current NPC spawn creates one neutral NPC and binds it to a trader record; it does not create a faction, mobile group, merchant role, guard roles, or a caravan member list.

Therefore, adding another button to the ordinary inventory transfer path would not be enough. The safe foundation is a new trading mode that reuses the inventory window's shell and controls where useful, while keeping its data model, endpoint, validation, and commit behavior separate from ordinary inventory movement.

## Evidence reviewed

### DynamicTrading

- `DTCommon_TradeWindow.lua` is currently a minimal 440x250 panel with one buy button, one sell button, and the first stock item only.
- `DTCommon_Client.lua` requests a trader snapshot and opens that custom panel.
- `DTCommon_TraderService.lua` supports one-item buy/sell requests and a stock-version check, but not a multi-row quote or atomic basket transaction.
- `DTCommon_TraderStock.lua` already has the correct integration seam for MarketSense pricing, but currently has a small fallback price and no trade-row eligibility model.
- `DTHoomans_Server.lua` calls `PNC.API.Spawn` once and binds one NPC ID to the trader.
- `DTHoomans_Context.lua` maps the NPC to a `Trade` context option, but does not open a Project Hoomans trading mode.
- `DTCommon_Storage.lua` already uses PsychopatzCore's compact inventory serializer. This should remain the persistence boundary.

The new DynamicTrading files are not yet represented in the current code graph, so these findings were verified directly from the working tree.

### Project Hoomans inventory UI

- `PNC_InventoryWindow.lua` composes the reusable inventory window.
- `InventoryWindow/_Lifecycle.lua` already accepts `Open(npcId, options)` and is the natural public entry point for `mode = "trade"`.
- `InventoryWindow/_Endpoint.lua` resets the endpoint, requests a snapshot, and controls normal gift/read-only state.
- `InventoryWindow/_Refresh.lua` builds player and NPC transfer rows and currently assumes both panes are inventory containers.
- `InventoryWindow/_Presentation.lua` already has enough list/pane drawing structure to support custom catalog columns.
- `PNC_InventoryUI_Model/_NPCRows.lua` exposes NPC item rows, including equipped and restricted state.
- `PNC_InventoryUI_Model/_Native.lua` already detects equipped and interaction-locked player items.
- `PNC_InventoryUI_Model/_Weights.lua` provides the current displayed weight calculations.
- `PNC_InventoryTransferEndpoint/_NPC.lua` is designed for normal NPC inventory transfer snapshots and commands, not economic trade quotes.

The architecture audit also identifies the inventory row builder, detail-row builder, refresh path, and prerender path as high-pressure UI areas. Trade mode should be isolated behind an adapter or mode-specific renderer instead of spreading trade conditionals through every ordinary inventory path.

### Project Hoomans group and equipment seams

- `PNC.Factions.Create` creates a persistent faction and can attach a leader.
- `PNC.Factions.AddNPC`, `SetNPCRole`, and `SetLeader` provide persistent member and role ownership.
- `PNC.Factions.SetMobileGroup` stores mobile-group state.
- `PNC.MobileGroupDirector.GenerateForFaction` already creates a multi-member mobile faction and imports it into `PNC.AbstractGroups`.
- The generic mobile director equips looters with `both` weapon modes, but trader generation does not automatically arm members. A caravan-specific spawn specification must explicitly request guard equipment.
- `PNC.Inventory.GetDebugEquipmentSpawnMode` and `PNC.Inventory.ResolveStartingEquipment` already provide the equipment policy boundary.
- `PNC.AbstractGroups.ImportMobileFaction` creates or reconciles the abstract group for NPC-to-radio/abstract continuity.
- `PNC_Inventory_Items_Weights.lua` counts the physical weight of every item, including a bag item, while the root maximum remains a per-inventory carry limit.

The existing faction, mobile-group, abstract-group, and equipment APIs should be reused rather than creating a second DynamicTrading NPC lifecycle.

## Desired UI contract

The target should resemble the supplied RimWorld reference: a dark two-sided trade ledger with a player offer side, a merchant stock side, sortable rows, quantity controls, prices, totals, and explicit Reset / Accept / Cancel actions.

### Header

- Player side: player inventory or offer label.
- NPC side: caravan/faction name and trader name.
- Subheading: trader role, negotiation state, or market status when available.
- Optional sort controls: category, name, market value, and availability.

### Rows

Every row should use stable item identity and bounded primitive fields:

```text
fullType
displayName
category
texture
availableQuantity
unitPrice
selectedQuantity
side: PLAYER | TRADER
itemIDs (sell-side identity only)
```

The row renderer can reuse the existing list and icon infrastructure, but it needs dedicated quantity and price columns:

```text
icon | item | category | available | unit price | - | selected | +
```

The selected quantities are only a client-side draft until Accept is confirmed.

### Visibility rules

The trade catalog must not expose items that the player cannot legally offer or that the merchant should not sell:

- hide equipped items;
- hide worn and attached items;
- hide locked or interaction-restricted items;
- hide identity cards, name cards, and other protected identity items;
- hide disabled or non-tradable rows;
- hide non-empty containers unless the transaction model explicitly supports container transfer;
- do not expose guard weapons as merchant stock by accident;
- retain normal inventory mode's current visibility and restrictions.

The player-side filter should use the same native equipped/locked probes already used by Project Hoomans. The NPC-side filter should additionally understand faction roles, so guard equipment remains combat equipment rather than stock.

## Proposed integration shape

### 1. Add a trade mode, do not replace normal inventory mode

Extend the existing open contract conceptually:

```lua
PNC.InventoryWindow.Open(npcID, {
    mode = "trade",
    traderID = traderID,
    caravanID = caravanID,
})
```

The exact option names can change during implementation, but the compatibility rule should remain:

```text
no mode / ordinary options -> existing inventory behavior
mode = gift                 -> existing gift behavior
mode = trade                -> new trade endpoint and trade presentation
```

Do not make `DTCommon_TradeWindow` the long-term UI. It should either be removed after migration or become a thin compatibility bridge that opens the Project Hoomans trade mode.

### 2. Add a dedicated trade endpoint

Do not reuse `TransferEndpoint.NPC` for economic transactions. That endpoint is intentionally shaped around give/take operations and inventory revisions.

The new endpoint should expose:

- trader identity and caravan identity;
- merchant and guard member IDs;
- compact trade snapshot;
- player tradable rows;
- merchant tradable rows;
- aggregate capacity summary;
- market quote version / stock revision;
- money and budget values;
- request/response methods for quote refresh and commit.

The endpoint may reuse the existing snapshot transport and row presentation helpers, but it must not issue ordinary Give, Take, Deposit, or drag-and-drop actions.

### 3. Use quote then commit

The UI should build a draft basket and send only stable, bounded data:

```text
TradeQuoteRequest
  requestID
  traderID
  observedStockVersion
  buy rows: fullType + quantity
  sell rows: itemID(s) + quantity
```

The authoritative server must re-check all of the following before mutating anything:

- trader exists and is accessible through the selected mode;
- stock version is current;
- requested quantities are still available;
- MarketSense price and item eligibility are current;
- player owns the exact sell item IDs;
- sell items are not equipped, locked, protected, disabled, or otherwise non-tradable;
- player has sufficient money for the net cost;
- trader has sufficient budget for the sale side;
- the aggregate caravan inventory can accept purchased items;
- the transaction can complete atomically.

If any check fails, reject the entire basket and return a fresh snapshot. Do not partially apply a basket.

### 4. Preserve compact storage

Use PsychopatzCore's coder/decoder and existing DynamicTrading serializer for persisted trader stock. Persist only compact primitives such as:

```text
trader record: traderID, groupID, leaderID, memberIDs, stock revision,
               budget, access flags, profile keys
stock record:  encoded item data and bounded market state
```

Do not persist:

- Java-backed inventory objects;
- live NPC objects;
- rendered UI rows;
- client quote drafts;
- duplicated Project Hoomans inventory snapshots.

Project Hoomans remains the owner of NPC identity, membership, equipment, and NPC inventory persistence. DynamicTrading stores only the commercial identity and the references needed to resolve the caravan.

## Capacity interpretation

The requested rule is interpreted as follows for the first implementation:

```text
caravan used weight      = sum of every eligible member's used weight
caravan maximum capacity = sum of every eligible member's max carry weight
caravan remaining        = maximum capacity - used weight
```

Each bag item contributes its own physical weight once because the existing Hoomans weight calculation already includes item weight. A bag's internal capacity is not added again to the caravan's carry capacity; doing so would double-count storage space and produce capacity the NPCs do not physically carry.

This aggregate should be used by trade validation and displayed in the trade header or footer. It should not change ordinary per-NPC inventory weight behavior.

Open decision: whether the caravan should eventually use a separate shared cargo capacity in addition to member carry capacity. That is a future rule, not part of the first safe migration.

## Caravan group plan

### Members

The first debug caravan should create a configurable group, for example:

```text
1 merchant / leader
2 guards / members
```

The count should be data-driven so it can later become a sandbox option. The merchant and guards must share one Project Hoomans faction and one mobile/abstract group.

### Roles and equipment

- Merchant: faction role `leader` or the closest allowed trader role; no forced combat loadout unless the chosen archetype supplies one.
- Guards: faction role `guard` or the closest allowed role; explicit `equipmentSpawnMode = "ranged"` or `"both"`.
- Guard equipment is created by the existing Hoomans equipment pool and starting-equipment pipeline.
- Guard weapons remain hidden from merchant stock unless a later rule explicitly makes them tradable.

The implementation must verify the generated guard loadout and report a bounded failure if the requested weapon pool is unavailable. “Spawned” should not silently mean “unarmed.”

### Group lifecycle

1. Resolve or create the DynamicTrading commercial record.
2. Create a Project Hoomans trader faction with a stable debug/caravan tag.
3. Spawn the merchant and guards through the authoritative Hoomans spawn API.
4. Add each NPC to the faction with role and membership state.
5. Set the merchant as leader.
6. Set mobile-group state and import/reconcile the abstract group.
7. Store only `groupID`, `leaderID`, and bounded member references in the DynamicTrading record.
8. On repeat debug spawn, resolve live members before creating another caravan.
9. On partial failure, remove created memberships and despawn created NPCs using the existing rollback pattern.

The initial caravan may remain stationary at the debug spawn point. Group identity and abstract access should be established before adding travel behavior.

## Phased implementation roadmap

### Phase 0 — decisions and contracts

- [ ] Confirm the number of caravan members for the first playable test.
- [ ] Confirm whether guards use ranged-only or mixed ranged/melee loadouts.
- [ ] Confirm whether `Accept` is one atomic basket transaction.
- [ ] Confirm the exact money item/currency contract.
- [ ] Confirm whether player-side equipped items are hidden as well as NPC-side equipped items. The proposed default is to hide both.
- [ ] Confirm the first sort columns and whether negotiation modifiers are visible immediately.

### Phase 1 — trade data contract

- [ ] Define trade snapshot, row, quote, commit, result, and rejection-reason contracts.
- [ ] Add stable trader/caravan/member references to the compact DTCommon record.
- [ ] Keep stock encoding through the coder/decoder path.
- [ ] Add bounded request IDs and duplicate protection.
- [ ] Add quote/stock revision checks.

Acceptance: a headless test can build a multi-row quote, reject stale data, and return a deterministic result without touching the UI.

### Phase 2 — safe Hoomans trade endpoint

- [ ] Add a `TradingEndpoint` alongside `NPC`, `Storage`, and `LocalDraft` endpoints.
- [ ] Build player tradable rows using existing equipped/locked/protected-item probes.
- [ ] Build merchant rows from the trade snapshot, excluding guard equipment and protected items.
- [ ] Add aggregate caravan weight/capacity calculation.
- [ ] Ensure normal endpoint methods remain unchanged.

Acceptance: ordinary NPC inventory, gift mode, storage, and local draft still pass their existing tests; trade mode can render a read-only quote snapshot.

### Phase 3 — RimWorld-style presentation

- [ ] Reuse the existing window shell, resize behavior, icon rendering, localization, and list lifecycle.
- [ ] Add trade-only header, sort controls, quantity columns, prices, totals, and footer buttons.
- [ ] Hide or disable Give All, Take All, Deposit, drag/drop, and normal transfer context actions in trade mode.
- [ ] Add Reset, Accept, and Cancel.
- [ ] Keep the implementation in trade-specific adapter/presentation files where possible instead of expanding the already large ordinary refresh/prerender functions.

Acceptance: the window visually matches the supplied reference at normal and resized dimensions, and no ordinary inventory control is available in trade mode.

### Phase 4 — atomic transaction

- [ ] Add server-side multi-row buy/sell validation.
- [ ] Validate exact item identity for player sales.
- [ ] Validate capacity using the aggregate caravan rule.
- [ ] Apply money, player inventory, and caravan stock changes atomically.
- [ ] Increment stock/revision only after a successful commit.
- [ ] Return fresh state after success or rejection.

Acceptance: insufficient money, insufficient stock, stale quote, locked item, protected item, missing item, insufficient budget, and insufficient capacity all leave both sides unchanged.

### Phase 5 — real caravan spawn

- [ ] Replace one-NPC debug spawn with merchant plus guard group creation.
- [ ] Add faction membership, leader, roles, mobile state, and abstract-group import.
- [ ] Explicitly request and verify guard weapons.
- [ ] Bind the commercial trader identity to the group, not only one NPC.
- [ ] Reconcile or reject duplicate debug caravan spawns.
- [ ] Add rollback for partial spawn failures.

Acceptance: `[Debug] Spawn Trader` creates one merchant and the configured guards, all members share the same faction/group, guards are armed, and the same group is reachable from physical and abstract access.

### Phase 6 — access paths and regression verification

- [ ] NPC dialogue opens `mode = "trade"`.
- [ ] Radio/abstract access opens the same trader ID and stock.
- [ ] Conversation and semantic dialogue integration remains an optional front door, not a second transaction engine.
- [ ] Verify single-player and multiplayer authority behavior.
- [ ] Verify save/load and reconnect behavior.

## Test plan

### Existing baseline

Baseline executed during this audit:

```text
pnc_inventory_ui_smoke             PASS
pnc_inventory_open_perf_smoke      PASS
pnc_mobile_group_smoke              PASS
```

### New focused tests

- `dynamic_trading_trade_quote_smoke`
  - stable row identity;
  - MarketSense price adapter;
  - multi-row totals;
  - sort/filter behavior.
- `dynamic_trading_trade_visibility_smoke`
  - equipped, worn, attached, locked, identity, disabled, and guard items hidden;
  - ordinary inventory rows unchanged outside trade mode.
- `dynamic_trading_trade_transaction_smoke`
  - atomic buy/sell;
  - stale revision;
  - duplicate request ID;
  - capacity, money, budget, stock, and exact item validation.
- `dynamic_trading_caravan_spawn_smoke`
  - merchant plus guards;
  - faction and group membership;
  - leader and roles;
  - armed guard loadouts;
  - rollback and duplicate spawn handling.
- `dynamic_trading_trade_access_smoke`
  - NPC entry and abstract/radio entry resolve the same trader ID and stock.

### In-game verification matrix

| Scenario | Expected result |
| --- | --- |
| Ordinary NPC inventory | Existing transfer UI and actions unchanged. |
| Gift mode | Existing gift flow unchanged. |
| Storage/local draft | Existing read-only/editor flows unchanged. |
| NPC trade | RimWorld-style trade window; no drag/drop transfer controls. |
| Radio/abstract trade | Same stock, budget, prices, and revision as NPC trade. |
| Equipped/locked identity item | Hidden and rejected if manually requested. |
| Bag in caravan inventory | Bag's item weight counts once; aggregate capacity is shown. |
| Guard weapon | Used by guard; absent from merchant catalog. |
| Stale quote | Entire basket rejected; fresh snapshot returned. |
| Multiplayer client | Server owns validation and mutations. |
| Save/reload | Trader, group references, stock, and revisions recover without duplicate members. |

## Non-goals for this slice

- Rebuilding Project Hoomans inventory persistence.
- Creating a DynamicTrading-owned NPC framework.
- Making dialogue parsing the only trade entry point.
- Adding caravan travel, combat tactics, escort missions, or respawn behavior.
- Adding haggling, reputation, supply/demand simulation, or seasonal events before the atomic trade loop is stable.
- Making every Project Hoomans NPC a trader.

## Decisions needed before implementation

Please edit or answer these before the first code phase:

1. First caravan size: recommended default is one merchant plus two guards.
2. Guard loadout: ranged-only or mixed ranged/melee; recommended default is mixed so the existing equipment pipeline can be exercised.
3. Capacity rule: recommended default is aggregate member carry capacity, with bag mass counted once and bag internal capacity not added again.
4. Trade action: recommended default is one atomic Accept for the whole basket.
5. Physical access: recommended default is NPC dialogue/context menu opens the trade window; radio/abstract uses the same session contract.
6. Player-side visibility: recommended default is to hide equipped, worn, attached, locked, protected, and disabled items on both sides.

