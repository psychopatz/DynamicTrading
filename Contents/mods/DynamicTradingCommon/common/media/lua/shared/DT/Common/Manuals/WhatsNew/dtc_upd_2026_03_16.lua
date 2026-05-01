-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_03_16",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 02/13 - 03/16",
--   "description": "Factions, Quests, and a Trading Revolution. Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches. — Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 8,
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
--       "description": "Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches."
--     }
--   ],
--   "pages": [
--     {
--       "id": "cat_features",
--       "chapter_id": "release_notes",
--       "title": "Features",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_15_dynamictradingcommon",
--           "level": 2,
--           "text": "New Trading System and Faction Reputation"
--         },
--         {
--           "type": "paragraph",
--           "text": "* A **new reputation system** now influences trader dialogue, trade values, and NPC interactions.\n* Player killers are tracked, affecting how factions perceive you and display information.\n* Food categories and item types have been restructured to support future trading features.\n* UI logic updated to merge cached and live faction data for more accurate information."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now react to your reputation and faction standing with dynamic dialogue and prices."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_14_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Behavior Overhaul and Dialogue System Update"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs now detect player presence to manage idle, guard, and trading states more intelligently.\n- **New modular dialogue system** allows for configurable delays and better ambient conversations.\n- NPC movement speeds are now centrally configured for easier global adjustments.\n- Departure logic during trading and interactions has been significantly enhanced."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now react more naturally to players and offer improved trading interactions."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_13_dynamictradingcommon",
--           "level": 2,
--           "text": "Enhanced NPC Trading and Pathfinding"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs now have dedicated behaviors for trading, idling, and leaving shops.\n- Pathfinding includes **stuck detection** to prevent agents from getting trapped.\n- State transitions are refined for smoother interactions during trade sequences."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now handle trading interactions more reliably with improved movement logic."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_12_dynamictradingcommon",
--           "level": 2,
--           "text": "Advanced Trading Console & Item Management"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added log filtering by level and system to the debug console for easier troubleshooting.\n- Implemented **advanced item filtering** and a new dedicated page for managing trade inventory.\n- Refactored print statements into a global form to streamline console output."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances mod debugging capabilities and adds a dedicated interface for managing trade items."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_07_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Appearance Overhaul and Event System Upgrade"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs now generate with **archetype-specific hair, beards, and colors** for more distinct and consistent visuals.\n- Smooth NPC movement is achieved through new position interpolation logic.\n- The event system now supports **multi-flash stacking** and includes expanded sandbox controls.\n- Debug tools for faction administration and merchant stock have been reorganized for easier use."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now feature unique, consistent looks and the event system supports complex multi-stage scenarios."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_15_dynamictradingcommon",
--           "level": 2,
--           "text": "Multiplayer Stability and Faction System Update"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Resolved critical connectivity issues affecting multiplayer sessions and radio faction management.\n- Moved NPC and faction definitions to a common layer to **enhance multiplayer stability**.\n- Streamlined core systems to prevent future sync errors between players and servers."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Significantly improves connection reliability and prepares the faction system for future multiplayer features."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_13_dynamictradingcommon",
--           "level": 2,
--           "text": "Dedicated Faction Trading Interface Added"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Introduced a **dedicated faction UI** to streamline trading interactions with specific groups.\n- Improved navigation and clarity when managing relationships and exchanges with factions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now trade directly with specific factions using a new UI."
--         }
--       ]
--     },
--     {
--       "id": "cat_fixes",
--       "chapter_id": "release_notes",
--       "title": "Fixes",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Fixes Highlights",
--           "text": "Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_05_dynamictradingcommon",
--           "level": 2,
--           "text": "Updates for 2026-03-05"
--         },
--         {
--           "type": "paragraph",
--           "text": "Summary generated from commit activity for this day."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Incremental improvements and fixes."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_04_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading, Quests & Item Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Implemented a new quest system** to expand gameplay objectives and rewards.\n- Added dynamic weight reduction logic for traded packages to balance inventory.\n- Fixed invalid item IDs and updated formatting for better compatibility.\n- Refactored trading archetypes to improve stability and future updates."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now complete quests and trade packages with dynamic weight adjustments."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_03_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Version 2 Compatibility Fix"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed critical compatibility issues between V1 and V2 trading systems.\n- Ensures **older mod versions** can now trade seamlessly with the latest update.\n- Resolved parity errors that previously blocked transactions between versions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Restores full trading functionality for players using older mod versions."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_02_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading System Fixes and Linux Support"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed invalid format errors** in the V1 trading system to prevent crashes.\n- Improved overall compatibility and performance for Linux players."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves trading format errors and improves stability on Linux systems."
--         }
--       ]
--     },
--     {
--       "id": "cat_qol",
--       "chapter_id": "release_notes",
--       "title": "QoL",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "QoL Highlights",
--           "text": "Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_11_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading UI Overhaul and Radio Refinement"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Trader availability now checks roster status** and return times with clearer departure messages.\n- Unified radio and radar data management alongside server-authoritative network handling for commands.\n- Removed legacy V1 trading wrappers and centralized debug tools for easier server maintenance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamlined trader interactions and unified radio mechanics for a smoother survival experience."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_10_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Visuals Unified and Data Refactored"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Unified NPC visual generation under a single identity seed to ensure consistent looks.\n- Added type checks for ModData to prevent errors in global data listeners.\n- Renamed internal NPC data structures and debugger panels for better clarity."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now share consistent visual generation logic for improved stability and clarity."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_16_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI Refactoring"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Decoupled the configuration UI** to prevent conflicts with other mod windows.\n- Separated the faction info window logic for smoother menu navigation.\n- Optimized internal code structure to reduce potential UI lag."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Improved stability and responsiveness for trading configuration menus."
--         }
--       ]
--     },
--     {
--       "id": "cat_misc",
--       "chapter_id": "release_notes",
--       "title": "Misc",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Misc Highlights",
--           "text": "Includes internal debug script updates and data cleanup to support future development."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_16_dynamictradingcommon",
--           "level": 2,
--           "text": "Incapacitated NPCs, New Items & Pricing Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Wounded NPCs are now **incapacitated** with distinct health bars and unique dialogue options.\n- A new **tag-based pricing system** dynamically adjusts item values across the entire game.\n- Added diverse new containers, medical drugs, clothing, and electronics to loot pools.\n- Refined archetype editors now manage expert tags and wants multipliers for better AI."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now trade with wounded NPCs while enjoying a completely revamped item economy."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_27_dynamictradingcommon",
--           "level": 2,
--           "text": "Debug Script Update for Dynamic Trading"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed the debug server script to ensure it runs correctly.\n- Improves stability for developers testing dynamic trading features."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves issues with the local debug server setup for traders."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_03_16", {
        title = "Update: 02/13 - 03/16",
        description = "Factions, Quests, and a Trading Revolution. Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches. — Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 8,
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
                description = "Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_03_15_dynamictradingcommon", level = 2, text = "New Trading System and Faction Reputation" },
                    { type = "paragraph", text = "* A **new reputation system** now influences trader dialogue, trade values, and NPC interactions.\n* Player killers are tracked, affecting how factions perceive you and display information.\n* Food categories and item types have been restructured to support future trading features.\n* UI logic updated to merge cached and live faction data for more accurate information." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now react to your reputation and faction standing with dynamic dialogue and prices." },
                    { type = "heading", id = "item_item_2026_03_14_dynamictradingcommon", level = 2, text = "NPC Behavior Overhaul and Dialogue System Update" },
                    { type = "paragraph", text = "- NPCs now detect player presence to manage idle, guard, and trading states more intelligently.\n- **New modular dialogue system** allows for configurable delays and better ambient conversations.\n- NPC movement speeds are now centrally configured for easier global adjustments.\n- Departure logic during trading and interactions has been significantly enhanced." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now react more naturally to players and offer improved trading interactions." },
                    { type = "heading", id = "item_item_2026_03_13_dynamictradingcommon", level = 2, text = "Enhanced NPC Trading and Pathfinding" },
                    { type = "paragraph", text = "- NPCs now have dedicated behaviors for trading, idling, and leaving shops.\n- Pathfinding includes **stuck detection** to prevent agents from getting trapped.\n- State transitions are refined for smoother interactions during trade sequences." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now handle trading interactions more reliably with improved movement logic." },
                    { type = "heading", id = "item_item_2026_03_12_dynamictradingcommon", level = 2, text = "Advanced Trading Console & Item Management" },
                    { type = "paragraph", text = "- Added log filtering by level and system to the debug console for easier troubleshooting.\n- Implemented **advanced item filtering** and a new dedicated page for managing trade inventory.\n- Refactored print statements into a global form to streamline console output." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances mod debugging capabilities and adds a dedicated interface for managing trade items." },
                    { type = "heading", id = "item_item_2026_03_07_dynamictradingcommon", level = 2, text = "NPC Appearance Overhaul and Event System Upgrade" },
                    { type = "paragraph", text = "- NPCs now generate with **archetype-specific hair, beards, and colors** for more distinct and consistent visuals.\n- Smooth NPC movement is achieved through new position interpolation logic.\n- The event system now supports **multi-flash stacking** and includes expanded sandbox controls.\n- Debug tools for faction administration and merchant stock have been reorganized for easier use." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now feature unique, consistent looks and the event system supports complex multi-stage scenarios." },
                    { type = "heading", id = "item_item_2026_02_15_dynamictradingcommon", level = 2, text = "Multiplayer Stability and Faction System Update" },
                    { type = "paragraph", text = "- Resolved critical connectivity issues affecting multiplayer sessions and radio faction management.\n- Moved NPC and faction definitions to a common layer to **enhance multiplayer stability**.\n- Streamlined core systems to prevent future sync errors between players and servers." },
                    { type = "callout", tone = "success", title = "Impact", text = "Significantly improves connection reliability and prepares the faction system for future multiplayer features." },
                    { type = "heading", id = "item_item_2026_02_13_dynamictradingcommon", level = 2, text = "Dedicated Faction Trading Interface Added" },
                    { type = "paragraph", text = "- Introduced a **dedicated faction UI** to streamline trading interactions with specific groups.\n- Improved navigation and clarity when managing relationships and exchanges with factions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now trade directly with specific factions using a new UI." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches." },
                    { type = "heading", id = "item_item_2026_03_05_dynamictradingcommon", level = 2, text = "Updates for 2026-03-05" },
                    { type = "paragraph", text = "Summary generated from commit activity for this day." },
                    { type = "callout", tone = "success", title = "Impact", text = "Incremental improvements and fixes." },
                    { type = "heading", id = "item_item_2026_03_04_dynamictradingcommon", level = 2, text = "Dynamic Trading, Quests & Item Fixes" },
                    { type = "paragraph", text = "- **Implemented a new quest system** to expand gameplay objectives and rewards.\n- Added dynamic weight reduction logic for traded packages to balance inventory.\n- Fixed invalid item IDs and updated formatting for better compatibility.\n- Refactored trading archetypes to improve stability and future updates." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now complete quests and trade packages with dynamic weight adjustments." },
                    { type = "heading", id = "item_item_2026_03_03_dynamictradingcommon", level = 2, text = "Dynamic Trading Version 2 Compatibility Fix" },
                    { type = "paragraph", text = "- Fixed critical compatibility issues between V1 and V2 trading systems.\n- Ensures **older mod versions** can now trade seamlessly with the latest update.\n- Resolved parity errors that previously blocked transactions between versions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Restores full trading functionality for players using older mod versions." },
                    { type = "heading", id = "item_item_2026_03_02_dynamictradingcommon", level = 2, text = "Dynamic Trading System Fixes and Linux Support" },
                    { type = "paragraph", text = "- **Fixed invalid format errors** in the V1 trading system to prevent crashes.\n- Improved overall compatibility and performance for Linux players." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves trading format errors and improves stability on Linux systems." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools." },
                    { type = "heading", id = "item_item_2026_03_11_dynamictradingcommon", level = 2, text = "Trading UI Overhaul and Radio Refinement" },
                    { type = "paragraph", text = "- **Trader availability now checks roster status** and return times with clearer departure messages.\n- Unified radio and radar data management alongside server-authoritative network handling for commands.\n- Removed legacy V1 trading wrappers and centralized debug tools for easier server maintenance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamlined trader interactions and unified radio mechanics for a smoother survival experience." },
                    { type = "heading", id = "item_item_2026_03_10_dynamictradingcommon", level = 2, text = "NPC Visuals Unified and Data Refactored" },
                    { type = "paragraph", text = "- Unified NPC visual generation under a single identity seed to ensure consistent looks.\n- Added type checks for ModData to prevent errors in global data listeners.\n- Renamed internal NPC data structures and debugger panels for better clarity." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now share consistent visual generation logic for improved stability and clarity." },
                    { type = "heading", id = "item_item_2026_02_16_dynamictradingcommon", level = 2, text = "Dynamic Trading UI Refactoring" },
                    { type = "paragraph", text = "- **Decoupled the configuration UI** to prevent conflicts with other mod windows.\n- Separated the faction info window logic for smoother menu navigation.\n- Optimized internal code structure to reduce potential UI lag." },
                    { type = "callout", tone = "success", title = "Impact", text = "Improved stability and responsiveness for trading configuration menus." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Includes internal debug script updates and data cleanup to support future development." },
                    { type = "heading", id = "item_item_2026_03_16_dynamictradingcommon", level = 2, text = "Incapacitated NPCs, New Items & Pricing Overhaul" },
                    { type = "paragraph", text = "- Wounded NPCs are now **incapacitated** with distinct health bars and unique dialogue options.\n- A new **tag-based pricing system** dynamically adjusts item values across the entire game.\n- Added diverse new containers, medical drugs, clothing, and electronics to loot pools.\n- Refined archetype editors now manage expert tags and wants multipliers for better AI." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now trade with wounded NPCs while enjoying a completely revamped item economy." },
                    { type = "heading", id = "item_item_2026_02_27_dynamictradingcommon", level = 2, text = "Debug Script Update for Dynamic Trading" },
                    { type = "paragraph", text = "- Fixed the debug server script to ensure it runs correctly.\n- Improves stability for developers testing dynamic trading features." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves issues with the local debug server setup for traders." },
                },
            },
        },
    })
end
