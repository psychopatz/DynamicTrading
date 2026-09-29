# Dynamic Trading — Simplified Feature Checklist

This is an editable feature inventory for redesigning Dynamic Trading. It intentionally avoids implementation details and does not assume the legacy behavior should be preserved.

For each feature, mark one option:

`[ ] Keep`  `[ ] Change`  `[ ] Remove`  `[ ] Defer`

## Product shape

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Remote trading without a physical NPC.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trading with Project Hoomans NPCs.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — One shared trading system for both modes.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Single-player support.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Multiplayer support.

## Traders

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Stable trader identity.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader names and profiles.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader roles or archetypes.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader availability and status.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader factions.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader reputation.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader relationships with players.

## Items and market data

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — MarketSense item classification.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — MarketSense item eligibility.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — MarketSense base or intrinsic pricing.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Item tags and capabilities.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader-specific item preferences.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader stock.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Stock limits and restocking.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Item scarcity or availability.

## Trading actions

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Buy items.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Sell items.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Give items to a trader as an economic transaction.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Social gifts handled by Project Hoomans.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Quantity selection.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Item condition affecting value.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Negotiation or haggling.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trade restrictions based on reputation or faction.

## Remote / non-NPC mode

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Radio scanning for traders.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Radio or device requirements.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Saved trader contacts.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Contact status and availability.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Remote trader conversations.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Remote trade sessions.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Physical visits requested from a remote contact.

## Project Hoomans NPC mode

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Project Hoomans owns NPC identity.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Project Hoomans owns NPC movement.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Project Hoomans owns NPC behavior and lifecycle.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — NPC dialogue can open trading.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Natural-language requests can describe trades.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Stable mapping between an NPC and a trader.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Group conversations can include trading.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — NPC personality affects dialogue or trading.

## Market simulation

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Supply and demand.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Global price changes.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trader or faction wealth.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Reputation changes from trades.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Global heat or market pressure.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Deflation or market recovery.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Seasonal market changes.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Temporary market events.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Faction demand and faction needs.

## Interface and feedback

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Trading window.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Buy and sell views.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Item search and filtering.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Current money and trader budget display.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Stock and availability display.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Price explanations.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Dialogue responses after a trade.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Radio broadcasts or market information.

## Authority and persistence

- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Server-authoritative prices.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Server-authoritative inventory changes.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Server-authoritative trader stock.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Request IDs and duplicate protection.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Version checks for stale trade data.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Save/load persistence.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Data migrations.
- [ ] Keep  [ ] Change  [ ] Remove  [ ] Defer — Reconnect and timeout recovery.

## Explicitly excluded unless added later

- [ ] Include later — Dynamic Trading-owned NPC body, movement, combat, or respawn system.
- [ ] Include later — Quest and objective system.
- [ ] Include later — Player-owned marketplace.
- [ ] Include later — Courier and delivery system.
- [ ] Include later — Bandit and combat systems.
- [ ] Include later — Escort or companion system.

## Decisions and notes

### Core trading loop

- What should a player be able to do in the first playable version?
- What makes a trader different from another trader?
- What should determine the price of an item?

### Remote mode

- How does the player discover a trader?
- What can be done remotely?
- When, if ever, must the player meet the trader physically?

### NPC mode

- What should Project Hoomans handle?
- What should Dynamic Trading handle?
- Should dialogue open a trading UI, perform a direct trade, or support both?

### Market simulation

- Which market systems are essential?
- Which systems should be postponed?
- How visible should market changes be to the player?

### Terms to rename or remove

- Legacy term:
- New term:
- Decision:

## First version candidate

Write the smallest accepted feature set here after review:

```text

```
