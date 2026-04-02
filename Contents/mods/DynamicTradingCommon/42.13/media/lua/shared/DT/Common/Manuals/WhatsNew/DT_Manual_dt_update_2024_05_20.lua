-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_update_2024_05_20",
--   "module": "common",
--   "title": "Dynamic Trading Major Update",
--   "description": "New NPC chat, colony management, economy UI, and labour systems.",
--   "start_page_id": "overview",
--   "audiences": [
--     "common"
--   ],
--   "sort_order": 10,
--   "release_version": "1.0.0",
--   "popup_version": "2.0.0",
--   "auto_open_on_update": true,
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
--       "description": "Recent changes and new features"
--     }
--   ],
--   "pages": [
--     {
--       "id": "overview",
--       "chapter_id": "release_notes",
--       "title": "Overview",
--       "keywords": [
--         "update",
--         "release",
--         "patch"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "highlights",
--           "level": 1,
--           "text": "Highlights"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Comprehensive in-game manual UI with search and dynamic support banners.",
--             "Brand new player-owned factions and labour management systems.",
--             "Advanced Economy Dashboard and market influence guides.",
--             "Modular NPC chat with daily reputation and faction news.",
--             "In game Price Editor (You must be an admin on MP server or in Debug in SP)"
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Auto-Open Manuals",
--           "text": "The manual will now automatically open for new updates to keep you informed!"
--         }
--       ]
--     },
--     {
--       "id": "economy_trading",
--       "chapter_id": "release_notes",
--       "title": "Economy & Trading",
--       "keywords": [
--         "economy",
--         "trading",
--         "wallet",
--         "sell"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "economy-changes",
--           "level": 1,
--           "text": "Economy Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "Trading has been significantly overhauled with new quality-of-life features and deep economic mechanics."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Added quantity selection for selling items with optimized scanning and caching.",
--             "Introduced a new wallet lottery system with state tracking.",
--             "Added support for persistent price presets and dynamic base price configuration.",
--             "New tradable building and fluid item categories."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "colony_labour",
--       "chapter_id": "release_notes",
--       "title": "Colonies & Labour",
--       "keywords": [
--         "colony",
--         "labour",
--         "faction",
--         "worker"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "colony-systems",
--           "level": 1,
--           "text": "Colonies & Labour"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Create and manage your own player-owned factions with a dedicated UI.",
--             "New medical care system featuring Doctor jobs and Infirmary buildings.",
--             "Comprehensive tiredness system for labour workers, including new states and return reasons.",
--             "Auto-repeat functionality for scavenger jobs.",
--             "New building construction, management, and destruction systems."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Tip",
--           "text": "Monitor worker fatigue and supply your infirmaries to keep your colony running smoothly."
--         }
--       ]
--     },
--     {
--       "id": "npc_interaction",
--       "chapter_id": "release_notes",
--       "title": "NPC Interactions",
--       "keywords": [
--         "npc",
--         "chat",
--         "dialogue",
--         "reputation"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "npc-chat",
--           "level": 1,
--           "text": "NPC Interactions & Chat"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "New daily chat reputation system.(Moved to other mod Dynamic Colonies)",
--             "Expanded NPC dialogue options with faction news and personal info.",
--             "Refactored trader dialogue hubs to support modular chat interactions.",
--             "Archetype-based roster spawning and dynamic trade mode restrictions."
--           ]
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_update_2024_05_20", {
        title = "Dynamic Trading Major Update",
        description = "New NPC chat, colony management, economy UI, and labour systems.",
        startPageId = "overview",
        audiences = { "common" },
        sortOrder = 10,
        releaseVersion = "1.0.0",
        popupVersion = "2.0.0",
        autoOpenOnUpdate = true,
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
                description = "Recent changes and new features",
            },
        },
        pages = {
            {
                id = "overview",
                chapterId = "release_notes",
                title = "Overview",
                keywords = { "update", "release", "patch" },
                blocks = {
                    { type = "heading", id = "highlights", level = 1, text = "Highlights" },
                    { type = "bullet_list", items = { "Comprehensive in-game manual UI with search and dynamic support banners.", "Brand new player-owned factions and labour management systems.", "Advanced Economy Dashboard and market influence guides.", "Modular NPC chat with daily reputation and faction news.", "In game Price Editor (You must be an admin on MP server or in Debug in SP)" } },
                    { type = "callout", tone = "info", title = "Auto-Open Manuals", text = "The manual will now automatically open for new updates to keep you informed!" },
                },
            },
            {
                id = "economy_trading",
                chapterId = "release_notes",
                title = "Economy & Trading",
                keywords = { "economy", "trading", "wallet", "sell" },
                blocks = {
                    { type = "heading", id = "economy-changes", level = 1, text = "Economy Enhancements" },
                    { type = "paragraph", text = "Trading has been significantly overhauled with new quality-of-life features and deep economic mechanics." },
                    { type = "bullet_list", items = { "Added quantity selection for selling items with optimized scanning and caching.", "Introduced a new wallet lottery system with state tracking.", "Added support for persistent price presets and dynamic base price configuration.", "New tradable building and fluid item categories." } },
                },
            },
            {
                id = "colony_labour",
                chapterId = "release_notes",
                title = "Colonies & Labour",
                keywords = { "colony", "labour", "faction", "worker" },
                blocks = {
                    { type = "heading", id = "colony-systems", level = 1, text = "Colonies & Labour" },
                    { type = "bullet_list", items = { "Create and manage your own player-owned factions with a dedicated UI.", "New medical care system featuring Doctor jobs and Infirmary buildings.", "Comprehensive tiredness system for labour workers, including new states and return reasons.", "Auto-repeat functionality for scavenger jobs.", "New building construction, management, and destruction systems." } },
                    { type = "callout", tone = "info", title = "Tip", text = "Monitor worker fatigue and supply your infirmaries to keep your colony running smoothly." },
                },
            },
            {
                id = "npc_interaction",
                chapterId = "release_notes",
                title = "NPC Interactions",
                keywords = { "npc", "chat", "dialogue", "reputation" },
                blocks = {
                    { type = "heading", id = "npc-chat", level = 1, text = "NPC Interactions & Chat" },
                    { type = "bullet_list", items = { "New daily chat reputation system.(Moved to other mod Dynamic Colonies)", "Expanded NPC dialogue options with faction news and personal info.", "Refactored trader dialogue hubs to support modular chat interactions.", "Archetype-based roster spawning and dynamic trade mode restrictions." } },
                },
            },
        },
    })
end
