-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_upd_2026_02_08",
--   "module": "DynamicTrading",
--   "title": "Update: 02/02 - 02/08",
--   "description": "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTrading"
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
--           "id": "item_item_2026_02_08_dynamictrading",
--           "level": 2,
--           "text": "Trading UI Overhaul and Radio Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New trading settings design** improves configuration clarity and ease of use.\n- The radio interface is now **fully resizable** for better screen adaptability.\n- The trader conversation window **automatically closes** when the trading session expires."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enjoy a modernized trading interface with a resizable radio and smarter session handling."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_07_dynamictrading",
--           "level": 2,
--           "text": "Dynamic Trading UI & Budget Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Trader budgets are now calculated as a percentage for more consistent economy scaling.\n- The trading window automatically resizes to fit content, improving UI clarity and layout.\n- Fixed issues causing ghost lists when broadcasts expire and resolved NPC requirement errors.\n- Optimized logging for buying and selling actions to reduce server load and improve performance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now use percentage budgets and feature a responsive, dynamic interface."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_upd_2026_02_08", {
        title = "Update: 02/02 - 02/08",
        description = "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI.",
        startPageId = "cat_features",
        audiences = { "DynamicTrading" },
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
                    { type = "heading", id = "item_item_2026_02_08_dynamictrading", level = 2, text = "Trading UI Overhaul and Radio Enhancements" },
                    { type = "paragraph", text = "- **New trading settings design** improves configuration clarity and ease of use.\n- The radio interface is now **fully resizable** for better screen adaptability.\n- The trader conversation window **automatically closes** when the trading session expires." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enjoy a modernized trading interface with a resizable radio and smarter session handling." },
                    { type = "heading", id = "item_item_2026_02_07_dynamictrading", level = 2, text = "Dynamic Trading UI & Budget Overhaul" },
                    { type = "paragraph", text = "- Trader budgets are now calculated as a percentage for more consistent economy scaling.\n- The trading window automatically resizes to fit content, improving UI clarity and layout.\n- Fixed issues causing ghost lists when broadcasts expire and resolved NPC requirement errors.\n- Optimized logging for buying and selling actions to reduce server load and improve performance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now use percentage budgets and feature a responsive, dynamic interface." },
                },
            },
        },
    })
end
