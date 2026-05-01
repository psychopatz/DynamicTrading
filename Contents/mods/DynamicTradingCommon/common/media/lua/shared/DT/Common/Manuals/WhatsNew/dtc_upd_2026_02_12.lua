-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_02_12",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 02/09 - 02/12",
--   "description": "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Optimizes system stability and streamlines registration processes.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
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
--       "description": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
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
--           "id": "item_item_2026_02_12_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Events and UI Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "* Traders now utilize a new event system that **dynamically loads and reacts** to sandbox events.\n* The Liquid Container trader interface now shows **exact liter amounts** and updates prices instantly.\n* Fixed an issue where trader messages were failing to display to the player.\n* Reorganized sandbox options to better support the new dynamic event loading mechanics."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now react to dynamic events with improved UI feedback and accurate liquid pricing."
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
--           "text": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_11_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI Fixes and Translation System"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Implemented a new translation system** to support multiple languages for trader interactions.\n- Fixed overlapping UI elements in the trading window by applying a stencil wrapper.\n- Optimized log output to prevent flooding when accessing traders or loading translations.\n- Refactored configuration managers to be data agnostic for better mod compatibility."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves interface glitches and introduces in-game text translation support."
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
--           "text": "Optimizes system stability and streamlines registration processes."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_09_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading System Stability & Registration Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Improved the registration process for trading archetypes to prevent errors.\n- Made item registration more robust to ensure smoother trading interactions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances the reliability of item trading and archetype handling."
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
--           "text": "Overhauls pricing algorithms to create smarter and more realistic market values."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_10_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI & Pricing Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Trade windows and radio dialogs now **persist across game sessions** for better continuity.\n- Dynamic pricing logic has been updated to correctly value **food and liquid containers**.\n- Critical errors are fixed by closing trade interfaces immediately when a player dies.\n- Multiplayer compatibility is improved for trader item attributes and economic systems."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players now experience smarter, persistent trading with accurate liquid and food pricing."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_02_12", {
        title = "Update: 02/09 - 02/12",
        description = "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Optimizes system stability and streamlines registration processes.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
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
                description = "Resolves critical UI glitches, translation errors, and multiplayer network instability.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_02_12_dynamictradingcommon", level = 2, text = "Dynamic Trading Events and UI Updates" },
                    { type = "paragraph", text = "* Traders now utilize a new event system that **dynamically loads and reacts** to sandbox events.\n* The Liquid Container trader interface now shows **exact liter amounts** and updates prices instantly.\n* Fixed an issue where trader messages were failing to display to the player.\n* Reorganized sandbox options to better support the new dynamic event loading mechanics." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now react to dynamic events with improved UI feedback and accurate liquid pricing." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical UI glitches, translation errors, and multiplayer network instability." },
                    { type = "heading", id = "item_item_2026_02_11_dynamictradingcommon", level = 2, text = "Dynamic Trading UI Fixes and Translation System" },
                    { type = "paragraph", text = "- **Implemented a new translation system** to support multiple languages for trader interactions.\n- Fixed overlapping UI elements in the trading window by applying a stencil wrapper.\n- Optimized log output to prevent flooding when accessing traders or loading translations.\n- Refactored configuration managers to be data agnostic for better mod compatibility." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves interface glitches and introduces in-game text translation support." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimizes system stability and streamlines registration processes." },
                    { type = "heading", id = "item_item_2026_02_09_dynamictradingcommon", level = 2, text = "Trading System Stability & Registration Updates" },
                    { type = "paragraph", text = "- Improved the registration process for trading archetypes to prevent errors.\n- Made item registration more robust to ensure smoother trading interactions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances the reliability of item trading and archetype handling." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Overhauls pricing algorithms to create smarter and more realistic market values." },
                    { type = "heading", id = "item_item_2026_02_10_dynamictradingcommon", level = 2, text = "Dynamic Trading UI & Pricing Overhaul" },
                    { type = "paragraph", text = "- Trade windows and radio dialogs now **persist across game sessions** for better continuity.\n- Dynamic pricing logic has been updated to correctly value **food and liquid containers**.\n- Critical errors are fixed by closing trade interfaces immediately when a player dies.\n- Multiplayer compatibility is improved for trader item attributes and economic systems." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players now experience smarter, persistent trading with accurate liquid and food pricing." },
                },
            },
        },
    })
end
