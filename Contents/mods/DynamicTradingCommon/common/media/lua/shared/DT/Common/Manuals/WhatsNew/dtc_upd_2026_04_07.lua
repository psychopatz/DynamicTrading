-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_04_07",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 04/04 - 04/07",
--   "description": "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 10,
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
--           "id": "item_item_2026_04_07_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Companions, Combat Rhythm & Supporter UI"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPC travel companions now feature a new combat rhythm and dedicated supporter UI.\n- The Hall of Fame manual and supporter carousel UI have been updated for version 1.5.1.\n- Mod version has been bumped to 1.1.1 to reflect these major additions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Adds traveling NPC companions with combat support and updates the supporter recognition system."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_06_dynamictradingcommon",
--           "level": 2,
--           "text": "Travel Companions, Bandaging, and Combat Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new travel companion job UI and integrated it with NPC dialogue systems.\n- Companions can now **self-bandage** or heal players using linked supply items.\n- Implemented full NPC bandaging animations with new UI indicators and debug tools.\n- Standardized NPC state management and integrated ranged combat with shared protection."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Companions can now bandage themselves and you, with improved combat protection logic."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_04_dynamictradingcommon",
--           "level": 2,
--           "text": "NPC Equipment System & Radio Text Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs can now be assigned specific held weapons using a new debug command.\n- Radio scan flavor text has been centralized for better consistency across the game.\n- A new registry system manages NPC archetype equipment for improved mod compatibility."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs can now be assigned specific weapons and radio messages are more consistent."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_04_07", {
        title = "Update: 04/04 - 04/07",
        description = "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 10,
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
                    { type = "heading", id = "item_item_2026_04_07_dynamictradingcommon", level = 2, text = "NPC Companions, Combat Rhythm & Supporter UI" },
                    { type = "paragraph", text = "- NPC travel companions now feature a new combat rhythm and dedicated supporter UI.\n- The Hall of Fame manual and supporter carousel UI have been updated for version 1.5.1.\n- Mod version has been bumped to 1.1.1 to reflect these major additions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Adds traveling NPC companions with combat support and updates the supporter recognition system." },
                    { type = "heading", id = "item_item_2026_04_06_dynamictradingcommon", level = 2, text = "Travel Companions, Bandaging, and Combat Updates" },
                    { type = "paragraph", text = "- Added a new travel companion job UI and integrated it with NPC dialogue systems.\n- Companions can now **self-bandage** or heal players using linked supply items.\n- Implemented full NPC bandaging animations with new UI indicators and debug tools.\n- Standardized NPC state management and integrated ranged combat with shared protection." },
                    { type = "callout", tone = "success", title = "Impact", text = "Companions can now bandage themselves and you, with improved combat protection logic." },
                    { type = "heading", id = "item_item_2026_04_04_dynamictradingcommon", level = 2, text = "NPC Equipment System & Radio Text Updates" },
                    { type = "paragraph", text = "- NPCs can now be assigned specific held weapons using a new debug command.\n- Radio scan flavor text has been centralized for better consistency across the game.\n- A new registry system manages NPC archetype equipment for improved mod compatibility." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs can now be assigned specific weapons and radio messages are more consistent." },
                },
            },
        },
    })
end
