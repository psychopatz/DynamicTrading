# Dynamic Trading V1: Variable and Data Schema Mapping

This document provides a comprehensive map of the variables and ModData structures used in Dynamic Trading V1.

## 1. Persistent State (ModData)

Dynamic Trading V1 uses multiple `ModData` keys to separate authoritative server data from user-specific timers.

### Engine State (`DynamicTrading_Engine_v1.3`)
The core state for the V1 economy and trader roster.

**Location:** `media/lua/shared/DT/V1/Manager.lua`

* `DailyCycle`:
  * `dailyTraderLimit`: Integer (Max traders that can be found today)
  * `currentTradersFound`: Integer (Number of traders already discovered today)
  * `lastResetDay`: Integer (The "Trading Day" the market last reset)
  * `tradersVersion`: Integer (Version bump to trigger UI refreshes)
* `GlobalWealthPool`: Float (Total money available for the server's NPC traders to buy items)
* `globalHeat`: Table { [Category] = Float } (Inflation/Deflation multipliers per item category)
* `deflatedGlobal`: Table { [ItemFullType] = Boolean } (Tracks items that have already triggered a deflation roll today)
* `Traders`: Table (Roster of active radio contacts)
  * `[uniqueID]`:
    * `id`: String (e.g., "Radio_1712345678_1234")
    * `name`: String (Full name of the trader)
    * `archetype`: String (The trader's profession)
    * `gender`: String ("Male" or "Female")
    * `portraitID`: Integer (Index for the UI portrait)
    * `stocks`: Table (Current inventory: { [Item] = { qty, customData } })
    * `budget`: Float (The individual trader's cash on hand)
    * `expirationTime`: Float (WorldAgeHours when this trader disappears)
    * `lastRestockDay`: Integer (The day the trader last refreshed items)
    * `discoveredBy`: Table { [Username] = Boolean } (Tracks which players have access to this trader)
    * `localDeflation`: Table { [Item] = Integer } (Tracks how many of an item this specific trader has bought)
* `EventSystem`:
  * `activeEvents`: Table (List of currently running economic events)
  * `lastEventDay`: Integer (Day of the last randomly triggered flash event)

### Cooldown State (`DynamicTrading_Cooldowns_v1.0`)
Authoritative server-side timers.

**Location:** `media/lua/shared/DT/V1/CooldownManager.lua`

* `timers`: Table { [Username] = Float } (Last WorldAgeHours timestamp of a successful scan)
* `eventTimers`: Table { [EventID] = Integer } (The Trading Day when a specific event is allowed to fire again)

---

## 2. Dynamic Economy

### Pricing Modifiers
**Location:** `media/lua/shared/DT/V1/Economy.lua`

V1 pricing is derived from the `Common` economy module using the following context:
* `globalHeat`: Applied to both Buy and Sell prices.
* `localDeflationCount`: Applied to Sell prices (NPC buying from player) to simulate local market saturation.
* `GlobalWealthPool`: Regulates the initial `budget` assigned to new traders.

---

## 3. Communication Signals (Events)

**Location:** Hooked in `media/lua/shared/DT/V1/Events.lua` and `Manager.lua`

* `CheckDailyReset`: Fired periodically on the server to check for the 5:00 AM transition.
* `DynamicTrading_Engine_v1.3`: The core sync key for transmitting data to clients.
