-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_upd_2026_04_20",
--   "module": "DynamicTrading",
--   "title": "Update: 04/08 - 04/20",
--   "description": "The April Sprint: New Tools & Refinements. Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay. — Improved radio contact scheduling, companion UI visibility, and faction management interfaces.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTrading"
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
--       "description": "Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay."
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
--           "id": "item_item_2026_04_17_dynamictrading",
--           "level": 2,
--           "text": "Trader Radio Contacts & Scheduling Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a **global trader contact system** allowing you to save and manage NPC frequencies directly in the UI.\n- Implemented a new **trade scheduling calendar** with configurable eligibility settings for better planning.\n- Enhanced contact visits with dynamic UI feedback, ETA tracking, and improved conversation state persistence.\n- Improved backend routing and scan capacity management for V1 radio contact visits."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamline trader interactions with new radio contact systems and advanced scheduling tools."
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
--           "text": "Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_14_dynamictrading",
--           "level": 2,
--           "text": "Dynamic Trading Portraits & Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs now use a **shared portrait system** for consistent visuals across the map.\n- Fixed character validation errors to prevent trading interruptions.\n- Added debug tools to help developers troubleshoot portrait rendering issues."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now display shared portraits with improved trading stability."
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
--           "text": "Improved radio contact scheduling, companion UI visibility, and faction management interfaces."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_18_dynamictrading",
--           "level": 2,
--           "text": "Radio Scanner UI Overhaul & Refactoring"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Reorganized the Faction Info Window UI to improve component management.\n- Consolidated radio scanner elements into a shared library for easier maintenance.\n- Migrated V2 radar logic to the new common framework for **enhanced stability**."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamlined interface components for better stability and future feature expansion."
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
--           "text": "Optimized UI rendering and core logic to support Build 42.16 with reduced lag."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_15_dynamictrading",
--           "level": 2,
--           "text": "Dynamic Trading Update for Build 42.16"
--         },
--         {
--           "type": "paragraph",
--           "text": "* **Added full support for Project Zomboid build 42.16** to ensure the mod runs without issues.\n* Streamlined sandbox options and event management for a cleaner configuration experience.\n* Removed obsolete files and legacy NPC logic to improve performance and reduce errors."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Ensures full compatibility and stability for the Dynamic Trading mod on the latest game version."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_upd_2026_04_20", {
        title = "Update: 04/08 - 04/20",
        description = "The April Sprint: New Tools & Refinements. Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay. — Improved radio contact scheduling, companion UI visibility, and faction management interfaces.",
        startPageId = "cat_features",
        audiences = { "DynamicTrading" },
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
                description = "Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_04_17_dynamictrading", level = 2, text = "Trader Radio Contacts & Scheduling Overhaul" },
                    { type = "paragraph", text = "- Added a **global trader contact system** allowing you to save and manage NPC frequencies directly in the UI.\n- Implemented a new **trade scheduling calendar** with configurable eligibility settings for better planning.\n- Enhanced contact visits with dynamic UI feedback, ETA tracking, and improved conversation state persistence.\n- Improved backend routing and scan capacity management for V1 radio contact visits." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamline trader interactions with new radio contact systems and advanced scheduling tools." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved critical issues with trading portraits and UI rendering to ensure stable gameplay." },
                    { type = "heading", id = "item_item_2026_04_14_dynamictrading", level = 2, text = "Dynamic Trading Portraits & Fixes" },
                    { type = "paragraph", text = "- NPCs now use a **shared portrait system** for consistent visuals across the map.\n- Fixed character validation errors to prevent trading interruptions.\n- Added debug tools to help developers troubleshoot portrait rendering issues." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now display shared portraits with improved trading stability." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Improved radio contact scheduling, companion UI visibility, and faction management interfaces." },
                    { type = "heading", id = "item_item_2026_04_18_dynamictrading", level = 2, text = "Radio Scanner UI Overhaul & Refactoring" },
                    { type = "paragraph", text = "- Reorganized the Faction Info Window UI to improve component management.\n- Consolidated radio scanner elements into a shared library for easier maintenance.\n- Migrated V2 radar logic to the new common framework for **enhanced stability**." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamlined interface components for better stability and future feature expansion." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimized UI rendering and core logic to support Build 42.16 with reduced lag." },
                    { type = "heading", id = "item_item_2026_04_15_dynamictrading", level = 2, text = "Dynamic Trading Update for Build 42.16" },
                    { type = "paragraph", text = "* **Added full support for Project Zomboid build 42.16** to ensure the mod runs without issues.\n* Streamlined sandbox options and event management for a cleaner configuration experience.\n* Removed obsolete files and legacy NPC logic to improve performance and reduce errors." },
                    { type = "callout", tone = "success", title = "Impact", text = "Ensures full compatibility and stability for the Dynamic Trading mod on the latest game version." },
                },
            },
        },
    })
end
