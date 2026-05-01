-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_01_09",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 01/05 - 01/09",
--   "description": "Trader Portraits, Wallet Fixes, and Logic Overhaul. Resolves critical wallet errors and UI glitches affecting data synchronization. — Improves system stability by moving database logic to a more efficient location.",
--   "start_page_id": "cat_fixes",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 2,
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
--       "description": "Adds new trader portraits and refines core trading logic for better immersion."
--     }
--   ],
--   "pages": [
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
--           "text": "Resolves critical wallet errors and UI glitches affecting data synchronization."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_07_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading System Updates and Wallet Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Money and money bundles now have zero weight and support stacking via compress and decompress features.\n- The wallet lottery system and shop menus are now fully functional in both single-player and multiplayer.\n- Global Economy Stats have been moved to the sidebar panel for easier access during gameplay."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Money handling is now optimized and all trading features work reliably in both single and multiplayer modes."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_06_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader UI Fixes and Data Sync"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed incorrect trader names** appearing in buy and sell menus.\n- Trade and sell menus now remember your previously selected item.\n- Resolved an issue where client mod data failed to update from the server."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves trader naming errors and improves menu usability."
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
--           "text": "Improves system stability by moving database logic to a more efficient location."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_05_dynamictradingcommon",
--           "level": 2,
--           "text": "DynamicTrading Database Logic Moved"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Moved all database logic to the server side for better stability.\n- Fixes potential client crashes that occurred during trade negotiations.\n- Ensures trading data is handled securely on the dedicated server."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Improves server stability and prevents client-side crashes during trading."
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
--           "text": "General codebase organization and internal refactoring completed."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_09_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader UI Refinements and Sell Menu Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Dynamic text wrapping** now improves trader log readability without manual adjustments.\n- Added a **lock system** to the sell menu to prevent accidental item sales.\n- Fixed errors when selling items using HAM and resolved radio sound glitches.\n- Prevented used walkie-talkies from being sold and added new trader dialog options."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances trading stability and adds quality-of-life features to the sell menu."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_08_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader Portraits, UI Fixes, and Trading Logic"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added **dynamic trader portraits** and profile images to the trading interface for better immersion.\n- Fixed overlapping text bugs and corrected invalid item IDs to ensure smoother trading sessions.\n- Improved event randomization with cooldowns and made inflation decay fully configurable.\n- Resolved fuel trading issues by replacing jewelry with actual fuel items in the system."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances trading interactions with visual portraits and stabilizes core trading mechanics."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_01_09", {
        title = "Update: 01/05 - 01/09",
        description = "Trader Portraits, Wallet Fixes, and Logic Overhaul. Resolves critical wallet errors and UI glitches affecting data synchronization. — Improves system stability by moving database logic to a more efficient location.",
        startPageId = "cat_fixes",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 2,
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
                description = "Adds new trader portraits and refines core trading logic for better immersion.",
            },
        },
        pages = {
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical wallet errors and UI glitches affecting data synchronization." },
                    { type = "heading", id = "item_item_2026_01_07_dynamictradingcommon", level = 2, text = "Trading System Updates and Wallet Fixes" },
                    { type = "paragraph", text = "- Money and money bundles now have zero weight and support stacking via compress and decompress features.\n- The wallet lottery system and shop menus are now fully functional in both single-player and multiplayer.\n- Global Economy Stats have been moved to the sidebar panel for easier access during gameplay." },
                    { type = "callout", tone = "success", title = "Impact", text = "Money handling is now optimized and all trading features work reliably in both single and multiplayer modes." },
                    { type = "heading", id = "item_item_2026_01_06_dynamictradingcommon", level = 2, text = "Trader UI Fixes and Data Sync" },
                    { type = "paragraph", text = "- **Fixed incorrect trader names** appearing in buy and sell menus.\n- Trade and sell menus now remember your previously selected item.\n- Resolved an issue where client mod data failed to update from the server." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves trader naming errors and improves menu usability." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Improves system stability by moving database logic to a more efficient location." },
                    { type = "heading", id = "item_item_2026_01_05_dynamictradingcommon", level = 2, text = "DynamicTrading Database Logic Moved" },
                    { type = "paragraph", text = "- Moved all database logic to the server side for better stability.\n- Fixes potential client crashes that occurred during trade negotiations.\n- Ensures trading data is handled securely on the dedicated server." },
                    { type = "callout", tone = "success", title = "Impact", text = "Improves server stability and prevents client-side crashes during trading." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "General codebase organization and internal refactoring completed." },
                    { type = "heading", id = "item_item_2026_01_09_dynamictradingcommon", level = 2, text = "Trader UI Refinements and Sell Menu Fixes" },
                    { type = "paragraph", text = "- **Dynamic text wrapping** now improves trader log readability without manual adjustments.\n- Added a **lock system** to the sell menu to prevent accidental item sales.\n- Fixed errors when selling items using HAM and resolved radio sound glitches.\n- Prevented used walkie-talkies from being sold and added new trader dialog options." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances trading stability and adds quality-of-life features to the sell menu." },
                    { type = "heading", id = "item_item_2026_01_08_dynamictradingcommon", level = 2, text = "Trader Portraits, UI Fixes, and Trading Logic" },
                    { type = "paragraph", text = "- Added **dynamic trader portraits** and profile images to the trading interface for better immersion.\n- Fixed overlapping text bugs and corrected invalid item IDs to ensure smoother trading sessions.\n- Improved event randomization with cooldowns and made inflation decay fully configurable.\n- Resolved fuel trading issues by replacing jewelry with actual fuel items in the system." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances trading interactions with visual portraits and stabilizes core trading mechanics." },
                },
            },
        },
    })
end
