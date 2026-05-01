-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_02_08",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 02/02 - 02/08",
--   "description": "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI. — Resolved multiplayer radar issues, string errors, and various trading system bugs.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 6,
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
--       "description": "Added stock trading, revamped faction management, and overhauled the entire trading UI."
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
--           "text": "Added stock trading, revamped faction management, and overhauled the entire trading UI."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_07_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading UI Overhaul and Reputation System"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Trading windows now **resize dynamically** and use tabs instead of switch buttons.\n- Added **trader faction and reputation** details directly within the conversation UI.\n- Fixed NPC requirements and optimized the logging system for smoother trading.\n- Refactored core trading code to improve stability and future expansion."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enjoy a cleaner trading interface with new reputation features and optimized performance."
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
--           "text": "Resolved multiplayer radar issues, string errors, and various trading system bugs."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_08_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading System UI Updates and Bug Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Introduced a redesigned settings interface for the dynamic trading system.\n- Added hooks to the trader UI and auto-close functionality for expired deals.\n- *Fixed merchant debug mode* which was previously broken due to invalid triggers."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances trader interactions with new settings and fixes critical merchant debugging issues."
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
--           "text": "Adjusted radar value calculations to ensure fairer trading economics."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_05_dynamictradingcommon",
--           "level": 2,
--           "text": "Radar Value Balancing Adjustments"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Adjusted radar values to improve overall balance in dynamic trading.\n- Ensures radar items feel fairer when used in player-to-player exchanges."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Radar values have been tuned to provide a more balanced trading experience."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_02_08", {
        title = "Update: 02/02 - 02/08",
        description = "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI. — Resolved multiplayer radar issues, string errors, and various trading system bugs.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 6,
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
                description = "Added stock trading, revamped faction management, and overhauled the entire trading UI.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Features Highlights", text = "Added stock trading, revamped faction management, and overhauled the entire trading UI." },
                    { type = "heading", id = "item_item_2026_02_07_dynamictradingcommon", level = 2, text = "Trading UI Overhaul and Reputation System" },
                    { type = "paragraph", text = "- Trading windows now **resize dynamically** and use tabs instead of switch buttons.\n- Added **trader faction and reputation** details directly within the conversation UI.\n- Fixed NPC requirements and optimized the logging system for smoother trading.\n- Refactored core trading code to improve stability and future expansion." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enjoy a cleaner trading interface with new reputation features and optimized performance." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved multiplayer radar issues, string errors, and various trading system bugs." },
                    { type = "heading", id = "item_item_2026_02_08_dynamictradingcommon", level = 2, text = "Trading System UI Updates and Bug Fixes" },
                    { type = "paragraph", text = "- Introduced a redesigned settings interface for the dynamic trading system.\n- Added hooks to the trader UI and auto-close functionality for expired deals.\n- *Fixed merchant debug mode* which was previously broken due to invalid triggers." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances trader interactions with new settings and fixes critical merchant debugging issues." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Adjusted radar value calculations to ensure fairer trading economics." },
                    { type = "heading", id = "item_item_2026_02_05_dynamictradingcommon", level = 2, text = "Radar Value Balancing Adjustments" },
                    { type = "paragraph", text = "- Adjusted radar values to improve overall balance in dynamic trading.\n- Ensures radar items feel fairer when used in player-to-player exchanges." },
                    { type = "callout", tone = "success", title = "Impact", text = "Radar values have been tuned to provide a more balanced trading experience." },
                },
            },
        },
    })
end
