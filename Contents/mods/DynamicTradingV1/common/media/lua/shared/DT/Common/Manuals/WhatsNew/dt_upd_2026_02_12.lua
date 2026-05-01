-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_upd_2026_02_12",
--   "module": "DynamicTrading",
--   "title": "Update: 02/09 - 02/12",
--   "description": "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Adds radar enhancements, radio updates, and improved navigation tools for traders.",
--   "start_page_id": "cat_fixes",
--   "audiences": [
--     "DynamicTrading"
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
--       "description": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
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
--           "text": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_11_dynamictrading",
--           "level": 2,
--           "text": "Trading UI Fixes and Translation Support"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed overlapping network UI elements** by implementing a stencil wrapper for cleaner visuals.\n- Updated log systems to use refactored namespaces and made config data agnostic.\n- Added foundation for future translations and improved dialogue registration."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves interface overlap issues and prepares the mod for multiple languages."
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
--           "text": "Adds radar enhancements, radio updates, and improved navigation tools for traders."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_09_dynamictrading",
--           "level": 2,
--           "text": "Radar UI Enhancements and Radio Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The radar UI now displays **location information** to help players navigate the map more effectively.\n- A new location tab has been added to the radio interface for easier access to nearby points of interest.\n- Underlying archetype registration logic was streamlined to improve system stability and future mod compatibility."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now track specific locations directly within the radar and radio interfaces."
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
--           "id": "item_item_2026_02_10_dynamictrading",
--           "level": 2,
--           "text": "Dynamic Trading Fixes and Smarter Pricing"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The trade interface now closes automatically when you die to prevent crashes.\n- **Dynamic pricing now accounts for fluid and item details** for more accurate trades.\n- Trader items now utilize dynamic attributes just like player inventory.\n- Core economy logic has been reorganized to support future expansions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Prevents trading errors on death and improves item valuation accuracy."
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
--           "text": "Includes general refactoring and backend updates to support the new systems."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_12_dynamictrading",
--           "level": 2,
--           "text": "Dynamic Trading Options and Event System"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Reorganized sandbox options** make it easier to find and configure trading settings.\n- Dynamic event loading allows for more varied and spontaneous trading scenarios.\n- Underlying event system improvements ensure smoother performance during gameplay."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players gain access to reorganized sandbox settings and more flexible dynamic trading events."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_upd_2026_02_12", {
        title = "Update: 02/09 - 02/12",
        description = "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Adds radar enhancements, radio updates, and improved navigation tools for traders.",
        startPageId = "cat_fixes",
        audiences = { "DynamicTrading" },
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
                description = "Resolves critical UI glitches, translation errors, and multiplayer network instability.",
            },
        },
        pages = {
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical UI glitches, translation errors, and multiplayer network instability." },
                    { type = "heading", id = "item_item_2026_02_11_dynamictrading", level = 2, text = "Trading UI Fixes and Translation Support" },
                    { type = "paragraph", text = "- **Fixed overlapping network UI elements** by implementing a stencil wrapper for cleaner visuals.\n- Updated log systems to use refactored namespaces and made config data agnostic.\n- Added foundation for future translations and improved dialogue registration." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves interface overlap issues and prepares the mod for multiple languages." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Adds radar enhancements, radio updates, and improved navigation tools for traders." },
                    { type = "heading", id = "item_item_2026_02_09_dynamictrading", level = 2, text = "Radar UI Enhancements and Radio Updates" },
                    { type = "paragraph", text = "- The radar UI now displays **location information** to help players navigate the map more effectively.\n- A new location tab has been added to the radio interface for easier access to nearby points of interest.\n- Underlying archetype registration logic was streamlined to improve system stability and future mod compatibility." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now track specific locations directly within the radar and radio interfaces." },
                },
            },
            {
                id = "cat_balance",
                chapterId = "release_notes",
                title = "Balance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Balance Highlights", text = "Overhauls pricing algorithms to create smarter and more realistic market values." },
                    { type = "heading", id = "item_item_2026_02_10_dynamictrading", level = 2, text = "Dynamic Trading Fixes and Smarter Pricing" },
                    { type = "paragraph", text = "- The trade interface now closes automatically when you die to prevent crashes.\n- **Dynamic pricing now accounts for fluid and item details** for more accurate trades.\n- Trader items now utilize dynamic attributes just like player inventory.\n- Core economy logic has been reorganized to support future expansions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Prevents trading errors on death and improves item valuation accuracy." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Includes general refactoring and backend updates to support the new systems." },
                    { type = "heading", id = "item_item_2026_02_12_dynamictrading", level = 2, text = "Dynamic Trading Options and Event System" },
                    { type = "paragraph", text = "- **Reorganized sandbox options** make it easier to find and configure trading settings.\n- Dynamic event loading allows for more varied and spontaneous trading scenarios.\n- Underlying event system improvements ensure smoother performance during gameplay." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players gain access to reorganized sandbox settings and more flexible dynamic trading events." },
                },
            },
        },
    })
end
