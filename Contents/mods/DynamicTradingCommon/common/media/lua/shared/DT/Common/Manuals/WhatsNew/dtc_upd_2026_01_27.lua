-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_01_27",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 01/19 - 01/27",
--   "description": "Dynamic Trading System Launch and UI Overhaul. Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability. — Updated common libraries and core files to support the new trading architecture.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 4,
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
--       "description": "Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability."
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
--           "id": "item_item_2026_01_25_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading UI Overhaul and Dialogue Expansion"
--         },
--         {
--           "type": "paragraph",
--           "text": "- New trading and radio signal interfaces are now available for use.\n- Added an ask button to the sell window for better transaction control.\n- **Expanded dialogue options** across all NPC archetypes for richer interactions.\n- Includes new icons and organized configuration files for stability."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players gain new trading tools, visual icons, and expanded NPC conversations."
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
--           "text": "Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_26_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading System Launch and Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Initial dynamic trading system** now includes NPC wallets, loot logic, and a new trading UI.\n- Traders are now correctly visible during scans even when the public network is disabled.\n- Player names are logged when a trader is successfully found, aiding in debugging and tracking."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Unlock a fully functional NPC trading economy with new UI and debugging tools."
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
--           "text": "Updated common libraries and core files to support the new trading architecture."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_27_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading Fixes, Wallet Queue & Audio Manager"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed critical trade bugs where non-two-way items could pass and dialogue conflicted with other mods.\n- Introduced a new **open wallet queue system** to manage transaction requests more effectively.\n- Added a centralized AudioManager and Options config manager for improved audio and settings handling.\n- Reorganized portrait and dialogue files into Archetypes folders to fix load order issues."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves trade bugs and adds a new wallet queue system for better trading control."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_01_27", {
        title = "Update: 01/19 - 01/27",
        description = "Dynamic Trading System Launch and UI Overhaul. Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability. — Updated common libraries and core files to support the new trading architecture.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 4,
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
                description = "Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_01_25_dynamictradingcommon", level = 2, text = "Trading UI Overhaul and Dialogue Expansion" },
                    { type = "paragraph", text = "- New trading and radio signal interfaces are now available for use.\n- Added an ask button to the sell window for better transaction control.\n- **Expanded dialogue options** across all NPC archetypes for richer interactions.\n- Includes new icons and organized configuration files for stability." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players gain new trading tools, visual icons, and expanded NPC conversations." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved critical issues in the trading logic, wallet queue management, and audio handling to ensure stability." },
                    { type = "heading", id = "item_item_2026_01_26_dynamictradingcommon", level = 2, text = "Dynamic Trading System Launch and Fixes" },
                    { type = "paragraph", text = "- **Initial dynamic trading system** now includes NPC wallets, loot logic, and a new trading UI.\n- Traders are now correctly visible during scans even when the public network is disabled.\n- Player names are logged when a trader is successfully found, aiding in debugging and tracking." },
                    { type = "callout", tone = "success", title = "Impact", text = "Unlock a fully functional NPC trading economy with new UI and debugging tools." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated common libraries and core files to support the new trading architecture." },
                    { type = "heading", id = "item_item_2026_01_27_dynamictradingcommon", level = 2, text = "Trading Fixes, Wallet Queue & Audio Manager" },
                    { type = "paragraph", text = "- Fixed critical trade bugs where non-two-way items could pass and dialogue conflicted with other mods.\n- Introduced a new **open wallet queue system** to manage transaction requests more effectively.\n- Added a centralized AudioManager and Options config manager for improved audio and settings handling.\n- Reorganized portrait and dialogue files into Archetypes folders to fix load order issues." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves trade bugs and adds a new wallet queue system for better trading control." },
                },
            },
        },
    })
end
