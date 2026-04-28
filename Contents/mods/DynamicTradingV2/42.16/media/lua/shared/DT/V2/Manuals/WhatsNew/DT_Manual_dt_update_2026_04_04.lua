-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_update_2026_04_04",
--   "module": "DynamicTradingV2",
--   "title": "April 5, 2026 Update",
--   "description": "NPC Combat Update",
--   "start_page_id": "overview",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 10,
--   "release_version": "1.1.0",
--   "popup_version": "1.1.0",
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
--       "description": "What changed"
--     }
--   ],
--   "pages": [
--     {
--       "id": "overview",
--       "chapter_id": "release_notes",
--       "title": "Overview",
--       "keywords": [
--         "update",
--         "release"
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
--             "New DynamicTrading V2 NPC lifecycle and network sync",
--             "Dedicated V2 loader files for shared/server/client",
--             "Sandbox options: NPC walk speed, crawler speed, base armor, durability",
--             "NPC combat updates: pursuit, flee, protection, and animation sets",
--             "Map-agnostic trading encounters with re-anchoring"
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Note",
--           "text": "Requires V2 save compatibility and server restart."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_update_2026_04_04", {
        title = "April 5, 2026 Update",
        description = "NPC Combat Update",
        startPageId = "overview",
        audiences = { "DynamicTradingV2" },
        sortOrder = 10,
        releaseVersion = "1.1.0",
        popupVersion = "1.1.0",
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
                description = "What changed",
            },
        },
        pages = {
            {
                id = "overview",
                chapterId = "release_notes",
                title = "Overview",
                keywords = { "update", "release" },
                blocks = {
                    { type = "heading", id = "highlights", level = 1, text = "Highlights" },
                    { type = "bullet_list", items = { "New DynamicTrading V2 NPC lifecycle and network sync", "Dedicated V2 loader files for shared/server/client", "Sandbox options: NPC walk speed, crawler speed, base armor, durability", "NPC combat updates: pursuit, flee, protection, and animation sets", "Map-agnostic trading encounters with re-anchoring" } },
                    { type = "callout", tone = "info", title = "Note", text = "Requires V2 save compatibility and server restart." },
                },
            },
        },
    })
end
