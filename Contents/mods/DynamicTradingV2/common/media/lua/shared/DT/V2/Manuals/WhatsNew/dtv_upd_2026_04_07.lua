-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_04_07",
--   "module": "DynamicTradingV2",
--   "title": "Update: 04/04 - 04/07",
--   "description": "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors. — The supporter UI received updates to better reflect the new companion and combat systems.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 7,
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
--           "id": "item_item_2026_04_06_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Combat, Health, and Companion Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Travel companions now have dedicated job UIs, order menus, and can self-bandage using linked supplies.\n- **NPC combat is overhauled** with tactical recovery, kiting, dynamic flavor text, and modular aggro management.\n- Health systems are modularized to support passive regeneration, custom incapacitation values, and offline processing.\n- Ranged combat logic is standardized with new sandbox options and an in-game manual for all NPC behaviors."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now fight smarter, heal themselves, and can travel as companions with full UI support."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_05_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Combat Health and Pursuit Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs feature a new health system with configurable scaling for balanced combat.\n- **Smart pursuit logic** now tracks targets and stops chasing unreachable enemies.\n- Fixed NPC movement animations to ensure consistent walking states during fights."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now fight with realistic health scaling and smarter pursuit tracking."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_04_dynamictradingv2",
--           "level": 2,
--           "text": "NPC System Overhaul and Combat Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs gain an **ambient auto-defense system** that activates while they are stationary.\n- Improved zombie persistence uses weighted scoring to prevent duplicates and ensure stability.\n- New sandbox options allow players to control weapon durability and suppress engine states.\n- Combat behavior includes custom animations and patches for vanilla fishing compatibility."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now feature smarter combat behavior, better persistence, and new defensive capabilities."
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
--           "text": "The supporter UI received updates to better reflect the new companion and combat systems."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_07_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Travel Companions and Combat Rhythm"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **NPCs can now join you as travel companions** and engage in combat with improved rhythm.\n- A new **Supporter UI** has been added to manage companion interactions and status.\n- The mod version has been updated to 1.1.1 to reflect these significant additions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now travel with you, fight with better timing, and offer a new supporter interface."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_04_07", {
        title = "Update: 04/04 - 04/07",
        description = "Companions, Combat, and System Overhaul. New NPC travel companions now join your group with improved combat rhythms, health systems, and pursuit behaviors. — The supporter UI received updates to better reflect the new companion and combat systems.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
        sortOrder = 7,
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
                    { type = "heading", id = "item_item_2026_04_06_dynamictradingv2", level = 2, text = "NPC Combat, Health, and Companion Overhaul" },
                    { type = "paragraph", text = "- Travel companions now have dedicated job UIs, order menus, and can self-bandage using linked supplies.\n- **NPC combat is overhauled** with tactical recovery, kiting, dynamic flavor text, and modular aggro management.\n- Health systems are modularized to support passive regeneration, custom incapacitation values, and offline processing.\n- Ranged combat logic is standardized with new sandbox options and an in-game manual for all NPC behaviors." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now fight smarter, heal themselves, and can travel as companions with full UI support." },
                    { type = "heading", id = "item_item_2026_04_05_dynamictradingv2", level = 2, text = "NPC Combat Health and Pursuit Enhancements" },
                    { type = "paragraph", text = "- NPCs feature a new health system with configurable scaling for balanced combat.\n- **Smart pursuit logic** now tracks targets and stops chasing unreachable enemies.\n- Fixed NPC movement animations to ensure consistent walking states during fights." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now fight with realistic health scaling and smarter pursuit tracking." },
                    { type = "heading", id = "item_item_2026_04_04_dynamictradingv2", level = 2, text = "NPC System Overhaul and Combat Enhancements" },
                    { type = "paragraph", text = "- NPCs gain an **ambient auto-defense system** that activates while they are stationary.\n- Improved zombie persistence uses weighted scoring to prevent duplicates and ensure stability.\n- New sandbox options allow players to control weapon durability and suppress engine states.\n- Combat behavior includes custom animations and patches for vanilla fishing compatibility." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now feature smarter combat behavior, better persistence, and new defensive capabilities." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "The supporter UI received updates to better reflect the new companion and combat systems." },
                    { type = "heading", id = "item_item_2026_04_07_dynamictradingv2", level = 2, text = "NPC Travel Companions and Combat Rhythm" },
                    { type = "paragraph", text = "- **NPCs can now join you as travel companions** and engage in combat with improved rhythm.\n- A new **Supporter UI** has been added to manage companion interactions and status.\n- The mod version has been updated to 1.1.1 to reflect these significant additions." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now travel with you, fight with better timing, and offer a new supporter interface." },
                },
            },
        },
    })
end
