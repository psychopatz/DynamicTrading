-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_03_16",
--   "module": "DynamicTradingV2",
--   "title": "Update: 02/13 - 03/16",
--   "description": "Factions, Quests, and a Trading Revolution. Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches. — Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 5,
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
--           "id": "item_item_2026_03_15_dynamictradingv2",
--           "level": 2,
--           "text": "New Reputation System and Faction Tracking"
--         },
--         {
--           "type": "paragraph",
--           "text": "- A **new reputation system** now influences trader dialogue and tracks your trade value with NPCs.\n- Faction information windows are updated to better track player killers and NPC death details.\n- NPC idle animations are standardized with a new trade bat animation added for interactions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now react to your actions with a dynamic reputation system and improved faction data."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_14_dynamictradingv2",
--           "level": 2,
--           "text": "Enhanced NPC Behavior and Dialogue Systems"
--         },
--         {
--           "type": "paragraph",
--           "text": "* NPCs feature improved stationary behaviors with better player detection and interaction poses.\n* **Overhead health bars and names** are now visible for all NPCs to track their status easily.\n* Ambient dialogue is fully modularized with client-side display and configurable delays.\n* NPC movement speeds are now controlled via global settings instead of individual files."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now interact more naturally with players and display health information clearly."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_11_dynamictradingv2",
--           "level": 2,
--           "text": "Radar Discovery, NPC Metadata & Trading Refactor"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Unified radio and radar discovery data while moving NPC trading options to a shared configuration.\n- **Client-side NPC metadata caching** now populates the global list with discovered details from radar.\n- Added debug tools for wiping data and spawning items via the PsychopatzDebugServer."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamlines NPC discovery and centralizes trading configuration for a smoother gameplay experience."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_04_dynamictradingv2",
--           "level": 2,
--           "text": "Quest System Added to Dynamic Trading"
--         },
--         {
--           "type": "paragraph",
--           "text": "* A new **quest system** is now active within the Dynamic Trading framework.\n* Complete specific trading objectives to earn unique rewards and progression."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now accept and complete specific trading quests for rewards."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_27_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading NPC Lifecycle System"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Implemented a new manager system** to handle NPC creation, registration, and unique identification.\n- Added support for NPC respawn logic and proper save/load functionality for persistent worlds.\n- Optimized tick processing to ensure smooth NPC behavior during trading activities."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enables robust NPC management for dynamic trading interactions."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_14_dynamictradingv2",
--           "level": 2,
--           "text": "Market Panel Fixes and New Economic Features"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed text formatting and scrolling issues** within the market panel for better usability.\n- Added a new tab to track **inflation and deflation trends** affecting the economy.\n- Introduced a faction events summary window with dedicated sub-tabs for easy navigation."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves interface bugs while adding inflation tracking and faction event summaries."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_13_dynamictradingv2",
--           "level": 2,
--           "text": "Enhanced NPC Profiles and Faction Interface"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New NPC profile panel** provides detailed character information at a glance.\n- **Dedicated faction UI** with tabbed navigation streamlines group management.\n- **Auto-resizing fonts** ensure text remains readable when scaling the interface."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now view detailed NPC profiles and manage factions through a dedicated, scalable UI."
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
--           "id": "item_item_2026_03_13_dynamictradingv2",
--           "level": 2,
--           "text": "Updates for 2026-03-13"
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
--           "id": "item_item_2026_03_12_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading Enhancements and NPC Stability"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Prevents duplicate NPCs from spawning and stops redundant trade requests.\n- **Optimized NPC respawn logic** to check only perimeter squares for efficiency.\n- Added log filtering by level and system to the debug console for easier troubleshooting.\n- Refined overall trading, economy systems, and item definitions for better balance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Smoother trading interactions with improved NPC behavior and better debug tools."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_03_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading V2 Compatibility Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed compatibility issues to ensure V2 behaves identically to V1.\n- Resolved errors that could occur when switching between trading versions.\n- Ensured stable trading mechanics for all existing save files."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Restores full functionality for players using the previous version of the trading system."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_02_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading V2 Fixes and Linux Support"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed invalid formatting issues** in the Dynamic Trading V1 system to prevent errors.\n- Improved compatibility to ensure the mod functions correctly on **Linux operating systems**."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves critical formatting errors and enables the mod to run on Linux systems."
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
--           "id": "item_item_2026_03_10_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Visual Consistency and Data Cleanup"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Unified NPC visual generation to ensure consistent looks and identities across sessions.\n- Added safety checks for mod data to prevent crashes in global event listeners.\n- Renamed internal data structures for better clarity and easier future maintenance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Improves NPC appearance stability and fixes potential data errors during gameplay."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_08_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading NPC Idle Animation Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Trading NPCs now cycle through **diverse new idle animations** instead of repeating generic states.\n- Updated animation logic ensures NPCs display natural movement while waiting for player interaction."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Trading NPCs now display varied and realistic idle behaviors to enhance immersion."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_16_dynamictradingv2",
--           "level": 2,
--           "text": "Trading System Configuration Refactor"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Decoupled the trading configuration UI to prevent interface lag during complex trades.\n- Streamlined internal logic for smoother interaction with the trading menu.\n- Enhanced overall system stability when modifying trade settings in-game."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Improves the stability and responsiveness of the dynamic trading interface."
--         }
--       ]
--     },
--     {
--       "id": "cat_performance",
--       "chapter_id": "release_notes",
--       "title": "Performance",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Performance Highlights",
--           "text": "Optimizes NPC lifecycle management and rendering to ensure smoother gameplay in populated areas."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_03_07_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Optimization, Visuals, and Trading V2"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Optimized NPC management** using spatial hashing to reduce lag and improve respawn logic.\n- Added **archetype-specific hair and beard styles** with seed-based generation for unique NPC looks.\n- Implemented distance-aware networking to **reduce bandwidth usage** during Dynamic Trading V2.\n- Reworked debug UIs for easier faction administration, stock management, and location tracking."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances NPC performance, visual variety, and trading efficiency while refining debug tools."
--         }
--       ]
--     },
--     {
--       "id": "cat_balance",
--       "chapter_id": "release_notes",
--       "title": "Balance",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Balance Highlights",
--           "text": "Adjusts economic inflation mechanics and pricing structures to create a more realistic market environment."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_15_dynamictradingv2",
--           "level": 2,
--           "text": "Trading System Refactor and Inflation Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Moved NPC and faction definitions to a shared system to improve stability.\n- Fixed critical inflation mechanics that were causing economic imbalance.\n- Addressed connectivity issues affecting the Dynamic Trading V2 system."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves trading connectivity issues and corrects inflation mechanics for a stable economy."
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
--           "id": "item_item_2026_03_16_dynamictradingv2",
--           "level": 2,
--           "text": "Incapacitated NPC System & Trading Refinements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added **incapacitated NPC behavior** with distinct pulsing health bars and integrated state management.\n- Refined trading window logic and dynamically refreshed faction info within the conversation UI.\n- Secured debug features behind admin access checks and added configuration for debug logging."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced NPC realism with new incapacitation states and improved trading interface stability."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_03_16", {
        title = "Update: 02/13 - 03/16",
        description = "Factions, Quests, and a Trading Revolution. Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches. — Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
        sortOrder = 5,
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
                    { type = "heading", id = "item_item_2026_03_15_dynamictradingv2", level = 2, text = "New Reputation System and Faction Tracking" },
                    { type = "paragraph", text = "- A **new reputation system** now influences trader dialogue and tracks your trade value with NPCs.\n- Faction information windows are updated to better track player killers and NPC death details.\n- NPC idle animations are standardized with a new trade bat animation added for interactions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now react to your actions with a dynamic reputation system and improved faction data." },
                    { type = "heading", id = "item_item_2026_03_14_dynamictradingv2", level = 2, text = "Enhanced NPC Behavior and Dialogue Systems" },
                    { type = "paragraph", text = "* NPCs feature improved stationary behaviors with better player detection and interaction poses.\n* **Overhead health bars and names** are now visible for all NPCs to track their status easily.\n* Ambient dialogue is fully modularized with client-side display and configurable delays.\n* NPC movement speeds are now controlled via global settings instead of individual files." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now interact more naturally with players and display health information clearly." },
                    { type = "heading", id = "item_item_2026_03_11_dynamictradingv2", level = 2, text = "Radar Discovery, NPC Metadata & Trading Refactor" },
                    { type = "paragraph", text = "- Unified radio and radar discovery data while moving NPC trading options to a shared configuration.\n- **Client-side NPC metadata caching** now populates the global list with discovered details from radar.\n- Added debug tools for wiping data and spawning items via the PsychopatzDebugServer." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamlines NPC discovery and centralizes trading configuration for a smoother gameplay experience." },
                    { type = "heading", id = "item_item_2026_03_04_dynamictradingv2", level = 2, text = "Quest System Added to Dynamic Trading" },
                    { type = "paragraph", text = "* A new **quest system** is now active within the Dynamic Trading framework.\n* Complete specific trading objectives to earn unique rewards and progression." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now accept and complete specific trading quests for rewards." },
                    { type = "heading", id = "item_item_2026_02_27_dynamictradingv2", level = 2, text = "Dynamic Trading NPC Lifecycle System" },
                    { type = "paragraph", text = "- **Implemented a new manager system** to handle NPC creation, registration, and unique identification.\n- Added support for NPC respawn logic and proper save/load functionality for persistent worlds.\n- Optimized tick processing to ensure smooth NPC behavior during trading activities." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enables robust NPC management for dynamic trading interactions." },
                    { type = "heading", id = "item_item_2026_02_14_dynamictradingv2", level = 2, text = "Market Panel Fixes and New Economic Features" },
                    { type = "paragraph", text = "- **Fixed text formatting and scrolling issues** within the market panel for better usability.\n- Added a new tab to track **inflation and deflation trends** affecting the economy.\n- Introduced a faction events summary window with dedicated sub-tabs for easy navigation." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves interface bugs while adding inflation tracking and faction event summaries." },
                    { type = "heading", id = "item_item_2026_02_13_dynamictradingv2", level = 2, text = "Enhanced NPC Profiles and Faction Interface" },
                    { type = "paragraph", text = "- **New NPC profile panel** provides detailed character information at a glance.\n- **Dedicated faction UI** with tabbed navigation streamlines group management.\n- **Auto-resizing fonts** ensure text remains readable when scaling the interface." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now view detailed NPC profiles and manage factions through a dedicated, scalable UI." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical multiplayer stability issues, Linux compatibility bugs, and various trading interface glitches." },
                    { type = "heading", id = "item_item_2026_03_13_dynamictradingv2", level = 2, text = "Updates for 2026-03-13" },
                    { type = "paragraph", text = "Summary generated from commit activity for this day." },
                    { type = "callout", tone = "success", title = "Impact", text = "Incremental improvements and fixes." },
                    { type = "heading", id = "item_item_2026_03_12_dynamictradingv2", level = 2, text = "Dynamic Trading Enhancements and NPC Stability" },
                    { type = "paragraph", text = "- Prevents duplicate NPCs from spawning and stops redundant trade requests.\n- **Optimized NPC respawn logic** to check only perimeter squares for efficiency.\n- Added log filtering by level and system to the debug console for easier troubleshooting.\n- Refined overall trading, economy systems, and item definitions for better balance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Smoother trading interactions with improved NPC behavior and better debug tools." },
                    { type = "heading", id = "item_item_2026_03_03_dynamictradingv2", level = 2, text = "Dynamic Trading V2 Compatibility Fixes" },
                    { type = "paragraph", text = "- Fixed compatibility issues to ensure V2 behaves identically to V1.\n- Resolved errors that could occur when switching between trading versions.\n- Ensured stable trading mechanics for all existing save files." },
                    { type = "callout", tone = "success", title = "Impact", text = "Restores full functionality for players using the previous version of the trading system." },
                    { type = "heading", id = "item_item_2026_03_02_dynamictradingv2", level = 2, text = "Dynamic Trading V2 Fixes and Linux Support" },
                    { type = "paragraph", text = "- **Fixed invalid formatting issues** in the Dynamic Trading V1 system to prevent errors.\n- Improved compatibility to ensure the mod functions correctly on **Linux operating systems**." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves critical formatting errors and enables the mod to run on Linux systems." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Improves the trading UI with better configuration options, unified NPC visuals, and refined radio scanning tools." },
                    { type = "heading", id = "item_item_2026_03_10_dynamictradingv2", level = 2, text = "NPC Visual Consistency and Data Cleanup" },
                    { type = "paragraph", text = "- Unified NPC visual generation to ensure consistent looks and identities across sessions.\n- Added safety checks for mod data to prevent crashes in global event listeners.\n- Renamed internal data structures for better clarity and easier future maintenance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Improves NPC appearance stability and fixes potential data errors during gameplay." },
                    { type = "heading", id = "item_item_2026_03_08_dynamictradingv2", level = 2, text = "Dynamic Trading NPC Idle Animation Overhaul" },
                    { type = "paragraph", text = "- Trading NPCs now cycle through **diverse new idle animations** instead of repeating generic states.\n- Updated animation logic ensures NPCs display natural movement while waiting for player interaction." },
                    { type = "callout", tone = "success", title = "Impact", text = "Trading NPCs now display varied and realistic idle behaviors to enhance immersion." },
                    { type = "heading", id = "item_item_2026_02_16_dynamictradingv2", level = 2, text = "Trading System Configuration Refactor" },
                    { type = "paragraph", text = "- Decoupled the trading configuration UI to prevent interface lag during complex trades.\n- Streamlined internal logic for smoother interaction with the trading menu.\n- Enhanced overall system stability when modifying trade settings in-game." },
                    { type = "callout", tone = "success", title = "Impact", text = "Improves the stability and responsiveness of the dynamic trading interface." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimizes NPC lifecycle management and rendering to ensure smoother gameplay in populated areas." },
                    { type = "heading", id = "item_item_2026_03_07_dynamictradingv2", level = 2, text = "NPC Optimization, Visuals, and Trading V2" },
                    { type = "paragraph", text = "- **Optimized NPC management** using spatial hashing to reduce lag and improve respawn logic.\n- Added **archetype-specific hair and beard styles** with seed-based generation for unique NPC looks.\n- Implemented distance-aware networking to **reduce bandwidth usage** during Dynamic Trading V2.\n- Reworked debug UIs for easier faction administration, stock management, and location tracking." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances NPC performance, visual variety, and trading efficiency while refining debug tools." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Adjusts economic inflation mechanics and pricing structures to create a more realistic market environment." },
                    { type = "heading", id = "item_item_2026_02_15_dynamictradingv2", level = 2, text = "Trading System Refactor and Inflation Fixes" },
                    { type = "paragraph", text = "- Moved NPC and faction definitions to a shared system to improve stability.\n- Fixed critical inflation mechanics that were causing economic imbalance.\n- Addressed connectivity issues affecting the Dynamic Trading V2 system." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves trading connectivity issues and corrects inflation mechanics for a stable economy." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Includes internal debug script updates and data cleanup to support future development." },
                    { type = "heading", id = "item_item_2026_03_16_dynamictradingv2", level = 2, text = "Incapacitated NPC System & Trading Refinements" },
                    { type = "paragraph", text = "- Added **incapacitated NPC behavior** with distinct pulsing health bars and integrated state management.\n- Refined trading window logic and dynamically refreshed faction info within the conversation UI.\n- Secured debug features behind admin access checks and added configuration for debug logging." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced NPC realism with new incapacitation states and improved trading interface stability." },
                },
            },
        },
    })
end
