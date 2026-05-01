-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_02_01",
--   "module": "DynamicTradingV2",
--   "title": "Update: 01/28 - 02/01",
--   "description": "Dynamic Trading: Smarter NPCs and Balanced Markets. Resolved critical bugs in trader AI behavior and NPC interaction stability. — General maintenance and internal updates to the trading common library.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
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
--       "description": "Resolved critical bugs in trader AI behavior and NPC interaction stability."
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
--           "id": "item_item_2026_01_29_dynamictradingv2",
--           "level": 2,
--           "text": "Faction Wealth System & Initialization Update"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Factions now maintain a **wealth value** to influence trading and interactions.\n- Implemented updated initialization logic to ensure stable faction setup."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Factions now track and utilize wealth values for improved economic interactions."
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
--           "text": "Resolved critical bugs in trader AI behavior and NPC interaction stability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_30_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Interaction UI and Faction Stability Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new context menu to talk with NPCs for improved interaction flow.\n- **Fixed faction initialization** to ensure consistent town data across all saves.\n- Resolved multiplayer desyncs in faction debugging and NPC base spawning logic."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced NPC dialogue options while resolving critical multiplayer and spawning issues."
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
--           "text": "General maintenance and internal updates to the trading common library."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_01_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading System Stability Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed a bug** where NPCs would get stuck in an endless away loop during cooldowns.\n- Added logic to let NPCs rest and flee properly instead of staying indefinitely.\n- Enhanced trading flexibility by adding custom parameters for better NPC behavior."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Prevents NPCs from getting stuck in infinite away loops during trades."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_31_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading Agent Behavior Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Fixed trading agent behaviors** that were failing after recent code decoupling.\n- Refactored client synchronization logic to ensure stable NPC trading performance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves critical trading agent failures to restore functional NPC interactions."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_02_01", {
        title = "Update: 01/28 - 02/01",
        description = "Dynamic Trading: Smarter NPCs and Balanced Markets. Resolved critical bugs in trader AI behavior and NPC interaction stability. — General maintenance and internal updates to the trading common library.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
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
                description = "Resolved critical bugs in trader AI behavior and NPC interaction stability.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_01_29_dynamictradingv2", level = 2, text = "Faction Wealth System & Initialization Update" },
                    { type = "paragraph", text = "- Factions now maintain a **wealth value** to influence trading and interactions.\n- Implemented updated initialization logic to ensure stable faction setup." },
                    { type = "callout", tone = "success", title = "Impact", text = "Factions now track and utilize wealth values for improved economic interactions." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved critical bugs in trader AI behavior and NPC interaction stability." },
                    { type = "heading", id = "item_item_2026_01_30_dynamictradingv2", level = 2, text = "NPC Interaction UI and Faction Stability Fixes" },
                    { type = "paragraph", text = "- Added a new context menu to talk with NPCs for improved interaction flow.\n- **Fixed faction initialization** to ensure consistent town data across all saves.\n- Resolved multiplayer desyncs in faction debugging and NPC base spawning logic." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced NPC dialogue options while resolving critical multiplayer and spawning issues." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "General maintenance and internal updates to the trading common library." },
                    { type = "heading", id = "item_item_2026_02_01_dynamictradingv2", level = 2, text = "Dynamic Trading System Stability Fixes" },
                    { type = "paragraph", text = "- **Fixed a bug** where NPCs would get stuck in an endless away loop during cooldowns.\n- Added logic to let NPCs rest and flee properly instead of staying indefinitely.\n- Enhanced trading flexibility by adding custom parameters for better NPC behavior." },
                    { type = "callout", tone = "success", title = "Impact", text = "Prevents NPCs from getting stuck in infinite away loops during trades." },
                    { type = "heading", id = "item_item_2026_01_31_dynamictradingv2", level = 2, text = "Dynamic Trading Agent Behavior Fixes" },
                    { type = "paragraph", text = "- **Fixed trading agent behaviors** that were failing after recent code decoupling.\n- Refactored client synchronization logic to ensure stable NPC trading performance." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves critical trading agent failures to restore functional NPC interactions." },
                },
            },
        },
    })
end
