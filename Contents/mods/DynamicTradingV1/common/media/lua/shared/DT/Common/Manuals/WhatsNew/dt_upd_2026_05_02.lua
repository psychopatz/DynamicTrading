-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_upd_2026_05_02",
--   "module": "DynamicTrading",
--   "title": "Update: 04/21 - 05/02",
--   "description": "Trader Overhaul, Bandit Raids, and New Quests. Adjusted colony wealth settings and trading economics to create a more challenging and realistic survival loop.",
--   "start_page_id": "cat_balance",
--   "audiences": [
--     "DynamicTrading"
--   ],
--   "sort_order": 7,
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
--           "id": "item_item_2026_04_21_dynamictrading",
--           "level": 2,
--           "text": "Colony Wealth Settings and Trading Refactor"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new **colony wealth option** to the sandbox settings menu.\n- Refactored internal trading names for better clarity and future updates."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now configure colony wealth limits in sandbox mode."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_upd_2026_05_02", {
        title = "Update: 04/21 - 05/02",
        description = "Trader Overhaul, Bandit Raids, and New Quests. Adjusted colony wealth settings and trading economics to create a more challenging and realistic survival loop.",
        startPageId = "cat_balance",
        audiences = { "DynamicTrading" },
        sortOrder = 7,
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
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Adjusted colony wealth settings and trading economics to create a more challenging and realistic survival loop." },
                    { type = "heading", id = "item_item_2026_04_21_dynamictrading", level = 2, text = "Colony Wealth Settings and Trading Refactor" },
                    { type = "paragraph", text = "- Added a new **colony wealth option** to the sandbox settings menu.\n- Refactored internal trading names for better clarity and future updates." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now configure colony wealth limits in sandbox mode." },
                },
            },
        },
    })
end
