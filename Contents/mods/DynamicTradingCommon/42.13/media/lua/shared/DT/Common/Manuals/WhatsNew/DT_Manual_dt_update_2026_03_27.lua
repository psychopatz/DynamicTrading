-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_update_2026_03_27",
--   "title": "March 27, 2026 Update",
--   "description": "Patch highlights and release notes for the manual library upgrade.",
--   "start_page_id": "update_overview",
--   "audiences": [
--     "common"
--   ],
--   "sort_order": 10,
--   "release_version": "2026-03-27",
--   "popup_version": "2026-03-27",
--   "manual_type": "whats_new",
--   "auto_open_on_update": true,
--   "is_whats_new": true,
--   "show_in_library": false,
--   "chapters": [
--     {
--       "id": "release_notes",
--       "title": "Release Notes",
--       "description": "What changed in this update."
--     }
--   ],
--   "pages": [
--     {
--       "id": "update_overview",
--       "chapter_id": "release_notes",
--       "title": "Manual Library Upgrade",
--       "keywords": [
--         "update",
--         "release",
--         "patch",
--         "what's new"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "manual-library-upgrade",
--           "level": 1,
--           "text": "Manual Library Upgrade"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "The manual browser now supports version-aware documentation for V1, V2, and Dynamic Colonies.",
--             "Manual ordering is now driven by explicit hierarchy data instead of an alphabetical fallback.",
--             "The update system now opens in a dedicated What's New view instead of being mixed into the normal manual library.",
--             "The Dynamic Trading Manager now supports manual ordering metadata and a dedicated update editor."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "How It Works",
--           "text": "Use the checkbox in the update viewer to stop this version from auto-opening again. A newer release version will automatically re-enable update popups."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_update_2026_03_27", {
        title = "March 27, 2026 Update",
        description = "Patch highlights and release notes for the manual library upgrade.",
        startPageId = "update_overview",
        audiences = { "common" },
        sortOrder = 10,
        releaseVersion = "2026-03-27",
        popupVersion = "2026-03-27",
        manualType = "whats_new",
        autoOpenOnUpdate = true,
        isWhatsNew = true,
        showInLibrary = false,
        chapters = {
            {
                id = "release_notes",
                title = "Release Notes",
                description = "What changed in this update.",
            },
        },
        pages = {
            {
                id = "update_overview",
                chapterId = "release_notes",
                title = "Manual Library Upgrade",
                keywords = { "update", "release", "patch", "what's new" },
                blocks = {
                    { type = "heading", id = "manual-library-upgrade", level = 1, text = "Manual Library Upgrade" },
                    { type = "bullet_list", items = {
                        "The manual browser now supports version-aware documentation for V1, V2, and Dynamic Colonies.",
                        "Manual ordering is now driven by explicit hierarchy data instead of an alphabetical fallback.",
                        "The update system now opens in a dedicated What's New view instead of being mixed into the normal manual library.",
                        "The Dynamic Trading Manager now supports manual ordering metadata and a dedicated update editor."
                    } },
                    { type = "callout", tone = "info", title = "How It Works", text = "Use the checkbox in the update viewer to stop this version from auto-opening again. A newer release version will automatically re-enable update popups." },
                },
            },
        },
    })
end
