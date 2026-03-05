
📊 DynamicTradingCommon Architecture Report
Executive Summary
DynamicTradingCommon is a sophisticated shared library mod for Project Zomboid Build 42 that provides:

10+ major subsystems working in concert
40+ trader archetypes with unique behaviors
Dynamic economy simulation with scarcity, events, and faction interactions
Full multiplayer support with server authority and client synchronization
Modular design allowing V1 and V2 implementations to extend it
🔧 Core Systems Breakdown
1. Economy & Pricing System
Multi-factor pricing: base price × expertise × scarcity × events × difficulty
Dynamic stock generation based on archetype allocations
Weighted random item selection from tag pools
Supports drainable items (uses, charges) and condition-based pricing
2. Stock Management
Per-trader inventories with 24-hour restock cycles
Scarcity pricing (0 qty = 1.5× price, <5 qty = 1.2× price)
Tracks quantities, prices, and custom data per item
Integration with faction wealth system
3. Faction System
Creates persistent faction groups per town (Rosewood, Muldraugh, WestPoint, Riverside, Louisville)
Daily simulation: production, consumption, casualties, recruitment, death
Tracks wealth, stockpiles (food/ammo/meds/fuel), reputation, member count
Dynamic events affect faction survival and growth
4. NPC/Roster System
"Souls" registry = persistent NPC identities
Trader status tracking (Trading/Dead/Roaming)
Player-trader memory (trust, trade volume, last interaction)
NPC Wardrobe: 40+ archetypes with gender-specific outfits
5. Quest System
7 quest package types (Small/Medium/Large/Fragile/Medical/Military/Gift)
Dynamic weight scaling based on difficulty
Unique QuestID tracking and validation
30% weight reduction mechanic
6. Event System
30+ events across 3 types:
Flash Events: Random positive/negative (Gold Rush, Plague, War, Tech Boom)
Meta Events: Persistent world conditions
Seasonal Events: Date-based (Winter, Summer)
Effects: price modifiers, item injections, casualties, attrition
7. Network & Multiplayer
Server authority for all critical data
Client-server command dispatch system
Transaction validation and atomic execution
Admin/debug command interface
ModData synchronization with selective transmit
8. Dialogue System
Contextual NPC responses (greetings, buying, selling, idle, quests)
27 language support: EN, ES, FR, DE, JP, KO, CH, RU, and more
Archetype-specific dialogue variants
Dynamic translation loading
9. Configuration System
Sandbox options: price multipliers, stock multipliers, wallet settings, global wealth
Radio tiers: 10 radio types with power/capacity ratings
Tag registry: 100+ item tags with price/weight modifiers
Archetype definitions: 40+ trader types with allocations, expertise, wants, forbids
10. Location & Loot Systems
Town-based faction spawning (15+ locations per town)
Building scanner for item placement analysis
World loot integration
NPC wallet/money generation
📁 File Organization

DynamicTradingCommon/42.13/media/├── lua/│   ├── shared/              [Core logic - runs on both client/server]│   │   ├── 00_DT_Core.lua   [Main initialization, registration APIs]│   │   ├── DT/Common/│   │   │   ├── Faction/TradingSys/    [Faction lifecycle, simulation, network]│   │   │   ├── Events/                [Flash/Meta/Seasonal events]│   │   │   ├── Items/                 [Item category definitions]│   │   │   ├── NPC/                   [Archetypes, wardrobe]│   │   │   ├── Quests/                [Quest manager]│   │   │   ├── Trading/               [Economy math]│   │   │   ├── ArchetypeDefinitions/  [40+ archetypes with dialogues]│   │   │   ├── Config.lua             [Configuration API]│   │   │   └── Tags.lua               [Tag registry]│   ├── server/              [Server-only logic]│   │   └── DT/Common/│   │       ├── Faction/Templates/     [Town locations]│   │       ├── Quests/                [Server quest handler]│   │       └── Misc/                  [Wallet, loot, building scanner]│   └── client/              [Client-only UI/display]│       └── DT/Common/│           ├── UI/                    [Trading windows]│           └── DT_DialogueManager.lua [Dialogue rendering]├── sandbox-options.txt      [Sandbox configuration]├── scripts/                 [Item definitions]└── ui/                      [UI assets]
🔄 Data Flow Architecture
Initialization Flow
00_DT_Core.lua creates global tables and registration APIs
Config.lua loads archetype definitions and dialogue
System modules register their data (Factions, Economy, Events)
Client/server-specific systems initialize
Trade Transaction Flow

Player clicks "Buy"   → Client sends command to server  → Server validates (wealth, stock)  → Server calculates price (multi-factor)  → Server executes (atomic transaction)  → Server updates ModData  → Server syncs to client  → Client updates UI
Daily Faction Simulation

OnDynamicTradingDailySimulation event fires  → For each faction:    - Calculate production (archetype × members)    - Apply consumption (members × rate)    - Process event impacts (casualties, attrition)    - Check recruitment conditions    - Check death conditions  → Update faction ModData  → Transmit changes to clients
🎯 Key Data Structures
Faction

{    name, memberCount, wealth,    stockpile = { food, ammo, meds, fuel },    reputation = { [player] = trust },    homeCoords = { x, y, z, town },    isNomadic, ActiveFlashEvent, consecutiveStableDays}
Trader Stock

{    items = { [itemFullType] = { qty, basePrice, dynamicMod, customData } },    restock = { lastRestockTime, nextRestockTime },    factionID, name, archetype, portraitID, gender}
Archetype

{    id, name,    allocations = { { tags, count } },    expertTags = { ... },  -- Price bonuses    wants = { ... },        -- Buy multipliers    forbid = { ... }        -- Never stock}
🔌 Integration Points
How V1/V2 Use This Library
DynamicTradingCommon provides:

✅ Configuration & registration APIs
✅ Shared economy math and pricing
✅ Faction lifecycle and simulation
✅ Event system and registry
✅ Network layer and commands
✅ Item master list and tags
✅ Core UI templates
V1/V2 provide:

🔹 Version-specific NPC generation
🔹 Custom dialogue variants
🔹 UI customization
🔹 Trader spawning mechanics
🔹 Quest refinements
📊 Performance & Scale
Optimizations:

Lazy loading of soul brain data
Roster filtering (only "Trading" status synced)
Selective ModData transmit
Batch item loading
Weighted pools for O(n) random selection
Limits:

Network logs pruned to 12 entries (configurable)
Event cooldowns: 14-day minimum
Faction member caps via sandbox settings
✅ Next Steps for Documentation
Based on this analysis, I can now create comprehensive documentation. Here's what I recommend:

Proposed Documentation Structure
README.md - Overview, features, installation
ARCHITECTURE.md - This detailed system breakdown
API_REFERENCE.md - For modders extending the system
SYSTEMS_GUIDE.md - Deep dives into each subsystem
CONFIGURATION_GUIDE.md - Sandbox options and customization
NETWORK_PROTOCOL.md - Multiplayer commands and sync
MODDING_GUIDE.md - How to add archetypes, items, events
TROUBLESHOOTING.md - Common issues and solutions