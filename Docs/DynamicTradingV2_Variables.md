# Dynamic Trading V2: Variable and Data Schema Mapping

This document provides a comprehensive map of the variables and ModData structures used in Dynamic Trading V2.

## 1. Static Configuration (`DynamicTrading.V2.Config`)

**Location:** `media/lua/shared/DT/V2/Config.lua`

### Resource Mapping
Maps item tags (from `Archetype Tags`) to macro resource pools.
* `DynamicTrading.V2.Config.ResourceMap`: Table
  * `Vegetable`, `Fruit`, `Grain`, `Meat`, `Fresh`, `Canned`, `Fish`, `Farming` -> `food`
  * `Ammo`, `Gun`, `Weapon` -> `ammo`
  * `Medical`, `Pills`, `Bandage` -> `meds`
  * `Fuel`, `Electronics` -> `fuel`

### Simulation Constants
Used by the daily simulation engine to calculate faction survival and growth.
* `DynamicTrading.V2.Config.Sim`: Table
  * `BaseConsumption`: { food: 1.0, meds: 0.1, ammo: 0.2, fuel: 0.5 }
  * `ProductionMultiplier`: 2.0 (Converts allocation score to resource units)
  * `StarvationThreshold`: 3 (Days without food before deaths occur)
  * `DeathRate`: 0.1 (Percentage of population lost per day when starving)
  * `RecruitCost`: { food: 50, meds: 10 } (Surplus needed for 1 recruit)
  * `MaxDailyGrowth`: 2 (Limit on daily population increase per faction)

---

## 2. Persistent State (ModData)

All V2 persistence is handled via `ModData`.

### Engine State (`DynamicTrading_Engine_v2`)
The global conductor for the simulation.

**Location:** `media/lua/shared/DT/V2/Faction/TradingSys/DynamicTrading_Engine.lua`

* `SimState`:
  * `lastSimulationDay`: Integer (Last day survival simulation ran)
  * `lastHourTick`: Integer (Last hour the hourly signal fired)
  * `systemLock`: Boolean (Internal lock for critical operations)
* `Demographics`:
  * `availableRecruits`: Integer (Pool of potential recruits available today)
  * `migrationRate`: Float (Multiplier for movement between towns - Unused)
  * `attritionRate`: Float (Percentage of natural population loss - Unused)
* `WorldEconomy`:
  * `scavengeEfficiency`: Float (Multiplier for resource discovery)
  * `consumptionMods`: { food, ammo, meds, fuel } (Global modifiers for consumption)
* `Spectrum`:
  * `assignedFrequencies`: Table (Mapping of radio frequencies)
  * `rangeMin`: Float (88.0)
  * `rangeMax`: Float (108.0)

### Faction State (`DynamicTrading_Factions`)
Tracks macro-level data for groups.

**Location:** `media/lua/shared/DT/V2/Faction/TradingSys/Factions/Lifecycle.lua` (Initialized) | `Factions/Interaction.lua` (Modified)

* `[factionID]`: Table
  * `id`: String (Unique Faction ID, e.g., "Rosewood_123456")
  * `name`: String (Flavor name, e.g., "The Iron Vanguard")
  * `town`: String (Origin town)
  * `homeCoords`: Table { x, y, z, name } (Physical base location)
  * `stockpile`: Table { food, ammo, meds, fuel } (Resource units)
  * `state`: String ("Stable", "Starving", "Booming")
  * `memberCount`: Integer (Total population)
  * `wealth`: Float (Total capital held by the faction)
  * `reputation`: Table { [Username] = Integer } (Player standing)
  * `starvationDays`: Integer (Consecutive days without food)

### Roster State (`DynamicTrading_Roster`)
Manages both persistent "Souls" and active "Traders".

**Location:** `media/lua/shared/DT/V2/Faction/TradingSys/DynamicTrading_Roster.lua`

* `Traders`: Table (Physical/Radio instances)
  * `[traderID]`: { factionID, homeCoords, returnTime, isPhysicallySpawned, visuals, memory }
* `Souls`: Table (Lightweight Registry of all NPCs)
  * `[uuid]`: { name, factionID, archetypeID, status, ... }
* `FactionMembers`: Table
  * `[factionID]`: List of `uuid`s belonging to this faction.

### Soul Data (`DTSOUL_[uuid]`)
Full "Brain" data for an NPC. This is the source of truth for an NPC's identity, visuals, and logic state.

**Location:** `media/lua/shared/DT/V2/NPC/Sys/DTNPC_Generator.lua` (Schema) | `DynamicTrading_Roster.lua` (Storage)

* `uuid`: String (Unique ID, e.g., "soul_123456_1712345678")
* `name`: String (Full name)
* `factionID`: String (ID of the parent faction)
* `archetypeID`: String (The trader's profession, e.g., "Gunrunner")
* `homeCoords`: Table { x, y, z } (Where the NPC "lives")
* `workCoords`: Table { x, y, z } (Where the NPC "works")
* `status`: String ("Resting", "Away", "Trading", "Working")
* `health`: Float (0.0 to 1.0)
* `isFemale`: Boolean
* `portraitID`: Integer (Index for the UI portrait)
* `visuals`: (Embedded directly or in `brain` sub-table)
  * `outfit`: String (Outfit ID)
  * `hairStyle`: String (Hair ID)
  * `beardStyle`: String (Beard ID)
  * `visualID`: Integer (Seed for variation)
* `logic`:
  * `state`: String ("Stay", "Follow", "Guard", etc. - used when spawned)
  * `masterID`: String (UUID of the player/leader they are following)
  * `tasks`: Table (Reserved for utility AI tasks)
* `memory`: Table { [Username] = { trust, lastSeen, tradeVolume } }

### Stock State (`DynamicTrading_Stock`)
Tracks what each trader is currently selling.

**Location:** `media/lua/shared/DT/V2/Faction/TradingSys/DynamicTrading_Stock.lua`

* `[traderUUID]`: Table
  * `items`: Table { [ItemFullType] = { qty, basePrice, dynamicMod, customData } }
  * `restock`: Table { lastRestockTime, nextRestockTime }
  * `factionID`: String
  * `name`: String
  * `archetype`: String
  * `portraitID`: Integer
  * `gender`: String ("Male" or "Female")

---

## 3. Physical NPCs (`DTNPC`)

These variables are attached to the spawned `IsoZombie` objects in the game world.

**Location:** `media/lua/shared/DT/V2/NPC/Sys/DTNPC_Data.lua` (Accessors) | `DTNPC_Logic.lua` (Processing)

### Object ModData
* `modData.IsDTNPC`: Boolean (Flag to identify the zombie as an NPC)
* `modData.DTNPCBrain`: Table (The physical manifestation of a "Soul")

### Runtime Logic Variables
These are added to the `brain` table when the NPC is physically spawned.
* `brain.anchorX`, `brain.anchorY`, `brain.anchorZ`: Float (Locked coordinates for `Stay` or `Guard` states)
* `brain.tickTimer`: Integer (Internal counter for behavior throttling)
* `brain.lastHealth`: Float (Used to detect player betrayal/attacks)
* `brain.isHostile`: Boolean (Flag for combat initiation)

### Global Constants
* `DTNPC.DefaultWalkSpeed`: 0.06
* `DTNPC.DefaultRunSpeed`: 0.09

---

## 4. Communication Signals (Events)

**Location:** Hooked across across various `TradingSys` files.

* `OnDynamicTradingHourlyTick`: Fires every game hour.
* `OnDynamicTradingDailySimulation`: Fires at 05:00 AM game time.
* `OnDynamicTradingStockUpdate`: Fires when a trader's stock changes.
