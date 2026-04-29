-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_04_29",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 12/31 - 04/29",
--   "description": "Consolidated updates from 2025-12-31 to 2026-04-29",
--   "start_page_id": "2026_04_28",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 0,
--   "release_version": "",
--   "popup_version": "",
--   "auto_open_on_update": false,
--   "is_whats_new": true,
--   "manual_type": "whats_new",
--   "show_in_library": false,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "WhatsNew",
--   "chapters": [
--     {
--       "id": "release_notes",
--       "title": "Release Notes",
--       "description": ""
--     }
--   ],
--   "pages": [
--     {
--       "id": "2026_04_28",
--       "chapter_id": "release_notes",
--       "title": "2026-04-28",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-28"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_28",
--           "level": 1,
--           "text": "Updates for 2026-04-28"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_conversation_ui_overhaul",
--           "level": 2,
--           "text": "Conversation UI Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a **faction rumor system** directly into the conversation window, allowing players to see dynamic intel about factions while chatting.",
--             "Implemented **navigation history** with footer controls, letting users move back and forward through dialog trees without losing context.",
--             "Introduced an **automated exit dialogue** and queued conversation‑closing logic to ensure UI consistency when dialogs finish or are interrupted.",
--             "Built a **responsive layout system** and a set of **custom UI components** for the conversation window, improving readability on all screen sizes.",
--             "Added a **conversation transparency toggle**, giving players the option to dim the background for better focus.",
--             "Refactored the **scanner UI components** and renamed radio scanner categories, streamlining the discovery interface.",
--             "Integrated **automatic discovery triggers** for new radio signals, so relevant conversations start as soon as a signal is picked up."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_bandit_behavior_interaction",
--           "level": 2,
--           "text": "Bandit Behavior & Interaction"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created a full **Bandit House Roam system** with state management, enabling bandits to patrol and react dynamically to player actions.",
--             "Developed a **hostile negotiation system** for bandit NPCs, including automated return behavior and state tracking for smoother encounters.",
--             "Added **hostile trade cycle mechanics** and **faction‑based bandit demand logic**, giving bandits realistic trading motivations.",
--             "Implemented **prioritization of hostile NPCs over zombies** when deciding protection targets, making combat decisions more logical.",
--             "Preserved **bandit encounter states across NPC respawns**, ensuring continuity in ongoing storylines.",
--             "Excluded bandits from radar discovery to prevent unintended spotting, keeping their movements stealthier."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_trading_economy_enhancements",
--           "level": 2,
--           "text": "Trading & Economy Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added **gift transaction support**, allowing players to give items as gifts with proper server‑side validation.",
--             "Introduced a **flavor text system** for trades, providing contextual descriptions that enrich the trading experience.",
--             "Implemented a **Wave Hi emote auto‑talk patch**, which automatically triggers trader conversations when the emote is used."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_reputation_faction_system",
--           "level": 2,
--           "text": "Reputation & Faction System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refactored **reputation resolution** to include faction context and synchronized bias adjustments server‑side, delivering more accurate reputation outcomes.",
--             "Integrated the **faction rumor system** into conversations, giving players actionable intel that directly influences reputation changes."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_ui_utilities_performance",
--           "level": 2,
--           "text": "UI Utilities & Performance"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Extracted item texture resolution logic into a reusable **DT_ItemIconUtils** utility module, improving texture handling across the mod.",
--             "Generalized the **Wave Hi interaction** to support dynamic dialogues and custom NPC interactions, making future extensions easier."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_28_escort_job_system",
--           "level": 2,
--           "text": "Escort Job System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added **escort job commands** with a detailed status UI, allowing players to issue clear instructions to escort NPCs.",
--             "Implemented a **horde warning sound effect**, alerting players when an escort is about to be overwhelmed.",
--             "These updates collectively expand interaction depth, streamline UI flow, and enhance the strategic elements of bandit and trading systems."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_27",
--       "chapter_id": "release_notes",
--       "title": "2026-04-27",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-27"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_27",
--           "level": 1,
--           "text": "Updates for 2026-04-27"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_27_nomadic_faction_mechanics",
--           "level": 2,
--           "text": "Nomadic Faction Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Abstract soul management for nomadic groups** – Introduces a unified system to track and allocate “souls” (resource points) for wandering factions, enabling more dynamic population and reputation handling.",
--             "**Mission viewer integration** – Adds a dedicated button to the radio scanner UI, allowing players to quickly access and review active nomadic missions without leaving the main screen."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_27_npc_combat_behavior_enhancements",
--           "level": 2,
--           "text": "NPC Combat & Behavior Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Hostile chase give‑up logic** – NPCs now abandon pursuits after a configurable cooldown, reducing endless chases and improving performance.",
--             "**Advanced target searching and line‑of‑sight** – Implements smarter enemy detection, accounting for obstacles and distance, which results in more realistic combat engagements.",
--             "**Off‑screen despawn handling** – NPCs that wander far from the player are gracefully removed, freeing server resources and preventing clutter.",
--             "**Interaction tracking for stock data** – Records player interactions with NPC inventories, laying groundwork for future trade analytics and dynamic pricing.",
--             "**Debug logging for combat lifecycle events** – Adds comprehensive logs for NPC combat phases, aiding developers in diagnosing behavior issues."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_27_bandit_raider_systems",
--           "level": 2,
--           "text": "Bandit & Raider Systems"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Hostile Raiders flavor text & UI update** – Distinguishes bandits from hostile raiders in the NPC job UI, providing clearer context and immersive lore.",
--             "**Tiered bandit tribute system** – Introduces a gifting mechanic where players can offer resources to bandits, influencing raid frequency and hostility levels through dialogue options.",
--             "**Decoupled raid architecture** – Splits raid logic into server‑side processing, client‑side UI, and localized flavor text, improving stability and allowing easier future extensions.",
--             "**CurrencyExpanded restriction & faction exclusion** – Bandit mechanics now activate only when the CurrencyExpanded mod is present and respect exclusion rules to prevent overpopulation of certain factions.",
--             "**Configurable bandit raid parameters** – Allows server admins to set party sizes and reputation thresholds that trigger raids, offering granular control over difficulty scaling.",
--             "**Bandit ambush system** – Adds specialized ambush archetypes with server‑managed spawning and a custom interaction UI, delivering more varied and challenging encounters."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_27_ui_improvements",
--           "level": 2,
--           "text": "UI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Mission viewer button** – Integrated into the radio scanner for seamless access to nomadic missions.",
--             "**NPC job UI enhancements** – Visual differentiation between regular bandits and hostile raiders for quicker identification during gameplay."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_27_debug_tracking_tools",
--           "level": 2,
--           "text": "Debug & Tracking Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Combat behavior logs** – Detailed debug output for NPC combat actions, facilitating rapid troubleshooting and balance tuning.",
--             "**Stock interaction metrics** – Captures player‑NPC trade interactions, providing data for future economic adjustments."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_26",
--       "chapter_id": "release_notes",
--       "title": "2026-04-26",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-26"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_26",
--           "level": 1,
--           "text": "Updates for 2026-04-26"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_26_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Introduced the ItemUseabilityRanker system**",
--             "Implements a ranking algorithm that evaluates items based on their practical utility, allowing traders to prioritize more valuable or versatile goods.",
--             "Enhances trading AI decision‑making, leading to more realistic and strategic barter outcomes.",
--             "**Added marquee text UI utility**",
--             "Provides a scrolling text component for the trading interface, ensuring long item names or descriptions remain fully visible without truncation.",
--             "Improves user experience by delivering clear, readable information during trade negotiations."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_25",
--       "chapter_id": "release_notes",
--       "title": "2026-04-25",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-25"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_25",
--           "level": 1,
--           "text": "Updates for 2026-04-25"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_25_radio_quest_system",
--           "level": 2,
--           "text": "Radio Quest System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced radio‑based quest offers, allowing players to receive new missions directly through the scanner.",
--             "Added a quest‑focus mode to the radio scanner, highlighting active objectives and streamlining navigation.",
--             "Simplified the quest UI logic by removing the previous scan‑difficulty scaling, resulting in a cleaner and more intuitive interface."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_25_npc_escort_mechanics",
--           "level": 2,
--           "text": "NPC Escort Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented an **escort‑lock** state for NPCs, preventing them from receiving conflicting orders while engaged in an escort mission.",
--             "This lock ensures escort parties remain cohesive, reducing AI errors and improving overall mission reliability."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_25_trader_help_escort_ui",
--           "level": 2,
--           "text": "Trader Help Escort UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a dedicated **TraderHelpEscort** job UI, fully integrated with NPC interaction and the radio scanner systems.",
--             "Players can now easily assign, monitor, and manage escort tasks through an intuitive interface, enhancing coordination between traders and their protectors."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_24",
--       "chapter_id": "release_notes",
--       "title": "2026-04-24",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-24"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_24",
--           "level": 1,
--           "text": "Updates for 2026-04-24"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_24_npc_trading_quest_integration",
--           "level": 2,
--           "text": "NPC Trading Quest Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a full quest‑offer system for NPC traders, allowing quests to be presented through the new dialogue interface.",
--             "Made the quest UI tab conditional, so it only appears when relevant quests exist, reducing UI clutter for players who aren’t engaged in trading quests.",
--             "Removed the legacy quest system code, streamlining the trading module and improving load times."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_24_admin_debug_store_ui_cleanup",
--           "level": 2,
--           "text": "Admin Debug & Store UI Cleanup"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Restricted debug‑mode access to administrators only, enhancing server security and preventing accidental misuse by regular players.",
--             "Removed unused store‑related buttons (both the faction store button and the virtual store button) from the UI, resulting in a cleaner interface and eliminating dead code paths."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_21",
--       "chapter_id": "release_notes",
--       "title": "2026-04-21",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-21"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_21",
--           "level": 1,
--           "text": "Updates for 2026-04-21"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_21_dynamic_trading_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Added a Colony Wealth sandbox option** – players can now set a custom wealth level for their colony when starting a sandbox game, providing finer control over economic difficulty and balance.",
--             "**Refactored internal naming conventions** – updated variable and function names to be more descriptive, improving code readability and easing future maintenance for the trading system."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_20",
--       "chapter_id": "release_notes",
--       "title": "2026-04-20",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-20"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_20",
--           "level": 1,
--           "text": "Updates for 2026-04-20"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_20_dynamic_trading_signal_tracking_building_indexing",
--           "level": 2,
--           "text": "Dynamic Trading – Signal Tracking & Building Indexing"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a new **Signal Tracking dialogue** that lets players monitor active trading signals directly from the UI.",
--             "Implemented a **spatial‑hash based building indexing system**, dramatically speeding up lookup of nearby structures for trade routes and reducing CPU overhead during large‑scale map scans."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_20_dynamic_trading_world_data_faction_management",
--           "level": 2,
--           "text": "Dynamic Trading – World Data & Faction Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced the **GeolocatorSystem**, a centralized service that parses map data, defines town boundaries, and automatically resolves faction locations.",
--             "Enables dynamic placement of trader NPCs and faction‑specific offers based on real‑time geographic information, improving immersion and ensuring that trade interactions reflect the current state of the world."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_20_maintenance_legacy_cleanup",
--           "level": 2,
--           "text": "Maintenance – Legacy Cleanup"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Removed obsolete legacy files and refactored the codebase to eliminate outdated dependencies, resulting in a cleaner project structure and easier future maintenance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_18",
--       "chapter_id": "release_notes",
--       "title": "2026-04-18",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-18"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_18",
--           "level": 1,
--           "text": "Updates for 2026-04-18"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_ui_enhancements_utilities",
--           "level": 2,
--           "text": "UI Enhancements & Utilities"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added distinctive icons to context‑menu entries, giving players immediate visual cues for actions.",
--             "Introduced a shared UI utility module that centralizes list‑item selection handling and background rendering, simplifying future UI work.",
--             "Refined the faction debug listbox styling and selection logic for clearer visual feedback.",
--             "Cleaned up radio scanner listboxes by removing unnecessary background and border elements, and wrapped all listboxes in styled clipping containers for a more polished appearance.",
--             "Updated UI layout padding and introduced dynamic button widths, improving consistency across windows and ensuring better fit on various screen resolutions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_centralized_gameplay_logging_system",
--           "level": 2,
--           "text": "Centralized Gameplay Logging System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a comprehensive event‑logging framework that captures faction activities (membership changes, leadership updates, reputation shifts, combat outcomes) and radio communications.",
--             "Added UI panels that display logged faction events such as trades and construction, giving players transparent insight into faction dynamics.",
--             "Created a unified gameplay‑logging registry, eliminating redundant network‑log wrappers and streamlining how events are recorded and accessed."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_faction_simulation_colony_infrastructure",
--           "level": 2,
--           "text": "Faction Simulation & Colony Infrastructure"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Modularized faction simulation logic, separating generic processing from town‑specific handlers for clearer code separation and easier future expansion.",
--             "Delivered a full colony infrastructure system, including horde management, with dedicated UI and underlying logic modules.",
--             "Integrated a virtual store system and linked economy modifiers to flash events, allowing dynamic pricing and market fluctuations."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_radio_scanner_radar_system_overhaul",
--           "level": 2,
--           "text": "Radio Scanner & Radar System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Standardized radar‑scan mechanics and introduced spam‑protection with visual feedback, preventing accidental scan flooding.",
--             "Reworked the scanner lifecycle to prioritize contact visits and added dynamic success probabilities, making scans feel more realistic.",
--             "Consolidated all radio‑scanner UI components into a shared library and migrated legacy radar logic to the new framework, enhancing maintainability.",
--             "Refined contact visibility rules and adjusted window dimensions and styling for a cleaner scanner interface.",
--             "Added a “night scanner gate” option, improved trader expiry formatting, and implemented trader death‑state handling for more immersive radio interactions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_trading_economy_improvements",
--           "level": 2,
--           "text": "Trading & Economy Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Integrated trader session budgets directly into the trading window data provider, ensuring players see accurate available funds.",
--             "Added extensive proximity‑based dialogue lines that trigger as NPCs approach or track the player, enriching in‑game conversations.",
--             "Implemented a radio‑scanner conversation panel that ties dialogue tracking into the scanner UI, providing seamless communication flow."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_18_core_refactoring_architecture",
--           "level": 2,
--           "text": "Core Refactoring & Architecture"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Migrated event‑manager modules to a version‑ed directory structure, preparing the codebase for future updates and better organization.",
--             "Reorganized documentation and centralized gameplay‑logging registration, making it easier for contributors to locate and understand core systems.",
--             "Updated faction UI component hierarchy and introduced radio‑linked lifecycle management for more cohesive window behavior.",
--             "These updates collectively enhance visual clarity, deepen gameplay immersion, and lay a robust foundation for future feature expansions."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_17",
--       "chapter_id": "release_notes",
--       "title": "2026-04-17",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-17"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_17",
--           "level": 1,
--           "text": "Updates for 2026-04-17"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_17_trade_scheduling_system",
--           "level": 2,
--           "text": "Trade Scheduling System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a full‑featured trade scheduling interface with a calendar view, allowing players to set and visualize trading windows.",
--             "Added configurable eligibility settings so only qualified NPCs can schedule trades, preventing unwanted matches.",
--             "Implemented enforcement logic and roster state normalization across both V1 and V2 trade managers, ensuring consistent behavior and reducing desynchronization bugs."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_17_debug_tools_hub",
--           "level": 2,
--           "text": "Debug Tools Hub"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Launched a central debug hub window that aggregates all development utilities in one place, streamlining testing and troubleshooting.",
--             "Replaced the fragile scrollbar‑relayout routine in the faction debug window with a robust `refreshRichTextPanel` helper, resulting in smoother UI updates and fewer rendering glitches."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_17_radio_contact_visit_system",
--           "level": 2,
--           "text": "Radio Contact Visit System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Developed the V1 radio contact visit system, complete with backend routing and scan‑capacity management, enabling NPCs to travel to radio stations reliably.",
--             "Enhanced visit requests with dynamic UI feedback, real‑time ETA tracking, and persistent conversation states, giving players clearer information and smoother interactions during radio‑based missions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_17_global_trader_contacts",
--           "level": 2,
--           "text": "Global Trader Contacts"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refactored trader contact handling into modular core, persistence, runtime, and event components, greatly improving code maintainability and future expandability.",
--             "Delivered a new global trader contacts UI that lets players manage and view saved NPC frequencies, making it easier to track and organize trading partners across the map."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_17_radar_companion_enhancements",
--           "level": 2,
--           "text": "Radar & Companion Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added callable travel companions to the radar system with ownership‑based filtering, ensuring only owned companions appear as selectable options.",
--             "Implemented ownership verification and extended metadata support for travel companions, providing richer information (e.g., load capacity, status) directly in the radar window.",
--             "Integrated an automated “inventory full” prompt for NPC companions, preventing lost loot and giving clear feedback when a companion cannot carry more items.",
--             "Improved overall radar UI feedback to reflect companion states and inventory status more intuitively.",
--             "Created an interactive loot‑search and collection system for NPC companions, allowing them to autonomously locate, retrieve, and deliver items, which enhances automation and reduces player micromanagement."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_16",
--       "chapter_id": "release_notes",
--       "title": "2026-04-16",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-16"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_16",
--           "level": 1,
--           "text": "Updates for 2026-04-16"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_debug_inspection_tools",
--           "level": 2,
--           "text": "Debug & Inspection Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a **Loot Vision Inspector** that visualizes NPC loot perception ranges, making it easier to fine‑tune loot distribution logic.",
--             "Implemented comprehensive **NPC removal logging** with detailed trace output, helping identify why and when NPCs are despawned.",
--             "Introduced a robust **debug logging framework** for all NPC systems, providing clear, filterable messages for developers during testing."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_npc_loot_inventory_enhancements",
--           "level": 2,
--           "text": "NPC Loot & Inventory Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Developed **LootNearby** behavior that directs NPCs to scavenge nearby items, complete with UI feedback and server‑side state synchronization for consistent world updates.",
--             "Integrated **ammo status checks** that prevent NPCs from attempting ranged attacks with insufficient ammunition, reducing wasted combat actions.",
--             "Added **durability‑based weapon retirement** logic, automatically discarding heavily worn weapons to keep NPC inventories functional.",
--             "Implemented **condition validation** for items, ensuring NPCs only equip gear that meets defined quality thresholds."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_combat_guard_ai_improvements",
--           "level": 2,
--           "text": "Combat & Guard AI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created **guard combat orders** and multiple **attack modes** (e.g., aggressive, defensive, hold position) giving players granular control over NPC defensive behavior.",
--             "Added a **Stay** behavior allowing guards to remain stationary while still monitoring threats, useful for securing key locations.",
--             "Integrated **combat attack tracking** for linked workers, enabling coordinated strikes and synchronized damage calculations.",
--             "Enhanced UI with **customizable color schemes** for guard states, improving at‑a‑glance status recognition."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_anti_stuck_follow_system",
--           "level": 2,
--           "text": "Anti‑Stuck & Follow System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a **modular anti‑stuck recovery system** that detects and resolves path‑finding dead‑ends, then seamlessly reintegrates the logic into the existing **follow** behavior, resulting in smoother NPC movement and fewer interruptions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_state_tracking_synchronization",
--           "level": 2,
--           "text": "State Tracking & Synchronization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added **zombie state tracking** within the NPC synchronization flow, ensuring NPCs correctly react to evolving undead threats.",
--             "Developed a **reusable body identification** module for respawn systems, allowing NPCs to locate and interact with their own corpses reliably.",
--             "Prevented NPCs from **targeting player characters** unintentionally, reducing accidental friendly fire and improving overall gameplay balance."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_skill_companion_systems",
--           "level": 2,
--           "text": "Skill & Companion Systems"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a new **Monolith‑Decoupler** skill, providing NPCs with a unique ability that alters their interaction with monolithic structures.",
--             "Added **companion dialogue** for ranged combat scenarios, giving players contextual feedback when companions assist with firearms."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_16_codebase_refactoring_shared_library_migration",
--           "level": 2,
--           "text": "Codebase Refactoring & Shared Library Migration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Consolidated manual definitions, archetype items, events, and version‑specific files into a **common shared library**, reducing duplication and simplifying future updates.",
--             "Removed redundant wrapper functions and unused constants from protect behavior logic, streamlining the codebase and improving maintainability."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_15",
--       "chapter_id": "release_notes",
--       "title": "2026-04-15",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-15"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_15",
--           "level": 1,
--           "text": "Updates for 2026-04-15"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_15_core_refactoring_cleanup",
--           "level": 2,
--           "text": "Core Refactoring & Cleanup"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Consolidated all mod assets into a shared directory, simplifying maintenance and ensuring consistent access across the mod.",
--             "Removed outdated files, assets, and legacy NPC logic components, reducing clutter and preventing potential conflicts.",
--             "Reorganized sandbox option handling and streamlined event manager module paths for clearer code structure and easier future extensions.",
--             "Updated file path conventions to match the new modular architecture and added robust error logging for network‑related dependencies, improving diagnostics and stability."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_15_compatibility_version_support",
--           "level": 2,
--           "text": "Compatibility & Version Support"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented full support for Project Zomboid build **b42.16**, ensuring the Dynamic Trading system functions correctly with the latest game version."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_15_ui_performance_enhancements",
--           "level": 2,
--           "text": "UI & Performance Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced lazy‑loading for 3D portrait model views, markedly decreasing UI load times and lowering memory usage during trading interactions."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_14",
--       "chapter_id": "release_notes",
--       "title": "2026-04-14",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-14"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_14",
--           "level": 1,
--           "text": "Updates for 2026-04-14"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_npc_portrait_animation_system",
--           "level": 2,
--           "text": "NPC Portrait & Animation System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added transaction‑specific portrait animations, introducing the **DTPortraitIdleAiming** state for smoother visual feedback during trades.",
--             "Implemented NPC portrait animation profiles with dynamic speech states, enhancing the trading and conversation UI with context‑aware facial expressions.",
--             "Developed a shared NPC portrait rendering pipeline, including resolution handling, debug tools, and a CRT overlay toggle for visual testing.",
--             "Integrated dummy target generation into the portrait debugger to facilitate rapid prototyping of animation states.",
--             "Expanded portrait UI panels (height increase) and replaced static labels with dynamic info panels for clearer, real‑time data display."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_trading_conversation_ui_enhancements",
--           "level": 2,
--           "text": "Trading & Conversation UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced dynamic speech state handling, allowing NPCs to react visually to player dialogue choices during trading interactions.",
--             "Updated UI assets and manual documentation to reflect new portrait and animation features, ensuring players and modders have accurate guidance."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_medical_self_care_mechanics",
--           "level": 2,
--           "text": "Medical & Self‑Care Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented medical supply tracking and validation for NPC self‑patching actions, guaranteeing that NPCs only use appropriate resources.",
--             "Fixed remote‑client response for NPC self‑bandage actions, correctly returning **applying** status instead of **blocked**.",
--             "Added crawling animation support and refined self‑bandage cancellation logic, improving realism when NPCs heal themselves while moving."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_faction_colony_management",
--           "level": 2,
--           "text": "Faction & Colony Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added comprehensive faction administration tools, including colony archiving with a dedicated debug UI for easier server maintenance.",
--             "Introduced worker retention options when kicking faction members, preserving valuable labor resources.",
--             "Enhanced worker transfer logic during join/leave events, ensuring seamless redistribution of tasks and preventing job loss."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_companion_ui_improvements",
--           "level": 2,
--           "text": "Companion UI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Integrated companion command transfer and claim functionality into the travel companion UI, allowing players to delegate control of companions or reclaim them instantly."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_update_notification_system",
--           "level": 2,
--           "text": "Update & Notification System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented version‑aware manual update notifications, alerting players when a new mod version is available and guiding them through the update process."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_debug_developer_tools",
--           "level": 2,
--           "text": "Debug & Developer Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a CRT overlay toggle to the NPC portrait debugger for visual effect testing.",
--             "Created a search utility to streamline asset lookup within debug and manual documentation.",
--             "Updated NPC debug assets and manual resources to reflect new systems and provide clearer guidance for developers."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_14_core_refactors_system_modularization",
--           "level": 2,
--           "text": "Core Refactors & System Modularization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Replaced static UI labels with dynamic information panels, improving adaptability across different screen resolutions and content changes.",
--             "Removed obsolete agent documentation skills, simplifying the skill tree and reducing clutter.",
--             "Extracted NPC death and incapacitation logic into a dedicated system package, modularizing lifecycle management for easier future extensions and maintenance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_13",
--       "chapter_id": "release_notes",
--       "title": "2026-04-13",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-13"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_13",
--           "level": 1,
--           "text": "Updates for 2026-04-13"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_13_npc_health_damage_management",
--           "level": 2,
--           "text": "NPC Health & Damage Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added health‑delta suppression for incapacitated NPCs, preventing unintended damage while they are downed.",
--             "Implemented friendly‑fire protection, ensuring NPCs no longer damage each other during combat.",
--             "Introduced data‑only damage handling that updates health states without triggering visual effects, improving performance in crowded encounters.",
--             "Fixed bandage completion tracking to rely on animation cues, with a fallback grace period to guarantee heal completion even if animation data is missing."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_13_npc_mobility_movement_system",
--           "level": 2,
--           "text": "NPC Mobility & Movement System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refactored the monolithic movement code into a dedicated **DTNPC_Mobility** module, making the system easier to maintain and extend.",
--             "Integrated the new mobility core across all NPC behaviors, standardizing movement, obstacle navigation, and retreat logic when taking damage.",
--             "Added locomotion synchronization with separate walking and running animation sets, delivering smoother and more realistic NPC motion.",
--             "Updated facing logic to prioritize the direction of movement rather than a static target orientation, resulting in more natural turning behavior."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_13_combat_threat_handling",
--           "level": 2,
--           "text": "Combat & Threat Handling"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented line‑of‑sight checks and immediate threat targeting, allowing NPCs to react quickly to visible dangers.",
--             "Added an evasion and damage‑mitigation system that scales with NPC skill levels and combat state, giving higher‑skill NPCs a tangible defensive edge.",
--             "Fixed the combat noise emission system and refined despawn handling to prioritize live departures, reducing abrupt disappearances and improving immersion."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_13_trading_system_refactor",
--           "level": 2,
--           "text": "Trading System Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Split trading behavior into modular sub‑components and introduced ranged‑combat logic for merchant NPCs, enabling them to defend themselves from a distance.",
--             "Integrated the new mobility framework into trading interactions, ensuring merchants move and react consistently with other NPC types."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_08",
--       "chapter_id": "release_notes",
--       "title": "2026-04-08",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-08"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_08",
--           "level": 1,
--           "text": "Updates for 2026-04-08"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_08_dynamic_trading_npc_equipment_loadout_system",
--           "level": 2,
--           "text": "Dynamic Trading – NPC Equipment & Loadout System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Candidate Selection System for NPC Visuals and Loadouts**",
--             "Introduced a robust algorithm that evaluates and selects appropriate equipment visual sets and loadouts for NPCs. This ensures that each trader displays gear that matches their role and rarity, enhancing immersion and visual consistency.",
--             "**Combat Fallback Logic & Notifications for Missing Loadouts**",
--             "Added safety checks that trigger when an NPC lacks a predefined loadout during auto‑protect combat scenarios. The system now defaults to a sensible backup loadout and provides clear in‑game notifications, preventing combat glitches and keeping player interactions smooth."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_07",
--       "chapter_id": "release_notes",
--       "title": "2026-04-07",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-07"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_07",
--           "level": 1,
--           "text": "Updates for 2026-04-07"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_07_npc_companion_combat_enhancements",
--           "level": 2,
--           "text": "NPC Companion & Combat Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced travel companions for NPCs, allowing them to move together and provide tactical support during journeys.",
--             "Added a combat rhythm system that syncs NPC attack patterns, creating more engaging and predictable combat encounters.",
--             "Updated the mod version to **1.1.1**, reflecting these new gameplay features and ensuring compatibility with the latest game build."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_07_supporter_carousel_ui_hall_of_fame_integration",
--           "level": 2,
--           "text": "Supporter Carousel UI & Hall of Fame Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a new **Supporter Carousel** UI component that showcases supporters in a rotating display, enhancing visibility and appreciation.",
--             "Integrated the Hall of Fame manual with the carousel, allowing players to view supporter achievements directly within the UI.",
--             "Refreshed the Hall of Fame supporter carousel UI for a cleaner, more intuitive presentation."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_07_documentation_version_updates",
--           "level": 2,
--           "text": "Documentation & Version Updates"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a comprehensive **1.5.1 update manual**, detailing new features, configuration options, and installation steps.",
--             "Updated the Hall of Fame manual to reflect the latest carousel integration and supporter recognition workflow."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_06",
--       "chapter_id": "release_notes",
--       "title": "2026-04-06",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-06"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_06",
--           "level": 1,
--           "text": "Updates for 2026-04-06"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_06_npc_health_system",
--           "level": 2,
--           "text": "NPC Health System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Dynamic bandage icon rendering** – Health bars now display distinct icons based on the specific bandage type an NPC is using, making status monitoring clearer for players.",
--             "**Configurable incapacitated HP values** – NPCs start with custom health values instead of defaulting to zero, allowing finer tuning of difficulty and survivability.",
--             "**Passive health regeneration** – Resting NPCs slowly regain health, with regeneration continuing even while the player is offline via the manager tick, improving realism and NPC longevity.",
--             "**Modular health architecture** – NPC health logic has been moved to a dedicated directory with shared utility functions, simplifying future maintenance and extension."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_06_travel_companion_system",
--           "level": 2,
--           "text": "Travel Companion System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Travel companion job UI** – A new interface lets players assign and manage companion jobs, fully integrated with NPC behavior and dialogue systems.",
--             "**Companion order menu & self‑bandage** – Players can issue orders through a streamlined menu, and companions can automatically apply bandages using linked supply caches, enhancing autonomous support."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_06_combat_enhancements",
--           "level": 2,
--           "text": "Combat Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Combat overhaul** – Revamped NPC combat mechanics, lifecycle handling, and network synchronization, accompanied by new sandbox options and an in‑game manual for easier configuration.",
--             "**Combat rhythm system** – Introduces tactical recovery periods, kiting mechanics, and dynamic flavor text, giving NPCs more realistic and varied combat behavior.",
--             "**Ranged combat integration** – Standardized ranged attack logic with the shared protection system and unified NPC state management, resulting in smoother and more consistent combat interactions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_06_aggro_ai_management",
--           "level": 2,
--           "text": "Aggro & AI Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Modular zombie aggro system** – NPCs now use a dedicated aggro management module, allowing clearer control over zombie attraction and threat handling."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_06_bandaging_system",
--           "level": 2,
--           "text": "Bandaging System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Full NPC bandaging workflow** – Added animation sets, UI indicators, and debug tools for NPCs to bandage themselves and others, providing visual feedback and easier troubleshooting for modders."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_05",
--       "chapter_id": "release_notes",
--       "title": "2026-04-05",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-05"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_05",
--           "level": 1,
--           "text": "Updates for 2026-04-05"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_05_custom_npc_health_system",
--           "level": 2,
--           "text": "Custom NPC Health System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a configurable health framework for NPCs, allowing health values to scale based on difficulty settings and player progression.",
--             "Integrated the new health system with combat mechanics so that damage calculations, death handling, and loot drops now reflect the custom health values."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_05_npc_combat_movement_improvements",
--           "level": 2,
--           "text": "NPC Combat & Movement Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented combat pursuit tracking, enabling NPCs to maintain focus on a target and intelligently break off when the target becomes unreachable.",
--             "Added a timeout mechanism for unreachable targets, preventing NPCs from getting stuck in endless chase loops.",
--             "Updated walk animation variables to synchronize movement states, ensuring smoother and more consistent NPC locomotion during combat and idle periods."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_04",
--       "chapter_id": "release_notes",
--       "title": "2026-04-04",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-04"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_04",
--           "level": 1,
--           "text": "Updates for 2026-04-04"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_04_core_npc_system_overhaul",
--           "level": 2,
--           "text": "Core NPC System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Modularized NPC architecture** – Split the monolithic NPC logic, data, and equipment files into clearly structured sub‑directories, making future maintenance and extensions far easier.",
--             "**Weighted zombie selection & duplicate pruning** – Replaced the simple zombie lookup with a scoring system that prefers optimal candidates and automatically removes duplicates, resulting in more stable NPC persistence and fewer spawning glitches.",
--             "**Centralized radio scan flavor text** – Moved all radio‑scan messages and their localization strings into a shared utility module, streamlining translation updates and ensuring consistent in‑game text."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_04_combat_defense_enhancements",
--           "level": 2,
--           "text": "Combat & Defense Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Ambient auto‑defense for stationary NPCs** – Stationary NPCs now automatically defend themselves when threatened, with a post‑return logic that resets their state after combat.",
--             "**Combat protection behavior & custom animation sets** – Added protective combat routines and bespoke animation packs for NPCs, giving them more realistic reactions and smoother visual feedback during fights.",
--             "**Vanilla fishing handler compatibility patch** – Adjusted NPC combat code to coexist with the base game’s fishing system, preventing conflicts when players fish near NPCs."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_04_equipment_gear_management",
--           "level": 2,
--           "text": "Equipment & Gear Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Archetype equipment registry** – Introduced a centralized registry that defines default gear for each NPC archetype, simplifying gear assignment and balancing.",
--             "**Debug command for weapon assignment** – New console command lets developers instantly equip NPCs with specific weapons for testing purposes.",
--             "**Outfit ID refactor to body instance ID** – Renamed outfit identifier references to use body instance IDs, improving clarity and reducing mismatches in gear handling.",
--             "**Zombie reattachment via startup hints** – Implemented a system that reattaches zombie parts at world start using body instance hints, enhancing visual consistency for reanimated NPCs."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_04_sandbox_gameplay_options",
--           "level": 2,
--           "text": "Sandbox & Gameplay Options"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**NPC engine state suppression** – Added the ability to suppress certain engine states for NPCs, giving modders finer control over NPC processing load.",
--             "**Weapon durability sandbox toggle** – New sandbox option lets players enable or disable weapon durability degradation for NPCs, allowing customized difficulty and role‑play experiences."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_03",
--       "chapter_id": "release_notes",
--       "title": "2026-04-03",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-03"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_03",
--           "level": 1,
--           "text": "Updates for 2026-04-03"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_03_codebase_modularization_architecture",
--           "level": 2,
--           "text": "Codebase Modularization & Architecture"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Split **SignalPanel** logic into its own directory with dedicated sub‑modules, improving code discoverability and future feature expansion.",
--             "Refactored network server handlers, separating raw data processing from trade‑specific logic, which simplifies maintenance and reduces the risk of cross‑module side effects.",
--             "Re‑organized **soul management** into distinct modules for creation, status tracking, storage, and cleanup, enabling clearer responsibilities and easier debugging.",
--             "Decomposed the **economy system** into multiple sub‑modules and updated file paths, resulting in a cleaner project structure and faster compile times.",
--             "Moved NPC context‑menu and radar‑window code into dedicated sub‑directories, making UI extensions and bug fixes more straightforward.",
--             "Re‑structured the **radar manager** into modular files, enhancing readability and allowing independent updates to radar features.",
--             "Migrated all NPC client‑side logic to a structured **ClientSync** directory and broke out health‑bar components, paving the way for smoother client‑server synchronization.",
--             "Isolated the **health bar system** into separate files, improving maintainability and enabling targeted performance tweaks.",
--             "Reorganized **building scanner** configuration and logic to better support county‑level scanning, expanding the tool’s utility for large‑scale maps."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_03_in_game_manual_documentation_system",
--           "level": 2,
--           "text": "In‑Game Manual & Documentation System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a fully functional **in‑game manual system**, providing players with searchable, context‑aware documentation for colony, economy, and NPC mechanics.",
--             "Added a dedicated **Scavenger Radio manual** and corrected formatting across existing documentation, ensuring consistent presentation.",
--             "Overhauled the **World Events manual**, now featuring an **Economics Dashboard**, detailed flash‑event explanations, and market‑influence guides to help players strategize during dynamic events.",
--             "Updated faction intelligence manual content and removed obsolete casino assets, keeping the guide current with the latest gameplay balance.",
--             "Refined manual titles, added new update notes for the March 27 2026 release, and streamlined the auto‑open logic for a smoother user experience.",
--             "Expanded the documentation metadata schema to include economy and NPC guides, facilitating richer search results and future content integration.",
--             "Renamed and standardized manual titles, refreshed intelligence tips, and renamed the radio manual file for clearer organization."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_03_asset_cleanup",
--           "level": 2,
--           "text": "Asset Cleanup"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Eliminated redundant item definitions from literature and weapon‑trading lists, reducing potential conflicts and decreasing load times."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_04_01",
--       "chapter_id": "release_notes",
--       "title": "2026-04-01",
--       "keywords": [
--         "update",
--         "release",
--         "2026-04-01"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_04_01",
--           "level": 1,
--           "text": "Updates for 2026-04-01"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_04_01_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Replaced outdated manual files with comprehensive **Economy Guide** and **Event Guide**, providing clearer instructions on trading mechanics and event-driven market changes.",
--             "Added new support assets (icons, UI elements, and reference tables) to enhance the visual presentation of the trading system.",
--             "Impact:* Players now have access to up‑to‑date documentation and richer visual cues, making it easier to understand and engage with the dynamic economy and special events."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_31",
--       "chapter_id": "release_notes",
--       "title": "2026-03-31",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-31"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_31",
--           "level": 1,
--           "text": "Updates for 2026-03-31"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_31_dynamic_trading_ui_improvements",
--           "level": 2,
--           "text": "Dynamic Trading UI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added text‑wrapping to the manual trading interface, preventing overflow and keeping long messages readable.",
--             "Implemented dynamic support‑banner height adjustments so the banner resizes automatically to fit its content, eliminating visual clipping.",
--             "Refactored UI state management to use per‑save **ModData**, ensuring each game save retains its own trading UI settings and avoiding cross‑save data leakage.",
--             "Updated the support‑banner layout to work with the new dynamic height logic, delivering a cleaner and more responsive appearance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_30",
--       "chapter_id": "release_notes",
--       "title": "2026-03-30",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-30"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_30",
--           "level": 1,
--           "text": "Updates for 2026-03-30"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_30_chat_dialogue_enhancements",
--           "level": 2,
--           "text": "Chat & Dialogue Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Modular Conversation Menus** – Added `DT_ConversationChatMenus` and refactored trader dialogue hubs, allowing each trader to present context‑specific chat options without hard‑coded scripts.",
--             "**Daily Reputation System** – Introduced a reputation tracker that updates based on daily chat interactions, giving players a clear progression path for building trust with NPCs.",
--             "**Expanded NPC Dialogue** – NPCs now share faction news and personal details, enriching role‑play opportunities and making conversations feel more alive."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_30_trader_roster_systems",
--           "level": 2,
--           "text": "Trader & Roster Systems"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Archetype‑Based Roster Spawning** – Traders are generated according to defined archetypes, ensuring balanced and varied trader populations across maps.",
--             "**Dynamic Trade Mode Restrictions** – Trade modes now adapt to the current game state (e.g., survivor count, zone safety), preventing inappropriate trades and improving immersion.",
--             "**Admin‑Level Forced Trader Generation** – New console commands let administrators spawn specific traders on demand for testing or event scenarios."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_30_compatibility_integration",
--           "level": 2,
--           "text": "Compatibility & Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**CurrencyExpanded Audio Support** – Integrated the CurrencyExpanded mod’s sound categories, so new currencies trigger appropriate audio cues.",
--             "**Roster Logic Updates** – Adjusted internal references to align with the new archetype system, ensuring seamless interaction with other mods that modify trader rosters."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_30_cleanup_removal",
--           "level": 2,
--           "text": "Cleanup & Removal"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Wallet System Removal** – Eliminated the legacy wallet mechanic, its documentation, related sandbox options, and unused sound assets, reducing mod bloat and potential conflicts."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_28",
--       "chapter_id": "release_notes",
--       "title": "2026-03-28",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-28"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_28",
--           "level": 1,
--           "text": "Updates for 2026-03-28"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_28_trading_ui_dynamic_colonies_integration",
--           "level": 2,
--           "text": "Trading UI & Dynamic Colonies Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a comprehensive scavenging manual and a bridge UI to seamlessly connect with the Dynamic Colonies system, improving player guidance and inter-mod communication.",
--             "Refined the trading interface to accommodate the new integration, delivering a more intuitive experience when managing scavenged resources."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_28_pricing_system_enhancements",
--           "level": 2,
--           "text": "Pricing System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented support for persistent price presets, allowing market prices to retain their values across game sessions.",
--             "Introduced configurable dynamic base prices, giving server hosts fine‑grained control over economic scaling and enabling more realistic price fluctuations."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_28_wallet_lottery_mechanics",
--           "level": 2,
--           "text": "Wallet & Lottery Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Developed a wallet lottery system that rewards players with random items based on wallet contents, adding an exciting chance‑based element to trading.",
--             "Added state tracking for wallet items, ensuring accurate accounting of items held, spent, or won, which enhances reliability of the new lottery feature."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_28_new_tradable_item_categories",
--           "level": 2,
--           "text": "New Tradable Item Categories"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created new tradable building and fluid item categories, expanding the range of assets that can be bought, sold, or exchanged.",
--             "Updated the trading UI, economy calculations, and item generation scripts to recognize and properly handle these categories, enriching the in‑game economy with more diverse trade options."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_27",
--       "chapter_id": "release_notes",
--       "title": "2026-03-27",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-27"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_27",
--           "level": 1,
--           "text": "Updates for 2026-03-27"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_27_dynamic_trading_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a quantity selector when selling items, allowing players to specify exact stack sizes rather than defaulting to whole stacks.",
--             "Impact:* Improves inventory management and speeds up trading by reducing repetitive clicks.",
--             "Implemented caching and grouping for sellable‑item scans, dramatically reducing the number of inventory passes required.",
--             "Impact:* Faster trade UI refreshes, especially in large inventories, leading to smoother gameplay."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_27_user_guidance_update_notifications",
--           "level": 2,
--           "text": "User Guidance & Update Notifications"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a manual “auto‑open” feature that automatically displays the update notes window when a new mod version is detected.",
--             "Impact:* Ensures players are immediately aware of important changes without needing to check manually.",
--             "Added a dismissible support banner that provides quick access to help resources and can be hidden permanently per user preference.",
--             "Impact:* Enhances user experience by offering assistance without cluttering the interface.",
--             "Created new manual pages covering the latest features and usage tips.",
--             "Impact:* Provides clear documentation, helping both new and veteran players make the most of recent additions."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_26",
--       "chapter_id": "release_notes",
--       "title": "2026-03-26",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-26"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_26",
--           "level": 1,
--           "text": "Updates for 2026-03-26"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_26_user_interface_enhancements",
--           "level": 2,
--           "text": "User Interface Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a comprehensive in‑game manual UI featuring searchable content, intuitive navigation, and dynamic rendering of entries, allowing players to quickly locate information without leaving the game."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_26_gameplay_balance_skill_adjustments",
--           "level": 2,
--           "text": "Gameplay Balance & Skill Adjustments"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Replaced the **Artistic** skill with **Maintenance** across relevant character archetypes, aligning skill progression with the new focus on equipment upkeep.",
--             "Added item‑condition and head‑condition application logic, integrating the `DC_Colony` equipment state system to reflect wear and tear more realistically.",
--             "Enforced minimum skill caps for Maintenance tasks, ensuring that only suitably trained survivors can perform advanced repairs."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_26_multiplayer_synchronization_improvements",
--           "level": 2,
--           "text": "Multiplayer Synchronization Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented server‑side synchronization of custom item data after modifications, guaranteeing that all players see consistent item states in shared sessions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_26_content_cleanup",
--           "level": 2,
--           "text": "Content Cleanup"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Removed all Labour‑related sandbox options and their associated translations, streamlining the configuration menu and eliminating unused content."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_25",
--       "chapter_id": "release_notes",
--       "title": "2026-03-25",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-25"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_25",
--           "level": 1,
--           "text": "Updates for 2026-03-25"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_25_player_faction_membership_management",
--           "level": 2,
--           "text": "Player Faction Membership Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a comprehensive system for handling player faction membership, covering invitation handling, role assignment, and real‑time status updates.",
--             "Players can now send and receive faction invites, accept or decline them, and view pending requests.",
--             "Role management allows faction leaders to assign, modify, or revoke specific roles, granting tailored permissions and responsibilities.",
--             "Status tracking ensures that changes in membership (e.g., joining, leaving, role changes) are reflected instantly across the server, improving coordination and immersion in multiplayer sessions."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_24",
--       "chapter_id": "release_notes",
--       "title": "2026-03-24",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-24"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_24",
--           "level": 1,
--           "text": "Updates for 2026-03-24"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_24_ui_improvements",
--           "level": 2,
--           "text": "UI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Owned faction prioritization** – UI now sorts and highlights factions that the player already controls, making trade partner selection faster and more intuitive.",
--             "**Faction info header refresh** – Updated to reflect the removal of legacy systems, providing cleaner and more relevant information at a glance.",
--             "**Project status panels** – New UI elements display real‑time installation progress and detailed project details, helping players monitor construction without opening multiple menus."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_24_core_system_refactor",
--           "level": 2,
--           "text": "Core System Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Removed Labour and Buildings subsystems** – Eliminated outdated mechanics and their associated UI, reducing code complexity and improving overall performance.",
--             "**Adjusted related UI components** – Updated remaining interfaces to work seamlessly with the streamlined architecture, enhancing stability and maintainability."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_24_medical_care_system",
--           "level": 2,
--           "text": "Medical Care System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Doctor job introduced** – Characters assigned as Doctors can now treat injuries and illnesses, improving survivor health management.",
--             "**Infirmary building added** – Provides a dedicated space for medical treatment, increasing the effectiveness of the Doctor role.",
--             "**Refined provisioning logic** – Medical supplies are now allocated more efficiently to patients, reducing waste and ensuring critical resources are available when needed."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_24_construction_project_management",
--           "level": 2,
--           "text": "Construction & Project Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Building installations** – Players can now place and activate structures, expanding settlement development options.",
--             "**Project material supply system** – Automatically tracks required resources and feeds them to active projects, simplifying logistics and reducing manual micromanagement.",
--             "**Enhanced construction UI** – Detailed project requirement lists and progress bars give players clearer insight for better planning and resource allocation."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_24_development_tools",
--           "level": 2,
--           "text": "Development Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**VS Code workspace file** – Added a ready‑to‑use workspace configuration to streamline development setup for contributors."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_23",
--       "chapter_id": "release_notes",
--       "title": "2026-03-23",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-23"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_23",
--           "level": 1,
--           "text": "Updates for 2026-03-23"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_23_building_management_tracking",
--           "level": 2,
--           "text": "Building Management & Tracking"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a dedicated Buildings Management system with a full‑screen UI, map integration and project tracking tools, giving players clear visibility over construction sites and ongoing projects.",
--             "Refactored core building components to improve modularity and future extensibility."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_23_construction_destruction_mechanics",
--           "level": 2,
--           "text": "Construction & Destruction Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added robust building construction functionality, including UI prompts, labour assignment handling, and network synchronization for multiplayer sessions.",
--             "Implemented building destruction logic with validation checks, UI feedback, and server‑client communication to ensure consistent world updates."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_23_labour_system_enhancements",
--           "level": 2,
--           "text": "Labour System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Integrated scavenge result data into worker profiles, allowing detailed performance tracking.",
--             "Added a new “Needs” panel to the worker UI, presenting resource requirements and status at a glance."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_23_archetype_skill_system",
--           "level": 2,
--           "text": "Archetype Skill System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created a comprehensive archetype skill framework with new skill definitions, configuration files, and registry integration.",
--             "Added UI elements for labour to display skill levels and specializations, empowering players to assign workers more strategically."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_23_tiredness_fatigue_management",
--           "level": 2,
--           "text": "Tiredness & Fatigue Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Developed a full tiredness system for labour workers, introducing distinct fatigue states, automatic return reasons, and visual UI indicators.",
--             "Enables realistic worker stamina behavior, improving immersion and requiring careful workforce management."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_22",
--       "chapter_id": "release_notes",
--       "title": "2026-03-22",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-22"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_22",
--           "level": 1,
--           "text": "Updates for 2026-03-22"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_22_system_architecture_modularization",
--           "level": 2,
--           "text": "System Architecture & Modularization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refactored the faction, economy, event, server, and configuration systems into distinct, reusable modules, improving code maintainability and future extensibility.",
--             "Separated labour simulation logic and worker interaction handling into dedicated modules, allowing easier tweaking of labour mechanics.",
--             "Split worker network handlers into their own components, streamlining networking code and reducing cross‑module dependencies.",
--             "Organized supply‑window actions into individual files, enhancing readability and simplifying future feature additions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_22_user_interface_improvements",
--           "level": 2,
--           "text": "User Interface Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Overhauled the main UI components, delivering a cleaner and more intuitive player experience.",
--             "Modularized the Faction Info Window and Supply Window presentation logic, enabling independent updates and customisation.",
--             "Added new view modes to the supply window to display labour warehouse contents more clearly.",
--             "Replaced the previous job‑type cycling with a dedicated job‑selection modal, giving players precise control over worker assignments."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_22_labour_warehouse_system_enhancements",
--           "level": 2,
--           "text": "Labour & Warehouse System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a labour warehouse system with display names for each warehouse, making inventory tracking straightforward.",
--             "Implemented advanced labour interaction strings that convey progress and outcomes, improving player feedback during labour tasks.",
--             "Added auto‑repeat functionality for scavenger jobs, reducing micromanagement for repetitive scavenging runs.",
--             "Developed a comprehensive scavenging simulation that accounts for worker presence, travel logic, provisioning, and map integration, resulting in more realistic and balanced scavenging outcomes.",
--             "Updated worker job management UI with clear scavenging provision warnings, helping players avoid unintended resource loss."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_22_player_owned_faction_features",
--           "level": 2,
--           "text": "Player‑Owned Faction Features"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added full support for player‑owned factions, including UI for creation, management, and worker trade control.",
--             "Implemented a `RemoveTrader` utility and synchronized linked workers when factions are altered, ensuring data consistency across the game world."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_22_sandbox_configuration_gameplay_options",
--           "level": 2,
--           "text": "Sandbox Configuration & Gameplay Options"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Provided new sandbox options and core configuration parameters for labour work cycles and multipliers, granting map creators fine‑grained control over labour pacing and productivity."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_21",
--       "chapter_id": "release_notes",
--       "title": "2026-03-21",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-21"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_21",
--           "level": 1,
--           "text": "Updates for 2026-03-21"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_labour_system_overhaul",
--           "level": 2,
--           "text": "Labour System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Modularized labour configuration and nutrition logic into dedicated files, improving maintainability and future expandability.",
--             "Re‑engineered the main labour window UI: core logic, layout, and state management are now split into separate modules, resulting in a cleaner codebase and smoother UI updates.",
--             "Introduced a new labour help window that guides players through job assignments and explains mechanics.",
--             "Redesigned worker nutrition and health handling to use HP‑based consumption and meal‑based intake, with automatic UI refresh for real‑time feedback.",
--             "Added sandbox options allowing server admins to set daily calorie and hydration consumption for workers, giving finer control over difficulty and realism."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_supply_window_ui_redesign",
--           "level": 2,
--           "text": "Supply Window UI Redesign"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Completely overhauled the supply window: dual‑list layout, searchable items, detailed item panels, and bulk‑deposit functionality streamline inventory management.",
--             "Implemented a tabbed interface separating provisions, output, and equipment, making it faster to locate and organize resources.",
--             "Updated the rich‑text panel refreshing logic to ensure information stays current during gameplay.",
--             "Refactored and relocated all SupplyWindow UI components into a new **Core** directory, simplifying future UI enhancements."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_worker_mechanics_scavenging_enhancements",
--           "level": 2,
--           "text": "Worker Mechanics & Scavenging Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added worker carry‑weight, container capacity, and weight‑reduction mechanics, allowing more realistic load handling during scavenging.",
--             "Enhanced scavenger UI to display carry‑weight limits and current load, giving players clear visual cues.",
--             "Implemented automatic scavenge‑site profiling that analyses location context and presents site details directly in the worker UI.",
--             "Developed detailed scavenging job mechanics with configurable tool requirements and a dedicated UI presentation, giving deeper strategic options.",
--             "Created a worker cache system that stores nutrition status, equipped tools, and expected outputs, reducing runtime calculations and improving performance.",
--             "Integrated an activity log into the labour UI, providing a chronological record of worker actions and outcomes."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_item_texture_improvements",
--           "level": 2,
--           "text": "Item Texture Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added support for script‑based texture variants, clothing item textures, and multiple fallback mechanisms, resulting in higher‑resolution visuals and fewer missing‑texture glitches."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_faction_reputation_debug_ui",
--           "level": 2,
--           "text": "Faction Reputation & Debug UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented personal reputation adjustments within the faction debug UI, enabling quick testing of reputation impacts on gameplay.",
--             "Removed legacy `isRadio` checks from UI system functions, cleaning up the code and preventing unnecessary conditional logic."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_21_core_ui_refactoring",
--           "level": 2,
--           "text": "Core UI Refactoring"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized UI components across the mod into dedicated directories (e.g., **Core**, **SupplyWindow**, **Labour**), establishing a clear project structure that eases navigation and future development."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_20",
--       "chapter_id": "release_notes",
--       "title": "2026-03-20",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-20"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_20",
--           "level": 1,
--           "text": "Updates for 2026-03-20"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_20_dynamic_trading_labour_system_refactor",
--           "level": 2,
--           "text": "Dynamic Trading – Labour System Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Modularized Labour Registry and Labour Network**",
--             "Extracted core labour management logic into separate, self‑contained files. This makes the codebase easier to navigate, simplifies future extensions, and reduces the risk of accidental cross‑component interference.",
--             "**Split Labour UI into Dedicated Windows**",
--             "Replaced the single, monolithic `DT_LabourWindow` with two focused interfaces: a **Main Labour Window** for overall overview and a **Supply Window** for detailed resource management. Players now experience a cleaner, more intuitive UI that isolates high‑level stats from supply specifics.",
--             "**Created a New `DT_System` Module**",
--             "Consolidated all labour‑related UI components under a unified `DT_System` namespace and reorganized the `LabourSupplyWindow` structure. This enhances maintainability, improves load times, and sets a solid foundation for future UI enhancements within the Dynamic Trading mod."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_19",
--       "chapter_id": "release_notes",
--       "title": "2026-03-19",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-19"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_19",
--           "level": 1,
--           "text": "Updates for 2026-03-19"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_19_labour_management_system",
--           "level": 2,
--           "text": "Labour Management System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a comprehensive labour supply management UI, featuring a quantity‑input modal that lets players fine‑tune workforce allocations instantly.",
--             "Added a dedicated worker money storage system, enabling accurate tracking of wages, earnings, and expenses per employee.",
--             "Updated hydration unit handling to reflect realistic water consumption for labour activities, improving resource balance.",
--             "Implemented a worker registry and job simulation engine, providing a structured way to assign, monitor, and simulate tasks across the settlement.",
--             "Integrated resource handling tied to labour operations, ensuring that production, consumption, and logistics respond dynamically to workforce changes."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_18",
--       "chapter_id": "release_notes",
--       "title": "2026-03-18",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-18"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_18",
--           "level": 1,
--           "text": "Updates for 2026-03-18"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_18_trading_system_overhaul",
--           "level": 2,
--           "text": "Trading System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added comprehensive trading features, including new NPC archetypes and a full suite of assets to support Dynamic Trading.",
--             "Reimplemented core trading action logic in dedicated modules, improving readability and future extensibility.",
--             "Split item utility functions into specialized files, streamlining item handling and reducing cross‑module dependencies.",
--             "Consolidated and renamed common trading UI components, creating a clearer hierarchy for UI developers.",
--             "Integrated faction data requests and refined transaction handling across client and server, resulting in more reliable trade operations."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_18_reputation_system_revamp",
--           "level": 2,
--           "text": "Reputation System Revamp"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a modular **DT_Reputation API** that isolates reputation logic from other systems, making it easier to extend and maintain.",
--             "Adjusted reputation gains from trade interactions and enhanced the reputation halo text to display faction names and stage changes, giving players clearer feedback on their standing.",
--             "Implemented full integration of the new reputation system with trading transactions, ensuring reputation updates occur consistently during trades."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_18_npc_behavior_enhancements",
--           "level": 2,
--           "text": "NPC Behavior Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Disabled zombie NPCs from biting flags during spawning, preventing unintended flag damage and reducing early‑game frustration."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_18_ui_improvements",
--           "level": 2,
--           "text": "UI Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized conversation UI into separate core, visuals, faction, runtime, actions, and options files, enabling more focused development and faster UI updates.",
--             "Integrated the Player ModData Browser into the Faction Debug Menu with updated access control, providing moderators with quick insight into player data.",
--             "Added a debug UI for browsing local player ModData with expandable table contents, allowing developers to inspect and verify stored data efficiently."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_18_code_refactoring_modularization",
--           "level": 2,
--           "text": "Code Refactoring & Modularization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Relocated and renamed common trading provider files into a dedicated `Provider` subdirectory, improving project structure.",
--             "Split helper utilities into multiple specialized modules within a new subdirectory, reducing file bloat and simplifying maintenance.",
--             "Overall modularization across trading, reputation, and UI components enhances code clarity, facilitates future feature additions, and speeds up debugging."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_17",
--       "chapter_id": "release_notes",
--       "title": "2026-03-17",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-17"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_17",
--           "level": 1,
--           "text": "Updates for 2026-03-17"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_17_dynamic_trading_system_overhaul",
--           "level": 2,
--           "text": "Dynamic Trading System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Unified Trading UI & Pricing Logic**",
--             "Extracted common user‑interface components and pricing calculations into shared modules, allowing all trading providers to reuse the same visual layout and price formulas. This reduces duplicated code and ensures consistent trading experiences across the game.",
--             "**Centralized Dialogue Generation**",
--             "Consolidated the creation of trading dialogues into a single provider, streamlining how conversations with traders are built. The `TradeTransaction` server command has also been moved to a shared handler, simplifying server‑side processing and improving reliability.",
--             "**Cached Master Key Resolution**",
--             "Added a high‑performance cached utility for resolving master keys, and integrated it across all trading data providers. This reduces repeated look‑ups, speeds up data retrieval, and lowers the overhead of trading operations."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_16",
--       "chapter_id": "release_notes",
--       "title": "2026-03-16",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-16"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_16",
--           "level": 1,
--           "text": "Updates for 2026-03-16"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_npc_incapacitation_ui_enhancements",
--           "level": 2,
--           "text": "NPC Incapacitation & UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added logic for incapacitated NPCs, allowing them to remain in the world with a distinct, pulsing health bar that clearly signals their state to players.",
--             "Integrated the incapacitated state into NPC data structures, UI displays, and dialogue options, enabling realistic interactions such as treating or abandoning wounded survivors."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_secure_debug_tools",
--           "level": 2,
--           "text": "Secure Debug Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented admin‑only access checks for all debug features, ensuring that only authorized users can activate debugging utilities.",
--             "Introduced a configurable debug‑logging system, giving server admins fine‑grained control over what internal events are recorded."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_dynamic_conversation_ui",
--           "level": 2,
--           "text": "Dynamic Conversation UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added automatic refresh of faction information within the conversation window, so players always see up‑to‑date reputation data during dialogues."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_trading_window_state_management",
--           "level": 2,
--           "text": "Trading Window State Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refined the internal state handling of the trading UI, resulting in smoother opening/closing transitions and more reliable synchronization between client and server."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_archetype_editor_ui_backend",
--           "level": 2,
--           "text": "Archetype Editor (UI & Backend)"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Delivered a full‑screen Archetype Editor with a dedicated user interface for editing archetype names, expert tags, forbidden tags, and “wants” multipliers.",
--             "Exposed new API endpoints and backend logic to persist archetype allocations, allowing server operators to customise survivor skill distributions without editing raw files.",
--             "Updated default item allocations for several archetypes to better reflect their intended playstyles."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_item_tagging_categorisation_pricing_system",
--           "level": 2,
--           "text": "Item Tagging, Categorisation & Pricing System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Re‑engineered the item pricing engine to use tag‑based heuristics, providing a more logical and adaptable price structure across all item categories.",
--             "Standardised item tags and category keys throughout event effects and archetype definitions, improving consistency and simplifying future balancing.",
--             "Restructured item resources into type‑specific files (e.g., electronics, food, clothing) and introduced a unified tagging system that drives both price calculations and blacklist handling.",
--             "Updated numerous item definitions (clothing, electronics, cookware, medical drugs, containers, etc.) with new tags and pricing data, delivering a more coherent economy and clearer item differentiation."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_new_containers_medical_items",
--           "level": 2,
--           "text": "New Containers & Medical Items"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a variety of container types (e.g., backpacks, crates) and a suite of medical drugs, each with appropriate tags and pricing, expanding the inventory options available to players."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_electronics_food_cookware_expansion",
--           "level": 2,
--           "text": "Electronics, Food & Cookware Expansion"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced new electronic devices and cookware items, refined tagging for existing electronics and food, and updated the item blacklist to prevent inappropriate spawns."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_16_code_refactoring_resource_organisation",
--           "level": 2,
--           "text": "Code Refactoring & Resource Organisation"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Consolidated item definitions into modular, type‑specific files and cleaned up generation scripts, making the codebase easier to navigate and maintain.",
--             "Performed broad refactors to align item category keys and tags across the project, laying groundwork for future content additions and balance tweaks."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_15",
--       "chapter_id": "release_notes",
--       "title": "2026-03-15",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-15"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_15",
--           "level": 1,
--           "text": "Updates for 2026-03-15"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_15_item_system_overhaul",
--           "level": 2,
--           "text": "Item System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added new building and resource item registries, expanding the pool of tradable assets.",
--             "Updated the item‑tagging system to recognize the new registries, enabling more precise filtering and search in trader inventories.",
--             "Restructured food item categories and introduced additional item types, improving organization and allowing modders to classify consumables more intuitively.",
--             "Refreshed related item registries and scripts to align with the new categorization, reducing duplication and simplifying future item additions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_15_data_management_ui_integration",
--           "level": 2,
--           "text": "Data Management & UI Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented data resolution functions that intelligently merge cached and live faction/roster ModData.",
--             "Updated the faction information window to draw from the merged data, ensuring traders and players see the most current faction states without reloads.",
--             "Adjusted UI logic to handle the unified data source, resulting in smoother navigation and fewer UI inconsistencies."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_15_combat_interaction_enhancements",
--           "level": 2,
--           "text": "Combat Interaction Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added player‑killer tracking for NPC deaths, allowing the system to record which player eliminated a given NPC.",
--             "Integrated this information into the faction info window, giving traders insight into player‑specific actions and enabling more contextual dialogues."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_15_reputation_system",
--           "level": 2,
--           "text": "Reputation System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a dynamic reputation framework that influences trader dialogue based on player interactions.",
--             "Tracked trade value and NPC interactions to calculate reputation scores, giving players tangible feedback for positive or negative trading behavior.",
--             "Modified trader responses to reflect reputation changes, creating a more immersive and consequence‑driven economy."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_15_animation_interaction_improvements",
--           "level": 2,
--           "text": "Animation & Interaction Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Standardized the XML structure for NPC idle animations, simplifying future animation additions and maintenance.",
--             "Added a new idle animation for the trade bat, giving the trading area a more lively appearance.",
--             "Updated trade interaction logic to correctly handle the new idle state, ensuring seamless transitions between trading and idle behaviors."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_14",
--       "chapter_id": "release_notes",
--       "title": "2026-03-14",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-14"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_14",
--           "level": 1,
--           "text": "Updates for 2026-03-14"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_14_npc_behavior_interaction",
--           "level": 2,
--           "text": "NPC Behavior & Interaction"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a **shared stationary behavior module** that unifies idle, guard, and trading states, now detecting player proximity and managing interaction poses for smoother NPC responses.",
--             "Refined **NPC interaction and trading logic** with robust state management and smarter departure handling, reducing unexpected NPC despawns during trades.",
--             "Implemented **`DTNPCManager.ReclaimZombie`**, which repairs and re‑registers existing NPCs, improving spawn reliability and providing detailed debug logs for easier troubleshooting.",
--             "Centralized **NPC movement speed configuration** into global settings, eliminating per‑NPC speed properties and simplifying balance adjustments."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_14_ambient_dialogue_system",
--           "level": 2,
--           "text": "Ambient Dialogue System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Re‑architected the ambient dialogue system, moving files from `Ambient/DTNPC_AmbientDialogue` to a new `Dialogue/Ambient` hierarchy for clearer project organization.",
--             "Consolidated ambient dialogue registration and data structures into the main dialogue framework, streamlining the registration process and reducing redundant code.",
--             "Introduced a **modular, archetype‑based ambient NPC dialogue system** that allows configurable delay intervals per archetype, enabling more varied and natural conversations.",
--             "Added **client‑side overhead dialogue display**, letting players see NPC speech bubbles above characters without server overhead."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_14_ui_enhancements_overhead_indicators",
--           "level": 2,
--           "text": "UI Enhancements – Overhead Indicators"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reimplemented and optimized **NPC health‑bar tracking and rendering**, delivering more accurate visual feedback on NPC health status.",
--             "Introduced **overhead health bars and name tags** for NPCs, improving situational awareness for players. The obsolete debug script `DT_WorldTextDebug.lua` was removed as it is no longer needed."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_13",
--       "chapter_id": "release_notes",
--       "title": "2026-03-13",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-13"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_13",
--           "level": 1,
--           "text": "Updates for 2026-03-13"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_13_npc_system_overhaul",
--           "level": 2,
--           "text": "NPC System Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Consolidated NPC spawning and synchronization into a central `DTNPC_ServerCore` module, adding distance‑based optimizations that reduce unnecessary updates for far‑away characters.",
--             "Updated NPC data attachment processes to ensure consistent state handling across server and client."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_13_npc_behavior_enhancements",
--           "level": 2,
--           "text": "NPC Behavior Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Standardized movement animation variables and rotation logic for all NPC actions, delivering smoother visual transitions.",
--             "Refined departure handling to prevent abrupt exits and improve realism when NPCs leave the trading area.",
--             "Introduced dedicated behavior states for **trading**, **idling**, and **departure**, allowing NPCs to react more intelligently to player interactions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_13_pathfinding_stuck_detection",
--           "level": 2,
--           "text": "Pathfinding & Stuck Detection"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Enhanced the GoTo pathfinding system with built‑in stuck detection, enabling NPCs to recover automatically when they encounter obstacles or become trapped."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_13_trading_ui_refactor",
--           "level": 2,
--           "text": "Trading UI Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Modularized and refactored the trading window wrappers, separating support for the legacy V1 Radio UI and the newer V2 UI. This paves the way for future UI upgrades and simplifies maintenance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_12",
--       "chapter_id": "release_notes",
--       "title": "2026-03-12",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-12"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_12",
--           "level": 1,
--           "text": "Updates for 2026-03-12"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_12_npc_trading_enhancements",
--           "level": 2,
--           "text": "NPC & Trading Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added **active adoption** for existing NPCs and introduced pre‑spawn checks to eliminate duplicate spawns, improving NPC population stability.",
--             "Optimized **NPC respawn square search** to evaluate only the perimeter, reducing computational load during world generation.",
--             "Updated NPC data synchronization to use a unified `savedData` parameter, ensuring consistent state across server and client.",
--             "Refined the **trading system** to prevent redundant trade requests and extended the stock generation timeout, resulting in smoother vendor interactions.",
--             "Broadened the overall **economy mechanics** and refreshed several item definitions, delivering a more balanced and immersive trading experience."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_12_debug_console_logging",
--           "level": 2,
--           "text": "Debug Console & Logging"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a dedicated **debug console page** with backend log parsing and real‑time viewing, giving developers immediate insight into server activity.",
--             "Added **log filtering by level and system**, including API parameters, to the console UI, allowing targeted diagnostics without overwhelming output.",
--             "Decoupled print statements into a global logging form, standardizing output handling and simplifying future log enhancements."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_12_simulation_engine",
--           "level": 2,
--           "text": "Simulation Engine"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created a **backend simulation module** paired with a comprehensive **frontend dashboard**, enabling advanced scenario testing directly from the mod’s UI.",
--             "Developed a **client‑side simulation engine** with interactive controls and state management, giving users the ability to tweak and observe simulation parameters on the fly."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_12_item_management",
--           "level": 2,
--           "text": "Item Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced **advanced item filtering** capabilities and a dedicated **item management page**, streamlining inventory handling for both developers and players.",
--             "Refined startup scripts for backend and frontend components to ensure the new item management tools load reliably and efficiently."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_12_task_management_system",
--           "level": 2,
--           "text": "Task Management System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Launched a **task management system** featuring a frontend console for creating, tracking, and completing tasks.",
--             "Refactored item data definitions to better integrate with the task workflow, and updated backend processing to support the new task features.",
--             "These updates collectively enhance NPC behavior, trading stability, debugging efficiency, simulation flexibility, item handling, and task organization, delivering a more robust and user‑friendly DynamicTrading experience."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_11",
--       "chapter_id": "release_notes",
--       "title": "2026-03-11",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-11"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_11",
--           "level": 1,
--           "text": "Updates for 2026-03-11"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_03_11",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "feat: Implement the new ItemManagement backend module with tagging, pricing, parsing, and UI functionalities.",
--             "feat: Remove DynamicTradingInfoUI and refactor V1 virtual faction data injection into the FactionInfoWindow.",
--             "feat: Validate trader availability using roster status and return time, and update UI messages to reflect departure status.",
--             "refactor: remove V1-specific trading window wrapper and dialogue UI files.",
--             "feat: unify V1 radio and V2 radar discovery data management, move NPC trading sandbox options to common, and refactor radio interaction checks.",
--             "feat: Implement server-authoritative network handling for V1 Radio commands, refactor V1 Manager functions, and enhance soul generation with scattered home coordinates and improved UUIDs.",
--             "refactor: Centralize debug data wipe functionality and add debug item spawning to PsychopatzDebugServer.lua.",
--             "feat: Introduce client-side NPC metadata cache, populated by radar, and display discovered NPCs with details in the global list."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_10",
--       "chapter_id": "release_notes",
--       "title": "2026-03-10",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-10"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_10",
--           "level": 1,
--           "text": "Updates for 2026-03-10"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_03_10",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "refactor: Unify NPC visual generation under `identitySeed`, replacing `portraitID` and `lookSeed`, and update soul ID generation.",
--             "fix: Add type checks for ModData in global data listeners and make minor client adjustments.",
--             "refactor: Rename NPC data structure from 'brain' to 'npcData' and update debugger panel names for clarity."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_08",
--       "chapter_id": "release_notes",
--       "title": "2026-03-08",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-08"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_08",
--           "level": 1,
--           "text": "Updates for 2026-03-08"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_08_dynamic_trading_npc_animation_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading – NPC Animation Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a variety of new idle animation states for Dynamic Trading NPCs, replacing the previous generic loop and increasing the total idle state count. This gives merchants more lifelike behavior and reduces visual repetition.",
--             "Implemented a cyclical animation system using new animation nodes and Lua logic to manage NPC idle states. NPCs now transition smoothly between idle poses, creating a more immersive trading environment."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_07",
--       "chapter_id": "release_notes",
--       "title": "2026-03-07",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-07"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_07",
--           "level": 1,
--           "text": "Updates for 2026-03-07"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_07_npc_management_visuals",
--           "level": 2,
--           "text": "NPC Management & Visuals"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Modularized NPC respawn and trade cycle** – reorganized logic into a clean directory layout, making future extensions easier to maintain.",
--             "**Implemented a spatial‑hash system** for fast lookup of NPC locations, reducing the cost of distance checks during each tick.",
--             "**Added distance‑based update frequency** – NPCs far from players are processed less often, improving overall server performance.",
--             "**Integrated position interpolation** to smooth NPC movement, eliminating jittery transitions.",
--             "**Introduced archetype‑specific hair, beard, and hair‑color definitions** with seed‑based generation, giving each NPC a more distinctive and consistent appearance.",
--             "**Created comprehensive look definitions** that feed directly into the wardrobe system, ensuring NPC outfits match their archetype.",
--             "**Implemented anchor stabilization** with configurable drift tolerance and snap cooldown, preventing NPCs from drifting away from their intended positions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_07_server_core_refactoring",
--           "level": 2,
--           "text": "Server Core Refactoring"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Extracted all server‑side DTNPC logic** into a new **ServerCore** module, centralizing core functionality and simplifying cross‑module interactions.",
--             "**Renamed and reorganized DTNPC spatial‑hash files**, adding a central loader that automatically registers the hash system on startup.",
--             "**Split the monolithic `DT_EventManager`** into three focused modules (global, faction, registry), each handling its own responsibilities and providing clearer event pathways."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_07_debug_administration_ui",
--           "level": 2,
--           "text": "Debug & Administration UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Developed dedicated debug UIs** for faction administration, merchant stock management, NPC location tracking, and network adapter status.",
--             "**Moved the debug UI** into a shared module, allowing other sub‑systems to reuse common debugging widgets without duplication."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_07_event_system_enhancements",
--           "level": 2,
--           "text": "Event System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Reworked the event architecture** to support multi‑flash stacking, enabling more complex chained events without loss of timing fidelity.",
--             "**Added new sandbox control events** and updated engine data structures to version 2, expanding the range of in‑game scripting possibilities."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_07_network_optimization_dynamictrading_v2",
--           "level": 2,
--           "text": "Network Optimization (DynamicTrading V2)"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Introduced distance‑aware network broadcasting** – only players within a relevant radius receive NPC updates, drastically reducing bandwidth consumption.",
--             "**Provided an optimization plan for DynamicTrading V2**, laying groundwork for future performance improvements in trade‑related network traffic."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_05",
--       "chapter_id": "release_notes",
--       "title": "2026-03-05",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-05"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_05",
--           "level": 1,
--           "text": "Updates for 2026-03-05"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_03_05",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: v1 radio scanning bug on multiplayer",
--             "feat: impliment tags string parser",
--             "refactor(wip): put items into subfolders",
--             "refactor: update all of archetype tags",
--             "refactor(wip): connect the updated tags to archetypes",
--             "refactor(wip): refactor tags to be generalized"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_04",
--       "chapter_id": "release_notes",
--       "title": "2026-03-04",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-04"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_04",
--           "level": 1,
--           "text": "Updates for 2026-03-04"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_04_trading_system_refactor",
--           "level": 2,
--           "text": "Trading System Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized archetype definitions to improve readability and future extensibility.",
--             "Standardized item ID tag formatting across the trading module, ensuring consistent parsing and easier maintenance.",
--             "Cleared out invalid item IDs, preventing potential transaction errors and reducing server load."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_04_package_weight_mechanics",
--           "level": 2,
--           "text": "Package Weight Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added dynamic weight reduction for packaged items, allowing the total carried weight to adjust based on package contents. This provides a more realistic inventory burden and helps players manage encumbrance more effectively."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_04_quest_system",
--           "level": 2,
--           "text": "Quest System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a basic quest framework, introducing objectives, rewards, and progression tracking. Players can now receive and complete quests, adding new gameplay depth and replayability."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_03",
--       "chapter_id": "release_notes",
--       "title": "2026-03-03",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-03"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_03",
--           "level": 1,
--           "text": "Updates for 2026-03-03"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_03_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Restored full compatibility with the original version 1 by aligning all trading mechanics to match the updated version 2 implementation. This ensures that existing saves and older multiplayer sessions continue to function seamlessly after the update."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_03_02",
--       "chapter_id": "release_notes",
--       "title": "2026-03-02",
--       "keywords": [
--         "update",
--         "release",
--         "2026-03-02"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_03_02",
--           "level": 1,
--           "text": "Updates for 2026-03-02"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_03_02_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved an invalid format issue in version 1, preventing data corruption and ensuring stable trade interactions.",
--             "Enhanced Linux compatibility, fixing platform‑specific errors to provide a smoother experience for Linux users."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_27",
--       "chapter_id": "release_notes",
--       "title": "2026-02-27",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-27"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_27",
--           "level": 1,
--           "text": "Updates for 2026-02-27"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_27_dynamic_trading_system",
--           "level": 2,
--           "text": "Dynamic Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Enhanced debugging capabilities** – Updated the debug server script to improve reliability when testing NPC interactions, making it easier for developers to trace and resolve issues during development.",
--             "**Implemented DTNPC Manager** – Introduced a comprehensive NPC lifecycle manager that handles:",
--             "Per‑tick processing for dynamic behavior updates",
--             "Unique UUID assignment for reliable NPC identification",
--             "Registration and deregistration mechanisms for clean NPC handling",
--             "Automatic respawn logic to maintain population consistency",
--             "Save and load integration to persist NPC states across game sessions",
--             "These additions provide a robust foundation for dynamic trading NPCs, ensuring stable performance, consistent world persistence, and smoother development workflows."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_16",
--       "chapter_id": "release_notes",
--       "title": "2026-02-16",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-16"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_16",
--           "level": 1,
--           "text": "Updates for 2026-02-16"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_16_dynamic_trading_ui_modularization",
--           "level": 2,
--           "text": "Dynamic Trading – UI Modularization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Decoupled configuration UI** – The settings panel is now isolated from the core trading logic, allowing UI updates without affecting backend functionality and simplifying future feature expansions.",
--             "**Extracted faction info window** – Faction details are displayed in a dedicated, independent window, reducing code interdependencies and improving maintainability of the trading interface."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_15",
--       "chapter_id": "release_notes",
--       "title": "2026-02-15",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-15"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_15",
--           "level": 1,
--           "text": "Updates for 2026-02-15"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_15_multiplayer_connectivity",
--           "level": 2,
--           "text": "Multiplayer & Connectivity"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved multiplayer synchronization issues in version 1, ensuring stable gameplay across hosts and clients.",
--             "Fixed connectivity problems related to radio‑based faction management, eliminating dropped connections and improving radio trade interactions.",
--             "Addressed lingering connectivity glitches, providing a smoother experience when players join or switch servers."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_15_faction_system_enhancements",
--           "level": 2,
--           "text": "Faction System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a new faction feature for version 1, expanding faction behavior and trade options.",
--             "Relocated all NPC definitions to the shared **common** module, centralising data for easier maintenance and future updates.",
--             "Moved the entire faction system logic into the **common** module, promoting code reuse and simplifying cross‑mod compatibility."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_15_economic_mechanics_inflation",
--           "level": 2,
--           "text": "Economic Mechanics (Inflation)"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected the inflation calculation algorithm, restoring realistic price fluctuations and preventing runaway price scaling."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_15_code_refactor",
--           "level": 2,
--           "text": "Code Refactor"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Consolidated NPC and faction definitions into a unified common library, reducing duplication and streamlining the mod’s architecture."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_14",
--       "chapter_id": "release_notes",
--       "title": "2026-02-14",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-14"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_14",
--           "level": 1,
--           "text": "Updates for 2026-02-14"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_14_ui_improvements_market_panel",
--           "level": 2,
--           "text": "UI Improvements – Market Panel"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected text formatting on the market panel to ensure clear and readable information.",
--             "Resolved scrolling issues on the market tab, providing smooth navigation through long lists of items."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_14_market_system_enhancements",
--           "level": 2,
--           "text": "Market System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a new **Inflation & Deflation** tab, allowing players to monitor and react to market price fluctuations in real time."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_14_faction_event_tracking",
--           "level": 2,
--           "text": "Faction Event Tracking"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a **Faction Events Summary** window that consolidates recent event outcomes for quick reference.",
--             "Implemented sub‑tabs within the events interface, enabling organized navigation between different event categories (e.g., raids, trades, diplomatic actions)."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_13",
--       "chapter_id": "release_notes",
--       "title": "2026-02-13",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-13"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_13",
--           "level": 1,
--           "text": "Updates for 2026-02-13"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_13_npc_interaction_ui",
--           "level": 2,
--           "text": "NPC Interaction UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a dedicated **NPC Profile Panel** to display detailed information about trading partners, improving player insight and decision‑making during transactions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_13_responsive_ui_enhancements",
--           "level": 2,
--           "text": "Responsive UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented **auto‑resizing fonts** that adjust smoothly when the game window is scaled, ensuring all UI text remains clear and readable at any resolution."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_13_faction_ui_overhaul",
--           "level": 2,
--           "text": "Faction UI Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a **stand‑alone Faction UI** with its own layout, providing a focused area for faction management.",
--             "Added **tab navigation** within the Faction UI, allowing quick access to different faction sections (e.g., trade routes, member lists, reputation) without leaving the screen."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_12",
--       "chapter_id": "release_notes",
--       "title": "2026-02-12",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-12"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_12",
--           "level": 1,
--           "text": "Updates for 2026-02-12"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_event_system_overhaul_v2",
--           "level": 2,
--           "text": "Event System Overhaul (v2)"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a brand‑new event system (v2) with extended parameters, allowing richer event data and more flexible scripting.",
--             "Decoupled the event system from core gameplay logic and moved it to a common module, improving modularity and making future extensions easier.",
--             "Added debugging support for spawn options and faction handling within events, streamlining testing of event‑driven features."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_global_heat_mechanic",
--           "level": 2,
--           "text": "Global Heat Mechanic"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a global heat variable on V2 that tracks overall map temperature, enabling heat‑related mechanics such as fire spread and player stamina effects."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_trader_ui_enhancements",
--           "level": 2,
--           "text": "Trader UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Updated the trader interface for liquid containers to show the exact number of liters held.",
--             "Implemented dynamic price recalculation while the player interacts with the container, giving real‑time feedback on trade values.",
--             "Fixed the trader message display issue, ensuring all notifications appear correctly."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_sandbox_dynamic_event_loading",
--           "level": 2,
--           "text": "Sandbox & Dynamic Event Loading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized sandbox configuration options for clearer navigation and faster tweaking.",
--             "Added support for dynamic loading of events, allowing new events to be injected without restarting the game."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_debug_development_tools",
--           "level": 2,
--           "text": "Debug & Development Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Centralized debug print statements into a dedicated method, cleaning up console output and simplifying future debugging.",
--             "Added a spawn‑options debug view for factions, providing developers with immediate visibility of spawn settings during event testing."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_base_spawn_additions",
--           "level": 2,
--           "text": "Base Spawn Additions"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a new Louisville base spawn location, expanding the variety of starting points for survivors."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_12_code_cleanup_refactoring",
--           "level": 2,
--           "text": "Code Cleanup & Refactoring"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Removed redundant attrition logic, reducing unnecessary calculations and improving overall performance.",
--             "Fixed color UI rendering on V2, restoring proper visual cues for players."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_11",
--       "chapter_id": "release_notes",
--       "title": "2026-02-11",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-11"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_11",
--           "level": 1,
--           "text": "Updates for 2026-02-11"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_02_11",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "refactor: rename Networklogs",
--             "fix: overlapping Network Ui by using stencil Wrapper",
--             "refactor: decouple DynamicTrading_Factions.lua",
--             "refactor: decouple DynamicTrading_Network_Server.lua",
--             "fix: visibility check floods the logs when accessing trader despawns while accessing the window",
--             "fix: V1 message logs now uses refactored names space",
--             "fix: optimize translation loading to avoid flodding the logs",
--             "feat: impliment translation system",
--             "refactor(wip): dialogue autoregister",
--             "feat(wip): impliment translations",
--             "refactor: made option and config manager data agnostic"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_10",
--       "chapter_id": "release_notes",
--       "title": "2026-02-10",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-10"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_10",
--           "level": 1,
--           "text": "Updates for 2026-02-10"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_02_10",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: optimize TradingWindow to not recheck when the window closed",
--             "feat: persistent event marker",
--             "feat: add  info tab",
--             "feat: auto open radar ui when finding a trader",
--             "fix: optimize ConversationUI checking tick to mninimal",
--             "feat: add refusal when trading instead of hiding it while npc is resting",
--             "fix: close tradeui when dead to prevent errors",
--             "refactor: move optionui to common folder",
--             "feat: persistent DT_RadioWindow.lua",
--             "feat: persistent DT_TradingWindow.lua",
--             "feat: dynamic price on liquid based on per Liters",
--             "fix: fix trader items atrributes to also work on V2 multiplayer",
--             "feat: impliment dynamic attributes to trader's items too",
--             "fix: food items can now properly priced",
--             "fix(wip): properly detect drainable items",
--             "feat(wip): add debugs for the items with remaining value",
--             "fix: liquid container now properly detected",
--             "fix(wip): properly display fluid container name",
--             "feat(wip): impliment smarter fluid and item details detection for dynamic pricing",
--             "refactor: decouple economy.lua to be agnostic"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_09",
--       "chapter_id": "release_notes",
--       "title": "2026-02-09",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-09"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_09",
--           "level": 1,
--           "text": "Updates for 2026-02-09"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_09_backend_refactoring",
--           "level": 2,
--           "text": "Backend Refactoring"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Streamlined archetype registration to ensure more reliable loading and reduce initialization errors.",
--             "Reinforced the registration process for Dynamic Trading items, making it more robust against missing or duplicate entries, which improves overall stability of the trading system."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_09_ui_enhancements",
--           "level": 2,
--           "text": "UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Integrated location details into the radar interface, allowing players to see precise coordinates and region names directly on the map overlay.",
--             "Added a dedicated **Location** tab to the radio UI, providing quick access to current position data and nearby points of interest without leaving the communication screen."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_08",
--       "chapter_id": "release_notes",
--       "title": "2026-02-08",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-08"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_08",
--           "level": 1,
--           "text": "Updates for 2026-02-08"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_08_ui_overhaul",
--           "level": 2,
--           "text": "UI Overhaul"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a brand‑new settings layout, giving users a cleaner and more intuitive configuration experience.",
--             "Implemented a resizable radio button UI (V1), allowing players to adjust the interface to fit their screen preferences.",
--             "Corrected portrait UI integration so character images now display correctly across all trader screens."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_08_trader_interaction_enhancements",
--           "level": 2,
--           "text": "Trader Interaction Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added hooks for the trader UI, paving the way for future extensions such as custom animations or additional data displays.",
--             "Developed the core trader UI, providing a polished and responsive interface for buying, selling, and bartering with NPC merchants.",
--             "Implemented an automatic close hook that gracefully exits the Conversation UI when a trader’s session expires, preventing lingering dialogs."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_08_multiplayer_compatibility",
--           "level": 2,
--           "text": "Multiplayer Compatibility"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Updated the stock trading handler to function reliably in multiplayer sessions, ensuring synchronized inventories and trade actions for all players."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_08_debug_maintenance",
--           "level": 2,
--           "text": "Debug & Maintenance"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Fixed the Merchant debug system, restoring functionality that was broken due to outdated trigger references.",
--             "Refactored the `DT_ConversationUI` component into a shared common module, improving code reuse and simplifying future maintenance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_07",
--       "chapter_id": "release_notes",
--       "title": "2026-02-07",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-07"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_07",
--           "level": 1,
--           "text": "Updates for 2026-02-07"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_02_07",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: DynamicTradingV2 npc requires",
--             "fix: publicbroadcast set to true causes ghost list when expired",
--             "feat: change the trader budget into percent based",
--             "feat: change the buy and sell switch button to be a tab button",
--             "feat: make the tradingUI window dynamic size",
--             "feat: optimized logging system on buy and sell",
--             "fix: correct old required",
--             "refactor: DynamicTradingUI to DT_TradingWindow",
--             "refactor(wip): decouple tradeUI to make it agnostic",
--             "feat: add trader faction and reputation to DT_ConversationUI",
--             "refactor: refactor DynamicTrading V1 and V2 code to be nested",
--             "refactor: refactor DynamicTrading V1 and V2 code to be neat"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_06",
--       "chapter_id": "release_notes",
--       "title": "2026-02-06",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-06"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_06",
--           "level": 1,
--           "text": "Updates for 2026-02-06"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_06_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a fully functional stock trading system, allowing players to buy and sell shares within the game economy.",
--             "Added a dedicated trade handler for stocks, managing order processing, price updates, and transaction validation.",
--             "Integrated stock market data with existing market mechanics, providing a realistic and responsive financial simulation for players."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_05",
--       "chapter_id": "release_notes",
--       "title": "2026-02-05",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-05"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_05",
--           "level": 1,
--           "text": "Updates for 2026-02-05"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_05_trader_radar_ui_enhancements",
--           "level": 2,
--           "text": "Trader Radar UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added tab navigation to the Radar UI, allowing quicker access to different radar functions.",
--             "Implemented automatic closing of the Radar UI when the Radio UI is closed, keeping the screen uncluttered.",
--             "Introduced distance readouts in the Radio UI, giving players precise location data for traders.",
--             "Developed a dedicated Radar UI for NPC traders, providing visual tracking of merchant positions.",
--             "Added a minimum size constraint to the Radio UI to ensure all elements remain legible on various screen resolutions.",
--             "Implemented sorting of traders by proximity and updated the display interval automatically, helping players identify the nearest traders at a glance.",
--             "Added visual feedback for selected traders, improving usability when choosing a target."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_05_multiplayer_compatibility_balancing",
--           "level": 2,
--           "text": "Multiplayer Compatibility & Balancing"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Fixed the trader radar to function reliably in multiplayer sessions, ensuring all participants see accurate trader locations.",
--             "Adjusted radar value calculations for better game balance, preventing overly aggressive or passive trader detection."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_05_code_structure_improvements",
--           "level": 2,
--           "text": "Code Structure Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Refactored the Radar UI into a separate module, simplifying future maintenance and feature expansion.",
--             "Updated device identification logic to correctly distinguish windows by their names, reducing UI conflicts and improving stability."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_04",
--       "chapter_id": "release_notes",
--       "title": "2026-02-04",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-04"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_04",
--           "level": 1,
--           "text": "Updates for 2026-02-04"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_02_04",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: npc now spawns on their respected county",
--             "fix: virtually simulate trader spawning",
--             "feat(wip): trader spawning"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_02",
--       "chapter_id": "release_notes",
--       "title": "2026-02-02",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-02"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_02",
--           "level": 1,
--           "text": "Updates for 2026-02-02"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_02_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected a typo in the DT_Manager class, preventing initialization failures and ensuring the manager loads correctly.",
--             "Properly instantiated archetypes and sandbox variables, which stabilizes trade generation and removes null‑reference errors during gameplay.",
--             "Resolved duplicate return strings in faction management, resulting in clearer faction messages and a cleaner user interface."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_02_01",
--       "chapter_id": "release_notes",
--       "title": "2026-02-01",
--       "keywords": [
--         "update",
--         "release",
--         "2026-02-01"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_02_01",
--           "level": 1,
--           "text": "Updates for 2026-02-01"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_02_01_dynamic_trading_system",
--           "level": 2,
--           "text": "Dynamic Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a custom, generic parameter that decouples the trading module from the rest system, making the feature more modular and easier to extend.",
--             "Fixed a cooldown bug that forced NPCs to keep moving away, which caused an endless “away” loop; NPCs now stay put during cooldown, eliminating the glitch.",
--             "Implemented a transition that moves NPCs from the **rest** state to **away** when they begin fleeing, resulting in smoother and more realistic NPC behavior."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_31",
--       "chapter_id": "release_notes",
--       "title": "2026-01-31",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-31"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_31",
--           "level": 1,
--           "text": "Updates for 2026-01-31"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_31_dynamic_trading_system_core_refactor_behavior_fixes",
--           "level": 2,
--           "text": "Dynamic Trading System – Core Refactor & Behavior Fixes"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Decoupled client‑side synchronization logic**",
--             "Reorganized `DTNPC_ClientSync.lua` to separate concerns, improving code readability and making future extensions easier to implement.",
--             "**Restored NPC trading behaviors**",
--             "Fixed an issue where NPC trading actions failed after the decoupling change, ensuring all dynamic trading interactions function correctly again."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_30",
--       "chapter_id": "release_notes",
--       "title": "2026-01-30",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-30"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_30",
--           "level": 1,
--           "text": "Updates for 2026-01-30"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_30_faction_system_stability",
--           "level": 2,
--           "text": "Faction System Stability"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved inconsistent town data during faction initialization, ensuring all factions correctly recognize their associated towns.",
--             "Fixed the faction debugging tool so it now functions reliably in multiplayer sessions, giving hosts and clients accurate diagnostics."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_30_npc_interaction_improvements",
--           "level": 2,
--           "text": "NPC Interaction Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Implemented a contextual talk UI menu for NPCs, allowing players to initiate conversations through an intuitive right‑click interface."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_30_npc_spawning_base_integration",
--           "level": 2,
--           "text": "NPC Spawning & Base Integration"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected NPC spawning logic on player‑built bases, preventing unwanted NPC placements and preserving base integrity.",
--             "Enhanced NPC initialization on faction bases, improving reliability of NPC presence and behavior on owned territories."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_29",
--       "chapter_id": "release_notes",
--       "title": "2026-01-29",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-29"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_29",
--           "level": 1,
--           "text": "Updates for 2026-01-29"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_29_dynamic_trading_faction_system_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading – Faction System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Added wealth tracking to factions** – Factions now maintain a dynamic wealth value, enabling more realistic trade negotiations and economic fluctuations.",
--             "**Implemented version 2 faction initialization** – Overhauled the faction setup process for greater stability, easier configuration, and support for expanded faction attributes."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_29_dynamic_trading_building_management",
--           "level": 2,
--           "text": "Dynamic Trading – Building Management"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Introduced automatic building selector** – The system now auto‑selects appropriate buildings for trade routes, reducing manual setup time and improving the flow of goods between settlements."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_28",
--       "chapter_id": "release_notes",
--       "title": "2026-01-28",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-28"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_28",
--           "level": 1,
--           "text": "Updates for 2026-01-28"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_01_28",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: Archetypes not properly loaded on dynamic trading manager",
--             "fix: error on multiplayer when scanning due to wrong cooldown decoupling",
--             "fix: crank down gunpowder price for balancing",
--             "fix: remove money and money bundle from trade pool",
--             "feat: add selling failures when the trader doesnt have enough money",
--             "feat: add Chat system framework",
--             "feat: implement request trader system",
--             "refactor: decouple NetworkLogs and Cooldown from DynamicTrader_Engine",
--             "feat: implement Global Wealth System for traders",
--             "feat: introduce proper deflation and trader budget money"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_27",
--       "chapter_id": "release_notes",
--       "title": "2026-01-27",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-27"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_27",
--           "level": 1,
--           "text": "Updates for 2026-01-27"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_01_27",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "fix: rename archetype dialogue to prevent namespace conflict",
--             "fix: archetype namespace to prevent other mod conflicts",
--             "fix: performance issue on trade sell UI",
--             "fix: ham radios is now properly distinguished",
--             "fix: non two way item can pass trade",
--             "feat: Add open wallet queue system",
--             "feat: Add deflation mechanic when selling items",
--             "feat: add typing indicator in trader logs",
--             "fix: clothing items now properly renders its icons",
--             "feat: implement lock on favorite items, lock button on sell confirmation modal, and autorefresh list when user inventory is changed",
--             "feat: add tag highlight to each item",
--             "refactor: move the portrait.lua into their respective Archetypes",
--             "refactor: move dialogue into their archetypes folder",
--             "fix: improper load order due to naming scheme",
--             "feat: add AudioManager and Options config manager"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_26",
--       "chapter_id": "release_notes",
--       "title": "2026-01-26",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-26"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_26",
--           "level": 1,
--           "text": "Updates for 2026-01-26"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2026_01_26",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "feat: overide the signal animation frame temporarily for responsive scanning",
--             "feat: display player's name when they found the trader to the logs",
--             "fix: traders not visible when doing scans if public network is off",
--             "feat: Add initial dynamic trading systems, including NPC debugging, wallet, loot, UI, and various debug utilities."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_25",
--       "chapter_id": "release_notes",
--       "title": "2026-01-25",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-25"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_25",
--           "level": 1,
--           "text": "Updates for 2026-01-25"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_25_core_trading_system",
--           "level": 2,
--           "text": "Core Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added full client‑ and server‑side command handling for trading actions, enabling synchronized operations across multiplayer sessions.",
--             "Implemented trader discovery state, allowing players to track which traders have been located and which remain hidden.",
--             "Introduced transaction handling for bags, now displaying the contents of a bag when it is sold so players are fully informed before confirming.",
--             "Fixed a duplication bug that occurred when selling generators that were subsequently dropped, ensuring item counts remain accurate."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_25_user_interface_enhancements",
--           "level": 2,
--           "text": "User Interface Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Launched new trading UI and a dedicated radio‑signal UI, providing clearer visual feedback and easier navigation for players.",
--             "Refined the trading list UI for smoother scrolling, better item grouping, and clearer price displays.",
--             "Added dynamic item icons using `getTex()`, ensuring that every item’s visual representation updates correctly in real time.",
--             "Integrated an “Ask What They Want” button on the sell‑trader window, allowing players to request a trader’s current wish list directly.",
--             "Updated icon assets across the UI, giving a more polished and consistent visual style."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_25_trader_archetype_dialogue",
--           "level": 2,
--           "text": "Trader Archetype & Dialogue"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized archetype data into separate folders, simplifying maintenance and future expansion.",
--             "Decoupled dialogue configurations from the core trading scripts, attaching each dialogue set directly to its corresponding archetype.",
--             "Populated additional archetype dialogue entries, enriching interactions with a broader range of trader personalities and responses."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_25_debug_development_tools",
--           "level": 2,
--           "text": "Debug & Development Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a debug data‑wipe command, giving developers a quick way to reset trading data during testing without affecting the rest of the game."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_25_codebase_refactoring",
--           "level": 2,
--           "text": "Codebase Refactoring"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Moved all trading‑related scripts into a dedicated folder, improving project structure and discoverability.",
--             "Separated the dynamic trading system from the original NPC trading module, creating a cleaner, more modular architecture for future feature integration."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_24",
--       "chapter_id": "release_notes",
--       "title": "2026-01-24",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-24"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_24",
--           "level": 1,
--           "text": "Updates for 2026-01-24"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_24_admin_debug_tools",
--           "level": 2,
--           "text": "Admin Debug Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a client‑side debug admin panel that allows live item spawning, giving developers and server operators instant access to any in‑game item for testing and content creation.",
--             "Integrated a server‑side data‑wipe command directly into the panel, enabling quick resets of player or world data without needing external scripts.",
--             "The panel is accessible only to users with admin privileges, ensuring it does not affect regular gameplay."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_24_npc_system_improvements",
--           "level": 2,
--           "text": "NPC System Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved long‑standing bugs that caused NPCs to behave erratically or fail to spawn, restoring expected AI patterns and interactions.",
--             "Enhanced overall NPC stability, resulting in smoother encounters and fewer server crashes related to the NPC subsystem."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_22",
--       "chapter_id": "release_notes",
--       "title": "2026-01-22",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-22"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_22",
--           "level": 1,
--           "text": "Updates for 2026-01-22"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_22_multiplayer_stability",
--           "level": 2,
--           "text": "Multiplayer Stability"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved NPC desynchronization issues in multiplayer sessions, ensuring consistent NPC behavior across all clients.",
--             "Fixed a clothing synchronization bug that caused NPCs to display incorrect outfits when playing together.",
--             "Eliminated the problem where NPCs would repeatedly change their appearance while executing behaviors, leading to a smoother and more realistic visual experience."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_22_debug_development_tools",
--           "level": 2,
--           "text": "Debug & Development Tools"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a comprehensive NPC list debug utility, allowing developers and server admins to view and inspect active NPCs in real time for easier troubleshooting and balance testing."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_22_code_organization",
--           "level": 2,
--           "text": "Code Organization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Reorganized source files into appropriate subfolders, improving project structure, readability, and future maintainability."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_21",
--       "chapter_id": "release_notes",
--       "title": "2026-01-21",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-21"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_21",
--           "level": 1,
--           "text": "Updates for 2026-01-21"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_21_dynamic_trading_system",
--           "level": 2,
--           "text": "Dynamic Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a fully‑functional dynamic trading architecture, allowing traders to be generated with distinct archetypes and faction affiliations.",
--             "Added server‑side network infrastructure and data‑management tools to handle trader spawning, inventory refresh, and persistence across game sessions.",
--             "Enabled faction‑based trader spawning, creating varied market opportunities that evolve with player actions and world events, enhancing replayability and immersion."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_21_conversation_ui_framework",
--           "level": 2,
--           "text": "Conversation UI Framework"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Delivered a generic conversation UI framework that supports chat history, selectable dialogue options, and seamless NPC integration.",
--             "Added shared resource files for NPC presets, archetypes, dialogue scripts, and event triggers, streamlining the creation of new characters and story interactions.",
--             "Implemented a polished UI layout for player‑NPC conversations, improving readability and providing a more engaging dialog experience."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_20",
--       "chapter_id": "release_notes",
--       "title": "2026-01-20",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-20"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_20",
--           "level": 1,
--           "text": "Updates for 2026-01-20"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_20_event_marker_system",
--           "level": 2,
--           "text": "Event Marker System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Introduced a full‑featured event marker system, enabling dynamic placement and tracking of in‑game events to create richer trading scenarios.",
--             "Added debug context menus for testing event markers and managing DTNPC orders, streamlining QA and rapid iteration."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_20_npc_animation_audio_improvements",
--           "level": 2,
--           "text": "NPC Animation & Audio Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Fixed walking animation glitches for NPCs, delivering smoother and more natural movement.",
--             "Synchronized footstep sounds with NPC animations, enhancing overall immersion."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_20_wallet_interaction_enhancements",
--           "level": 2,
--           "text": "Wallet Interaction Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Updated wallet mechanics so they function correctly when stored inside backpacks, giving players greater inventory flexibility."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_14",
--       "chapter_id": "release_notes",
--       "title": "2026-01-14",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-14"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_14",
--           "level": 1,
--           "text": "Updates for 2026-01-14"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_14_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Fixed NPC item ID validation to ensure all referenced items exist, preventing trading errors and potential game crashes."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_13",
--       "chapter_id": "release_notes",
--       "title": "2026-01-13",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-13"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_13",
--           "level": 1,
--           "text": "Updates for 2026-01-13"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_13_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Resolved a synchronization issue with IsoZombie entities during trading sessions, improving stability and consistency in multiplayer environments."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_12",
--       "chapter_id": "release_notes",
--       "title": "2026-01-12",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-12"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_12",
--           "level": 1,
--           "text": "Updates for 2026-01-12"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_12_dynamic_trading_npc_behavior_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading – NPC Behavior Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Implemented attack range logic for NPCs** – NPCs now evaluate the distance to their targets before initiating combat, resulting in more realistic and tactical encounters during trading interactions. This addition improves AI decision‑making and reduces unexpected close‑range attacks."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_11",
--       "chapter_id": "release_notes",
--       "title": "2026-01-11",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-11"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_11",
--           "level": 1,
--           "text": "Updates for 2026-01-11"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_11_npc_behavior_enhancements",
--           "level": 2,
--           "text": "NPC Behavior Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Replaced the standard “go‑to” pathfinding with instant teleportation for trading NPCs, resulting in smoother, more reliable movement and eliminating navigation glitches.",
--             "Introduced a fleeing AI routine, enabling NPCs to retreat from threats. This adds realistic combat reactions and reduces unwanted NPC crowding during dangerous encounters."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_10",
--       "chapter_id": "release_notes",
--       "title": "2026-01-10",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-10"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_10",
--           "level": 1,
--           "text": "Updates for 2026-01-10"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_10_npc_core_architecture",
--           "level": 2,
--           "text": "NPC Core Architecture"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Established a solid foundation for NPC behavior, introducing core loops and data structures that power all subsequent NPC features.",
--             "Enabled selection of multiple NPCs at once, facilitating group commands and coordinated interactions.",
--             "Fixed zombie pathfinding to ensure NPCs navigate the world reliably, preventing erratic movement and improving overall AI stability."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_10_npc_visual_customization",
--           "level": 2,
--           "text": "NPC Visual Customization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a dynamic clothing system that updates NPC outfits based on context, enhancing visual variety and immersion.",
--             "Implemented automatic zombie reskinning that preserves each NPC’s unique traits when they turn, keeping character identity consistent after infection.",
--             "Introduced automatic staring behavior, causing NPCs to lock eyes with nearby players or entities for a more lifelike presence."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_10_trading_dialogue_system",
--           "level": 2,
--           "text": "Trading & Dialogue System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Created an introductory screen that appears when players first access a trader, delivering clear guidance and setting the tone for the encounter.",
--             "Developed a full player‑to‑trader conversation system, enabling scripted dialogues and interactive trading prompts.",
--             "Added a “no‑cash” dialogue branch that gracefully informs players when they lack sufficient funds, preventing confusing trade failures.",
--             "Fixed idle trader messages to trigger correctly, ensuring traders continuously provide helpful feedback during downtime.",
--             "Integrated a disconnect sound effect that plays when a trader’s session expires, giving audible confirmation of trade termination."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_09",
--       "chapter_id": "release_notes",
--       "title": "2026-01-09",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-09"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_09",
--           "level": 1,
--           "text": "Updates for 2026-01-09"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_ui_enhancements",
--           "level": 2,
--           "text": "UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Dynamic text wrapping for trader logs** – Refactored the text‑wrapping logic into a reusable utility and applied it to trader logs, resulting in cleaner, more readable trade histories regardless of language or font size."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_asset_performance_optimization",
--           "level": 2,
--           "text": "Asset & Performance Optimization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Optimized texture handling** – Streamlined texture loading and memory usage, reducing load times and improving overall game performance when the trading interface is active."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_audio_fixes",
--           "level": 2,
--           "text": "Audio Fixes"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Resolved radio sound glitch** – Fixed an issue that caused distorted or missing audio cues on the in‑game radio, ensuring reliable sound playback during trading sessions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_quality_of_life_improvements",
--           "level": 2,
--           "text": "Quality of Life Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Lock system for the sell menu** – Introduced a lock mechanism that prevents accidental sales, giving players a clear confirmation step before confirming a transaction.",
--             "**Protection against selling used walkie‑talkies** – Added a safeguard that blocks the sale of walkie‑talkies that have already been used, preserving essential communication tools for the player."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_bug_fixes",
--           "level": 2,
--           "text": "Bug Fixes"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Corrected HAM‑related selling errors** – Fixed a crash/exception that occurred when selling items using the HAM (Hardcoded Asset Manager), stabilizing the sell workflow."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_09_additional_content",
--           "level": 2,
--           "text": "Additional Content"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**New dialog entries** – Added several new dialog lines to enrich trader interactions, providing more context and flavor during trading conversations."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_08",
--       "chapter_id": "release_notes",
--       "title": "2026-01-08",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-08"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_08",
--           "level": 1,
--           "text": "Updates for 2026-01-08"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_08_trader_ui_enhancements",
--           "level": 2,
--           "text": "Trader UI Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added dynamic portraits for traders, giving each vendor a unique visual identity.",
--             "Integrated trader profile images into the UI, allowing players to recognize NPCs at a glance.",
--             "Refactored the Dynamic Trading UI into modular components, improving maintainability and future extensibility.",
--             "Fixed overlapping text issues for trader names and archetypes, and rearranged text placement for clearer readability.",
--             "Implemented temporary image and log display within the trading UI to aid debugging and provide richer visual feedback."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_08_dynamic_trading_system_improvements",
--           "level": 2,
--           "text": "Dynamic Trading System Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected invalid item IDs that previously caused trade failures.",
--             "Replaced placeholder fuel items in the **DT_Fuel** category with actual fuel objects, restoring realistic resource handling.",
--             "Resolved server output display problems when scanning trades in single‑player mode, ensuring logs are visible to the player."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_08_event_system_enhancements",
--           "level": 2,
--           "text": "Event System Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Updated the event randomization system to include a cooldown mechanism, reducing the likelihood of the same event triggering repeatedly and creating a more varied gameplay experience."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_08_configuration_options",
--           "level": 2,
--           "text": "Configuration Options"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Made inflation decay rates configurable, giving server operators finer control over the in‑game economy and price stabilization."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_07",
--       "chapter_id": "release_notes",
--       "title": "2026-01-07",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-07"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_07",
--           "level": 1,
--           "text": "Updates for 2026-01-07"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_07_money_handling_compression",
--           "level": 2,
--           "text": "Money Handling & Compression"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Set the weight of **Base.Money** and **Base.MoneyBundle** to **0**, eliminating inventory encumbrance for cash items.",
--             "Added a **compress/decompress** system that stacks money into compact bundles, reducing clutter and improving performance when handling large sums."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_07_wallet_lottery_system",
--           "level": 2,
--           "text": "Wallet Lottery System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Updated the wallet lottery mechanics to work reliably in both **single‑player** and **multiplayer** sessions, ensuring fair prize distribution across all game modes."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_07_global_economy_ui",
--           "level": 2,
--           "text": "Global Economy UI"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Relocated the **Global Economy Statistics** panel to the **sidebar**, providing players with quick, at‑a‑glance access to market trends without disrupting gameplay flow."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_07_shop_menu_refresh",
--           "level": 2,
--           "text": "Shop Menu Refresh"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Fixed the shop interface to correctly refresh its contents in **single‑player** mode, preventing stale inventory listings and ensuring accurate transaction options."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_07_trading_logic_compatibility",
--           "level": 2,
--           "text": "Trading Logic Compatibility"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Adjusted the scanning and trading algorithms to support **both single‑player and multiplayer** environments, guaranteeing consistent trade behavior regardless of the game mode."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_06",
--       "chapter_id": "release_notes",
--       "title": "2026-01-06",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-06"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_06",
--           "level": 1,
--           "text": "Updates for 2026-01-06"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_06_dynamic_trading_system",
--           "level": 2,
--           "text": "Dynamic Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Corrected the trader name shown on both the buy and sell interfaces, ensuring players see accurate vendor identification.",
--             "Updated the trade and sell menus to retain the previously selected item when reopening, streamlining repeated transactions.",
--             "Fixed a synchronization issue where the client failed to receive the latest mod data from the server, improving consistency for all players."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_05",
--       "chapter_id": "release_notes",
--       "title": "2026-01-05",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-05"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_05",
--           "level": 1,
--           "text": "Updates for 2026-01-05"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_05_dynamic_trading",
--           "level": 2,
--           "text": "Dynamic Trading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Relocated all database operations to the server side, enhancing data security and reducing client‑side processing overhead. This change ensures more reliable trade data handling and improves overall game performance."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_04",
--       "chapter_id": "release_notes",
--       "title": "2026-01-04",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-04"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_04",
--           "level": 1,
--           "text": "Updates for 2026-01-04"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_04_dynamic_trading_core_enhancements",
--           "level": 2,
--           "text": "Dynamic Trading Core Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Wallet Lottery System** – Introduced a lottery mechanic that rewards players with random cash bonuses when using their trader wallet, adding an extra layer of excitement to trading activities.",
--             "**Default Value Tweaks** – Adjusted baseline parameters (prices, stock limits, and transaction fees) to improve balance across all trader interactions.",
--             "**New Trader Archetypes** – Added several distinct trader personalities, each with unique inventory pools and pricing strategies, expanding the variety of trading partners.",
--             "**Temporary Trait Integration** – Implemented a provisional trait system that allows traders to possess special characteristics (e.g., “generous” or “stingy”), influencing price negotiations and stock refresh rates."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_04_event_system_improvements",
--           "level": 2,
--           "text": "Event System Improvements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Expanded Event Catalogue** – Added multiple new event types (e.g., flash sales, market crashes) to keep the trading environment dynamic and unpredictable.",
--             "**Meta & Flash Event Refactor** – Reorganized the underlying meta‑event and flash‑event data structures for cleaner processing and easier future extensions.",
--             "**Sub‑Table Structure Overhaul** – Re‑structured auxiliary data tables to improve lookup speed and reduce memory overhead during event handling.",
--             "**Event Loop Fix** – Resolved a loop issue that prevented certain events from triggering, ensuring all scheduled market events now fire reliably.",
--             "**Event Modification Enhancements** – Extended event effects to include scan‑chance bonuses and refreshed the Info UI to display these new modifiers, giving players clearer feedback on event impacts."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_04_user_interface_updates",
--           "level": 2,
--           "text": "User Interface Updates"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Market Info Button** – Added a dedicated button to the `DynamicTradingTraderListUI` that opens a detailed market overview, helping players make informed purchasing decisions.",
--             "**Sell Window Cleanup** – Hidden items with zero value or designated as “money” from the sell interface, decluttering the UI and preventing accidental sales of worthless goods.",
--             "**Info UI Refresh** – Updated the trader information panels to reflect new event modifiers (e.g., scan chances) and trait influences, delivering real‑time context to players."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_04_new_content_items",
--           "level": 2,
--           "text": "New Content & Items"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Walkie‑Talkie Corpse Spawn** – Implemented a chance for walkie‑talkies to appear when looting corpses, providing an additional source of communication gear for survivors."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_04_developer_utilities",
--           "level": 2,
--           "text": "Developer Utilities"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**`extract_tags.bat` Tool** – Added a batch script that automatically extracts item tags for LLM ingestion, streamlining content creation and documentation workflows."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_03",
--       "chapter_id": "release_notes",
--       "title": "2026-01-03",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-03"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_03",
--           "level": 1,
--           "text": "Updates for 2026-01-03"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_03_dynamic_trading_system",
--           "level": 2,
--           "text": "Dynamic Trading System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Improved daily reset logic** – Daily limits and the count of traders discovered now reset correctly each day, ensuring players receive fresh trading opportunities without lingering state from previous sessions.",
--             "**Added unique item IDs** – Every tradable item now carries a distinct identifier, enabling more reliable tracking, better inventory synchronization, and future expansion of item‑specific trade rules.",
--             "**Expanded trader archetypes** – Introduced several new trader archetypes, diversifying the pool of merchants and providing players with a broader range of goods, prices, and negotiation styles.",
--             "**Auto‑close trade UI** – The trade interface now automatically closes if the trader walks away, preventing UI hangs and improving overall user experience during dynamic encounters."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_02",
--       "chapter_id": "release_notes",
--       "title": "2026-01-02",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-02"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_02",
--           "level": 1,
--           "text": "Updates for 2026-01-02"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_core_trading_mechanics",
--           "level": 2,
--           "text": "Core Trading Mechanics"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Implemented daily scanning constraint for traders** – prevents traders from being scanned more than once per in‑game day, reducing exploitation and balancing supply cycles.",
--             "**Added support for multiple trader instances with weighted item chances** – allows several independent trader NPCs, each with configurable rarity tables, enriching variety and replayability.",
--             "**Reimplemented the buy/sell category system** – restores proper categorisation of items, making it easier for players to locate and trade specific goods."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_user_interface_enhancements",
--           "level": 2,
--           "text": "User Interface Enhancements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Integrated a Scan button directly into the trader UI** – gives players a clear, one‑click way to initiate a scanner scan without leaving the interface.",
--             "**Automatic window closure when the player moves away or communication devices are turned off** – prevents lingering UI windows, reduces screen clutter, and avoids unintended interactions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_logging_system",
--           "level": 2,
--           "text": "Logging System"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Added a dedicated log system for the trader network** – records trade actions and scanner events, providing players with a clear transaction history.",
--             "**Made the system log un‑scrollable and limited its size** – eliminates item overflow bugs and keeps the log performant and readable."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_multiplayer_data_synchronization",
--           "level": 2,
--           "text": "Multiplayer & Data Synchronization"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Improved multiplayer synchronization by routing trader data through server commands** – ensures consistent trader states across clients, reducing desync issues in co‑op sessions."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_communication_requirements",
--           "level": 2,
--           "text": "Communication Requirements"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Required ham radio or walkie‑talkie usage before accessing trader stores** – adds a realistic communication step, encouraging players to maintain functional radio equipment before trading."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_02_miscellaneous_fixes",
--           "level": 2,
--           "text": "Miscellaneous Fixes"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "**Corrected invalid sandbox‑option syntax** – restores proper loading of sandbox settings.",
--             "**Fixed item selection to properly re‑select the previously purchased item** – improves UI continuity after a trade."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2026_01_01",
--       "chapter_id": "release_notes",
--       "title": "2026-01-01",
--       "keywords": [
--         "update",
--         "release",
--         "2026-01-01"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2026_01_01",
--           "level": 1,
--           "text": "Updates for 2026-01-01"
--         },
--         {
--           "type": "heading",
--           "id": "ai_h_2026_01_01_dynamic_trading_new_items",
--           "level": 2,
--           "text": "Dynamic Trading – New Items"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added a range of additional items to the trading catalog, expanding the variety of goods players can buy and sell.",
--             "Introduced a temporary placeholder set of items for testing purposes, allowing developers to evaluate balance and pricing before final implementation.",
--             "Impact:* These additions enrich the in‑game economy, giving players more options for bartering and increasing the depth of the trading experience."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "2025_12_31",
--       "chapter_id": "release_notes",
--       "title": "2025-12-31",
--       "keywords": [
--         "update",
--         "release",
--         "2025-12-31"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "heading_2025_12_31",
--           "level": 1,
--           "text": "Updates for 2025-12-31"
--         },
--         {
--           "type": "heading",
--           "id": "repo_dynamictrading_2025_12_31",
--           "level": 2,
--           "text": "DynamicTrading"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "refactor: remove unused files",
--             "feat: implement dynamic sell system",
--             "feat: implement buy button",
--             "feat:  update the drawListItem function to include Text Truncation Logic",
--             "feat: when the daily reset timer triggers, force close the UI if it is open",
--             "fix: enforce a Minimum Quantity of 1 for any item that gets selected for the shelf.",
--             "refactor: compress the config items into an Item definitions",
--             "feat: populate DT_Household data",
--             "feat: populate DT_Electronics.lua data",
--             "feat: populate DT_Clothing.lua data",
--             "feat: populate DT_Ammo.lua data",
--             "feat: update workshop details",
--             "feat: reorganized configs into different folders"
--           ]
--         }
--       ]
--     },
--     {
--       "id": "hall_of_fame",
--       "chapter_id": "release_notes",
--       "title": "Hall of Fame",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "supporter_carousel",
--           "title": "Hall of Fame Donators",
--           "autoplay_ms": 4000,
--           "currency_symbol": "$",
--           "thank_you_text": "",
--           "supporters": [
--             {
--               "id": "summer",
--               "name": "Summer",
--               "total_donation": 20.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png",
--               "support_message": "Love your mod, thank you for sharing your creation with the community, we appreciate you!",
--               "active": true
--             },
--             {
--               "id": "amikcze",
--               "name": "Amikcze",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_fb22414ddf.png",
--               "support_message": "Thank you for the best trading mod on Zomboid! Don't bother with the people who can't read descriptions. Your vision for the mod is amazing, and the real fans appreciate the hard work. Take care of yourself first! Hopefully, we will see your vision come to life!",
--               "active": true
--             },
--             {
--               "id": "dremons",
--               "name": "Dremons",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_5e4eff3fde.png",
--               "support_message": "Greetings from Brazil",
--               "active": true
--             },
--             {
--               "id": "psy",
--               "name": "Psy",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_46a120b30e.png",
--               "support_message": "Thanks for the mod, I'm really enjoying the extra depth and purpose it gives to the game. Just started my first run with the colony add-on!",
--               "active": true
--             },
--             {
--               "id": "supporter_4",
--               "name": "ДанилоМироненко",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_1b927e850e.png",
--               "support_message": "I sent a donation and wanted to suggest improving price balance, as some values feel inconsistent.\n\nThanks for your work!",
--               "active": true
--             }
--           ]
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_04_29", {
        title = "Update: 12/31 - 04/29",
        description = "Consolidated updates from 2025-12-31 to 2026-04-29",
        startPageId = "2026_04_28",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 0,
        releaseVersion = "",
        popupVersion = "",
        autoOpenOnUpdate = false,
        isWhatsNew = true,
        manualType = "whats_new",
        showInLibrary = false,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "release_notes",
                title = "Release Notes",
                description = "",
            },
        },
        pages = {
            {
                id = "2026_04_28",
                chapterId = "release_notes",
                title = "2026-04-28",
                keywords = { "update", "release", "2026-04-28" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_28", level = 1, text = "Updates for 2026-04-28" },
                    { type = "heading", id = "ai_h_2026_04_28_conversation_ui_overhaul", level = 2, text = "Conversation UI Overhaul" },
                    { type = "bullet_list", items = { "Added a **faction rumor system** directly into the conversation window, allowing players to see dynamic intel about factions while chatting.", "Implemented **navigation history** with footer controls, letting users move back and forward through dialog trees without losing context.", "Introduced an **automated exit dialogue** and queued conversation‑closing logic to ensure UI consistency when dialogs finish or are interrupted.", "Built a **responsive layout system** and a set of **custom UI components** for the conversation window, improving readability on all screen sizes.", "Added a **conversation transparency toggle**, giving players the option to dim the background for better focus.", "Refactored the **scanner UI components** and renamed radio scanner categories, streamlining the discovery interface.", "Integrated **automatic discovery triggers** for new radio signals, so relevant conversations start as soon as a signal is picked up." } },
                    { type = "heading", id = "ai_h_2026_04_28_bandit_behavior_interaction", level = 2, text = "Bandit Behavior & Interaction" },
                    { type = "bullet_list", items = { "Created a full **Bandit House Roam system** with state management, enabling bandits to patrol and react dynamically to player actions.", "Developed a **hostile negotiation system** for bandit NPCs, including automated return behavior and state tracking for smoother encounters.", "Added **hostile trade cycle mechanics** and **faction‑based bandit demand logic**, giving bandits realistic trading motivations.", "Implemented **prioritization of hostile NPCs over zombies** when deciding protection targets, making combat decisions more logical.", "Preserved **bandit encounter states across NPC respawns**, ensuring continuity in ongoing storylines.", "Excluded bandits from radar discovery to prevent unintended spotting, keeping their movements stealthier." } },
                    { type = "heading", id = "ai_h_2026_04_28_trading_economy_enhancements", level = 2, text = "Trading & Economy Enhancements" },
                    { type = "bullet_list", items = { "Added **gift transaction support**, allowing players to give items as gifts with proper server‑side validation.", "Introduced a **flavor text system** for trades, providing contextual descriptions that enrich the trading experience.", "Implemented a **Wave Hi emote auto‑talk patch**, which automatically triggers trader conversations when the emote is used." } },
                    { type = "heading", id = "ai_h_2026_04_28_reputation_faction_system", level = 2, text = "Reputation & Faction System" },
                    { type = "bullet_list", items = { "Refactored **reputation resolution** to include faction context and synchronized bias adjustments server‑side, delivering more accurate reputation outcomes.", "Integrated the **faction rumor system** into conversations, giving players actionable intel that directly influences reputation changes." } },
                    { type = "heading", id = "ai_h_2026_04_28_ui_utilities_performance", level = 2, text = "UI Utilities & Performance" },
                    { type = "bullet_list", items = { "Extracted item texture resolution logic into a reusable **DT_ItemIconUtils** utility module, improving texture handling across the mod.", "Generalized the **Wave Hi interaction** to support dynamic dialogues and custom NPC interactions, making future extensions easier." } },
                    { type = "heading", id = "ai_h_2026_04_28_escort_job_system", level = 2, text = "Escort Job System" },
                    { type = "bullet_list", items = { "Added **escort job commands** with a detailed status UI, allowing players to issue clear instructions to escort NPCs.", "Implemented a **horde warning sound effect**, alerting players when an escort is about to be overwhelmed.", "These updates collectively expand interaction depth, streamline UI flow, and enhance the strategic elements of bandit and trading systems." } },
                },
            },
            {
                id = "2026_04_27",
                chapterId = "release_notes",
                title = "2026-04-27",
                keywords = { "update", "release", "2026-04-27" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_27", level = 1, text = "Updates for 2026-04-27" },
                    { type = "heading", id = "ai_h_2026_04_27_nomadic_faction_mechanics", level = 2, text = "Nomadic Faction Mechanics" },
                    { type = "bullet_list", items = { "**Abstract soul management for nomadic groups** – Introduces a unified system to track and allocate “souls” (resource points) for wandering factions, enabling more dynamic population and reputation handling.", "**Mission viewer integration** – Adds a dedicated button to the radio scanner UI, allowing players to quickly access and review active nomadic missions without leaving the main screen." } },
                    { type = "heading", id = "ai_h_2026_04_27_npc_combat_behavior_enhancements", level = 2, text = "NPC Combat & Behavior Enhancements" },
                    { type = "bullet_list", items = { "**Hostile chase give‑up logic** – NPCs now abandon pursuits after a configurable cooldown, reducing endless chases and improving performance.", "**Advanced target searching and line‑of‑sight** – Implements smarter enemy detection, accounting for obstacles and distance, which results in more realistic combat engagements.", "**Off‑screen despawn handling** – NPCs that wander far from the player are gracefully removed, freeing server resources and preventing clutter.", "**Interaction tracking for stock data** – Records player interactions with NPC inventories, laying groundwork for future trade analytics and dynamic pricing.", "**Debug logging for combat lifecycle events** – Adds comprehensive logs for NPC combat phases, aiding developers in diagnosing behavior issues." } },
                    { type = "heading", id = "ai_h_2026_04_27_bandit_raider_systems", level = 2, text = "Bandit & Raider Systems" },
                    { type = "bullet_list", items = { "**Hostile Raiders flavor text & UI update** – Distinguishes bandits from hostile raiders in the NPC job UI, providing clearer context and immersive lore.", "**Tiered bandit tribute system** – Introduces a gifting mechanic where players can offer resources to bandits, influencing raid frequency and hostility levels through dialogue options.", "**Decoupled raid architecture** – Splits raid logic into server‑side processing, client‑side UI, and localized flavor text, improving stability and allowing easier future extensions.", "**CurrencyExpanded restriction & faction exclusion** – Bandit mechanics now activate only when the CurrencyExpanded mod is present and respect exclusion rules to prevent overpopulation of certain factions.", "**Configurable bandit raid parameters** – Allows server admins to set party sizes and reputation thresholds that trigger raids, offering granular control over difficulty scaling.", "**Bandit ambush system** – Adds specialized ambush archetypes with server‑managed spawning and a custom interaction UI, delivering more varied and challenging encounters." } },
                    { type = "heading", id = "ai_h_2026_04_27_ui_improvements", level = 2, text = "UI Improvements" },
                    { type = "bullet_list", items = { "**Mission viewer button** – Integrated into the radio scanner for seamless access to nomadic missions.", "**NPC job UI enhancements** – Visual differentiation between regular bandits and hostile raiders for quicker identification during gameplay." } },
                    { type = "heading", id = "ai_h_2026_04_27_debug_tracking_tools", level = 2, text = "Debug & Tracking Tools" },
                    { type = "bullet_list", items = { "**Combat behavior logs** – Detailed debug output for NPC combat actions, facilitating rapid troubleshooting and balance tuning.", "**Stock interaction metrics** – Captures player‑NPC trade interactions, providing data for future economic adjustments." } },
                },
            },
            {
                id = "2026_04_26",
                chapterId = "release_notes",
                title = "2026-04-26",
                keywords = { "update", "release", "2026-04-26" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_26", level = 1, text = "Updates for 2026-04-26" },
                    { type = "heading", id = "ai_h_2026_04_26_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "**Introduced the ItemUseabilityRanker system**", "Implements a ranking algorithm that evaluates items based on their practical utility, allowing traders to prioritize more valuable or versatile goods.", "Enhances trading AI decision‑making, leading to more realistic and strategic barter outcomes.", "**Added marquee text UI utility**", "Provides a scrolling text component for the trading interface, ensuring long item names or descriptions remain fully visible without truncation.", "Improves user experience by delivering clear, readable information during trade negotiations." } },
                },
            },
            {
                id = "2026_04_25",
                chapterId = "release_notes",
                title = "2026-04-25",
                keywords = { "update", "release", "2026-04-25" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_25", level = 1, text = "Updates for 2026-04-25" },
                    { type = "heading", id = "ai_h_2026_04_25_radio_quest_system", level = 2, text = "Radio Quest System" },
                    { type = "bullet_list", items = { "Introduced radio‑based quest offers, allowing players to receive new missions directly through the scanner.", "Added a quest‑focus mode to the radio scanner, highlighting active objectives and streamlining navigation.", "Simplified the quest UI logic by removing the previous scan‑difficulty scaling, resulting in a cleaner and more intuitive interface." } },
                    { type = "heading", id = "ai_h_2026_04_25_npc_escort_mechanics", level = 2, text = "NPC Escort Mechanics" },
                    { type = "bullet_list", items = { "Implemented an **escort‑lock** state for NPCs, preventing them from receiving conflicting orders while engaged in an escort mission.", "This lock ensures escort parties remain cohesive, reducing AI errors and improving overall mission reliability." } },
                    { type = "heading", id = "ai_h_2026_04_25_trader_help_escort_ui", level = 2, text = "Trader Help Escort UI" },
                    { type = "bullet_list", items = { "Added a dedicated **TraderHelpEscort** job UI, fully integrated with NPC interaction and the radio scanner systems.", "Players can now easily assign, monitor, and manage escort tasks through an intuitive interface, enhancing coordination between traders and their protectors." } },
                },
            },
            {
                id = "2026_04_24",
                chapterId = "release_notes",
                title = "2026-04-24",
                keywords = { "update", "release", "2026-04-24" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_24", level = 1, text = "Updates for 2026-04-24" },
                    { type = "heading", id = "ai_h_2026_04_24_npc_trading_quest_integration", level = 2, text = "NPC Trading Quest Integration" },
                    { type = "bullet_list", items = { "Implemented a full quest‑offer system for NPC traders, allowing quests to be presented through the new dialogue interface.", "Made the quest UI tab conditional, so it only appears when relevant quests exist, reducing UI clutter for players who aren’t engaged in trading quests.", "Removed the legacy quest system code, streamlining the trading module and improving load times." } },
                    { type = "heading", id = "ai_h_2026_04_24_admin_debug_store_ui_cleanup", level = 2, text = "Admin Debug & Store UI Cleanup" },
                    { type = "bullet_list", items = { "Restricted debug‑mode access to administrators only, enhancing server security and preventing accidental misuse by regular players.", "Removed unused store‑related buttons (both the faction store button and the virtual store button) from the UI, resulting in a cleaner interface and eliminating dead code paths." } },
                },
            },
            {
                id = "2026_04_21",
                chapterId = "release_notes",
                title = "2026-04-21",
                keywords = { "update", "release", "2026-04-21" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_21", level = 1, text = "Updates for 2026-04-21" },
                    { type = "heading", id = "ai_h_2026_04_21_dynamic_trading_enhancements", level = 2, text = "Dynamic Trading Enhancements" },
                    { type = "bullet_list", items = { "**Added a Colony Wealth sandbox option** – players can now set a custom wealth level for their colony when starting a sandbox game, providing finer control over economic difficulty and balance.", "**Refactored internal naming conventions** – updated variable and function names to be more descriptive, improving code readability and easing future maintenance for the trading system." } },
                },
            },
            {
                id = "2026_04_20",
                chapterId = "release_notes",
                title = "2026-04-20",
                keywords = { "update", "release", "2026-04-20" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_20", level = 1, text = "Updates for 2026-04-20" },
                    { type = "heading", id = "ai_h_2026_04_20_dynamic_trading_signal_tracking_building_indexing", level = 2, text = "Dynamic Trading – Signal Tracking & Building Indexing" },
                    { type = "bullet_list", items = { "Added a new **Signal Tracking dialogue** that lets players monitor active trading signals directly from the UI.", "Implemented a **spatial‑hash based building indexing system**, dramatically speeding up lookup of nearby structures for trade routes and reducing CPU overhead during large‑scale map scans." } },
                    { type = "heading", id = "ai_h_2026_04_20_dynamic_trading_world_data_faction_management", level = 2, text = "Dynamic Trading – World Data & Faction Management" },
                    { type = "bullet_list", items = { "Introduced the **GeolocatorSystem**, a centralized service that parses map data, defines town boundaries, and automatically resolves faction locations.", "Enables dynamic placement of trader NPCs and faction‑specific offers based on real‑time geographic information, improving immersion and ensuring that trade interactions reflect the current state of the world." } },
                    { type = "heading", id = "ai_h_2026_04_20_maintenance_legacy_cleanup", level = 2, text = "Maintenance – Legacy Cleanup" },
                    { type = "bullet_list", items = { "Removed obsolete legacy files and refactored the codebase to eliminate outdated dependencies, resulting in a cleaner project structure and easier future maintenance." } },
                },
            },
            {
                id = "2026_04_18",
                chapterId = "release_notes",
                title = "2026-04-18",
                keywords = { "update", "release", "2026-04-18" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_18", level = 1, text = "Updates for 2026-04-18" },
                    { type = "heading", id = "ai_h_2026_04_18_ui_enhancements_utilities", level = 2, text = "UI Enhancements & Utilities" },
                    { type = "bullet_list", items = { "Added distinctive icons to context‑menu entries, giving players immediate visual cues for actions.", "Introduced a shared UI utility module that centralizes list‑item selection handling and background rendering, simplifying future UI work.", "Refined the faction debug listbox styling and selection logic for clearer visual feedback.", "Cleaned up radio scanner listboxes by removing unnecessary background and border elements, and wrapped all listboxes in styled clipping containers for a more polished appearance.", "Updated UI layout padding and introduced dynamic button widths, improving consistency across windows and ensuring better fit on various screen resolutions." } },
                    { type = "heading", id = "ai_h_2026_04_18_centralized_gameplay_logging_system", level = 2, text = "Centralized Gameplay Logging System" },
                    { type = "bullet_list", items = { "Implemented a comprehensive event‑logging framework that captures faction activities (membership changes, leadership updates, reputation shifts, combat outcomes) and radio communications.", "Added UI panels that display logged faction events such as trades and construction, giving players transparent insight into faction dynamics.", "Created a unified gameplay‑logging registry, eliminating redundant network‑log wrappers and streamlining how events are recorded and accessed." } },
                    { type = "heading", id = "ai_h_2026_04_18_faction_simulation_colony_infrastructure", level = 2, text = "Faction Simulation & Colony Infrastructure" },
                    { type = "bullet_list", items = { "Modularized faction simulation logic, separating generic processing from town‑specific handlers for clearer code separation and easier future expansion.", "Delivered a full colony infrastructure system, including horde management, with dedicated UI and underlying logic modules.", "Integrated a virtual store system and linked economy modifiers to flash events, allowing dynamic pricing and market fluctuations." } },
                    { type = "heading", id = "ai_h_2026_04_18_radio_scanner_radar_system_overhaul", level = 2, text = "Radio Scanner & Radar System Overhaul" },
                    { type = "bullet_list", items = { "Standardized radar‑scan mechanics and introduced spam‑protection with visual feedback, preventing accidental scan flooding.", "Reworked the scanner lifecycle to prioritize contact visits and added dynamic success probabilities, making scans feel more realistic.", "Consolidated all radio‑scanner UI components into a shared library and migrated legacy radar logic to the new framework, enhancing maintainability.", "Refined contact visibility rules and adjusted window dimensions and styling for a cleaner scanner interface.", "Added a “night scanner gate” option, improved trader expiry formatting, and implemented trader death‑state handling for more immersive radio interactions." } },
                    { type = "heading", id = "ai_h_2026_04_18_trading_economy_improvements", level = 2, text = "Trading & Economy Improvements" },
                    { type = "bullet_list", items = { "Integrated trader session budgets directly into the trading window data provider, ensuring players see accurate available funds.", "Added extensive proximity‑based dialogue lines that trigger as NPCs approach or track the player, enriching in‑game conversations.", "Implemented a radio‑scanner conversation panel that ties dialogue tracking into the scanner UI, providing seamless communication flow." } },
                    { type = "heading", id = "ai_h_2026_04_18_core_refactoring_architecture", level = 2, text = "Core Refactoring & Architecture" },
                    { type = "bullet_list", items = { "Migrated event‑manager modules to a version‑ed directory structure, preparing the codebase for future updates and better organization.", "Reorganized documentation and centralized gameplay‑logging registration, making it easier for contributors to locate and understand core systems.", "Updated faction UI component hierarchy and introduced radio‑linked lifecycle management for more cohesive window behavior.", "These updates collectively enhance visual clarity, deepen gameplay immersion, and lay a robust foundation for future feature expansions." } },
                },
            },
            {
                id = "2026_04_17",
                chapterId = "release_notes",
                title = "2026-04-17",
                keywords = { "update", "release", "2026-04-17" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_17", level = 1, text = "Updates for 2026-04-17" },
                    { type = "heading", id = "ai_h_2026_04_17_trade_scheduling_system", level = 2, text = "Trade Scheduling System" },
                    { type = "bullet_list", items = { "Introduced a full‑featured trade scheduling interface with a calendar view, allowing players to set and visualize trading windows.", "Added configurable eligibility settings so only qualified NPCs can schedule trades, preventing unwanted matches.", "Implemented enforcement logic and roster state normalization across both V1 and V2 trade managers, ensuring consistent behavior and reducing desynchronization bugs." } },
                    { type = "heading", id = "ai_h_2026_04_17_debug_tools_hub", level = 2, text = "Debug Tools Hub" },
                    { type = "bullet_list", items = { "Launched a central debug hub window that aggregates all development utilities in one place, streamlining testing and troubleshooting.", "Replaced the fragile scrollbar‑relayout routine in the faction debug window with a robust `refreshRichTextPanel` helper, resulting in smoother UI updates and fewer rendering glitches." } },
                    { type = "heading", id = "ai_h_2026_04_17_radio_contact_visit_system", level = 2, text = "Radio Contact Visit System" },
                    { type = "bullet_list", items = { "Developed the V1 radio contact visit system, complete with backend routing and scan‑capacity management, enabling NPCs to travel to radio stations reliably.", "Enhanced visit requests with dynamic UI feedback, real‑time ETA tracking, and persistent conversation states, giving players clearer information and smoother interactions during radio‑based missions." } },
                    { type = "heading", id = "ai_h_2026_04_17_global_trader_contacts", level = 2, text = "Global Trader Contacts" },
                    { type = "bullet_list", items = { "Refactored trader contact handling into modular core, persistence, runtime, and event components, greatly improving code maintainability and future expandability.", "Delivered a new global trader contacts UI that lets players manage and view saved NPC frequencies, making it easier to track and organize trading partners across the map." } },
                    { type = "heading", id = "ai_h_2026_04_17_radar_companion_enhancements", level = 2, text = "Radar & Companion Enhancements" },
                    { type = "bullet_list", items = { "Added callable travel companions to the radar system with ownership‑based filtering, ensuring only owned companions appear as selectable options.", "Implemented ownership verification and extended metadata support for travel companions, providing richer information (e.g., load capacity, status) directly in the radar window.", "Integrated an automated “inventory full” prompt for NPC companions, preventing lost loot and giving clear feedback when a companion cannot carry more items.", "Improved overall radar UI feedback to reflect companion states and inventory status more intuitively.", "Created an interactive loot‑search and collection system for NPC companions, allowing them to autonomously locate, retrieve, and deliver items, which enhances automation and reduces player micromanagement." } },
                },
            },
            {
                id = "2026_04_16",
                chapterId = "release_notes",
                title = "2026-04-16",
                keywords = { "update", "release", "2026-04-16" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_16", level = 1, text = "Updates for 2026-04-16" },
                    { type = "heading", id = "ai_h_2026_04_16_debug_inspection_tools", level = 2, text = "Debug & Inspection Tools" },
                    { type = "bullet_list", items = { "Added a **Loot Vision Inspector** that visualizes NPC loot perception ranges, making it easier to fine‑tune loot distribution logic.", "Implemented comprehensive **NPC removal logging** with detailed trace output, helping identify why and when NPCs are despawned.", "Introduced a robust **debug logging framework** for all NPC systems, providing clear, filterable messages for developers during testing." } },
                    { type = "heading", id = "ai_h_2026_04_16_npc_loot_inventory_enhancements", level = 2, text = "NPC Loot & Inventory Enhancements" },
                    { type = "bullet_list", items = { "Developed **LootNearby** behavior that directs NPCs to scavenge nearby items, complete with UI feedback and server‑side state synchronization for consistent world updates.", "Integrated **ammo status checks** that prevent NPCs from attempting ranged attacks with insufficient ammunition, reducing wasted combat actions.", "Added **durability‑based weapon retirement** logic, automatically discarding heavily worn weapons to keep NPC inventories functional.", "Implemented **condition validation** for items, ensuring NPCs only equip gear that meets defined quality thresholds." } },
                    { type = "heading", id = "ai_h_2026_04_16_combat_guard_ai_improvements", level = 2, text = "Combat & Guard AI Improvements" },
                    { type = "bullet_list", items = { "Created **guard combat orders** and multiple **attack modes** (e.g., aggressive, defensive, hold position) giving players granular control over NPC defensive behavior.", "Added a **Stay** behavior allowing guards to remain stationary while still monitoring threats, useful for securing key locations.", "Integrated **combat attack tracking** for linked workers, enabling coordinated strikes and synchronized damage calculations.", "Enhanced UI with **customizable color schemes** for guard states, improving at‑a‑glance status recognition." } },
                    { type = "heading", id = "ai_h_2026_04_16_anti_stuck_follow_system", level = 2, text = "Anti‑Stuck & Follow System" },
                    { type = "bullet_list", items = { "Implemented a **modular anti‑stuck recovery system** that detects and resolves path‑finding dead‑ends, then seamlessly reintegrates the logic into the existing **follow** behavior, resulting in smoother NPC movement and fewer interruptions." } },
                    { type = "heading", id = "ai_h_2026_04_16_state_tracking_synchronization", level = 2, text = "State Tracking & Synchronization" },
                    { type = "bullet_list", items = { "Added **zombie state tracking** within the NPC synchronization flow, ensuring NPCs correctly react to evolving undead threats.", "Developed a **reusable body identification** module for respawn systems, allowing NPCs to locate and interact with their own corpses reliably.", "Prevented NPCs from **targeting player characters** unintentionally, reducing accidental friendly fire and improving overall gameplay balance." } },
                    { type = "heading", id = "ai_h_2026_04_16_skill_companion_systems", level = 2, text = "Skill & Companion Systems" },
                    { type = "bullet_list", items = { "Introduced a new **Monolith‑Decoupler** skill, providing NPCs with a unique ability that alters their interaction with monolithic structures.", "Added **companion dialogue** for ranged combat scenarios, giving players contextual feedback when companions assist with firearms." } },
                    { type = "heading", id = "ai_h_2026_04_16_codebase_refactoring_shared_library_migration", level = 2, text = "Codebase Refactoring & Shared Library Migration" },
                    { type = "bullet_list", items = { "Consolidated manual definitions, archetype items, events, and version‑specific files into a **common shared library**, reducing duplication and simplifying future updates.", "Removed redundant wrapper functions and unused constants from protect behavior logic, streamlining the codebase and improving maintainability." } },
                },
            },
            {
                id = "2026_04_15",
                chapterId = "release_notes",
                title = "2026-04-15",
                keywords = { "update", "release", "2026-04-15" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_15", level = 1, text = "Updates for 2026-04-15" },
                    { type = "heading", id = "ai_h_2026_04_15_core_refactoring_cleanup", level = 2, text = "Core Refactoring & Cleanup" },
                    { type = "bullet_list", items = { "Consolidated all mod assets into a shared directory, simplifying maintenance and ensuring consistent access across the mod.", "Removed outdated files, assets, and legacy NPC logic components, reducing clutter and preventing potential conflicts.", "Reorganized sandbox option handling and streamlined event manager module paths for clearer code structure and easier future extensions.", "Updated file path conventions to match the new modular architecture and added robust error logging for network‑related dependencies, improving diagnostics and stability." } },
                    { type = "heading", id = "ai_h_2026_04_15_compatibility_version_support", level = 2, text = "Compatibility & Version Support" },
                    { type = "bullet_list", items = { "Implemented full support for Project Zomboid build **b42.16**, ensuring the Dynamic Trading system functions correctly with the latest game version." } },
                    { type = "heading", id = "ai_h_2026_04_15_ui_performance_enhancements", level = 2, text = "UI & Performance Enhancements" },
                    { type = "bullet_list", items = { "Introduced lazy‑loading for 3D portrait model views, markedly decreasing UI load times and lowering memory usage during trading interactions." } },
                },
            },
            {
                id = "2026_04_14",
                chapterId = "release_notes",
                title = "2026-04-14",
                keywords = { "update", "release", "2026-04-14" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_14", level = 1, text = "Updates for 2026-04-14" },
                    { type = "heading", id = "ai_h_2026_04_14_npc_portrait_animation_system", level = 2, text = "NPC Portrait & Animation System" },
                    { type = "bullet_list", items = { "Added transaction‑specific portrait animations, introducing the **DTPortraitIdleAiming** state for smoother visual feedback during trades.", "Implemented NPC portrait animation profiles with dynamic speech states, enhancing the trading and conversation UI with context‑aware facial expressions.", "Developed a shared NPC portrait rendering pipeline, including resolution handling, debug tools, and a CRT overlay toggle for visual testing.", "Integrated dummy target generation into the portrait debugger to facilitate rapid prototyping of animation states.", "Expanded portrait UI panels (height increase) and replaced static labels with dynamic info panels for clearer, real‑time data display." } },
                    { type = "heading", id = "ai_h_2026_04_14_trading_conversation_ui_enhancements", level = 2, text = "Trading & Conversation UI Enhancements" },
                    { type = "bullet_list", items = { "Introduced dynamic speech state handling, allowing NPCs to react visually to player dialogue choices during trading interactions.", "Updated UI assets and manual documentation to reflect new portrait and animation features, ensuring players and modders have accurate guidance." } },
                    { type = "heading", id = "ai_h_2026_04_14_medical_self_care_mechanics", level = 2, text = "Medical & Self‑Care Mechanics" },
                    { type = "bullet_list", items = { "Implemented medical supply tracking and validation for NPC self‑patching actions, guaranteeing that NPCs only use appropriate resources.", "Fixed remote‑client response for NPC self‑bandage actions, correctly returning **applying** status instead of **blocked**.", "Added crawling animation support and refined self‑bandage cancellation logic, improving realism when NPCs heal themselves while moving." } },
                    { type = "heading", id = "ai_h_2026_04_14_faction_colony_management", level = 2, text = "Faction & Colony Management" },
                    { type = "bullet_list", items = { "Added comprehensive faction administration tools, including colony archiving with a dedicated debug UI for easier server maintenance.", "Introduced worker retention options when kicking faction members, preserving valuable labor resources.", "Enhanced worker transfer logic during join/leave events, ensuring seamless redistribution of tasks and preventing job loss." } },
                    { type = "heading", id = "ai_h_2026_04_14_companion_ui_improvements", level = 2, text = "Companion UI Improvements" },
                    { type = "bullet_list", items = { "Integrated companion command transfer and claim functionality into the travel companion UI, allowing players to delegate control of companions or reclaim them instantly." } },
                    { type = "heading", id = "ai_h_2026_04_14_update_notification_system", level = 2, text = "Update & Notification System" },
                    { type = "bullet_list", items = { "Implemented version‑aware manual update notifications, alerting players when a new mod version is available and guiding them through the update process." } },
                    { type = "heading", id = "ai_h_2026_04_14_debug_developer_tools", level = 2, text = "Debug & Developer Tools" },
                    { type = "bullet_list", items = { "Added a CRT overlay toggle to the NPC portrait debugger for visual effect testing.", "Created a search utility to streamline asset lookup within debug and manual documentation.", "Updated NPC debug assets and manual resources to reflect new systems and provide clearer guidance for developers." } },
                    { type = "heading", id = "ai_h_2026_04_14_core_refactors_system_modularization", level = 2, text = "Core Refactors & System Modularization" },
                    { type = "bullet_list", items = { "Replaced static UI labels with dynamic information panels, improving adaptability across different screen resolutions and content changes.", "Removed obsolete agent documentation skills, simplifying the skill tree and reducing clutter.", "Extracted NPC death and incapacitation logic into a dedicated system package, modularizing lifecycle management for easier future extensions and maintenance." } },
                },
            },
            {
                id = "2026_04_13",
                chapterId = "release_notes",
                title = "2026-04-13",
                keywords = { "update", "release", "2026-04-13" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_13", level = 1, text = "Updates for 2026-04-13" },
                    { type = "heading", id = "ai_h_2026_04_13_npc_health_damage_management", level = 2, text = "NPC Health & Damage Management" },
                    { type = "bullet_list", items = { "Added health‑delta suppression for incapacitated NPCs, preventing unintended damage while they are downed.", "Implemented friendly‑fire protection, ensuring NPCs no longer damage each other during combat.", "Introduced data‑only damage handling that updates health states without triggering visual effects, improving performance in crowded encounters.", "Fixed bandage completion tracking to rely on animation cues, with a fallback grace period to guarantee heal completion even if animation data is missing." } },
                    { type = "heading", id = "ai_h_2026_04_13_npc_mobility_movement_system", level = 2, text = "NPC Mobility & Movement System" },
                    { type = "bullet_list", items = { "Refactored the monolithic movement code into a dedicated **DTNPC_Mobility** module, making the system easier to maintain and extend.", "Integrated the new mobility core across all NPC behaviors, standardizing movement, obstacle navigation, and retreat logic when taking damage.", "Added locomotion synchronization with separate walking and running animation sets, delivering smoother and more realistic NPC motion.", "Updated facing logic to prioritize the direction of movement rather than a static target orientation, resulting in more natural turning behavior." } },
                    { type = "heading", id = "ai_h_2026_04_13_combat_threat_handling", level = 2, text = "Combat & Threat Handling" },
                    { type = "bullet_list", items = { "Implemented line‑of‑sight checks and immediate threat targeting, allowing NPCs to react quickly to visible dangers.", "Added an evasion and damage‑mitigation system that scales with NPC skill levels and combat state, giving higher‑skill NPCs a tangible defensive edge.", "Fixed the combat noise emission system and refined despawn handling to prioritize live departures, reducing abrupt disappearances and improving immersion." } },
                    { type = "heading", id = "ai_h_2026_04_13_trading_system_refactor", level = 2, text = "Trading System Refactor" },
                    { type = "bullet_list", items = { "Split trading behavior into modular sub‑components and introduced ranged‑combat logic for merchant NPCs, enabling them to defend themselves from a distance.", "Integrated the new mobility framework into trading interactions, ensuring merchants move and react consistently with other NPC types." } },
                },
            },
            {
                id = "2026_04_08",
                chapterId = "release_notes",
                title = "2026-04-08",
                keywords = { "update", "release", "2026-04-08" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_08", level = 1, text = "Updates for 2026-04-08" },
                    { type = "heading", id = "ai_h_2026_04_08_dynamic_trading_npc_equipment_loadout_system", level = 2, text = "Dynamic Trading – NPC Equipment & Loadout System" },
                    { type = "bullet_list", items = { "**Candidate Selection System for NPC Visuals and Loadouts**", "Introduced a robust algorithm that evaluates and selects appropriate equipment visual sets and loadouts for NPCs. This ensures that each trader displays gear that matches their role and rarity, enhancing immersion and visual consistency.", "**Combat Fallback Logic & Notifications for Missing Loadouts**", "Added safety checks that trigger when an NPC lacks a predefined loadout during auto‑protect combat scenarios. The system now defaults to a sensible backup loadout and provides clear in‑game notifications, preventing combat glitches and keeping player interactions smooth." } },
                },
            },
            {
                id = "2026_04_07",
                chapterId = "release_notes",
                title = "2026-04-07",
                keywords = { "update", "release", "2026-04-07" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_07", level = 1, text = "Updates for 2026-04-07" },
                    { type = "heading", id = "ai_h_2026_04_07_npc_companion_combat_enhancements", level = 2, text = "NPC Companion & Combat Enhancements" },
                    { type = "bullet_list", items = { "Introduced travel companions for NPCs, allowing them to move together and provide tactical support during journeys.", "Added a combat rhythm system that syncs NPC attack patterns, creating more engaging and predictable combat encounters.", "Updated the mod version to **1.1.1**, reflecting these new gameplay features and ensuring compatibility with the latest game build." } },
                    { type = "heading", id = "ai_h_2026_04_07_supporter_carousel_ui_hall_of_fame_integration", level = 2, text = "Supporter Carousel UI & Hall of Fame Integration" },
                    { type = "bullet_list", items = { "Implemented a new **Supporter Carousel** UI component that showcases supporters in a rotating display, enhancing visibility and appreciation.", "Integrated the Hall of Fame manual with the carousel, allowing players to view supporter achievements directly within the UI.", "Refreshed the Hall of Fame supporter carousel UI for a cleaner, more intuitive presentation." } },
                    { type = "heading", id = "ai_h_2026_04_07_documentation_version_updates", level = 2, text = "Documentation & Version Updates" },
                    { type = "bullet_list", items = { "Added a comprehensive **1.5.1 update manual**, detailing new features, configuration options, and installation steps.", "Updated the Hall of Fame manual to reflect the latest carousel integration and supporter recognition workflow." } },
                },
            },
            {
                id = "2026_04_06",
                chapterId = "release_notes",
                title = "2026-04-06",
                keywords = { "update", "release", "2026-04-06" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_06", level = 1, text = "Updates for 2026-04-06" },
                    { type = "heading", id = "ai_h_2026_04_06_npc_health_system", level = 2, text = "NPC Health System" },
                    { type = "bullet_list", items = { "**Dynamic bandage icon rendering** – Health bars now display distinct icons based on the specific bandage type an NPC is using, making status monitoring clearer for players.", "**Configurable incapacitated HP values** – NPCs start with custom health values instead of defaulting to zero, allowing finer tuning of difficulty and survivability.", "**Passive health regeneration** – Resting NPCs slowly regain health, with regeneration continuing even while the player is offline via the manager tick, improving realism and NPC longevity.", "**Modular health architecture** – NPC health logic has been moved to a dedicated directory with shared utility functions, simplifying future maintenance and extension." } },
                    { type = "heading", id = "ai_h_2026_04_06_travel_companion_system", level = 2, text = "Travel Companion System" },
                    { type = "bullet_list", items = { "**Travel companion job UI** – A new interface lets players assign and manage companion jobs, fully integrated with NPC behavior and dialogue systems.", "**Companion order menu & self‑bandage** – Players can issue orders through a streamlined menu, and companions can automatically apply bandages using linked supply caches, enhancing autonomous support." } },
                    { type = "heading", id = "ai_h_2026_04_06_combat_enhancements", level = 2, text = "Combat Enhancements" },
                    { type = "bullet_list", items = { "**Combat overhaul** – Revamped NPC combat mechanics, lifecycle handling, and network synchronization, accompanied by new sandbox options and an in‑game manual for easier configuration.", "**Combat rhythm system** – Introduces tactical recovery periods, kiting mechanics, and dynamic flavor text, giving NPCs more realistic and varied combat behavior.", "**Ranged combat integration** – Standardized ranged attack logic with the shared protection system and unified NPC state management, resulting in smoother and more consistent combat interactions." } },
                    { type = "heading", id = "ai_h_2026_04_06_aggro_ai_management", level = 2, text = "Aggro & AI Management" },
                    { type = "bullet_list", items = { "**Modular zombie aggro system** – NPCs now use a dedicated aggro management module, allowing clearer control over zombie attraction and threat handling." } },
                    { type = "heading", id = "ai_h_2026_04_06_bandaging_system", level = 2, text = "Bandaging System" },
                    { type = "bullet_list", items = { "**Full NPC bandaging workflow** – Added animation sets, UI indicators, and debug tools for NPCs to bandage themselves and others, providing visual feedback and easier troubleshooting for modders." } },
                },
            },
            {
                id = "2026_04_05",
                chapterId = "release_notes",
                title = "2026-04-05",
                keywords = { "update", "release", "2026-04-05" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_05", level = 1, text = "Updates for 2026-04-05" },
                    { type = "heading", id = "ai_h_2026_04_05_custom_npc_health_system", level = 2, text = "Custom NPC Health System" },
                    { type = "bullet_list", items = { "Added a configurable health framework for NPCs, allowing health values to scale based on difficulty settings and player progression.", "Integrated the new health system with combat mechanics so that damage calculations, death handling, and loot drops now reflect the custom health values." } },
                    { type = "heading", id = "ai_h_2026_04_05_npc_combat_movement_improvements", level = 2, text = "NPC Combat & Movement Improvements" },
                    { type = "bullet_list", items = { "Implemented combat pursuit tracking, enabling NPCs to maintain focus on a target and intelligently break off when the target becomes unreachable.", "Added a timeout mechanism for unreachable targets, preventing NPCs from getting stuck in endless chase loops.", "Updated walk animation variables to synchronize movement states, ensuring smoother and more consistent NPC locomotion during combat and idle periods." } },
                },
            },
            {
                id = "2026_04_04",
                chapterId = "release_notes",
                title = "2026-04-04",
                keywords = { "update", "release", "2026-04-04" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_04", level = 1, text = "Updates for 2026-04-04" },
                    { type = "heading", id = "ai_h_2026_04_04_core_npc_system_overhaul", level = 2, text = "Core NPC System Overhaul" },
                    { type = "bullet_list", items = { "**Modularized NPC architecture** – Split the monolithic NPC logic, data, and equipment files into clearly structured sub‑directories, making future maintenance and extensions far easier.", "**Weighted zombie selection & duplicate pruning** – Replaced the simple zombie lookup with a scoring system that prefers optimal candidates and automatically removes duplicates, resulting in more stable NPC persistence and fewer spawning glitches.", "**Centralized radio scan flavor text** – Moved all radio‑scan messages and their localization strings into a shared utility module, streamlining translation updates and ensuring consistent in‑game text." } },
                    { type = "heading", id = "ai_h_2026_04_04_combat_defense_enhancements", level = 2, text = "Combat & Defense Enhancements" },
                    { type = "bullet_list", items = { "**Ambient auto‑defense for stationary NPCs** – Stationary NPCs now automatically defend themselves when threatened, with a post‑return logic that resets their state after combat.", "**Combat protection behavior & custom animation sets** – Added protective combat routines and bespoke animation packs for NPCs, giving them more realistic reactions and smoother visual feedback during fights.", "**Vanilla fishing handler compatibility patch** – Adjusted NPC combat code to coexist with the base game’s fishing system, preventing conflicts when players fish near NPCs." } },
                    { type = "heading", id = "ai_h_2026_04_04_equipment_gear_management", level = 2, text = "Equipment & Gear Management" },
                    { type = "bullet_list", items = { "**Archetype equipment registry** – Introduced a centralized registry that defines default gear for each NPC archetype, simplifying gear assignment and balancing.", "**Debug command for weapon assignment** – New console command lets developers instantly equip NPCs with specific weapons for testing purposes.", "**Outfit ID refactor to body instance ID** – Renamed outfit identifier references to use body instance IDs, improving clarity and reducing mismatches in gear handling.", "**Zombie reattachment via startup hints** – Implemented a system that reattaches zombie parts at world start using body instance hints, enhancing visual consistency for reanimated NPCs." } },
                    { type = "heading", id = "ai_h_2026_04_04_sandbox_gameplay_options", level = 2, text = "Sandbox & Gameplay Options" },
                    { type = "bullet_list", items = { "**NPC engine state suppression** – Added the ability to suppress certain engine states for NPCs, giving modders finer control over NPC processing load.", "**Weapon durability sandbox toggle** – New sandbox option lets players enable or disable weapon durability degradation for NPCs, allowing customized difficulty and role‑play experiences." } },
                },
            },
            {
                id = "2026_04_03",
                chapterId = "release_notes",
                title = "2026-04-03",
                keywords = { "update", "release", "2026-04-03" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_03", level = 1, text = "Updates for 2026-04-03" },
                    { type = "heading", id = "ai_h_2026_04_03_codebase_modularization_architecture", level = 2, text = "Codebase Modularization & Architecture" },
                    { type = "bullet_list", items = { "Split **SignalPanel** logic into its own directory with dedicated sub‑modules, improving code discoverability and future feature expansion.", "Refactored network server handlers, separating raw data processing from trade‑specific logic, which simplifies maintenance and reduces the risk of cross‑module side effects.", "Re‑organized **soul management** into distinct modules for creation, status tracking, storage, and cleanup, enabling clearer responsibilities and easier debugging.", "Decomposed the **economy system** into multiple sub‑modules and updated file paths, resulting in a cleaner project structure and faster compile times.", "Moved NPC context‑menu and radar‑window code into dedicated sub‑directories, making UI extensions and bug fixes more straightforward.", "Re‑structured the **radar manager** into modular files, enhancing readability and allowing independent updates to radar features.", "Migrated all NPC client‑side logic to a structured **ClientSync** directory and broke out health‑bar components, paving the way for smoother client‑server synchronization.", "Isolated the **health bar system** into separate files, improving maintainability and enabling targeted performance tweaks.", "Reorganized **building scanner** configuration and logic to better support county‑level scanning, expanding the tool’s utility for large‑scale maps." } },
                    { type = "heading", id = "ai_h_2026_04_03_in_game_manual_documentation_system", level = 2, text = "In‑Game Manual & Documentation System" },
                    { type = "bullet_list", items = { "Introduced a fully functional **in‑game manual system**, providing players with searchable, context‑aware documentation for colony, economy, and NPC mechanics.", "Added a dedicated **Scavenger Radio manual** and corrected formatting across existing documentation, ensuring consistent presentation.", "Overhauled the **World Events manual**, now featuring an **Economics Dashboard**, detailed flash‑event explanations, and market‑influence guides to help players strategize during dynamic events.", "Updated faction intelligence manual content and removed obsolete casino assets, keeping the guide current with the latest gameplay balance.", "Refined manual titles, added new update notes for the March 27 2026 release, and streamlined the auto‑open logic for a smoother user experience.", "Expanded the documentation metadata schema to include economy and NPC guides, facilitating richer search results and future content integration.", "Renamed and standardized manual titles, refreshed intelligence tips, and renamed the radio manual file for clearer organization." } },
                    { type = "heading", id = "ai_h_2026_04_03_asset_cleanup", level = 2, text = "Asset Cleanup" },
                    { type = "bullet_list", items = { "Eliminated redundant item definitions from literature and weapon‑trading lists, reducing potential conflicts and decreasing load times." } },
                },
            },
            {
                id = "2026_04_01",
                chapterId = "release_notes",
                title = "2026-04-01",
                keywords = { "update", "release", "2026-04-01" },
                blocks = {
                    { type = "heading", id = "heading_2026_04_01", level = 1, text = "Updates for 2026-04-01" },
                    { type = "heading", id = "ai_h_2026_04_01_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Replaced outdated manual files with comprehensive **Economy Guide** and **Event Guide**, providing clearer instructions on trading mechanics and event-driven market changes.", "Added new support assets (icons, UI elements, and reference tables) to enhance the visual presentation of the trading system.", "Impact:* Players now have access to up‑to‑date documentation and richer visual cues, making it easier to understand and engage with the dynamic economy and special events." } },
                },
            },
            {
                id = "2026_03_31",
                chapterId = "release_notes",
                title = "2026-03-31",
                keywords = { "update", "release", "2026-03-31" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_31", level = 1, text = "Updates for 2026-03-31" },
                    { type = "heading", id = "ai_h_2026_03_31_dynamic_trading_ui_improvements", level = 2, text = "Dynamic Trading UI Improvements" },
                    { type = "bullet_list", items = { "Added text‑wrapping to the manual trading interface, preventing overflow and keeping long messages readable.", "Implemented dynamic support‑banner height adjustments so the banner resizes automatically to fit its content, eliminating visual clipping.", "Refactored UI state management to use per‑save **ModData**, ensuring each game save retains its own trading UI settings and avoiding cross‑save data leakage.", "Updated the support‑banner layout to work with the new dynamic height logic, delivering a cleaner and more responsive appearance." } },
                },
            },
            {
                id = "2026_03_30",
                chapterId = "release_notes",
                title = "2026-03-30",
                keywords = { "update", "release", "2026-03-30" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_30", level = 1, text = "Updates for 2026-03-30" },
                    { type = "heading", id = "ai_h_2026_03_30_chat_dialogue_enhancements", level = 2, text = "Chat & Dialogue Enhancements" },
                    { type = "bullet_list", items = { "**Modular Conversation Menus** – Added `DT_ConversationChatMenus` and refactored trader dialogue hubs, allowing each trader to present context‑specific chat options without hard‑coded scripts.", "**Daily Reputation System** – Introduced a reputation tracker that updates based on daily chat interactions, giving players a clear progression path for building trust with NPCs.", "**Expanded NPC Dialogue** – NPCs now share faction news and personal details, enriching role‑play opportunities and making conversations feel more alive." } },
                    { type = "heading", id = "ai_h_2026_03_30_trader_roster_systems", level = 2, text = "Trader & Roster Systems" },
                    { type = "bullet_list", items = { "**Archetype‑Based Roster Spawning** – Traders are generated according to defined archetypes, ensuring balanced and varied trader populations across maps.", "**Dynamic Trade Mode Restrictions** – Trade modes now adapt to the current game state (e.g., survivor count, zone safety), preventing inappropriate trades and improving immersion.", "**Admin‑Level Forced Trader Generation** – New console commands let administrators spawn specific traders on demand for testing or event scenarios." } },
                    { type = "heading", id = "ai_h_2026_03_30_compatibility_integration", level = 2, text = "Compatibility & Integration" },
                    { type = "bullet_list", items = { "**CurrencyExpanded Audio Support** – Integrated the CurrencyExpanded mod’s sound categories, so new currencies trigger appropriate audio cues.", "**Roster Logic Updates** – Adjusted internal references to align with the new archetype system, ensuring seamless interaction with other mods that modify trader rosters." } },
                    { type = "heading", id = "ai_h_2026_03_30_cleanup_removal", level = 2, text = "Cleanup & Removal" },
                    { type = "bullet_list", items = { "**Wallet System Removal** – Eliminated the legacy wallet mechanic, its documentation, related sandbox options, and unused sound assets, reducing mod bloat and potential conflicts." } },
                },
            },
            {
                id = "2026_03_28",
                chapterId = "release_notes",
                title = "2026-03-28",
                keywords = { "update", "release", "2026-03-28" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_28", level = 1, text = "Updates for 2026-03-28" },
                    { type = "heading", id = "ai_h_2026_03_28_trading_ui_dynamic_colonies_integration", level = 2, text = "Trading UI & Dynamic Colonies Integration" },
                    { type = "bullet_list", items = { "Added a comprehensive scavenging manual and a bridge UI to seamlessly connect with the Dynamic Colonies system, improving player guidance and inter-mod communication.", "Refined the trading interface to accommodate the new integration, delivering a more intuitive experience when managing scavenged resources." } },
                    { type = "heading", id = "ai_h_2026_03_28_pricing_system_enhancements", level = 2, text = "Pricing System Enhancements" },
                    { type = "bullet_list", items = { "Implemented support for persistent price presets, allowing market prices to retain their values across game sessions.", "Introduced configurable dynamic base prices, giving server hosts fine‑grained control over economic scaling and enabling more realistic price fluctuations." } },
                    { type = "heading", id = "ai_h_2026_03_28_wallet_lottery_mechanics", level = 2, text = "Wallet & Lottery Mechanics" },
                    { type = "bullet_list", items = { "Developed a wallet lottery system that rewards players with random items based on wallet contents, adding an exciting chance‑based element to trading.", "Added state tracking for wallet items, ensuring accurate accounting of items held, spent, or won, which enhances reliability of the new lottery feature." } },
                    { type = "heading", id = "ai_h_2026_03_28_new_tradable_item_categories", level = 2, text = "New Tradable Item Categories" },
                    { type = "bullet_list", items = { "Created new tradable building and fluid item categories, expanding the range of assets that can be bought, sold, or exchanged.", "Updated the trading UI, economy calculations, and item generation scripts to recognize and properly handle these categories, enriching the in‑game economy with more diverse trade options." } },
                },
            },
            {
                id = "2026_03_27",
                chapterId = "release_notes",
                title = "2026-03-27",
                keywords = { "update", "release", "2026-03-27" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_27", level = 1, text = "Updates for 2026-03-27" },
                    { type = "heading", id = "ai_h_2026_03_27_dynamic_trading_enhancements", level = 2, text = "Dynamic Trading Enhancements" },
                    { type = "bullet_list", items = { "Added a quantity selector when selling items, allowing players to specify exact stack sizes rather than defaulting to whole stacks.", "Impact:* Improves inventory management and speeds up trading by reducing repetitive clicks.", "Implemented caching and grouping for sellable‑item scans, dramatically reducing the number of inventory passes required.", "Impact:* Faster trade UI refreshes, especially in large inventories, leading to smoother gameplay." } },
                    { type = "heading", id = "ai_h_2026_03_27_user_guidance_update_notifications", level = 2, text = "User Guidance & Update Notifications" },
                    { type = "bullet_list", items = { "Introduced a manual “auto‑open” feature that automatically displays the update notes window when a new mod version is detected.", "Impact:* Ensures players are immediately aware of important changes without needing to check manually.", "Added a dismissible support banner that provides quick access to help resources and can be hidden permanently per user preference.", "Impact:* Enhances user experience by offering assistance without cluttering the interface.", "Created new manual pages covering the latest features and usage tips.", "Impact:* Provides clear documentation, helping both new and veteran players make the most of recent additions." } },
                },
            },
            {
                id = "2026_03_26",
                chapterId = "release_notes",
                title = "2026-03-26",
                keywords = { "update", "release", "2026-03-26" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_26", level = 1, text = "Updates for 2026-03-26" },
                    { type = "heading", id = "ai_h_2026_03_26_user_interface_enhancements", level = 2, text = "User Interface Enhancements" },
                    { type = "bullet_list", items = { "Introduced a comprehensive in‑game manual UI featuring searchable content, intuitive navigation, and dynamic rendering of entries, allowing players to quickly locate information without leaving the game." } },
                    { type = "heading", id = "ai_h_2026_03_26_gameplay_balance_skill_adjustments", level = 2, text = "Gameplay Balance & Skill Adjustments" },
                    { type = "bullet_list", items = { "Replaced the **Artistic** skill with **Maintenance** across relevant character archetypes, aligning skill progression with the new focus on equipment upkeep.", "Added item‑condition and head‑condition application logic, integrating the `DC_Colony` equipment state system to reflect wear and tear more realistically.", "Enforced minimum skill caps for Maintenance tasks, ensuring that only suitably trained survivors can perform advanced repairs." } },
                    { type = "heading", id = "ai_h_2026_03_26_multiplayer_synchronization_improvements", level = 2, text = "Multiplayer Synchronization Improvements" },
                    { type = "bullet_list", items = { "Implemented server‑side synchronization of custom item data after modifications, guaranteeing that all players see consistent item states in shared sessions." } },
                    { type = "heading", id = "ai_h_2026_03_26_content_cleanup", level = 2, text = "Content Cleanup" },
                    { type = "bullet_list", items = { "Removed all Labour‑related sandbox options and their associated translations, streamlining the configuration menu and eliminating unused content." } },
                },
            },
            {
                id = "2026_03_25",
                chapterId = "release_notes",
                title = "2026-03-25",
                keywords = { "update", "release", "2026-03-25" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_25", level = 1, text = "Updates for 2026-03-25" },
                    { type = "heading", id = "ai_h_2026_03_25_player_faction_membership_management", level = 2, text = "Player Faction Membership Management" },
                    { type = "bullet_list", items = { "Introduced a comprehensive system for handling player faction membership, covering invitation handling, role assignment, and real‑time status updates.", "Players can now send and receive faction invites, accept or decline them, and view pending requests.", "Role management allows faction leaders to assign, modify, or revoke specific roles, granting tailored permissions and responsibilities.", "Status tracking ensures that changes in membership (e.g., joining, leaving, role changes) are reflected instantly across the server, improving coordination and immersion in multiplayer sessions." } },
                },
            },
            {
                id = "2026_03_24",
                chapterId = "release_notes",
                title = "2026-03-24",
                keywords = { "update", "release", "2026-03-24" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_24", level = 1, text = "Updates for 2026-03-24" },
                    { type = "heading", id = "ai_h_2026_03_24_ui_improvements", level = 2, text = "UI Improvements" },
                    { type = "bullet_list", items = { "**Owned faction prioritization** – UI now sorts and highlights factions that the player already controls, making trade partner selection faster and more intuitive.", "**Faction info header refresh** – Updated to reflect the removal of legacy systems, providing cleaner and more relevant information at a glance.", "**Project status panels** – New UI elements display real‑time installation progress and detailed project details, helping players monitor construction without opening multiple menus." } },
                    { type = "heading", id = "ai_h_2026_03_24_core_system_refactor", level = 2, text = "Core System Refactor" },
                    { type = "bullet_list", items = { "**Removed Labour and Buildings subsystems** – Eliminated outdated mechanics and their associated UI, reducing code complexity and improving overall performance.", "**Adjusted related UI components** – Updated remaining interfaces to work seamlessly with the streamlined architecture, enhancing stability and maintainability." } },
                    { type = "heading", id = "ai_h_2026_03_24_medical_care_system", level = 2, text = "Medical Care System" },
                    { type = "bullet_list", items = { "**Doctor job introduced** – Characters assigned as Doctors can now treat injuries and illnesses, improving survivor health management.", "**Infirmary building added** – Provides a dedicated space for medical treatment, increasing the effectiveness of the Doctor role.", "**Refined provisioning logic** – Medical supplies are now allocated more efficiently to patients, reducing waste and ensuring critical resources are available when needed." } },
                    { type = "heading", id = "ai_h_2026_03_24_construction_project_management", level = 2, text = "Construction & Project Management" },
                    { type = "bullet_list", items = { "**Building installations** – Players can now place and activate structures, expanding settlement development options.", "**Project material supply system** – Automatically tracks required resources and feeds them to active projects, simplifying logistics and reducing manual micromanagement.", "**Enhanced construction UI** – Detailed project requirement lists and progress bars give players clearer insight for better planning and resource allocation." } },
                    { type = "heading", id = "ai_h_2026_03_24_development_tools", level = 2, text = "Development Tools" },
                    { type = "bullet_list", items = { "**VS Code workspace file** – Added a ready‑to‑use workspace configuration to streamline development setup for contributors." } },
                },
            },
            {
                id = "2026_03_23",
                chapterId = "release_notes",
                title = "2026-03-23",
                keywords = { "update", "release", "2026-03-23" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_23", level = 1, text = "Updates for 2026-03-23" },
                    { type = "heading", id = "ai_h_2026_03_23_building_management_tracking", level = 2, text = "Building Management & Tracking" },
                    { type = "bullet_list", items = { "Introduced a dedicated Buildings Management system with a full‑screen UI, map integration and project tracking tools, giving players clear visibility over construction sites and ongoing projects.", "Refactored core building components to improve modularity and future extensibility." } },
                    { type = "heading", id = "ai_h_2026_03_23_construction_destruction_mechanics", level = 2, text = "Construction & Destruction Mechanics" },
                    { type = "bullet_list", items = { "Added robust building construction functionality, including UI prompts, labour assignment handling, and network synchronization for multiplayer sessions.", "Implemented building destruction logic with validation checks, UI feedback, and server‑client communication to ensure consistent world updates." } },
                    { type = "heading", id = "ai_h_2026_03_23_labour_system_enhancements", level = 2, text = "Labour System Enhancements" },
                    { type = "bullet_list", items = { "Integrated scavenge result data into worker profiles, allowing detailed performance tracking.", "Added a new “Needs” panel to the worker UI, presenting resource requirements and status at a glance." } },
                    { type = "heading", id = "ai_h_2026_03_23_archetype_skill_system", level = 2, text = "Archetype Skill System" },
                    { type = "bullet_list", items = { "Created a comprehensive archetype skill framework with new skill definitions, configuration files, and registry integration.", "Added UI elements for labour to display skill levels and specializations, empowering players to assign workers more strategically." } },
                    { type = "heading", id = "ai_h_2026_03_23_tiredness_fatigue_management", level = 2, text = "Tiredness & Fatigue Management" },
                    { type = "bullet_list", items = { "Developed a full tiredness system for labour workers, introducing distinct fatigue states, automatic return reasons, and visual UI indicators.", "Enables realistic worker stamina behavior, improving immersion and requiring careful workforce management." } },
                },
            },
            {
                id = "2026_03_22",
                chapterId = "release_notes",
                title = "2026-03-22",
                keywords = { "update", "release", "2026-03-22" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_22", level = 1, text = "Updates for 2026-03-22" },
                    { type = "heading", id = "ai_h_2026_03_22_system_architecture_modularization", level = 2, text = "System Architecture & Modularization" },
                    { type = "bullet_list", items = { "Refactored the faction, economy, event, server, and configuration systems into distinct, reusable modules, improving code maintainability and future extensibility.", "Separated labour simulation logic and worker interaction handling into dedicated modules, allowing easier tweaking of labour mechanics.", "Split worker network handlers into their own components, streamlining networking code and reducing cross‑module dependencies.", "Organized supply‑window actions into individual files, enhancing readability and simplifying future feature additions." } },
                    { type = "heading", id = "ai_h_2026_03_22_user_interface_improvements", level = 2, text = "User Interface Improvements" },
                    { type = "bullet_list", items = { "Overhauled the main UI components, delivering a cleaner and more intuitive player experience.", "Modularized the Faction Info Window and Supply Window presentation logic, enabling independent updates and customisation.", "Added new view modes to the supply window to display labour warehouse contents more clearly.", "Replaced the previous job‑type cycling with a dedicated job‑selection modal, giving players precise control over worker assignments." } },
                    { type = "heading", id = "ai_h_2026_03_22_labour_warehouse_system_enhancements", level = 2, text = "Labour & Warehouse System Enhancements" },
                    { type = "bullet_list", items = { "Introduced a labour warehouse system with display names for each warehouse, making inventory tracking straightforward.", "Implemented advanced labour interaction strings that convey progress and outcomes, improving player feedback during labour tasks.", "Added auto‑repeat functionality for scavenger jobs, reducing micromanagement for repetitive scavenging runs.", "Developed a comprehensive scavenging simulation that accounts for worker presence, travel logic, provisioning, and map integration, resulting in more realistic and balanced scavenging outcomes.", "Updated worker job management UI with clear scavenging provision warnings, helping players avoid unintended resource loss." } },
                    { type = "heading", id = "ai_h_2026_03_22_player_owned_faction_features", level = 2, text = "Player‑Owned Faction Features" },
                    { type = "bullet_list", items = { "Added full support for player‑owned factions, including UI for creation, management, and worker trade control.", "Implemented a `RemoveTrader` utility and synchronized linked workers when factions are altered, ensuring data consistency across the game world." } },
                    { type = "heading", id = "ai_h_2026_03_22_sandbox_configuration_gameplay_options", level = 2, text = "Sandbox Configuration & Gameplay Options" },
                    { type = "bullet_list", items = { "Provided new sandbox options and core configuration parameters for labour work cycles and multipliers, granting map creators fine‑grained control over labour pacing and productivity." } },
                },
            },
            {
                id = "2026_03_21",
                chapterId = "release_notes",
                title = "2026-03-21",
                keywords = { "update", "release", "2026-03-21" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_21", level = 1, text = "Updates for 2026-03-21" },
                    { type = "heading", id = "ai_h_2026_03_21_labour_system_overhaul", level = 2, text = "Labour System Overhaul" },
                    { type = "bullet_list", items = { "Modularized labour configuration and nutrition logic into dedicated files, improving maintainability and future expandability.", "Re‑engineered the main labour window UI: core logic, layout, and state management are now split into separate modules, resulting in a cleaner codebase and smoother UI updates.", "Introduced a new labour help window that guides players through job assignments and explains mechanics.", "Redesigned worker nutrition and health handling to use HP‑based consumption and meal‑based intake, with automatic UI refresh for real‑time feedback.", "Added sandbox options allowing server admins to set daily calorie and hydration consumption for workers, giving finer control over difficulty and realism." } },
                    { type = "heading", id = "ai_h_2026_03_21_supply_window_ui_redesign", level = 2, text = "Supply Window UI Redesign" },
                    { type = "bullet_list", items = { "Completely overhauled the supply window: dual‑list layout, searchable items, detailed item panels, and bulk‑deposit functionality streamline inventory management.", "Implemented a tabbed interface separating provisions, output, and equipment, making it faster to locate and organize resources.", "Updated the rich‑text panel refreshing logic to ensure information stays current during gameplay.", "Refactored and relocated all SupplyWindow UI components into a new **Core** directory, simplifying future UI enhancements." } },
                    { type = "heading", id = "ai_h_2026_03_21_worker_mechanics_scavenging_enhancements", level = 2, text = "Worker Mechanics & Scavenging Enhancements" },
                    { type = "bullet_list", items = { "Added worker carry‑weight, container capacity, and weight‑reduction mechanics, allowing more realistic load handling during scavenging.", "Enhanced scavenger UI to display carry‑weight limits and current load, giving players clear visual cues.", "Implemented automatic scavenge‑site profiling that analyses location context and presents site details directly in the worker UI.", "Developed detailed scavenging job mechanics with configurable tool requirements and a dedicated UI presentation, giving deeper strategic options.", "Created a worker cache system that stores nutrition status, equipped tools, and expected outputs, reducing runtime calculations and improving performance.", "Integrated an activity log into the labour UI, providing a chronological record of worker actions and outcomes." } },
                    { type = "heading", id = "ai_h_2026_03_21_item_texture_improvements", level = 2, text = "Item Texture Improvements" },
                    { type = "bullet_list", items = { "Added support for script‑based texture variants, clothing item textures, and multiple fallback mechanisms, resulting in higher‑resolution visuals and fewer missing‑texture glitches." } },
                    { type = "heading", id = "ai_h_2026_03_21_faction_reputation_debug_ui", level = 2, text = "Faction Reputation & Debug UI" },
                    { type = "bullet_list", items = { "Implemented personal reputation adjustments within the faction debug UI, enabling quick testing of reputation impacts on gameplay.", "Removed legacy `isRadio` checks from UI system functions, cleaning up the code and preventing unnecessary conditional logic." } },
                    { type = "heading", id = "ai_h_2026_03_21_core_ui_refactoring", level = 2, text = "Core UI Refactoring" },
                    { type = "bullet_list", items = { "Reorganized UI components across the mod into dedicated directories (e.g., **Core**, **SupplyWindow**, **Labour**), establishing a clear project structure that eases navigation and future development." } },
                },
            },
            {
                id = "2026_03_20",
                chapterId = "release_notes",
                title = "2026-03-20",
                keywords = { "update", "release", "2026-03-20" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_20", level = 1, text = "Updates for 2026-03-20" },
                    { type = "heading", id = "ai_h_2026_03_20_dynamic_trading_labour_system_refactor", level = 2, text = "Dynamic Trading – Labour System Refactor" },
                    { type = "bullet_list", items = { "**Modularized Labour Registry and Labour Network**", "Extracted core labour management logic into separate, self‑contained files. This makes the codebase easier to navigate, simplifies future extensions, and reduces the risk of accidental cross‑component interference.", "**Split Labour UI into Dedicated Windows**", "Replaced the single, monolithic `DT_LabourWindow` with two focused interfaces: a **Main Labour Window** for overall overview and a **Supply Window** for detailed resource management. Players now experience a cleaner, more intuitive UI that isolates high‑level stats from supply specifics.", "**Created a New `DT_System` Module**", "Consolidated all labour‑related UI components under a unified `DT_System` namespace and reorganized the `LabourSupplyWindow` structure. This enhances maintainability, improves load times, and sets a solid foundation for future UI enhancements within the Dynamic Trading mod." } },
                },
            },
            {
                id = "2026_03_19",
                chapterId = "release_notes",
                title = "2026-03-19",
                keywords = { "update", "release", "2026-03-19" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_19", level = 1, text = "Updates for 2026-03-19" },
                    { type = "heading", id = "ai_h_2026_03_19_labour_management_system", level = 2, text = "Labour Management System" },
                    { type = "bullet_list", items = { "Introduced a comprehensive labour supply management UI, featuring a quantity‑input modal that lets players fine‑tune workforce allocations instantly.", "Added a dedicated worker money storage system, enabling accurate tracking of wages, earnings, and expenses per employee.", "Updated hydration unit handling to reflect realistic water consumption for labour activities, improving resource balance.", "Implemented a worker registry and job simulation engine, providing a structured way to assign, monitor, and simulate tasks across the settlement.", "Integrated resource handling tied to labour operations, ensuring that production, consumption, and logistics respond dynamically to workforce changes." } },
                },
            },
            {
                id = "2026_03_18",
                chapterId = "release_notes",
                title = "2026-03-18",
                keywords = { "update", "release", "2026-03-18" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_18", level = 1, text = "Updates for 2026-03-18" },
                    { type = "heading", id = "ai_h_2026_03_18_trading_system_overhaul", level = 2, text = "Trading System Overhaul" },
                    { type = "bullet_list", items = { "Added comprehensive trading features, including new NPC archetypes and a full suite of assets to support Dynamic Trading.", "Reimplemented core trading action logic in dedicated modules, improving readability and future extensibility.", "Split item utility functions into specialized files, streamlining item handling and reducing cross‑module dependencies.", "Consolidated and renamed common trading UI components, creating a clearer hierarchy for UI developers.", "Integrated faction data requests and refined transaction handling across client and server, resulting in more reliable trade operations." } },
                    { type = "heading", id = "ai_h_2026_03_18_reputation_system_revamp", level = 2, text = "Reputation System Revamp" },
                    { type = "bullet_list", items = { "Introduced a modular **DT_Reputation API** that isolates reputation logic from other systems, making it easier to extend and maintain.", "Adjusted reputation gains from trade interactions and enhanced the reputation halo text to display faction names and stage changes, giving players clearer feedback on their standing.", "Implemented full integration of the new reputation system with trading transactions, ensuring reputation updates occur consistently during trades." } },
                    { type = "heading", id = "ai_h_2026_03_18_npc_behavior_enhancements", level = 2, text = "NPC Behavior Enhancements" },
                    { type = "bullet_list", items = { "Disabled zombie NPCs from biting flags during spawning, preventing unintended flag damage and reducing early‑game frustration." } },
                    { type = "heading", id = "ai_h_2026_03_18_ui_improvements", level = 2, text = "UI Improvements" },
                    { type = "bullet_list", items = { "Reorganized conversation UI into separate core, visuals, faction, runtime, actions, and options files, enabling more focused development and faster UI updates.", "Integrated the Player ModData Browser into the Faction Debug Menu with updated access control, providing moderators with quick insight into player data.", "Added a debug UI for browsing local player ModData with expandable table contents, allowing developers to inspect and verify stored data efficiently." } },
                    { type = "heading", id = "ai_h_2026_03_18_code_refactoring_modularization", level = 2, text = "Code Refactoring & Modularization" },
                    { type = "bullet_list", items = { "Relocated and renamed common trading provider files into a dedicated `Provider` subdirectory, improving project structure.", "Split helper utilities into multiple specialized modules within a new subdirectory, reducing file bloat and simplifying maintenance.", "Overall modularization across trading, reputation, and UI components enhances code clarity, facilitates future feature additions, and speeds up debugging." } },
                },
            },
            {
                id = "2026_03_17",
                chapterId = "release_notes",
                title = "2026-03-17",
                keywords = { "update", "release", "2026-03-17" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_17", level = 1, text = "Updates for 2026-03-17" },
                    { type = "heading", id = "ai_h_2026_03_17_dynamic_trading_system_overhaul", level = 2, text = "Dynamic Trading System Overhaul" },
                    { type = "bullet_list", items = { "**Unified Trading UI & Pricing Logic**", "Extracted common user‑interface components and pricing calculations into shared modules, allowing all trading providers to reuse the same visual layout and price formulas. This reduces duplicated code and ensures consistent trading experiences across the game.", "**Centralized Dialogue Generation**", "Consolidated the creation of trading dialogues into a single provider, streamlining how conversations with traders are built. The `TradeTransaction` server command has also been moved to a shared handler, simplifying server‑side processing and improving reliability.", "**Cached Master Key Resolution**", "Added a high‑performance cached utility for resolving master keys, and integrated it across all trading data providers. This reduces repeated look‑ups, speeds up data retrieval, and lowers the overhead of trading operations." } },
                },
            },
            {
                id = "2026_03_16",
                chapterId = "release_notes",
                title = "2026-03-16",
                keywords = { "update", "release", "2026-03-16" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_16", level = 1, text = "Updates for 2026-03-16" },
                    { type = "heading", id = "ai_h_2026_03_16_npc_incapacitation_ui_enhancements", level = 2, text = "NPC Incapacitation & UI Enhancements" },
                    { type = "bullet_list", items = { "Added logic for incapacitated NPCs, allowing them to remain in the world with a distinct, pulsing health bar that clearly signals their state to players.", "Integrated the incapacitated state into NPC data structures, UI displays, and dialogue options, enabling realistic interactions such as treating or abandoning wounded survivors." } },
                    { type = "heading", id = "ai_h_2026_03_16_secure_debug_tools", level = 2, text = "Secure Debug Tools" },
                    { type = "bullet_list", items = { "Implemented admin‑only access checks for all debug features, ensuring that only authorized users can activate debugging utilities.", "Introduced a configurable debug‑logging system, giving server admins fine‑grained control over what internal events are recorded." } },
                    { type = "heading", id = "ai_h_2026_03_16_dynamic_conversation_ui", level = 2, text = "Dynamic Conversation UI" },
                    { type = "bullet_list", items = { "Added automatic refresh of faction information within the conversation window, so players always see up‑to‑date reputation data during dialogues." } },
                    { type = "heading", id = "ai_h_2026_03_16_trading_window_state_management", level = 2, text = "Trading Window State Management" },
                    { type = "bullet_list", items = { "Refined the internal state handling of the trading UI, resulting in smoother opening/closing transitions and more reliable synchronization between client and server." } },
                    { type = "heading", id = "ai_h_2026_03_16_archetype_editor_ui_backend", level = 2, text = "Archetype Editor (UI & Backend)" },
                    { type = "bullet_list", items = { "Delivered a full‑screen Archetype Editor with a dedicated user interface for editing archetype names, expert tags, forbidden tags, and “wants” multipliers.", "Exposed new API endpoints and backend logic to persist archetype allocations, allowing server operators to customise survivor skill distributions without editing raw files.", "Updated default item allocations for several archetypes to better reflect their intended playstyles." } },
                    { type = "heading", id = "ai_h_2026_03_16_item_tagging_categorisation_pricing_system", level = 2, text = "Item Tagging, Categorisation & Pricing System" },
                    { type = "bullet_list", items = { "Re‑engineered the item pricing engine to use tag‑based heuristics, providing a more logical and adaptable price structure across all item categories.", "Standardised item tags and category keys throughout event effects and archetype definitions, improving consistency and simplifying future balancing.", "Restructured item resources into type‑specific files (e.g., electronics, food, clothing) and introduced a unified tagging system that drives both price calculations and blacklist handling.", "Updated numerous item definitions (clothing, electronics, cookware, medical drugs, containers, etc.) with new tags and pricing data, delivering a more coherent economy and clearer item differentiation." } },
                    { type = "heading", id = "ai_h_2026_03_16_new_containers_medical_items", level = 2, text = "New Containers & Medical Items" },
                    { type = "bullet_list", items = { "Added a variety of container types (e.g., backpacks, crates) and a suite of medical drugs, each with appropriate tags and pricing, expanding the inventory options available to players." } },
                    { type = "heading", id = "ai_h_2026_03_16_electronics_food_cookware_expansion", level = 2, text = "Electronics, Food & Cookware Expansion" },
                    { type = "bullet_list", items = { "Introduced new electronic devices and cookware items, refined tagging for existing electronics and food, and updated the item blacklist to prevent inappropriate spawns." } },
                    { type = "heading", id = "ai_h_2026_03_16_code_refactoring_resource_organisation", level = 2, text = "Code Refactoring & Resource Organisation" },
                    { type = "bullet_list", items = { "Consolidated item definitions into modular, type‑specific files and cleaned up generation scripts, making the codebase easier to navigate and maintain.", "Performed broad refactors to align item category keys and tags across the project, laying groundwork for future content additions and balance tweaks." } },
                },
            },
            {
                id = "2026_03_15",
                chapterId = "release_notes",
                title = "2026-03-15",
                keywords = { "update", "release", "2026-03-15" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_15", level = 1, text = "Updates for 2026-03-15" },
                    { type = "heading", id = "ai_h_2026_03_15_item_system_overhaul", level = 2, text = "Item System Overhaul" },
                    { type = "bullet_list", items = { "Added new building and resource item registries, expanding the pool of tradable assets.", "Updated the item‑tagging system to recognize the new registries, enabling more precise filtering and search in trader inventories.", "Restructured food item categories and introduced additional item types, improving organization and allowing modders to classify consumables more intuitively.", "Refreshed related item registries and scripts to align with the new categorization, reducing duplication and simplifying future item additions." } },
                    { type = "heading", id = "ai_h_2026_03_15_data_management_ui_integration", level = 2, text = "Data Management & UI Integration" },
                    { type = "bullet_list", items = { "Implemented data resolution functions that intelligently merge cached and live faction/roster ModData.", "Updated the faction information window to draw from the merged data, ensuring traders and players see the most current faction states without reloads.", "Adjusted UI logic to handle the unified data source, resulting in smoother navigation and fewer UI inconsistencies." } },
                    { type = "heading", id = "ai_h_2026_03_15_combat_interaction_enhancements", level = 2, text = "Combat Interaction Enhancements" },
                    { type = "bullet_list", items = { "Added player‑killer tracking for NPC deaths, allowing the system to record which player eliminated a given NPC.", "Integrated this information into the faction info window, giving traders insight into player‑specific actions and enabling more contextual dialogues." } },
                    { type = "heading", id = "ai_h_2026_03_15_reputation_system", level = 2, text = "Reputation System" },
                    { type = "bullet_list", items = { "Introduced a dynamic reputation framework that influences trader dialogue based on player interactions.", "Tracked trade value and NPC interactions to calculate reputation scores, giving players tangible feedback for positive or negative trading behavior.", "Modified trader responses to reflect reputation changes, creating a more immersive and consequence‑driven economy." } },
                    { type = "heading", id = "ai_h_2026_03_15_animation_interaction_improvements", level = 2, text = "Animation & Interaction Improvements" },
                    { type = "bullet_list", items = { "Standardized the XML structure for NPC idle animations, simplifying future animation additions and maintenance.", "Added a new idle animation for the trade bat, giving the trading area a more lively appearance.", "Updated trade interaction logic to correctly handle the new idle state, ensuring seamless transitions between trading and idle behaviors." } },
                },
            },
            {
                id = "2026_03_14",
                chapterId = "release_notes",
                title = "2026-03-14",
                keywords = { "update", "release", "2026-03-14" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_14", level = 1, text = "Updates for 2026-03-14" },
                    { type = "heading", id = "ai_h_2026_03_14_npc_behavior_interaction", level = 2, text = "NPC Behavior & Interaction" },
                    { type = "bullet_list", items = { "Added a **shared stationary behavior module** that unifies idle, guard, and trading states, now detecting player proximity and managing interaction poses for smoother NPC responses.", "Refined **NPC interaction and trading logic** with robust state management and smarter departure handling, reducing unexpected NPC despawns during trades.", "Implemented **`DTNPCManager.ReclaimZombie`**, which repairs and re‑registers existing NPCs, improving spawn reliability and providing detailed debug logs for easier troubleshooting.", "Centralized **NPC movement speed configuration** into global settings, eliminating per‑NPC speed properties and simplifying balance adjustments." } },
                    { type = "heading", id = "ai_h_2026_03_14_ambient_dialogue_system", level = 2, text = "Ambient Dialogue System" },
                    { type = "bullet_list", items = { "Re‑architected the ambient dialogue system, moving files from `Ambient/DTNPC_AmbientDialogue` to a new `Dialogue/Ambient` hierarchy for clearer project organization.", "Consolidated ambient dialogue registration and data structures into the main dialogue framework, streamlining the registration process and reducing redundant code.", "Introduced a **modular, archetype‑based ambient NPC dialogue system** that allows configurable delay intervals per archetype, enabling more varied and natural conversations.", "Added **client‑side overhead dialogue display**, letting players see NPC speech bubbles above characters without server overhead." } },
                    { type = "heading", id = "ai_h_2026_03_14_ui_enhancements_overhead_indicators", level = 2, text = "UI Enhancements – Overhead Indicators" },
                    { type = "bullet_list", items = { "Reimplemented and optimized **NPC health‑bar tracking and rendering**, delivering more accurate visual feedback on NPC health status.", "Introduced **overhead health bars and name tags** for NPCs, improving situational awareness for players. The obsolete debug script `DT_WorldTextDebug.lua` was removed as it is no longer needed." } },
                },
            },
            {
                id = "2026_03_13",
                chapterId = "release_notes",
                title = "2026-03-13",
                keywords = { "update", "release", "2026-03-13" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_13", level = 1, text = "Updates for 2026-03-13" },
                    { type = "heading", id = "ai_h_2026_03_13_npc_system_overhaul", level = 2, text = "NPC System Overhaul" },
                    { type = "bullet_list", items = { "Consolidated NPC spawning and synchronization into a central `DTNPC_ServerCore` module, adding distance‑based optimizations that reduce unnecessary updates for far‑away characters.", "Updated NPC data attachment processes to ensure consistent state handling across server and client." } },
                    { type = "heading", id = "ai_h_2026_03_13_npc_behavior_enhancements", level = 2, text = "NPC Behavior Enhancements" },
                    { type = "bullet_list", items = { "Standardized movement animation variables and rotation logic for all NPC actions, delivering smoother visual transitions.", "Refined departure handling to prevent abrupt exits and improve realism when NPCs leave the trading area.", "Introduced dedicated behavior states for **trading**, **idling**, and **departure**, allowing NPCs to react more intelligently to player interactions." } },
                    { type = "heading", id = "ai_h_2026_03_13_pathfinding_stuck_detection", level = 2, text = "Pathfinding & Stuck Detection" },
                    { type = "bullet_list", items = { "Enhanced the GoTo pathfinding system with built‑in stuck detection, enabling NPCs to recover automatically when they encounter obstacles or become trapped." } },
                    { type = "heading", id = "ai_h_2026_03_13_trading_ui_refactor", level = 2, text = "Trading UI Refactor" },
                    { type = "bullet_list", items = { "Modularized and refactored the trading window wrappers, separating support for the legacy V1 Radio UI and the newer V2 UI. This paves the way for future UI upgrades and simplifies maintenance." } },
                },
            },
            {
                id = "2026_03_12",
                chapterId = "release_notes",
                title = "2026-03-12",
                keywords = { "update", "release", "2026-03-12" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_12", level = 1, text = "Updates for 2026-03-12" },
                    { type = "heading", id = "ai_h_2026_03_12_npc_trading_enhancements", level = 2, text = "NPC & Trading Enhancements" },
                    { type = "bullet_list", items = { "Added **active adoption** for existing NPCs and introduced pre‑spawn checks to eliminate duplicate spawns, improving NPC population stability.", "Optimized **NPC respawn square search** to evaluate only the perimeter, reducing computational load during world generation.", "Updated NPC data synchronization to use a unified `savedData` parameter, ensuring consistent state across server and client.", "Refined the **trading system** to prevent redundant trade requests and extended the stock generation timeout, resulting in smoother vendor interactions.", "Broadened the overall **economy mechanics** and refreshed several item definitions, delivering a more balanced and immersive trading experience." } },
                    { type = "heading", id = "ai_h_2026_03_12_debug_console_logging", level = 2, text = "Debug Console & Logging" },
                    { type = "bullet_list", items = { "Implemented a dedicated **debug console page** with backend log parsing and real‑time viewing, giving developers immediate insight into server activity.", "Added **log filtering by level and system**, including API parameters, to the console UI, allowing targeted diagnostics without overwhelming output.", "Decoupled print statements into a global logging form, standardizing output handling and simplifying future log enhancements." } },
                    { type = "heading", id = "ai_h_2026_03_12_simulation_engine", level = 2, text = "Simulation Engine" },
                    { type = "bullet_list", items = { "Created a **backend simulation module** paired with a comprehensive **frontend dashboard**, enabling advanced scenario testing directly from the mod’s UI.", "Developed a **client‑side simulation engine** with interactive controls and state management, giving users the ability to tweak and observe simulation parameters on the fly." } },
                    { type = "heading", id = "ai_h_2026_03_12_item_management", level = 2, text = "Item Management" },
                    { type = "bullet_list", items = { "Introduced **advanced item filtering** capabilities and a dedicated **item management page**, streamlining inventory handling for both developers and players.", "Refined startup scripts for backend and frontend components to ensure the new item management tools load reliably and efficiently." } },
                    { type = "heading", id = "ai_h_2026_03_12_task_management_system", level = 2, text = "Task Management System" },
                    { type = "bullet_list", items = { "Launched a **task management system** featuring a frontend console for creating, tracking, and completing tasks.", "Refactored item data definitions to better integrate with the task workflow, and updated backend processing to support the new task features.", "These updates collectively enhance NPC behavior, trading stability, debugging efficiency, simulation flexibility, item handling, and task organization, delivering a more robust and user‑friendly DynamicTrading experience." } },
                },
            },
            {
                id = "2026_03_11",
                chapterId = "release_notes",
                title = "2026-03-11",
                keywords = { "update", "release", "2026-03-11" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_11", level = 1, text = "Updates for 2026-03-11" },
                    { type = "heading", id = "repo_dynamictrading_2026_03_11", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "feat: Implement the new ItemManagement backend module with tagging, pricing, parsing, and UI functionalities.", "feat: Remove DynamicTradingInfoUI and refactor V1 virtual faction data injection into the FactionInfoWindow.", "feat: Validate trader availability using roster status and return time, and update UI messages to reflect departure status.", "refactor: remove V1-specific trading window wrapper and dialogue UI files.", "feat: unify V1 radio and V2 radar discovery data management, move NPC trading sandbox options to common, and refactor radio interaction checks.", "feat: Implement server-authoritative network handling for V1 Radio commands, refactor V1 Manager functions, and enhance soul generation with scattered home coordinates and improved UUIDs.", "refactor: Centralize debug data wipe functionality and add debug item spawning to PsychopatzDebugServer.lua.", "feat: Introduce client-side NPC metadata cache, populated by radar, and display discovered NPCs with details in the global list." } },
                },
            },
            {
                id = "2026_03_10",
                chapterId = "release_notes",
                title = "2026-03-10",
                keywords = { "update", "release", "2026-03-10" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_10", level = 1, text = "Updates for 2026-03-10" },
                    { type = "heading", id = "repo_dynamictrading_2026_03_10", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "refactor: Unify NPC visual generation under `identitySeed`, replacing `portraitID` and `lookSeed`, and update soul ID generation.", "fix: Add type checks for ModData in global data listeners and make minor client adjustments.", "refactor: Rename NPC data structure from 'brain' to 'npcData' and update debugger panel names for clarity." } },
                },
            },
            {
                id = "2026_03_08",
                chapterId = "release_notes",
                title = "2026-03-08",
                keywords = { "update", "release", "2026-03-08" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_08", level = 1, text = "Updates for 2026-03-08" },
                    { type = "heading", id = "ai_h_2026_03_08_dynamic_trading_npc_animation_enhancements", level = 2, text = "Dynamic Trading – NPC Animation Enhancements" },
                    { type = "bullet_list", items = { "Added a variety of new idle animation states for Dynamic Trading NPCs, replacing the previous generic loop and increasing the total idle state count. This gives merchants more lifelike behavior and reduces visual repetition.", "Implemented a cyclical animation system using new animation nodes and Lua logic to manage NPC idle states. NPCs now transition smoothly between idle poses, creating a more immersive trading environment." } },
                },
            },
            {
                id = "2026_03_07",
                chapterId = "release_notes",
                title = "2026-03-07",
                keywords = { "update", "release", "2026-03-07" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_07", level = 1, text = "Updates for 2026-03-07" },
                    { type = "heading", id = "ai_h_2026_03_07_npc_management_visuals", level = 2, text = "NPC Management & Visuals" },
                    { type = "bullet_list", items = { "**Modularized NPC respawn and trade cycle** – reorganized logic into a clean directory layout, making future extensions easier to maintain.", "**Implemented a spatial‑hash system** for fast lookup of NPC locations, reducing the cost of distance checks during each tick.", "**Added distance‑based update frequency** – NPCs far from players are processed less often, improving overall server performance.", "**Integrated position interpolation** to smooth NPC movement, eliminating jittery transitions.", "**Introduced archetype‑specific hair, beard, and hair‑color definitions** with seed‑based generation, giving each NPC a more distinctive and consistent appearance.", "**Created comprehensive look definitions** that feed directly into the wardrobe system, ensuring NPC outfits match their archetype.", "**Implemented anchor stabilization** with configurable drift tolerance and snap cooldown, preventing NPCs from drifting away from their intended positions." } },
                    { type = "heading", id = "ai_h_2026_03_07_server_core_refactoring", level = 2, text = "Server Core Refactoring" },
                    { type = "bullet_list", items = { "**Extracted all server‑side DTNPC logic** into a new **ServerCore** module, centralizing core functionality and simplifying cross‑module interactions.", "**Renamed and reorganized DTNPC spatial‑hash files**, adding a central loader that automatically registers the hash system on startup.", "**Split the monolithic `DT_EventManager`** into three focused modules (global, faction, registry), each handling its own responsibilities and providing clearer event pathways." } },
                    { type = "heading", id = "ai_h_2026_03_07_debug_administration_ui", level = 2, text = "Debug & Administration UI" },
                    { type = "bullet_list", items = { "**Developed dedicated debug UIs** for faction administration, merchant stock management, NPC location tracking, and network adapter status.", "**Moved the debug UI** into a shared module, allowing other sub‑systems to reuse common debugging widgets without duplication." } },
                    { type = "heading", id = "ai_h_2026_03_07_event_system_enhancements", level = 2, text = "Event System Enhancements" },
                    { type = "bullet_list", items = { "**Reworked the event architecture** to support multi‑flash stacking, enabling more complex chained events without loss of timing fidelity.", "**Added new sandbox control events** and updated engine data structures to version 2, expanding the range of in‑game scripting possibilities." } },
                    { type = "heading", id = "ai_h_2026_03_07_network_optimization_dynamictrading_v2", level = 2, text = "Network Optimization (DynamicTrading V2)" },
                    { type = "bullet_list", items = { "**Introduced distance‑aware network broadcasting** – only players within a relevant radius receive NPC updates, drastically reducing bandwidth consumption.", "**Provided an optimization plan for DynamicTrading V2**, laying groundwork for future performance improvements in trade‑related network traffic." } },
                },
            },
            {
                id = "2026_03_05",
                chapterId = "release_notes",
                title = "2026-03-05",
                keywords = { "update", "release", "2026-03-05" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_05", level = 1, text = "Updates for 2026-03-05" },
                    { type = "heading", id = "repo_dynamictrading_2026_03_05", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: v1 radio scanning bug on multiplayer", "feat: impliment tags string parser", "refactor(wip): put items into subfolders", "refactor: update all of archetype tags", "refactor(wip): connect the updated tags to archetypes", "refactor(wip): refactor tags to be generalized" } },
                },
            },
            {
                id = "2026_03_04",
                chapterId = "release_notes",
                title = "2026-03-04",
                keywords = { "update", "release", "2026-03-04" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_04", level = 1, text = "Updates for 2026-03-04" },
                    { type = "heading", id = "ai_h_2026_03_04_trading_system_refactor", level = 2, text = "Trading System Refactor" },
                    { type = "bullet_list", items = { "Reorganized archetype definitions to improve readability and future extensibility.", "Standardized item ID tag formatting across the trading module, ensuring consistent parsing and easier maintenance.", "Cleared out invalid item IDs, preventing potential transaction errors and reducing server load." } },
                    { type = "heading", id = "ai_h_2026_03_04_package_weight_mechanics", level = 2, text = "Package Weight Mechanics" },
                    { type = "bullet_list", items = { "Added dynamic weight reduction for packaged items, allowing the total carried weight to adjust based on package contents. This provides a more realistic inventory burden and helps players manage encumbrance more effectively." } },
                    { type = "heading", id = "ai_h_2026_03_04_quest_system", level = 2, text = "Quest System" },
                    { type = "bullet_list", items = { "Implemented a basic quest framework, introducing objectives, rewards, and progression tracking. Players can now receive and complete quests, adding new gameplay depth and replayability." } },
                },
            },
            {
                id = "2026_03_03",
                chapterId = "release_notes",
                title = "2026-03-03",
                keywords = { "update", "release", "2026-03-03" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_03", level = 1, text = "Updates for 2026-03-03" },
                    { type = "heading", id = "ai_h_2026_03_03_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Restored full compatibility with the original version 1 by aligning all trading mechanics to match the updated version 2 implementation. This ensures that existing saves and older multiplayer sessions continue to function seamlessly after the update." } },
                },
            },
            {
                id = "2026_03_02",
                chapterId = "release_notes",
                title = "2026-03-02",
                keywords = { "update", "release", "2026-03-02" },
                blocks = {
                    { type = "heading", id = "heading_2026_03_02", level = 1, text = "Updates for 2026-03-02" },
                    { type = "heading", id = "ai_h_2026_03_02_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Resolved an invalid format issue in version 1, preventing data corruption and ensuring stable trade interactions.", "Enhanced Linux compatibility, fixing platform‑specific errors to provide a smoother experience for Linux users." } },
                },
            },
            {
                id = "2026_02_27",
                chapterId = "release_notes",
                title = "2026-02-27",
                keywords = { "update", "release", "2026-02-27" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_27", level = 1, text = "Updates for 2026-02-27" },
                    { type = "heading", id = "ai_h_2026_02_27_dynamic_trading_system", level = 2, text = "Dynamic Trading System" },
                    { type = "bullet_list", items = { "**Enhanced debugging capabilities** – Updated the debug server script to improve reliability when testing NPC interactions, making it easier for developers to trace and resolve issues during development.", "**Implemented DTNPC Manager** – Introduced a comprehensive NPC lifecycle manager that handles:", "Per‑tick processing for dynamic behavior updates", "Unique UUID assignment for reliable NPC identification", "Registration and deregistration mechanisms for clean NPC handling", "Automatic respawn logic to maintain population consistency", "Save and load integration to persist NPC states across game sessions", "These additions provide a robust foundation for dynamic trading NPCs, ensuring stable performance, consistent world persistence, and smoother development workflows." } },
                },
            },
            {
                id = "2026_02_16",
                chapterId = "release_notes",
                title = "2026-02-16",
                keywords = { "update", "release", "2026-02-16" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_16", level = 1, text = "Updates for 2026-02-16" },
                    { type = "heading", id = "ai_h_2026_02_16_dynamic_trading_ui_modularization", level = 2, text = "Dynamic Trading – UI Modularization" },
                    { type = "bullet_list", items = { "**Decoupled configuration UI** – The settings panel is now isolated from the core trading logic, allowing UI updates without affecting backend functionality and simplifying future feature expansions.", "**Extracted faction info window** – Faction details are displayed in a dedicated, independent window, reducing code interdependencies and improving maintainability of the trading interface." } },
                },
            },
            {
                id = "2026_02_15",
                chapterId = "release_notes",
                title = "2026-02-15",
                keywords = { "update", "release", "2026-02-15" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_15", level = 1, text = "Updates for 2026-02-15" },
                    { type = "heading", id = "ai_h_2026_02_15_multiplayer_connectivity", level = 2, text = "Multiplayer & Connectivity" },
                    { type = "bullet_list", items = { "Resolved multiplayer synchronization issues in version 1, ensuring stable gameplay across hosts and clients.", "Fixed connectivity problems related to radio‑based faction management, eliminating dropped connections and improving radio trade interactions.", "Addressed lingering connectivity glitches, providing a smoother experience when players join or switch servers." } },
                    { type = "heading", id = "ai_h_2026_02_15_faction_system_enhancements", level = 2, text = "Faction System Enhancements" },
                    { type = "bullet_list", items = { "Implemented a new faction feature for version 1, expanding faction behavior and trade options.", "Relocated all NPC definitions to the shared **common** module, centralising data for easier maintenance and future updates.", "Moved the entire faction system logic into the **common** module, promoting code reuse and simplifying cross‑mod compatibility." } },
                    { type = "heading", id = "ai_h_2026_02_15_economic_mechanics_inflation", level = 2, text = "Economic Mechanics (Inflation)" },
                    { type = "bullet_list", items = { "Corrected the inflation calculation algorithm, restoring realistic price fluctuations and preventing runaway price scaling." } },
                    { type = "heading", id = "ai_h_2026_02_15_code_refactor", level = 2, text = "Code Refactor" },
                    { type = "bullet_list", items = { "Consolidated NPC and faction definitions into a unified common library, reducing duplication and streamlining the mod’s architecture." } },
                },
            },
            {
                id = "2026_02_14",
                chapterId = "release_notes",
                title = "2026-02-14",
                keywords = { "update", "release", "2026-02-14" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_14", level = 1, text = "Updates for 2026-02-14" },
                    { type = "heading", id = "ai_h_2026_02_14_ui_improvements_market_panel", level = 2, text = "UI Improvements – Market Panel" },
                    { type = "bullet_list", items = { "Corrected text formatting on the market panel to ensure clear and readable information.", "Resolved scrolling issues on the market tab, providing smooth navigation through long lists of items." } },
                    { type = "heading", id = "ai_h_2026_02_14_market_system_enhancements", level = 2, text = "Market System Enhancements" },
                    { type = "bullet_list", items = { "Introduced a new **Inflation & Deflation** tab, allowing players to monitor and react to market price fluctuations in real time." } },
                    { type = "heading", id = "ai_h_2026_02_14_faction_event_tracking", level = 2, text = "Faction Event Tracking" },
                    { type = "bullet_list", items = { "Added a **Faction Events Summary** window that consolidates recent event outcomes for quick reference.", "Implemented sub‑tabs within the events interface, enabling organized navigation between different event categories (e.g., raids, trades, diplomatic actions)." } },
                },
            },
            {
                id = "2026_02_13",
                chapterId = "release_notes",
                title = "2026-02-13",
                keywords = { "update", "release", "2026-02-13" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_13", level = 1, text = "Updates for 2026-02-13" },
                    { type = "heading", id = "ai_h_2026_02_13_npc_interaction_ui", level = 2, text = "NPC Interaction UI" },
                    { type = "bullet_list", items = { "Added a dedicated **NPC Profile Panel** to display detailed information about trading partners, improving player insight and decision‑making during transactions." } },
                    { type = "heading", id = "ai_h_2026_02_13_responsive_ui_enhancements", level = 2, text = "Responsive UI Enhancements" },
                    { type = "bullet_list", items = { "Implemented **auto‑resizing fonts** that adjust smoothly when the game window is scaled, ensuring all UI text remains clear and readable at any resolution." } },
                    { type = "heading", id = "ai_h_2026_02_13_faction_ui_overhaul", level = 2, text = "Faction UI Overhaul" },
                    { type = "bullet_list", items = { "Introduced a **stand‑alone Faction UI** with its own layout, providing a focused area for faction management.", "Added **tab navigation** within the Faction UI, allowing quick access to different faction sections (e.g., trade routes, member lists, reputation) without leaving the screen." } },
                },
            },
            {
                id = "2026_02_12",
                chapterId = "release_notes",
                title = "2026-02-12",
                keywords = { "update", "release", "2026-02-12" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_12", level = 1, text = "Updates for 2026-02-12" },
                    { type = "heading", id = "ai_h_2026_02_12_event_system_overhaul_v2", level = 2, text = "Event System Overhaul (v2)" },
                    { type = "bullet_list", items = { "Implemented a brand‑new event system (v2) with extended parameters, allowing richer event data and more flexible scripting.", "Decoupled the event system from core gameplay logic and moved it to a common module, improving modularity and making future extensions easier.", "Added debugging support for spawn options and faction handling within events, streamlining testing of event‑driven features." } },
                    { type = "heading", id = "ai_h_2026_02_12_global_heat_mechanic", level = 2, text = "Global Heat Mechanic" },
                    { type = "bullet_list", items = { "Introduced a global heat variable on V2 that tracks overall map temperature, enabling heat‑related mechanics such as fire spread and player stamina effects." } },
                    { type = "heading", id = "ai_h_2026_02_12_trader_ui_enhancements", level = 2, text = "Trader UI Enhancements" },
                    { type = "bullet_list", items = { "Updated the trader interface for liquid containers to show the exact number of liters held.", "Implemented dynamic price recalculation while the player interacts with the container, giving real‑time feedback on trade values.", "Fixed the trader message display issue, ensuring all notifications appear correctly." } },
                    { type = "heading", id = "ai_h_2026_02_12_sandbox_dynamic_event_loading", level = 2, text = "Sandbox & Dynamic Event Loading" },
                    { type = "bullet_list", items = { "Reorganized sandbox configuration options for clearer navigation and faster tweaking.", "Added support for dynamic loading of events, allowing new events to be injected without restarting the game." } },
                    { type = "heading", id = "ai_h_2026_02_12_debug_development_tools", level = 2, text = "Debug & Development Tools" },
                    { type = "bullet_list", items = { "Centralized debug print statements into a dedicated method, cleaning up console output and simplifying future debugging.", "Added a spawn‑options debug view for factions, providing developers with immediate visibility of spawn settings during event testing." } },
                    { type = "heading", id = "ai_h_2026_02_12_base_spawn_additions", level = 2, text = "Base Spawn Additions" },
                    { type = "bullet_list", items = { "Added a new Louisville base spawn location, expanding the variety of starting points for survivors." } },
                    { type = "heading", id = "ai_h_2026_02_12_code_cleanup_refactoring", level = 2, text = "Code Cleanup & Refactoring" },
                    { type = "bullet_list", items = { "Removed redundant attrition logic, reducing unnecessary calculations and improving overall performance.", "Fixed color UI rendering on V2, restoring proper visual cues for players." } },
                },
            },
            {
                id = "2026_02_11",
                chapterId = "release_notes",
                title = "2026-02-11",
                keywords = { "update", "release", "2026-02-11" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_11", level = 1, text = "Updates for 2026-02-11" },
                    { type = "heading", id = "repo_dynamictrading_2026_02_11", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "refactor: rename Networklogs", "fix: overlapping Network Ui by using stencil Wrapper", "refactor: decouple DynamicTrading_Factions.lua", "refactor: decouple DynamicTrading_Network_Server.lua", "fix: visibility check floods the logs when accessing trader despawns while accessing the window", "fix: V1 message logs now uses refactored names space", "fix: optimize translation loading to avoid flodding the logs", "feat: impliment translation system", "refactor(wip): dialogue autoregister", "feat(wip): impliment translations", "refactor: made option and config manager data agnostic" } },
                },
            },
            {
                id = "2026_02_10",
                chapterId = "release_notes",
                title = "2026-02-10",
                keywords = { "update", "release", "2026-02-10" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_10", level = 1, text = "Updates for 2026-02-10" },
                    { type = "heading", id = "repo_dynamictrading_2026_02_10", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: optimize TradingWindow to not recheck when the window closed", "feat: persistent event marker", "feat: add  info tab", "feat: auto open radar ui when finding a trader", "fix: optimize ConversationUI checking tick to mninimal", "feat: add refusal when trading instead of hiding it while npc is resting", "fix: close tradeui when dead to prevent errors", "refactor: move optionui to common folder", "feat: persistent DT_RadioWindow.lua", "feat: persistent DT_TradingWindow.lua", "feat: dynamic price on liquid based on per Liters", "fix: fix trader items atrributes to also work on V2 multiplayer", "feat: impliment dynamic attributes to trader's items too", "fix: food items can now properly priced", "fix(wip): properly detect drainable items", "feat(wip): add debugs for the items with remaining value", "fix: liquid container now properly detected", "fix(wip): properly display fluid container name", "feat(wip): impliment smarter fluid and item details detection for dynamic pricing", "refactor: decouple economy.lua to be agnostic" } },
                },
            },
            {
                id = "2026_02_09",
                chapterId = "release_notes",
                title = "2026-02-09",
                keywords = { "update", "release", "2026-02-09" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_09", level = 1, text = "Updates for 2026-02-09" },
                    { type = "heading", id = "ai_h_2026_02_09_backend_refactoring", level = 2, text = "Backend Refactoring" },
                    { type = "bullet_list", items = { "Streamlined archetype registration to ensure more reliable loading and reduce initialization errors.", "Reinforced the registration process for Dynamic Trading items, making it more robust against missing or duplicate entries, which improves overall stability of the trading system." } },
                    { type = "heading", id = "ai_h_2026_02_09_ui_enhancements", level = 2, text = "UI Enhancements" },
                    { type = "bullet_list", items = { "Integrated location details into the radar interface, allowing players to see precise coordinates and region names directly on the map overlay.", "Added a dedicated **Location** tab to the radio UI, providing quick access to current position data and nearby points of interest without leaving the communication screen." } },
                },
            },
            {
                id = "2026_02_08",
                chapterId = "release_notes",
                title = "2026-02-08",
                keywords = { "update", "release", "2026-02-08" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_08", level = 1, text = "Updates for 2026-02-08" },
                    { type = "heading", id = "ai_h_2026_02_08_ui_overhaul", level = 2, text = "UI Overhaul" },
                    { type = "bullet_list", items = { "Introduced a brand‑new settings layout, giving users a cleaner and more intuitive configuration experience.", "Implemented a resizable radio button UI (V1), allowing players to adjust the interface to fit their screen preferences.", "Corrected portrait UI integration so character images now display correctly across all trader screens." } },
                    { type = "heading", id = "ai_h_2026_02_08_trader_interaction_enhancements", level = 2, text = "Trader Interaction Enhancements" },
                    { type = "bullet_list", items = { "Added hooks for the trader UI, paving the way for future extensions such as custom animations or additional data displays.", "Developed the core trader UI, providing a polished and responsive interface for buying, selling, and bartering with NPC merchants.", "Implemented an automatic close hook that gracefully exits the Conversation UI when a trader’s session expires, preventing lingering dialogs." } },
                    { type = "heading", id = "ai_h_2026_02_08_multiplayer_compatibility", level = 2, text = "Multiplayer Compatibility" },
                    { type = "bullet_list", items = { "Updated the stock trading handler to function reliably in multiplayer sessions, ensuring synchronized inventories and trade actions for all players." } },
                    { type = "heading", id = "ai_h_2026_02_08_debug_maintenance", level = 2, text = "Debug & Maintenance" },
                    { type = "bullet_list", items = { "Fixed the Merchant debug system, restoring functionality that was broken due to outdated trigger references.", "Refactored the `DT_ConversationUI` component into a shared common module, improving code reuse and simplifying future maintenance." } },
                },
            },
            {
                id = "2026_02_07",
                chapterId = "release_notes",
                title = "2026-02-07",
                keywords = { "update", "release", "2026-02-07" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_07", level = 1, text = "Updates for 2026-02-07" },
                    { type = "heading", id = "repo_dynamictrading_2026_02_07", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: DynamicTradingV2 npc requires", "fix: publicbroadcast set to true causes ghost list when expired", "feat: change the trader budget into percent based", "feat: change the buy and sell switch button to be a tab button", "feat: make the tradingUI window dynamic size", "feat: optimized logging system on buy and sell", "fix: correct old required", "refactor: DynamicTradingUI to DT_TradingWindow", "refactor(wip): decouple tradeUI to make it agnostic", "feat: add trader faction and reputation to DT_ConversationUI", "refactor: refactor DynamicTrading V1 and V2 code to be nested", "refactor: refactor DynamicTrading V1 and V2 code to be neat" } },
                },
            },
            {
                id = "2026_02_06",
                chapterId = "release_notes",
                title = "2026-02-06",
                keywords = { "update", "release", "2026-02-06" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_06", level = 1, text = "Updates for 2026-02-06" },
                    { type = "heading", id = "ai_h_2026_02_06_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Implemented a fully functional stock trading system, allowing players to buy and sell shares within the game economy.", "Added a dedicated trade handler for stocks, managing order processing, price updates, and transaction validation.", "Integrated stock market data with existing market mechanics, providing a realistic and responsive financial simulation for players." } },
                },
            },
            {
                id = "2026_02_05",
                chapterId = "release_notes",
                title = "2026-02-05",
                keywords = { "update", "release", "2026-02-05" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_05", level = 1, text = "Updates for 2026-02-05" },
                    { type = "heading", id = "ai_h_2026_02_05_trader_radar_ui_enhancements", level = 2, text = "Trader Radar UI Enhancements" },
                    { type = "bullet_list", items = { "Added tab navigation to the Radar UI, allowing quicker access to different radar functions.", "Implemented automatic closing of the Radar UI when the Radio UI is closed, keeping the screen uncluttered.", "Introduced distance readouts in the Radio UI, giving players precise location data for traders.", "Developed a dedicated Radar UI for NPC traders, providing visual tracking of merchant positions.", "Added a minimum size constraint to the Radio UI to ensure all elements remain legible on various screen resolutions.", "Implemented sorting of traders by proximity and updated the display interval automatically, helping players identify the nearest traders at a glance.", "Added visual feedback for selected traders, improving usability when choosing a target." } },
                    { type = "heading", id = "ai_h_2026_02_05_multiplayer_compatibility_balancing", level = 2, text = "Multiplayer Compatibility & Balancing" },
                    { type = "bullet_list", items = { "Fixed the trader radar to function reliably in multiplayer sessions, ensuring all participants see accurate trader locations.", "Adjusted radar value calculations for better game balance, preventing overly aggressive or passive trader detection." } },
                    { type = "heading", id = "ai_h_2026_02_05_code_structure_improvements", level = 2, text = "Code Structure Improvements" },
                    { type = "bullet_list", items = { "Refactored the Radar UI into a separate module, simplifying future maintenance and feature expansion.", "Updated device identification logic to correctly distinguish windows by their names, reducing UI conflicts and improving stability." } },
                },
            },
            {
                id = "2026_02_04",
                chapterId = "release_notes",
                title = "2026-02-04",
                keywords = { "update", "release", "2026-02-04" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_04", level = 1, text = "Updates for 2026-02-04" },
                    { type = "heading", id = "repo_dynamictrading_2026_02_04", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: npc now spawns on their respected county", "fix: virtually simulate trader spawning", "feat(wip): trader spawning" } },
                },
            },
            {
                id = "2026_02_02",
                chapterId = "release_notes",
                title = "2026-02-02",
                keywords = { "update", "release", "2026-02-02" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_02", level = 1, text = "Updates for 2026-02-02" },
                    { type = "heading", id = "ai_h_2026_02_02_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Corrected a typo in the DT_Manager class, preventing initialization failures and ensuring the manager loads correctly.", "Properly instantiated archetypes and sandbox variables, which stabilizes trade generation and removes null‑reference errors during gameplay.", "Resolved duplicate return strings in faction management, resulting in clearer faction messages and a cleaner user interface." } },
                },
            },
            {
                id = "2026_02_01",
                chapterId = "release_notes",
                title = "2026-02-01",
                keywords = { "update", "release", "2026-02-01" },
                blocks = {
                    { type = "heading", id = "heading_2026_02_01", level = 1, text = "Updates for 2026-02-01" },
                    { type = "heading", id = "ai_h_2026_02_01_dynamic_trading_system", level = 2, text = "Dynamic Trading System" },
                    { type = "bullet_list", items = { "Added a custom, generic parameter that decouples the trading module from the rest system, making the feature more modular and easier to extend.", "Fixed a cooldown bug that forced NPCs to keep moving away, which caused an endless “away” loop; NPCs now stay put during cooldown, eliminating the glitch.", "Implemented a transition that moves NPCs from the **rest** state to **away** when they begin fleeing, resulting in smoother and more realistic NPC behavior." } },
                },
            },
            {
                id = "2026_01_31",
                chapterId = "release_notes",
                title = "2026-01-31",
                keywords = { "update", "release", "2026-01-31" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_31", level = 1, text = "Updates for 2026-01-31" },
                    { type = "heading", id = "ai_h_2026_01_31_dynamic_trading_system_core_refactor_behavior_fixes", level = 2, text = "Dynamic Trading System – Core Refactor & Behavior Fixes" },
                    { type = "bullet_list", items = { "**Decoupled client‑side synchronization logic**", "Reorganized `DTNPC_ClientSync.lua` to separate concerns, improving code readability and making future extensions easier to implement.", "**Restored NPC trading behaviors**", "Fixed an issue where NPC trading actions failed after the decoupling change, ensuring all dynamic trading interactions function correctly again." } },
                },
            },
            {
                id = "2026_01_30",
                chapterId = "release_notes",
                title = "2026-01-30",
                keywords = { "update", "release", "2026-01-30" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_30", level = 1, text = "Updates for 2026-01-30" },
                    { type = "heading", id = "ai_h_2026_01_30_faction_system_stability", level = 2, text = "Faction System Stability" },
                    { type = "bullet_list", items = { "Resolved inconsistent town data during faction initialization, ensuring all factions correctly recognize their associated towns.", "Fixed the faction debugging tool so it now functions reliably in multiplayer sessions, giving hosts and clients accurate diagnostics." } },
                    { type = "heading", id = "ai_h_2026_01_30_npc_interaction_improvements", level = 2, text = "NPC Interaction Improvements" },
                    { type = "bullet_list", items = { "Implemented a contextual talk UI menu for NPCs, allowing players to initiate conversations through an intuitive right‑click interface." } },
                    { type = "heading", id = "ai_h_2026_01_30_npc_spawning_base_integration", level = 2, text = "NPC Spawning & Base Integration" },
                    { type = "bullet_list", items = { "Corrected NPC spawning logic on player‑built bases, preventing unwanted NPC placements and preserving base integrity.", "Enhanced NPC initialization on faction bases, improving reliability of NPC presence and behavior on owned territories." } },
                },
            },
            {
                id = "2026_01_29",
                chapterId = "release_notes",
                title = "2026-01-29",
                keywords = { "update", "release", "2026-01-29" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_29", level = 1, text = "Updates for 2026-01-29" },
                    { type = "heading", id = "ai_h_2026_01_29_dynamic_trading_faction_system_enhancements", level = 2, text = "Dynamic Trading – Faction System Enhancements" },
                    { type = "bullet_list", items = { "**Added wealth tracking to factions** – Factions now maintain a dynamic wealth value, enabling more realistic trade negotiations and economic fluctuations.", "**Implemented version 2 faction initialization** – Overhauled the faction setup process for greater stability, easier configuration, and support for expanded faction attributes." } },
                    { type = "heading", id = "ai_h_2026_01_29_dynamic_trading_building_management", level = 2, text = "Dynamic Trading – Building Management" },
                    { type = "bullet_list", items = { "**Introduced automatic building selector** – The system now auto‑selects appropriate buildings for trade routes, reducing manual setup time and improving the flow of goods between settlements." } },
                },
            },
            {
                id = "2026_01_28",
                chapterId = "release_notes",
                title = "2026-01-28",
                keywords = { "update", "release", "2026-01-28" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_28", level = 1, text = "Updates for 2026-01-28" },
                    { type = "heading", id = "repo_dynamictrading_2026_01_28", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: Archetypes not properly loaded on dynamic trading manager", "fix: error on multiplayer when scanning due to wrong cooldown decoupling", "fix: crank down gunpowder price for balancing", "fix: remove money and money bundle from trade pool", "feat: add selling failures when the trader doesnt have enough money", "feat: add Chat system framework", "feat: implement request trader system", "refactor: decouple NetworkLogs and Cooldown from DynamicTrader_Engine", "feat: implement Global Wealth System for traders", "feat: introduce proper deflation and trader budget money" } },
                },
            },
            {
                id = "2026_01_27",
                chapterId = "release_notes",
                title = "2026-01-27",
                keywords = { "update", "release", "2026-01-27" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_27", level = 1, text = "Updates for 2026-01-27" },
                    { type = "heading", id = "repo_dynamictrading_2026_01_27", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "fix: rename archetype dialogue to prevent namespace conflict", "fix: archetype namespace to prevent other mod conflicts", "fix: performance issue on trade sell UI", "fix: ham radios is now properly distinguished", "fix: non two way item can pass trade", "feat: Add open wallet queue system", "feat: Add deflation mechanic when selling items", "feat: add typing indicator in trader logs", "fix: clothing items now properly renders its icons", "feat: implement lock on favorite items, lock button on sell confirmation modal, and autorefresh list when user inventory is changed", "feat: add tag highlight to each item", "refactor: move the portrait.lua into their respective Archetypes", "refactor: move dialogue into their archetypes folder", "fix: improper load order due to naming scheme", "feat: add AudioManager and Options config manager" } },
                },
            },
            {
                id = "2026_01_26",
                chapterId = "release_notes",
                title = "2026-01-26",
                keywords = { "update", "release", "2026-01-26" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_26", level = 1, text = "Updates for 2026-01-26" },
                    { type = "heading", id = "repo_dynamictrading_2026_01_26", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "feat: overide the signal animation frame temporarily for responsive scanning", "feat: display player's name when they found the trader to the logs", "fix: traders not visible when doing scans if public network is off", "feat: Add initial dynamic trading systems, including NPC debugging, wallet, loot, UI, and various debug utilities." } },
                },
            },
            {
                id = "2026_01_25",
                chapterId = "release_notes",
                title = "2026-01-25",
                keywords = { "update", "release", "2026-01-25" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_25", level = 1, text = "Updates for 2026-01-25" },
                    { type = "heading", id = "ai_h_2026_01_25_core_trading_system", level = 2, text = "Core Trading System" },
                    { type = "bullet_list", items = { "Added full client‑ and server‑side command handling for trading actions, enabling synchronized operations across multiplayer sessions.", "Implemented trader discovery state, allowing players to track which traders have been located and which remain hidden.", "Introduced transaction handling for bags, now displaying the contents of a bag when it is sold so players are fully informed before confirming.", "Fixed a duplication bug that occurred when selling generators that were subsequently dropped, ensuring item counts remain accurate." } },
                    { type = "heading", id = "ai_h_2026_01_25_user_interface_enhancements", level = 2, text = "User Interface Enhancements" },
                    { type = "bullet_list", items = { "Launched new trading UI and a dedicated radio‑signal UI, providing clearer visual feedback and easier navigation for players.", "Refined the trading list UI for smoother scrolling, better item grouping, and clearer price displays.", "Added dynamic item icons using `getTex()`, ensuring that every item’s visual representation updates correctly in real time.", "Integrated an “Ask What They Want” button on the sell‑trader window, allowing players to request a trader’s current wish list directly.", "Updated icon assets across the UI, giving a more polished and consistent visual style." } },
                    { type = "heading", id = "ai_h_2026_01_25_trader_archetype_dialogue", level = 2, text = "Trader Archetype & Dialogue" },
                    { type = "bullet_list", items = { "Reorganized archetype data into separate folders, simplifying maintenance and future expansion.", "Decoupled dialogue configurations from the core trading scripts, attaching each dialogue set directly to its corresponding archetype.", "Populated additional archetype dialogue entries, enriching interactions with a broader range of trader personalities and responses." } },
                    { type = "heading", id = "ai_h_2026_01_25_debug_development_tools", level = 2, text = "Debug & Development Tools" },
                    { type = "bullet_list", items = { "Added a debug data‑wipe command, giving developers a quick way to reset trading data during testing without affecting the rest of the game." } },
                    { type = "heading", id = "ai_h_2026_01_25_codebase_refactoring", level = 2, text = "Codebase Refactoring" },
                    { type = "bullet_list", items = { "Moved all trading‑related scripts into a dedicated folder, improving project structure and discoverability.", "Separated the dynamic trading system from the original NPC trading module, creating a cleaner, more modular architecture for future feature integration." } },
                },
            },
            {
                id = "2026_01_24",
                chapterId = "release_notes",
                title = "2026-01-24",
                keywords = { "update", "release", "2026-01-24" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_24", level = 1, text = "Updates for 2026-01-24" },
                    { type = "heading", id = "ai_h_2026_01_24_admin_debug_tools", level = 2, text = "Admin Debug Tools" },
                    { type = "bullet_list", items = { "Added a client‑side debug admin panel that allows live item spawning, giving developers and server operators instant access to any in‑game item for testing and content creation.", "Integrated a server‑side data‑wipe command directly into the panel, enabling quick resets of player or world data without needing external scripts.", "The panel is accessible only to users with admin privileges, ensuring it does not affect regular gameplay." } },
                    { type = "heading", id = "ai_h_2026_01_24_npc_system_improvements", level = 2, text = "NPC System Improvements" },
                    { type = "bullet_list", items = { "Resolved long‑standing bugs that caused NPCs to behave erratically or fail to spawn, restoring expected AI patterns and interactions.", "Enhanced overall NPC stability, resulting in smoother encounters and fewer server crashes related to the NPC subsystem." } },
                },
            },
            {
                id = "2026_01_22",
                chapterId = "release_notes",
                title = "2026-01-22",
                keywords = { "update", "release", "2026-01-22" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_22", level = 1, text = "Updates for 2026-01-22" },
                    { type = "heading", id = "ai_h_2026_01_22_multiplayer_stability", level = 2, text = "Multiplayer Stability" },
                    { type = "bullet_list", items = { "Resolved NPC desynchronization issues in multiplayer sessions, ensuring consistent NPC behavior across all clients.", "Fixed a clothing synchronization bug that caused NPCs to display incorrect outfits when playing together.", "Eliminated the problem where NPCs would repeatedly change their appearance while executing behaviors, leading to a smoother and more realistic visual experience." } },
                    { type = "heading", id = "ai_h_2026_01_22_debug_development_tools", level = 2, text = "Debug & Development Tools" },
                    { type = "bullet_list", items = { "Added a comprehensive NPC list debug utility, allowing developers and server admins to view and inspect active NPCs in real time for easier troubleshooting and balance testing." } },
                    { type = "heading", id = "ai_h_2026_01_22_code_organization", level = 2, text = "Code Organization" },
                    { type = "bullet_list", items = { "Reorganized source files into appropriate subfolders, improving project structure, readability, and future maintainability." } },
                },
            },
            {
                id = "2026_01_21",
                chapterId = "release_notes",
                title = "2026-01-21",
                keywords = { "update", "release", "2026-01-21" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_21", level = 1, text = "Updates for 2026-01-21" },
                    { type = "heading", id = "ai_h_2026_01_21_dynamic_trading_system", level = 2, text = "Dynamic Trading System" },
                    { type = "bullet_list", items = { "Introduced a fully‑functional dynamic trading architecture, allowing traders to be generated with distinct archetypes and faction affiliations.", "Added server‑side network infrastructure and data‑management tools to handle trader spawning, inventory refresh, and persistence across game sessions.", "Enabled faction‑based trader spawning, creating varied market opportunities that evolve with player actions and world events, enhancing replayability and immersion." } },
                    { type = "heading", id = "ai_h_2026_01_21_conversation_ui_framework", level = 2, text = "Conversation UI Framework" },
                    { type = "bullet_list", items = { "Delivered a generic conversation UI framework that supports chat history, selectable dialogue options, and seamless NPC integration.", "Added shared resource files for NPC presets, archetypes, dialogue scripts, and event triggers, streamlining the creation of new characters and story interactions.", "Implemented a polished UI layout for player‑NPC conversations, improving readability and providing a more engaging dialog experience." } },
                },
            },
            {
                id = "2026_01_20",
                chapterId = "release_notes",
                title = "2026-01-20",
                keywords = { "update", "release", "2026-01-20" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_20", level = 1, text = "Updates for 2026-01-20" },
                    { type = "heading", id = "ai_h_2026_01_20_event_marker_system", level = 2, text = "Event Marker System" },
                    { type = "bullet_list", items = { "Introduced a full‑featured event marker system, enabling dynamic placement and tracking of in‑game events to create richer trading scenarios.", "Added debug context menus for testing event markers and managing DTNPC orders, streamlining QA and rapid iteration." } },
                    { type = "heading", id = "ai_h_2026_01_20_npc_animation_audio_improvements", level = 2, text = "NPC Animation & Audio Improvements" },
                    { type = "bullet_list", items = { "Fixed walking animation glitches for NPCs, delivering smoother and more natural movement.", "Synchronized footstep sounds with NPC animations, enhancing overall immersion." } },
                    { type = "heading", id = "ai_h_2026_01_20_wallet_interaction_enhancements", level = 2, text = "Wallet Interaction Enhancements" },
                    { type = "bullet_list", items = { "Updated wallet mechanics so they function correctly when stored inside backpacks, giving players greater inventory flexibility." } },
                },
            },
            {
                id = "2026_01_14",
                chapterId = "release_notes",
                title = "2026-01-14",
                keywords = { "update", "release", "2026-01-14" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_14", level = 1, text = "Updates for 2026-01-14" },
                    { type = "heading", id = "ai_h_2026_01_14_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Fixed NPC item ID validation to ensure all referenced items exist, preventing trading errors and potential game crashes." } },
                },
            },
            {
                id = "2026_01_13",
                chapterId = "release_notes",
                title = "2026-01-13",
                keywords = { "update", "release", "2026-01-13" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_13", level = 1, text = "Updates for 2026-01-13" },
                    { type = "heading", id = "ai_h_2026_01_13_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Resolved a synchronization issue with IsoZombie entities during trading sessions, improving stability and consistency in multiplayer environments." } },
                },
            },
            {
                id = "2026_01_12",
                chapterId = "release_notes",
                title = "2026-01-12",
                keywords = { "update", "release", "2026-01-12" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_12", level = 1, text = "Updates for 2026-01-12" },
                    { type = "heading", id = "ai_h_2026_01_12_dynamic_trading_npc_behavior_enhancements", level = 2, text = "Dynamic Trading – NPC Behavior Enhancements" },
                    { type = "bullet_list", items = { "**Implemented attack range logic for NPCs** – NPCs now evaluate the distance to their targets before initiating combat, resulting in more realistic and tactical encounters during trading interactions. This addition improves AI decision‑making and reduces unexpected close‑range attacks." } },
                },
            },
            {
                id = "2026_01_11",
                chapterId = "release_notes",
                title = "2026-01-11",
                keywords = { "update", "release", "2026-01-11" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_11", level = 1, text = "Updates for 2026-01-11" },
                    { type = "heading", id = "ai_h_2026_01_11_npc_behavior_enhancements", level = 2, text = "NPC Behavior Enhancements" },
                    { type = "bullet_list", items = { "Replaced the standard “go‑to” pathfinding with instant teleportation for trading NPCs, resulting in smoother, more reliable movement and eliminating navigation glitches.", "Introduced a fleeing AI routine, enabling NPCs to retreat from threats. This adds realistic combat reactions and reduces unwanted NPC crowding during dangerous encounters." } },
                },
            },
            {
                id = "2026_01_10",
                chapterId = "release_notes",
                title = "2026-01-10",
                keywords = { "update", "release", "2026-01-10" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_10", level = 1, text = "Updates for 2026-01-10" },
                    { type = "heading", id = "ai_h_2026_01_10_npc_core_architecture", level = 2, text = "NPC Core Architecture" },
                    { type = "bullet_list", items = { "Established a solid foundation for NPC behavior, introducing core loops and data structures that power all subsequent NPC features.", "Enabled selection of multiple NPCs at once, facilitating group commands and coordinated interactions.", "Fixed zombie pathfinding to ensure NPCs navigate the world reliably, preventing erratic movement and improving overall AI stability." } },
                    { type = "heading", id = "ai_h_2026_01_10_npc_visual_customization", level = 2, text = "NPC Visual Customization" },
                    { type = "bullet_list", items = { "Added a dynamic clothing system that updates NPC outfits based on context, enhancing visual variety and immersion.", "Implemented automatic zombie reskinning that preserves each NPC’s unique traits when they turn, keeping character identity consistent after infection.", "Introduced automatic staring behavior, causing NPCs to lock eyes with nearby players or entities for a more lifelike presence." } },
                    { type = "heading", id = "ai_h_2026_01_10_trading_dialogue_system", level = 2, text = "Trading & Dialogue System" },
                    { type = "bullet_list", items = { "Created an introductory screen that appears when players first access a trader, delivering clear guidance and setting the tone for the encounter.", "Developed a full player‑to‑trader conversation system, enabling scripted dialogues and interactive trading prompts.", "Added a “no‑cash” dialogue branch that gracefully informs players when they lack sufficient funds, preventing confusing trade failures.", "Fixed idle trader messages to trigger correctly, ensuring traders continuously provide helpful feedback during downtime.", "Integrated a disconnect sound effect that plays when a trader’s session expires, giving audible confirmation of trade termination." } },
                },
            },
            {
                id = "2026_01_09",
                chapterId = "release_notes",
                title = "2026-01-09",
                keywords = { "update", "release", "2026-01-09" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_09", level = 1, text = "Updates for 2026-01-09" },
                    { type = "heading", id = "ai_h_2026_01_09_ui_enhancements", level = 2, text = "UI Enhancements" },
                    { type = "bullet_list", items = { "**Dynamic text wrapping for trader logs** – Refactored the text‑wrapping logic into a reusable utility and applied it to trader logs, resulting in cleaner, more readable trade histories regardless of language or font size." } },
                    { type = "heading", id = "ai_h_2026_01_09_asset_performance_optimization", level = 2, text = "Asset & Performance Optimization" },
                    { type = "bullet_list", items = { "**Optimized texture handling** – Streamlined texture loading and memory usage, reducing load times and improving overall game performance when the trading interface is active." } },
                    { type = "heading", id = "ai_h_2026_01_09_audio_fixes", level = 2, text = "Audio Fixes" },
                    { type = "bullet_list", items = { "**Resolved radio sound glitch** – Fixed an issue that caused distorted or missing audio cues on the in‑game radio, ensuring reliable sound playback during trading sessions." } },
                    { type = "heading", id = "ai_h_2026_01_09_quality_of_life_improvements", level = 2, text = "Quality of Life Improvements" },
                    { type = "bullet_list", items = { "**Lock system for the sell menu** – Introduced a lock mechanism that prevents accidental sales, giving players a clear confirmation step before confirming a transaction.", "**Protection against selling used walkie‑talkies** – Added a safeguard that blocks the sale of walkie‑talkies that have already been used, preserving essential communication tools for the player." } },
                    { type = "heading", id = "ai_h_2026_01_09_bug_fixes", level = 2, text = "Bug Fixes" },
                    { type = "bullet_list", items = { "**Corrected HAM‑related selling errors** – Fixed a crash/exception that occurred when selling items using the HAM (Hardcoded Asset Manager), stabilizing the sell workflow." } },
                    { type = "heading", id = "ai_h_2026_01_09_additional_content", level = 2, text = "Additional Content" },
                    { type = "bullet_list", items = { "**New dialog entries** – Added several new dialog lines to enrich trader interactions, providing more context and flavor during trading conversations." } },
                },
            },
            {
                id = "2026_01_08",
                chapterId = "release_notes",
                title = "2026-01-08",
                keywords = { "update", "release", "2026-01-08" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_08", level = 1, text = "Updates for 2026-01-08" },
                    { type = "heading", id = "ai_h_2026_01_08_trader_ui_enhancements", level = 2, text = "Trader UI Enhancements" },
                    { type = "bullet_list", items = { "Added dynamic portraits for traders, giving each vendor a unique visual identity.", "Integrated trader profile images into the UI, allowing players to recognize NPCs at a glance.", "Refactored the Dynamic Trading UI into modular components, improving maintainability and future extensibility.", "Fixed overlapping text issues for trader names and archetypes, and rearranged text placement for clearer readability.", "Implemented temporary image and log display within the trading UI to aid debugging and provide richer visual feedback." } },
                    { type = "heading", id = "ai_h_2026_01_08_dynamic_trading_system_improvements", level = 2, text = "Dynamic Trading System Improvements" },
                    { type = "bullet_list", items = { "Corrected invalid item IDs that previously caused trade failures.", "Replaced placeholder fuel items in the **DT_Fuel** category with actual fuel objects, restoring realistic resource handling.", "Resolved server output display problems when scanning trades in single‑player mode, ensuring logs are visible to the player." } },
                    { type = "heading", id = "ai_h_2026_01_08_event_system_enhancements", level = 2, text = "Event System Enhancements" },
                    { type = "bullet_list", items = { "Updated the event randomization system to include a cooldown mechanism, reducing the likelihood of the same event triggering repeatedly and creating a more varied gameplay experience." } },
                    { type = "heading", id = "ai_h_2026_01_08_configuration_options", level = 2, text = "Configuration Options" },
                    { type = "bullet_list", items = { "Made inflation decay rates configurable, giving server operators finer control over the in‑game economy and price stabilization." } },
                },
            },
            {
                id = "2026_01_07",
                chapterId = "release_notes",
                title = "2026-01-07",
                keywords = { "update", "release", "2026-01-07" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_07", level = 1, text = "Updates for 2026-01-07" },
                    { type = "heading", id = "ai_h_2026_01_07_money_handling_compression", level = 2, text = "Money Handling & Compression" },
                    { type = "bullet_list", items = { "Set the weight of **Base.Money** and **Base.MoneyBundle** to **0**, eliminating inventory encumbrance for cash items.", "Added a **compress/decompress** system that stacks money into compact bundles, reducing clutter and improving performance when handling large sums." } },
                    { type = "heading", id = "ai_h_2026_01_07_wallet_lottery_system", level = 2, text = "Wallet Lottery System" },
                    { type = "bullet_list", items = { "Updated the wallet lottery mechanics to work reliably in both **single‑player** and **multiplayer** sessions, ensuring fair prize distribution across all game modes." } },
                    { type = "heading", id = "ai_h_2026_01_07_global_economy_ui", level = 2, text = "Global Economy UI" },
                    { type = "bullet_list", items = { "Relocated the **Global Economy Statistics** panel to the **sidebar**, providing players with quick, at‑a‑glance access to market trends without disrupting gameplay flow." } },
                    { type = "heading", id = "ai_h_2026_01_07_shop_menu_refresh", level = 2, text = "Shop Menu Refresh" },
                    { type = "bullet_list", items = { "Fixed the shop interface to correctly refresh its contents in **single‑player** mode, preventing stale inventory listings and ensuring accurate transaction options." } },
                    { type = "heading", id = "ai_h_2026_01_07_trading_logic_compatibility", level = 2, text = "Trading Logic Compatibility" },
                    { type = "bullet_list", items = { "Adjusted the scanning and trading algorithms to support **both single‑player and multiplayer** environments, guaranteeing consistent trade behavior regardless of the game mode." } },
                },
            },
            {
                id = "2026_01_06",
                chapterId = "release_notes",
                title = "2026-01-06",
                keywords = { "update", "release", "2026-01-06" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_06", level = 1, text = "Updates for 2026-01-06" },
                    { type = "heading", id = "ai_h_2026_01_06_dynamic_trading_system", level = 2, text = "Dynamic Trading System" },
                    { type = "bullet_list", items = { "Corrected the trader name shown on both the buy and sell interfaces, ensuring players see accurate vendor identification.", "Updated the trade and sell menus to retain the previously selected item when reopening, streamlining repeated transactions.", "Fixed a synchronization issue where the client failed to receive the latest mod data from the server, improving consistency for all players." } },
                },
            },
            {
                id = "2026_01_05",
                chapterId = "release_notes",
                title = "2026-01-05",
                keywords = { "update", "release", "2026-01-05" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_05", level = 1, text = "Updates for 2026-01-05" },
                    { type = "heading", id = "ai_h_2026_01_05_dynamic_trading", level = 2, text = "Dynamic Trading" },
                    { type = "bullet_list", items = { "Relocated all database operations to the server side, enhancing data security and reducing client‑side processing overhead. This change ensures more reliable trade data handling and improves overall game performance." } },
                },
            },
            {
                id = "2026_01_04",
                chapterId = "release_notes",
                title = "2026-01-04",
                keywords = { "update", "release", "2026-01-04" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_04", level = 1, text = "Updates for 2026-01-04" },
                    { type = "heading", id = "ai_h_2026_01_04_dynamic_trading_core_enhancements", level = 2, text = "Dynamic Trading Core Enhancements" },
                    { type = "bullet_list", items = { "**Wallet Lottery System** – Introduced a lottery mechanic that rewards players with random cash bonuses when using their trader wallet, adding an extra layer of excitement to trading activities.", "**Default Value Tweaks** – Adjusted baseline parameters (prices, stock limits, and transaction fees) to improve balance across all trader interactions.", "**New Trader Archetypes** – Added several distinct trader personalities, each with unique inventory pools and pricing strategies, expanding the variety of trading partners.", "**Temporary Trait Integration** – Implemented a provisional trait system that allows traders to possess special characteristics (e.g., “generous” or “stingy”), influencing price negotiations and stock refresh rates." } },
                    { type = "heading", id = "ai_h_2026_01_04_event_system_improvements", level = 2, text = "Event System Improvements" },
                    { type = "bullet_list", items = { "**Expanded Event Catalogue** – Added multiple new event types (e.g., flash sales, market crashes) to keep the trading environment dynamic and unpredictable.", "**Meta & Flash Event Refactor** – Reorganized the underlying meta‑event and flash‑event data structures for cleaner processing and easier future extensions.", "**Sub‑Table Structure Overhaul** – Re‑structured auxiliary data tables to improve lookup speed and reduce memory overhead during event handling.", "**Event Loop Fix** – Resolved a loop issue that prevented certain events from triggering, ensuring all scheduled market events now fire reliably.", "**Event Modification Enhancements** – Extended event effects to include scan‑chance bonuses and refreshed the Info UI to display these new modifiers, giving players clearer feedback on event impacts." } },
                    { type = "heading", id = "ai_h_2026_01_04_user_interface_updates", level = 2, text = "User Interface Updates" },
                    { type = "bullet_list", items = { "**Market Info Button** – Added a dedicated button to the `DynamicTradingTraderListUI` that opens a detailed market overview, helping players make informed purchasing decisions.", "**Sell Window Cleanup** – Hidden items with zero value or designated as “money” from the sell interface, decluttering the UI and preventing accidental sales of worthless goods.", "**Info UI Refresh** – Updated the trader information panels to reflect new event modifiers (e.g., scan chances) and trait influences, delivering real‑time context to players." } },
                    { type = "heading", id = "ai_h_2026_01_04_new_content_items", level = 2, text = "New Content & Items" },
                    { type = "bullet_list", items = { "**Walkie‑Talkie Corpse Spawn** – Implemented a chance for walkie‑talkies to appear when looting corpses, providing an additional source of communication gear for survivors." } },
                    { type = "heading", id = "ai_h_2026_01_04_developer_utilities", level = 2, text = "Developer Utilities" },
                    { type = "bullet_list", items = { "**`extract_tags.bat` Tool** – Added a batch script that automatically extracts item tags for LLM ingestion, streamlining content creation and documentation workflows." } },
                },
            },
            {
                id = "2026_01_03",
                chapterId = "release_notes",
                title = "2026-01-03",
                keywords = { "update", "release", "2026-01-03" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_03", level = 1, text = "Updates for 2026-01-03" },
                    { type = "heading", id = "ai_h_2026_01_03_dynamic_trading_system", level = 2, text = "Dynamic Trading System" },
                    { type = "bullet_list", items = { "**Improved daily reset logic** – Daily limits and the count of traders discovered now reset correctly each day, ensuring players receive fresh trading opportunities without lingering state from previous sessions.", "**Added unique item IDs** – Every tradable item now carries a distinct identifier, enabling more reliable tracking, better inventory synchronization, and future expansion of item‑specific trade rules.", "**Expanded trader archetypes** – Introduced several new trader archetypes, diversifying the pool of merchants and providing players with a broader range of goods, prices, and negotiation styles.", "**Auto‑close trade UI** – The trade interface now automatically closes if the trader walks away, preventing UI hangs and improving overall user experience during dynamic encounters." } },
                },
            },
            {
                id = "2026_01_02",
                chapterId = "release_notes",
                title = "2026-01-02",
                keywords = { "update", "release", "2026-01-02" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_02", level = 1, text = "Updates for 2026-01-02" },
                    { type = "heading", id = "ai_h_2026_01_02_core_trading_mechanics", level = 2, text = "Core Trading Mechanics" },
                    { type = "bullet_list", items = { "**Implemented daily scanning constraint for traders** – prevents traders from being scanned more than once per in‑game day, reducing exploitation and balancing supply cycles.", "**Added support for multiple trader instances with weighted item chances** – allows several independent trader NPCs, each with configurable rarity tables, enriching variety and replayability.", "**Reimplemented the buy/sell category system** – restores proper categorisation of items, making it easier for players to locate and trade specific goods." } },
                    { type = "heading", id = "ai_h_2026_01_02_user_interface_enhancements", level = 2, text = "User Interface Enhancements" },
                    { type = "bullet_list", items = { "**Integrated a Scan button directly into the trader UI** – gives players a clear, one‑click way to initiate a scanner scan without leaving the interface.", "**Automatic window closure when the player moves away or communication devices are turned off** – prevents lingering UI windows, reduces screen clutter, and avoids unintended interactions." } },
                    { type = "heading", id = "ai_h_2026_01_02_logging_system", level = 2, text = "Logging System" },
                    { type = "bullet_list", items = { "**Added a dedicated log system for the trader network** – records trade actions and scanner events, providing players with a clear transaction history.", "**Made the system log un‑scrollable and limited its size** – eliminates item overflow bugs and keeps the log performant and readable." } },
                    { type = "heading", id = "ai_h_2026_01_02_multiplayer_data_synchronization", level = 2, text = "Multiplayer & Data Synchronization" },
                    { type = "bullet_list", items = { "**Improved multiplayer synchronization by routing trader data through server commands** – ensures consistent trader states across clients, reducing desync issues in co‑op sessions." } },
                    { type = "heading", id = "ai_h_2026_01_02_communication_requirements", level = 2, text = "Communication Requirements" },
                    { type = "bullet_list", items = { "**Required ham radio or walkie‑talkie usage before accessing trader stores** – adds a realistic communication step, encouraging players to maintain functional radio equipment before trading." } },
                    { type = "heading", id = "ai_h_2026_01_02_miscellaneous_fixes", level = 2, text = "Miscellaneous Fixes" },
                    { type = "bullet_list", items = { "**Corrected invalid sandbox‑option syntax** – restores proper loading of sandbox settings.", "**Fixed item selection to properly re‑select the previously purchased item** – improves UI continuity after a trade." } },
                },
            },
            {
                id = "2026_01_01",
                chapterId = "release_notes",
                title = "2026-01-01",
                keywords = { "update", "release", "2026-01-01" },
                blocks = {
                    { type = "heading", id = "heading_2026_01_01", level = 1, text = "Updates for 2026-01-01" },
                    { type = "heading", id = "ai_h_2026_01_01_dynamic_trading_new_items", level = 2, text = "Dynamic Trading – New Items" },
                    { type = "bullet_list", items = { "Added a range of additional items to the trading catalog, expanding the variety of goods players can buy and sell.", "Introduced a temporary placeholder set of items for testing purposes, allowing developers to evaluate balance and pricing before final implementation.", "Impact:* These additions enrich the in‑game economy, giving players more options for bartering and increasing the depth of the trading experience." } },
                },
            },
            {
                id = "2025_12_31",
                chapterId = "release_notes",
                title = "2025-12-31",
                keywords = { "update", "release", "2025-12-31" },
                blocks = {
                    { type = "heading", id = "heading_2025_12_31", level = 1, text = "Updates for 2025-12-31" },
                    { type = "heading", id = "repo_dynamictrading_2025_12_31", level = 2, text = "DynamicTrading" },
                    { type = "bullet_list", items = { "refactor: remove unused files", "feat: implement dynamic sell system", "feat: implement buy button", "feat:  update the drawListItem function to include Text Truncation Logic", "feat: when the daily reset timer triggers, force close the UI if it is open", "fix: enforce a Minimum Quantity of 1 for any item that gets selected for the shelf.", "refactor: compress the config items into an Item definitions", "feat: populate DT_Household data", "feat: populate DT_Electronics.lua data", "feat: populate DT_Clothing.lua data", "feat: populate DT_Ammo.lua data", "feat: update workshop details", "feat: reorganized configs into different folders" } },
                },
            },
            {
                id = "hall_of_fame",
                chapterId = "release_notes",
                title = "Hall of Fame",
                keywords = {  },
                blocks = {
                    { type = "supporter_carousel", title = "Hall of Fame Donators", autoplayMs = 4000, currencySymbol = "$", thankYouText = "", supporters = { { id = "summer", name = "Summer", totalDonation = 20.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png", supportMessage = "Love your mod, thank you for sharing your creation with the community, we appreciate you!", active = true }, { id = "amikcze", name = "Amikcze", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_fb22414ddf.png", supportMessage = "Thank you for the best trading mod on Zomboid! Don't bother with the people who can't read descriptions. Your vision for the mod is amazing, and the real fans appreciate the hard work. Take care of yourself first! Hopefully, we will see your vision come to life!", active = true }, { id = "dremons", name = "Dremons", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_5e4eff3fde.png", supportMessage = "Greetings from Brazil", active = true }, { id = "psy", name = "Psy", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_46a120b30e.png", supportMessage = "Thanks for the mod, I'm really enjoying the extra depth and purpose it gives to the game. Just started my first run with the colony add-on!", active = true }, { id = "supporter_4", name = "ДанилоМироненко", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_1b927e850e.png", supportMessage = "I sent a donation and wanted to suggest improving price balance, as some values feel inconsistent.\n\nThanks for your work!", active = true } } },
                },
            },
        },
    })
end
