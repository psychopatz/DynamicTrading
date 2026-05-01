-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_02_01",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 01/28 - 02/01",
--   "description": "Dynamic Trading: Smarter NPCs and Balanced Markets. Added an automatic building selector to streamline trader setup and management. — Refined trader balancing and resolved issues with the selling mechanics.",
--   "start_page_id": "cat_qol",
--   "audiences": [
--     "DynamicTradingCommon"
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
--       "description": "Resolved critical bugs in trader AI behavior and NPC interaction stability."
--     }
--   ],
--   "pages": [
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
--           "text": "Added an automatic building selector to streamline trader setup and management."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_29_dynamictradingcommon",
--           "level": 2,
--           "text": "Automatic Building Selector for Dynamic Trading"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The trading system now **automatically selects the correct building** when initiating a transaction.\n- Removes the need for manual building selection, reducing clicks during complex trades."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamlines trading interactions by automatically selecting the correct building."
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
--           "text": "Refined trader balancing and resolved issues with the selling mechanics."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_28_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader Balancing, Chat System, and Selling Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Trader budgets now include proper deflation mechanics** and gunpowder prices are reduced for better balance.\n- Added a new **Chat system framework** and the ability to request specific traders for trade.\n- Fixed issues where selling failed due to lack of funds and removed money from the trade pool."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now have realistic budgets and a new chat system is introduced for better interaction."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_02_01", {
        title = "Update: 01/28 - 02/01",
        description = "Dynamic Trading: Smarter NPCs and Balanced Markets. Added an automatic building selector to streamline trader setup and management. — Refined trader balancing and resolved issues with the selling mechanics.",
        startPageId = "cat_qol",
        audiences = { "DynamicTradingCommon" },
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
                description = "Resolved critical bugs in trader AI behavior and NPC interaction stability.",
            },
        },
        pages = {
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Added an automatic building selector to streamline trader setup and management." },
                    { type = "heading", id = "item_item_2026_01_29_dynamictradingcommon", level = 2, text = "Automatic Building Selector for Dynamic Trading" },
                    { type = "paragraph", text = "- The trading system now **automatically selects the correct building** when initiating a transaction.\n- Removes the need for manual building selection, reducing clicks during complex trades." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamlines trading interactions by automatically selecting the correct building." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Refined trader balancing and resolved issues with the selling mechanics." },
                    { type = "heading", id = "item_item_2026_01_28_dynamictradingcommon", level = 2, text = "Trader Balancing, Chat System, and Selling Fixes" },
                    { type = "paragraph", text = "- **Trader budgets now include proper deflation mechanics** and gunpowder prices are reduced for better balance.\n- Added a new **Chat system framework** and the ability to request specific traders for trade.\n- Fixed issues where selling failed due to lack of funds and removed money from the trade pool." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now have realistic budgets and a new chat system is introduced for better interaction." },
                },
            },
        },
    })
end
