-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_04_20",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 04/08 - 04/20",
--   "description": "The April Sprint: New Tools & Refinements. Optimized UI rendering and core logic to support Build 42.16 with reduced lag. — Updated internal versioning and refactored codebase for better mod maintainability.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 11,
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
--           "id": "item_item_2026_04_18_dynamictradingcommon",
--           "level": 2,
--           "text": "Faction Logging, Radio Scanner, and Colony Systems"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Comprehensive faction logging** now tracks membership, leadership, reputation, and combat events with UI display.\n- The **radio scanner** received major logic overhauls, dynamic success probabilities, and improved contact visibility.\n- New **colony infrastructure and horde systems** are live alongside a virtual store with economy modifiers.\n- UI updates include styled listboxes, dynamic button widths, and extensive proximity-based NPC dialogue lines."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced faction tracking, improved radio scanner mechanics, and new colony infrastructure features."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_17_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader Contact Visits & Radar Companion Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New trader contact system** allows scheduling visits with dynamic ETA tracking and saved frequency management.\n- Added a **central debug hub** to consolidate development tools alongside a new trade scheduling calendar UI.\n- Travel companions are now accessible via the radar with improved filtering based on player ownership.\n- Backend optimizations ensure smoother state persistence for conversation requests and roster normalization."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now schedule and track NPC trader visits while managing travel companions via the radar."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_16_dynamictradingcommon",
--           "level": 2,
--           "text": "Guard Combat Orders and UI Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Guards now support **direct combat orders** and new attack modes for better colony defense.\n- The Stay behavior has been added to prevent guards from wandering during critical moments.\n- UI color customization is expanded, allowing for clearer visual distinction of guard states.\n- Underlying code has been reorganized to improve performance and future modding stability."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now issue direct combat commands to guards and enjoy a more customizable interface."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_14_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Trading Portraits & Faction Management"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added dynamic portrait animations and speech states for **trading and conversation UI**.\n- Introduced a full faction administration system with colony archiving and debug tools.\n- Improved worker retention logic and added version-aware manual update notifications.\n- Refactored NPC assets and added search utilities while removing outdated documentation skills."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances trading visuals with dynamic animations and adds robust tools for managing faction colonies."
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
--           "id": "item_item_2026_04_15_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI Performance & B42.16 Support"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added full support for Project Zomboid Build 42.16 to ensure compatibility with the latest game version.\n- **Improved UI performance** by implementing lazy-loading for 3D portrait models during trading sessions.\n- Reorganized internal files and streamlined sandbox options for a cleaner and more stable mod experience."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "The mod now runs faster with optimized UI loading and fully supports the latest game update."
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
--           "text": "Updated internal versioning and refactored codebase for better mod maintainability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_20_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Signals and Map Intelligence"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New signal tracking dialogue** allows players to negotiate trades based on real-time market data.\n- Automated **map and town boundary resolution** helps factions locate bases without manual input.\n- Optimized building indexing system improves performance during large-scale trade calculations."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "New dialogue options and automated map data improve trading efficiency and faction tracking."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_04_20", {
        title = "Update: 04/08 - 04/20",
        description = "The April Sprint: New Tools & Refinements. Optimized UI rendering and core logic to support Build 42.16 with reduced lag. — Updated internal versioning and refactored codebase for better mod maintainability.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 11,
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
                    { type = "heading", id = "item_item_2026_04_18_dynamictradingcommon", level = 2, text = "Faction Logging, Radio Scanner, and Colony Systems" },
                    { type = "paragraph", text = "- **Comprehensive faction logging** now tracks membership, leadership, reputation, and combat events with UI display.\n- The **radio scanner** received major logic overhauls, dynamic success probabilities, and improved contact visibility.\n- New **colony infrastructure and horde systems** are live alongside a virtual store with economy modifiers.\n- UI updates include styled listboxes, dynamic button widths, and extensive proximity-based NPC dialogue lines." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced faction tracking, improved radio scanner mechanics, and new colony infrastructure features." },
                    { type = "heading", id = "item_item_2026_04_17_dynamictradingcommon", level = 2, text = "Trader Contact Visits & Radar Companion Updates" },
                    { type = "paragraph", text = "- **New trader contact system** allows scheduling visits with dynamic ETA tracking and saved frequency management.\n- Added a **central debug hub** to consolidate development tools alongside a new trade scheduling calendar UI.\n- Travel companions are now accessible via the radar with improved filtering based on player ownership.\n- Backend optimizations ensure smoother state persistence for conversation requests and roster normalization." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now schedule and track NPC trader visits while managing travel companions via the radar." },
                    { type = "heading", id = "item_item_2026_04_16_dynamictradingcommon", level = 2, text = "Guard Combat Orders and UI Enhancements" },
                    { type = "paragraph", text = "- Guards now support **direct combat orders** and new attack modes for better colony defense.\n- The Stay behavior has been added to prevent guards from wandering during critical moments.\n- UI color customization is expanded, allowing for clearer visual distinction of guard states.\n- Underlying code has been reorganized to improve performance and future modding stability." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now issue direct combat commands to guards and enjoy a more customizable interface." },
                    { type = "heading", id = "item_item_2026_04_14_dynamictradingcommon", level = 2, text = "NPC Trading Portraits & Faction Management" },
                    { type = "paragraph", text = "- Added dynamic portrait animations and speech states for **trading and conversation UI**.\n- Introduced a full faction administration system with colony archiving and debug tools.\n- Improved worker retention logic and added version-aware manual update notifications.\n- Refactored NPC assets and added search utilities while removing outdated documentation skills." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances trading visuals with dynamic animations and adds robust tools for managing faction colonies." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimized UI rendering and core logic to support Build 42.16 with reduced lag." },
                    { type = "heading", id = "item_item_2026_04_15_dynamictradingcommon", level = 2, text = "Dynamic Trading UI Performance & B42.16 Support" },
                    { type = "paragraph", text = "- Added full support for Project Zomboid Build 42.16 to ensure compatibility with the latest game version.\n- **Improved UI performance** by implementing lazy-loading for 3D portrait models during trading sessions.\n- Reorganized internal files and streamlined sandbox options for a cleaner and more stable mod experience." },
                    { type = "callout", tone = "success", title = "Impact", text = "The mod now runs faster with optimized UI loading and fully supports the latest game update." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated internal versioning and refactored codebase for better mod maintainability." },
                    { type = "heading", id = "item_item_2026_04_20_dynamictradingcommon", level = 2, text = "Dynamic Trading Signals and Map Intelligence" },
                    { type = "paragraph", text = "- **New signal tracking dialogue** allows players to negotiate trades based on real-time market data.\n- Automated **map and town boundary resolution** helps factions locate bases without manual input.\n- Optimized building indexing system improves performance during large-scale trade calculations." },
                    { type = "callout", tone = "success", title = "Impact", text = "New dialogue options and automated map data improve trading efficiency and faction tracking." },
                },
            },
        },
    })
end
