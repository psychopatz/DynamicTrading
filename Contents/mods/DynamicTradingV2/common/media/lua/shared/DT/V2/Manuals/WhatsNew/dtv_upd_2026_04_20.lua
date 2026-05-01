-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_04_20",
--   "module": "DynamicTradingV2",
--   "title": "Update: 04/08 - 04/20",
--   "description": "The April Sprint: New Tools & Refinements. Improved radio contact scheduling, companion UI visibility, and faction management interfaces. — Optimized UI rendering and core logic to support Build 42.16 with reduced lag.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 8,
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
--           "id": "item_item_2026_04_18_dynamictradingv2",
--           "level": 2,
--           "text": "Radio Scanner Overhaul & Faction Logging"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Radio scanner logic overhauled** to prioritize contact visits with dynamic success probabilities and night gate options.\n- New UI icons and visual feedback added to context menus to prevent radar scan spam and improve signal state clarity.\n- Comprehensive faction logging implemented to track membership, leadership, reputation, and combat events in real time.\n- Trader session budget integration and death state logic added to ensure accurate trading window data and expiry formatting."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced radio scanning mechanics with new visual feedback and comprehensive faction event tracking."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_17_dynamictradingv2",
--           "level": 2,
--           "text": "Radio Contact Visits, Companion Radar & Trading Upgrades"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New radio contact visits** allow players to request NPC arrivals with dynamic UI feedback and ETA tracking.\n- **Companion radar system** now supports ownership filtering, inventory prompts, and interactive loot collection.\n- **Trading updates** include a new calendar UI, scheduling enforcement, and a centralized debug hub for tools.\n- **Global trader contacts** feature a dedicated UI for managing and viewing saved NPC frequencies."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Streamlines NPC interactions with new radio contact visits, companion radar features, and enhanced trading tools."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_16_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Combat Logic & Loot Vision Enhancements"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Guards receive new combat orders and stay behaviors with **customizable UI colors** for better visual feedback.\n- Added a loot vision inspector tool to help players debug NPC looting and safety logic issues.\n- Implemented anti-stuck recovery and durable weapon retirement to prevent NPCs from getting trapped or using broken gear.\n- Refined NPC targeting to prevent accidental aggression toward players and improved respawn body identification."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Guards now follow smarter combat orders while loot visibility and debugging tools are significantly improved."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_13_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Combat, Mobility, and Trading Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs gained **advanced combat evasion**, damage mitigation, and proper friendly fire protection.\n- Movement logic was rebuilt to standardize walking, running, and obstacle avoidance behaviors.\n- Trading systems were modularized to support ranged combat and better health state management.\n- Fixed animation tracking for bandages and ensured NPCs leave safely instead of despawning."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now fight smarter, move more naturally, and trade safely without friendly fire."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_08_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Equipment Loadouts & Combat Fallback"
--         },
--         {
--           "type": "paragraph",
--           "text": "- NPCs now select and display candidate equipment visuals for realistic loadouts.\n- Added combat fallback logic to prevent errors when NPC gear is missing.\n- *Notifications* alert players when an NPC lacks a valid loadout during auto-protect."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "NPCs now display proper gear and handle missing loadouts safely during combat."
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
--           "text": "Improved radio contact scheduling, companion UI visibility, and faction management interfaces."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_04_14_dynamictradingv2",
--           "level": 2,
--           "text": "NPC Portrait System & Companion UI Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a new shared NPC portrait system with rendering tools and a debug overlay.\n- **Companion UI** now supports transferring and claiming travel commands.\n- Fixed NPC crawling animations and self-bandage logic for better survival realism.\n- Implemented medical supply tracking to validate NPC self-patching actions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced NPC visual feedback and improved companion command management."
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
--           "id": "item_item_2026_04_15_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading V2 Update and Optimization"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added full support for build 42.16 to ensure compatibility with the latest game updates.\n- **Migrated all assets and animations** to a common directory for better organization and performance.\n- Removed obsolete files and legacy logic to reduce mod overhead and prevent potential conflicts.\n- Streamlined sandbox options and reorganized event modules for a cleaner configuration experience."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Dynamic Trading V2 now supports the latest game version with improved stability and streamlined settings."
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
--           "id": "item_item_2026_04_20_dynamictradingv2",
--           "level": 2,
--           "text": "Geolocator System & Map Data Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The new Geolocator system now manages map data and town boundaries automatically.\n- **Automated faction location resolution** is fully integrated for smoother gameplay.\n- Internal map data structures have been refactored to support future expansions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Automated faction location resolution now handles map boundaries and town data."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_04_20", {
        title = "Update: 04/08 - 04/20",
        description = "The April Sprint: New Tools & Refinements. Improved radio contact scheduling, companion UI visibility, and faction management interfaces. — Optimized UI rendering and core logic to support Build 42.16 with reduced lag.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingV2" },
        sortOrder = 8,
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
                    { type = "heading", id = "item_item_2026_04_18_dynamictradingv2", level = 2, text = "Radio Scanner Overhaul & Faction Logging" },
                    { type = "paragraph", text = "- **Radio scanner logic overhauled** to prioritize contact visits with dynamic success probabilities and night gate options.\n- New UI icons and visual feedback added to context menus to prevent radar scan spam and improve signal state clarity.\n- Comprehensive faction logging implemented to track membership, leadership, reputation, and combat events in real time.\n- Trader session budget integration and death state logic added to ensure accurate trading window data and expiry formatting." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced radio scanning mechanics with new visual feedback and comprehensive faction event tracking." },
                    { type = "heading", id = "item_item_2026_04_17_dynamictradingv2", level = 2, text = "Radio Contact Visits, Companion Radar & Trading Upgrades" },
                    { type = "paragraph", text = "- **New radio contact visits** allow players to request NPC arrivals with dynamic UI feedback and ETA tracking.\n- **Companion radar system** now supports ownership filtering, inventory prompts, and interactive loot collection.\n- **Trading updates** include a new calendar UI, scheduling enforcement, and a centralized debug hub for tools.\n- **Global trader contacts** feature a dedicated UI for managing and viewing saved NPC frequencies." },
                    { type = "callout", tone = "success", title = "Impact", text = "Streamlines NPC interactions with new radio contact visits, companion radar features, and enhanced trading tools." },
                    { type = "heading", id = "item_item_2026_04_16_dynamictradingv2", level = 2, text = "NPC Combat Logic & Loot Vision Enhancements" },
                    { type = "paragraph", text = "- Guards receive new combat orders and stay behaviors with **customizable UI colors** for better visual feedback.\n- Added a loot vision inspector tool to help players debug NPC looting and safety logic issues.\n- Implemented anti-stuck recovery and durable weapon retirement to prevent NPCs from getting trapped or using broken gear.\n- Refined NPC targeting to prevent accidental aggression toward players and improved respawn body identification." },
                    { type = "callout", tone = "success", title = "Impact", text = "Guards now follow smarter combat orders while loot visibility and debugging tools are significantly improved." },
                    { type = "heading", id = "item_item_2026_04_13_dynamictradingv2", level = 2, text = "NPC Combat, Mobility, and Trading Overhaul" },
                    { type = "paragraph", text = "- NPCs gained **advanced combat evasion**, damage mitigation, and proper friendly fire protection.\n- Movement logic was rebuilt to standardize walking, running, and obstacle avoidance behaviors.\n- Trading systems were modularized to support ranged combat and better health state management.\n- Fixed animation tracking for bandages and ensured NPCs leave safely instead of despawning." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now fight smarter, move more naturally, and trade safely without friendly fire." },
                    { type = "heading", id = "item_item_2026_04_08_dynamictradingv2", level = 2, text = "NPC Equipment Loadouts & Combat Fallback" },
                    { type = "paragraph", text = "- NPCs now select and display candidate equipment visuals for realistic loadouts.\n- Added combat fallback logic to prevent errors when NPC gear is missing.\n- *Notifications* alert players when an NPC lacks a valid loadout during auto-protect." },
                    { type = "callout", tone = "success", title = "Impact", text = "NPCs now display proper gear and handle missing loadouts safely during combat." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Improved radio contact scheduling, companion UI visibility, and faction management interfaces." },
                    { type = "heading", id = "item_item_2026_04_14_dynamictradingv2", level = 2, text = "NPC Portrait System & Companion UI Updates" },
                    { type = "paragraph", text = "- Added a new shared NPC portrait system with rendering tools and a debug overlay.\n- **Companion UI** now supports transferring and claiming travel commands.\n- Fixed NPC crawling animations and self-bandage logic for better survival realism.\n- Implemented medical supply tracking to validate NPC self-patching actions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced NPC visual feedback and improved companion command management." },
                },
            },
            {
                id = "cat_performance",
                chapterId = "release_notes",
                title = "Performance",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Performance Highlights", text = "Optimized UI rendering and core logic to support Build 42.16 with reduced lag." },
                    { type = "heading", id = "item_item_2026_04_15_dynamictradingv2", level = 2, text = "Dynamic Trading V2 Update and Optimization" },
                    { type = "paragraph", text = "- Added full support for build 42.16 to ensure compatibility with the latest game updates.\n- **Migrated all assets and animations** to a common directory for better organization and performance.\n- Removed obsolete files and legacy logic to reduce mod overhead and prevent potential conflicts.\n- Streamlined sandbox options and reorganized event modules for a cleaner configuration experience." },
                    { type = "callout", tone = "success", title = "Impact", text = "Dynamic Trading V2 now supports the latest game version with improved stability and streamlined settings." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated internal versioning and refactored codebase for better mod maintainability." },
                    { type = "heading", id = "item_item_2026_04_20_dynamictradingv2", level = 2, text = "Geolocator System & Map Data Updates" },
                    { type = "paragraph", text = "- The new Geolocator system now manages map data and town boundaries automatically.\n- **Automated faction location resolution** is fully integrated for smoother gameplay.\n- Internal map data structures have been refactored to support future expansions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Automated faction location resolution now handles map boundaries and town data." },
                },
            },
        },
    })
end
