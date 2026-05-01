-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_01_18",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 01/10 - 01/18",
--   "description": "Smarter NPCs and Trading Refinements. Resolved critical issues with zombie synchronization, walking paths, and trading system stability. — General code cleanup and synchronization logic updates for the trading module.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
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
--       "description": "Resolved critical issues with zombie synchronization, walking paths, and trading system stability."
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
--           "id": "item_item_2026_01_12_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Attack Range Behavior Added"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **NPCs now utilize attack range logic** to determine when to engage players.\n- Improved combat realism as enemies react appropriately to distance."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now react to threats based on their specific attack range."
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
--           "text": "Resolved critical issues with zombie synchronization, walking paths, and trading system stability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_11_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Walking Fixes and Flee Behavior"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **NPCs teleport to destinations** to prevent getting stuck while walking.\n- Added new **flee behavior** allowing NPCs to run away from threats."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now teleport to destinations and can flee from danger."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_10_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Trading System & Zombie Pathfinding Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a full NPC trading system with dialogue, intro sequences, and no-cash notifications.\n- **NPCs now dynamically change clothing** and automatically stare at nearby players or entities.\n- Fixed zombie pathfinding errors and resolved missing idle messages for traders.\n- Enabled selection of multiple NPCs and added sound effects when trader connections expire."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enables dynamic NPC trading interactions and resolves zombie movement issues."
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
--           "text": "General code cleanup and synchronization logic updates for the trading module."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_14_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Trading Item ID Corrections"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Corrected NPC item IDs to ensure **trades function properly** without errors.\n- Resolved issues where specific items could not be bought or sold from NPCs."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Fixes broken trades with NPCs caused by invalid item identifiers."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_13_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Zombie Sync Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed a synchronization error that caused zombies to behave incorrectly near traders.\n- Ensures zombie states update properly to maintain stable gameplay during dynamic events."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves synchronization issues to prevent zombie behavior glitches during trading."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_01_18", {
        title = "Update: 01/10 - 01/18",
        description = "Smarter NPCs and Trading Refinements. Resolved critical issues with zombie synchronization, walking paths, and trading system stability. — General code cleanup and synchronization logic updates for the trading module.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
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
                description = "Resolved critical issues with zombie synchronization, walking paths, and trading system stability.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_01_12_dynamictradingcommon", level = 2, text = "NPC Attack Range Behavior Added" },
                    { type = "paragraph", text = "- **NPCs now utilize attack range logic** to determine when to engage players.\n- Improved combat realism as enemies react appropriately to distance." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now react to threats based on their specific attack range." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved critical issues with zombie synchronization, walking paths, and trading system stability." },
                    { type = "heading", id = "item_item_2026_01_11_dynamictradingcommon", level = 2, text = "NPC Walking Fixes and Flee Behavior" },
                    { type = "paragraph", text = "- **NPCs teleport to destinations** to prevent getting stuck while walking.\n- Added new **flee behavior** allowing NPCs to run away from threats." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now teleport to destinations and can flee from danger." },
                    { type = "heading", id = "item_item_2026_01_10_dynamictradingcommon", level = 2, text = "NPC Trading System & Zombie Pathfinding Fixes" },
                    { type = "paragraph", text = "- Added a full NPC trading system with dialogue, intro sequences, and no-cash notifications.\n- **NPCs now dynamically change clothing** and automatically stare at nearby players or entities.\n- Fixed zombie pathfinding errors and resolved missing idle messages for traders.\n- Enabled selection of multiple NPCs and added sound effects when trader connections expire." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enables dynamic NPC trading interactions and resolves zombie movement issues." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "General code cleanup and synchronization logic updates for the trading module." },
                    { type = "heading", id = "item_item_2026_01_14_dynamictradingcommon", level = 2, text = "NPC Trading Item ID Corrections" },
                    { type = "paragraph", text = "- Corrected NPC item IDs to ensure **trades function properly** without errors.\n- Resolved issues where specific items could not be bought or sold from NPCs." },
                    { type = "callout", tone = "success", title = "Impact", text = "Fixes broken trades with NPCs caused by invalid item identifiers." },
                    { type = "heading", id = "item_item_2026_01_13_dynamictradingcommon", level = 2, text = "Dynamic Trading Zombie Sync Fixes" },
                    { type = "paragraph", text = "- Fixed a synchronization error that caused zombies to behave incorrectly near traders.\n- Ensures zombie states update properly to maintain stable gameplay during dynamic events." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves synchronization issues to prevent zombie behavior glitches during trading." },
                },
            },
        },
    })
end
