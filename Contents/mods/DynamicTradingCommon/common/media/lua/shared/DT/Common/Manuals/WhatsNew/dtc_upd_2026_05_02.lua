-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_05_02",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 04/21 - 05/02",
--   "description": "Trader Overhaul, Bandit Raids, and New Quests. Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems. — Streamlined inventory management and cleaned up trader quest offer interfaces for better usability.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 12,
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
--       "description": "Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems."
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
--           "type": "callout",
--           "tone": "info",
--           "title": "Features Highlights",
--           "text": "Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_29_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading UI Overhaul and New Scanner Features"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The Manual UI now features improved layout responsiveness and dynamic image scaling for better readability.\n- **New radio scanner scan stats UI** and expanded trader contact recruitment options have been added.\n- Fixed collapsible manual logic and standardized item definitions across all trading modules.\n- Implemented a new archetype specialization system to allow flexible stock generation and NPC configuration."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced trading interface responsiveness and added new radio scanner mechanics for better gameplay immersion."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_28_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI & Bandit AI Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Revamped conversation UI** now includes faction rumors, navigation history, and responsive layout controls.\n- Bandits gain new roaming logic, hostile trade cycles, and are hidden from radar discovery.\n- Added support for escort jobs, gift transactions, and automatic dialogue triggers for new signals.\n- Improved reputation calculations with server-side bias sync and generalized emote interactions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances NPC interactions with new conversation systems, bandit behaviors, and trading mechanics."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_27_dynamictradingcommon",
--           "level": 2,
--           "text": "Bandit Raids, Tribute System & Combat AI Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "* **New bandit faction** introduces tiered tribute gifting, ambush mechanics, and distinct raid states.\n* NPC combat AI is smarter with improved line-of-sight tracking and off-screen despawn logic.\n* Radio scanner UI updated to show mission viewer buttons and differentiate bandits from raiders.\n* Bandit mechanics are now restricted to the CurrencyExpanded mod for better population balance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players now face dynamic bandit raids with a new tribute system and smarter enemy AI."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_25_dynamictradingcommon",
--           "level": 2,
--           "text": "Radio Quests and Escort Mechanics"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Radio scanner now offers quests** and includes a new focus mode for better targeting.\n- Added a dedicated Trader Help Escort job to guide NPCs without conflicting orders.\n- Removed scan difficulty scaling and streamlined the underlying quest UI logic."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Adds new radio-activated quests with dedicated escort jobs and improved NPC interaction logic."
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
--           "text": "Streamlined inventory management and cleaned up trader quest offer interfaces for better usability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_26_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading System Enhancements and UI Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Introduced a new system to better rank item usability during trading interactions.\n- Added marquee text utility to support scrolling labels in user interface elements."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Improved item evaluation logic and added scrolling text support for trade menus."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_24_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Trader Quest Offers & UI Cleanup"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Traders now offer **quests via new dialogue** options to expand gameplay interactions.\n- Quest UI tabs are now hidden when no quests are available to reduce clutter.\n- Debug access is restricted to admins and unused faction buttons have been removed."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders can now offer quests through new dialogue options while the UI is streamlined for better clarity."
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
--           "text": "Optimized trading calculations and UI rendering to ensure smooth gameplay during complex interactions."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_30_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Performance & UI Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Significant performance boost** for manual trading via optimized search indexing and memory management.\n- Added new NoBudget dialogue options allowing traders to bypass budget checks during transactions.\n- Enhanced UI with manual filtering, better mod name resolution, and refined interaction logic.\n- Updated documentation includes comprehensive manuals and the latest release notes."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now operate faster with new budget options and improved interface filtering."
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
--           "text": "Adjusted colony wealth settings and trading economics to create a more challenging and realistic survival loop."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_21_dynamictradingcommon",
--           "level": 2,
--           "text": "Colony Wealth Settings & Trading Refactor"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new sandbox option to adjust **colony wealth** for better game balance.\n- Refactored internal trading code names to improve mod stability and clarity."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now control colony wealth through a new sandbox option."
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
--           "text": "Included internal refactoring of the trading core to support future expansion and improved mod stability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_05_01_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader UI Overhaul and Inventory Optimization"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Improved trader interface** with new navigation blocks, a compact carousel for supporters, and synchronized stock updates.\n- Added radio scan animation fixes and validated radar operational states for better visual feedback.\n- Implemented inventory pre-warming and asynchronous loading to reduce stutter during trading sessions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced trader interfaces with smoother loading and new supporter features."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_05_02", {
        title = "Update: 04/21 - 05/02",
        description = "Trader Overhaul, Bandit Raids, and New Quests. Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems. — Streamlined inventory management and cleaned up trader quest offer interfaces for better usability.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 12,
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
                description = "Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Features Highlights", text = "Introduces a complete trading UI overhaul, radio scanner, bandit raids, escort jobs, and NPC recruitment systems." },
                    { type = "heading", id = "item_item_2026_04_29_dynamictradingcommon", level = 2, text = "Trading UI Overhaul and New Scanner Features" },
                    { type = "paragraph", text = "- The Manual UI now features improved layout responsiveness and dynamic image scaling for better readability.\n- **New radio scanner scan stats UI** and expanded trader contact recruitment options have been added.\n- Fixed collapsible manual logic and standardized item definitions across all trading modules.\n- Implemented a new archetype specialization system to allow flexible stock generation and NPC configuration." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced trading interface responsiveness and added new radio scanner mechanics for better gameplay immersion." },
                    { type = "heading", id = "item_item_2026_04_28_dynamictradingcommon", level = 2, text = "Dynamic Trading UI & Bandit AI Overhaul" },
                    { type = "paragraph", text = "- **Revamped conversation UI** now includes faction rumors, navigation history, and responsive layout controls.\n- Bandits gain new roaming logic, hostile trade cycles, and are hidden from radar discovery.\n- Added support for escort jobs, gift transactions, and automatic dialogue triggers for new signals.\n- Improved reputation calculations with server-side bias sync and generalized emote interactions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances NPC interactions with new conversation systems, bandit behaviors, and trading mechanics." },
                    { type = "heading", id = "item_item_2026_04_27_dynamictradingcommon", level = 2, text = "Bandit Raids, Tribute System & Combat AI Overhaul" },
                    { type = "paragraph", text = "* **New bandit faction** introduces tiered tribute gifting, ambush mechanics, and distinct raid states.\n* NPC combat AI is smarter with improved line-of-sight tracking and off-screen despawn logic.\n* Radio scanner UI updated to show mission viewer buttons and differentiate bandits from raiders.\n* Bandit mechanics are now restricted to the CurrencyExpanded mod for better population balance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players now face dynamic bandit raids with a new tribute system and smarter enemy AI." },
                    { type = "heading", id = "item_item_2026_04_25_dynamictradingcommon", level = 2, text = "Radio Quests and Escort Mechanics" },
                    { type = "paragraph", text = "- **Radio scanner now offers quests** and includes a new focus mode for better targeting.\n- Added a dedicated Trader Help Escort job to guide NPCs without conflicting orders.\n- Removed scan difficulty scaling and streamlined the underlying quest UI logic." },
                    { type = "callout", tone = "success", title = "Impact", text = "Adds new radio-activated quests with dedicated escort jobs and improved NPC interaction logic." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Streamlined inventory management and cleaned up trader quest offer interfaces for better usability." },
                    { type = "heading", id = "item_item_2026_04_26_dynamictradingcommon", level = 2, text = "Trading System Enhancements and UI Updates" },
                    { type = "paragraph", text = "- Introduced a new system to better rank item usability during trading interactions.\n- Added marquee text utility to support scrolling labels in user interface elements." },
                    { type = "callout", tone = "success", title = "Impact", text = "Improved item evaluation logic and added scrolling text support for trade menus." },
                    { type = "heading", id = "item_item_2026_04_24_dynamictradingcommon", level = 2, text = "NPC Trader Quest Offers & UI Cleanup" },
                    { type = "paragraph", text = "- Traders now offer **quests via new dialogue** options to expand gameplay interactions.\n- Quest UI tabs are now hidden when no quests are available to reduce clutter.\n- Debug access is restricted to admins and unused faction buttons have been removed." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders can now offer quests through new dialogue options while the UI is streamlined for better clarity." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimized trading calculations and UI rendering to ensure smooth gameplay during complex interactions." },
                    { type = "heading", id = "item_item_2026_04_30_dynamictradingcommon", level = 2, text = "Dynamic Trading Performance & UI Enhancements" },
                    { type = "paragraph", text = "- **Significant performance boost** for manual trading via optimized search indexing and memory management.\n- Added new NoBudget dialogue options allowing traders to bypass budget checks during transactions.\n- Enhanced UI with manual filtering, better mod name resolution, and refined interaction logic.\n- Updated documentation includes comprehensive manuals and the latest release notes." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now operate faster with new budget options and improved interface filtering." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Adjusted colony wealth settings and trading economics to create a more challenging and realistic survival loop." },
                    { type = "heading", id = "item_item_2026_04_21_dynamictradingcommon", level = 2, text = "Colony Wealth Settings & Trading Refactor" },
                    { type = "paragraph", text = "- Added a new sandbox option to adjust **colony wealth** for better game balance.\n- Refactored internal trading code names to improve mod stability and clarity." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now control colony wealth through a new sandbox option." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Included internal refactoring of the trading core to support future expansion and improved mod stability." },
                    { type = "heading", id = "item_item_2026_05_01_dynamictradingcommon", level = 2, text = "Trader UI Overhaul and Inventory Optimization" },
                    { type = "paragraph", text = "- **Improved trader interface** with new navigation blocks, a compact carousel for supporters, and synchronized stock updates.\n- Added radio scan animation fixes and validated radar operational states for better visual feedback.\n- Implemented inventory pre-warming and asynchronous loading to reduce stutter during trading sessions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced trader interfaces with smoother loading and new supporter features." },
                },
            },
        },
    })
end
