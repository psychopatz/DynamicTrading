-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_upd_2026_04_07",
--   "module": "DynamicTrading",
--   "title": "Update: 04/04 - 04/07",
--   "description": "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors. — Radio scan flavor text has been centralized to improve consistency and readability across the game.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTrading"
--   ],
--   "sort_order": 5,
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
--       "description": "New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors."
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
--           "text": "New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_07_dynamictrading",
--           "level": 2,
--           "text": "NPC Travel Companions and Combat Rhythm"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs can now join you as **travel companions** with improved combat timing.\n- Added a new **Supporter UI** to manage your allied NPCs more effectively.\n- Updated mod version to 1.1.1 to support these new companion features."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now travel with you, fight with better rhythm, and offer new supporter interactions."
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
--           "text": "Radio scan flavor text has been centralized to improve consistency and readability across the game."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_04_dynamictrading",
--           "level": 2,
--           "text": "Radio Scan Flavor Text Centralization"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Centralized radio scan flavor text** into a shared utility module for better consistency.\n- Streamlined localization data to support future language additions and translations."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Ensures radio scanning messages are consistent and easier to translate across all languages."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_upd_2026_04_07", {
        title = "Update: 04/04 - 04/07",
        description = "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors. — Radio scan flavor text has been centralized to improve consistency and readability across the game.",
        startPageId = "cat_features",
        audiences = { "DynamicTrading" },
        sortOrder = 5,
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
                description = "New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Features Highlights", text = "New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors." },
                    { type = "heading", id = "item_item_2026_04_07_dynamictrading", level = 2, text = "NPC Travel Companions and Combat Rhythm" },
                    { type = "paragraph", text = "- NPCs can now join you as **travel companions** with improved combat timing.\n- Added a new **Supporter UI** to manage your allied NPCs more effectively.\n- Updated mod version to 1.1.1 to support these new companion features." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now travel with you, fight with better rhythm, and offer new supporter interactions." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Radio scan flavor text has been centralized to improve consistency and readability across the game." },
                    { type = "heading", id = "item_item_2026_04_04_dynamictrading", level = 2, text = "Radio Scan Flavor Text Centralization" },
                    { type = "paragraph", text = "- **Centralized radio scan flavor text** into a shared utility module for better consistency.\n- Streamlined localization data to support future language additions and translations." },
                    { type = "callout", tone = "success", title = "Impact", text = "Ensures radio scanning messages are consistent and easier to translate across all languages." },
                },
            },
        },
    })
end
