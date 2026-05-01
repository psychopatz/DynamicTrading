-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_01_27",
--   "module": "DynamicTradingV2",
--   "title": "Update: 01/19 - 01/27",
--   "description": "Dynamic Trading System Launch and UI Overhaul. Updated common libraries and core files to support the new trading architecture.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 1,
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
--           "id": "item_item_2026_01_26_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading System and UI Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New dynamic trading system** allows players to buy and sell items with NPCs using a fresh wallet and loot mechanics.\n- Added comprehensive UI elements and debugging tools to help players track transactions and test features."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Introduces a fully functional dynamic trading system with new NPC interactions and inventory management."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_25_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading UI & Bag Transaction Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added new trading and radio signal UIs for better client and server control.\n- **Bags now notify players of their contents** during transaction handling.\n- Separated dynamic NPC trading logic from the original system for stability.\n- Reorganized archetypes into dedicated folders for improved mod structure."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced trading interactions with new interfaces and detailed bag notifications."
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
--           "id": "item_item_2026_01_27_dynamictradingv2",
--           "level": 2,
--           "text": "Trading Fixes and Audio Options Added"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed an exploit allowing one-way items to pass through trades incorrectly.\n- Added a new AudioManager and Options config manager for better sound control."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Prevents unfair trade exploits while adding new audio configuration options."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_01_27", {
        title = "Update: 01/19 - 01/27",
        description = "Dynamic Trading System Launch and UI Overhaul. Updated common libraries and core files to support the new trading architecture.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
        sortOrder = 1,
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
                    { type = "heading", id = "item_item_2026_01_26_dynamictradingv2", level = 2, text = "Dynamic Trading System and UI Overhaul" },
                    { type = "paragraph", text = "- **New dynamic trading system** allows players to buy and sell items with NPCs using a fresh wallet and loot mechanics.\n- Added comprehensive UI elements and debugging tools to help players track transactions and test features." },
                    { type = "callout", tone = "success", title = "Impact", text = "Introduces a fully functional dynamic trading system with new NPC interactions and inventory management." },
                    { type = "heading", id = "item_item_2026_01_25_dynamictradingv2", level = 2, text = "Dynamic Trading UI & Bag Transaction Updates" },
                    { type = "paragraph", text = "- Added new trading and radio signal UIs for better client and server control.\n- **Bags now notify players of their contents** during transaction handling.\n- Separated dynamic NPC trading logic from the original system for stability.\n- Reorganized archetypes into dedicated folders for improved mod structure." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced trading interactions with new interfaces and detailed bag notifications." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated common libraries and core files to support the new trading architecture." },
                    { type = "heading", id = "item_item_2026_01_27_dynamictradingv2", level = 2, text = "Trading Fixes and Audio Options Added" },
                    { type = "paragraph", text = "- Fixed an exploit allowing one-way items to pass through trades incorrectly.\n- Added a new AudioManager and Options config manager for better sound control." },
                    { type = "callout", tone = "success", title = "Impact", text = "Prevents unfair trade exploits while adding new audio configuration options." },
                },
            },
        },
    })
end
