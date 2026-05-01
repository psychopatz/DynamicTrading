-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_02_08",
--   "module": "DynamicTradingV2",
--   "title": "Update: 02/02 - 02/08",
--   "description": "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI. — Resolved multiplayer radar issues, string errors, and various trading system bugs.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 3,
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
--           "id": "item_item_2026_02_07_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading V2 UI & Faction Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added trader faction and reputation systems directly to the conversation interface.\n- Fixed an issue where NPCs failed to require specific conditions for trading.\n- Streamlined the underlying code structure for better stability and future updates."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now track reputation and offer improved conversation options."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_06_dynamictradingv2",
--           "level": 2,
--           "text": "Stock Trading System Implementation"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new **stock trading handler** to support market transactions.\n- Implemented the core logic required for buying and selling shares.\n- Expanded the Dynamic Trading system with full stock market support."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now buy and sell stocks through the new trading interface."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_04_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trader Spawning & County Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Traders now spawn in their correct counties instead of appearing randomly.\n- *Virtually simulated spawning* ensures traders appear logically within the world.\n- Preliminary work continues on the full Dynamic Trading V2 system."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now correctly spawn in their designated counties with improved simulation."
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
--           "id": "item_item_2026_02_05_dynamictradingv2",
--           "level": 2,
--           "text": "Radar UI Overhaul and Multiplayer Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Radar UI now features tabs, proximity sorting, and visual selection feedback for better navigation.\n- **Multiplayer stability is restored** ensuring trader radar functions perfectly in co-op sessions.\n- Radio UI includes new distance metrics and auto-closes when the radar window is dismissed.\n- Device identification and radar value balancing have been refined for a fairer experience."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Trader tracking is now stable in multiplayer with improved sorting and distance indicators."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_02_dynamictradingv2",
--           "level": 2,
--           "text": "Faction Management String Fix"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed double ret strings appearing in the **faction management** interface.\n- Cleaned up text rendering to improve readability during trading interactions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves display errors in faction management menus to ensure clean UI text."
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
--           "text": "Updated internal string references and localized text for better clarity."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_08_dynamictradingv2",
--           "level": 2,
--           "text": "Trader UI Updates and Multiplayer Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "* Fixed stock trading to function correctly in multiplayer sessions.\n* Added automatic window closure when a trader interaction expires.\n* Improved trader UI hooks and portrait display reliability.\n* Restored merchant debug functionality by fixing obsolete triggers."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves multiplayer trading errors and improves trader interface stability."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_02_08", {
        title = "Update: 02/02 - 02/08",
        description = "Trading UI Overhaul and Economy Expansion. Added stock trading, revamped faction management, and overhauled the entire trading UI. — Resolved multiplayer radar issues, string errors, and various trading system bugs.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
        sortOrder = 3,
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
                    { type = "heading", id = "item_item_2026_02_07_dynamictradingv2", level = 2, text = "Dynamic Trading V2 UI & Faction Updates" },
                    { type = "paragraph", text = "- Added trader faction and reputation systems directly to the conversation interface.\n- Fixed an issue where NPCs failed to require specific conditions for trading.\n- Streamlined the underlying code structure for better stability and future updates." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now track reputation and offer improved conversation options." },
                    { type = "heading", id = "item_item_2026_02_06_dynamictradingv2", level = 2, text = "Stock Trading System Implementation" },
                    { type = "paragraph", text = "- Added a new **stock trading handler** to support market transactions.\n- Implemented the core logic required for buying and selling shares.\n- Expanded the Dynamic Trading system with full stock market support." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now buy and sell stocks through the new trading interface." },
                    { type = "heading", id = "item_item_2026_02_04_dynamictradingv2", level = 2, text = "Dynamic Trader Spawning & County Fixes" },
                    { type = "paragraph", text = "- Traders now spawn in their correct counties instead of appearing randomly.\n- *Virtually simulated spawning* ensures traders appear logically within the world.\n- Preliminary work continues on the full Dynamic Trading V2 system." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now correctly spawn in their designated counties with improved simulation." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved multiplayer radar issues, string errors, and various trading system bugs." },
                    { type = "heading", id = "item_item_2026_02_05_dynamictradingv2", level = 2, text = "Radar UI Overhaul and Multiplayer Fixes" },
                    { type = "paragraph", text = "- Radar UI now features tabs, proximity sorting, and visual selection feedback for better navigation.\n- **Multiplayer stability is restored** ensuring trader radar functions perfectly in co-op sessions.\n- Radio UI includes new distance metrics and auto-closes when the radar window is dismissed.\n- Device identification and radar value balancing have been refined for a fairer experience." },
                    { type = "callout", tone = "success", title = "Impact", text = "Trader tracking is now stable in multiplayer with improved sorting and distance indicators." },
                    { type = "heading", id = "item_item_2026_02_02_dynamictradingv2", level = 2, text = "Faction Management String Fix" },
                    { type = "paragraph", text = "- Fixed double ret strings appearing in the **faction management** interface.\n- Cleaned up text rendering to improve readability during trading interactions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves display errors in faction management menus to ensure clean UI text." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated internal string references and localized text for better clarity." },
                    { type = "heading", id = "item_item_2026_02_08_dynamictradingv2", level = 2, text = "Trader UI Updates and Multiplayer Fixes" },
                    { type = "paragraph", text = "* Fixed stock trading to function correctly in multiplayer sessions.\n* Added automatic window closure when a trader interaction expires.\n* Improved trader UI hooks and portrait display reliability.\n* Restored merchant debug functionality by fixing obsolete triggers." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves multiplayer trading errors and improves trader interface stability." },
                },
            },
        },
    })
end
