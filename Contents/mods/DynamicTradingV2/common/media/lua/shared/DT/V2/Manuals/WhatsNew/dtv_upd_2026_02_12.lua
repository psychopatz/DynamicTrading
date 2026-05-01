-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtv_upd_2026_02_12",
--   "module": "DynamicTradingV2",
--   "title": "Update: 02/09 - 02/12",
--   "description": "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Adds radar enhancements, radio updates, and improved navigation tools for traders.",
--   "start_page_id": "cat_fixes",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 4,
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
--       "description": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
--     }
--   ],
--   "pages": [
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
--           "text": "Resolves critical UI glitches, translation errors, and multiplayer network instability."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_11_dynamictradingv2",
--           "level": 2,
--           "text": "Trading Network UI Fixes and Refactoring"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Fixed overlapping trader UI elements by implementing a stencil wrapper.\n- **Reduced log spam** caused by visibility checks during trader despawn events.\n- Decoupled core trading logic to improve mod stability and future updates.\n- Added support for translations and a more flexible configuration manager."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves visual glitches and improves system stability for traders."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_10_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading UI & Multiplayer Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "* The trading window now includes a new info tab and **persistent event markers** for better tracking.\n* Traders will explicitly refuse trades while resting instead of simply hiding their interface.\n* Fixed critical multiplayer issues where item attributes failed to apply correctly during trades.\n* Optimized performance by preventing unnecessary checks when the trading window is closed."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced trading stability and new information features for better player interaction."
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
--           "text": "Adds radar enhancements, radio updates, and improved navigation tools for traders."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_09_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading Radar and Radio UI Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Location information is now displayed** directly within the radar user interface.\n- A new dedicated location tab has been added to the radio menu for easier access.\n- Underlying item and archetype registration systems were refactored for better stability."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhanced trading navigation with new location data across radar and radio interfaces."
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
--           "text": "Includes general refactoring and backend updates to support the new systems."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_02_12_dynamictradingv2",
--           "level": 2,
--           "text": "Dynamic Trading V2 Event System Launch"
--         },
--         {
--           "type": "paragraph",
--           "text": "* Traders now feature a new event system that reacts to **global heat** and dynamic loading.\n* Fixed trader message display issues and restored full **color UI support** in V2.\n* Added Louisville base spawn options and reorganized sandbox settings for easier access."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now react to global heat and launch dynamic events with new UI support."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtv_upd_2026_02_12", {
        title = "Update: 02/09 - 02/12",
        description = "Dynamic Trading V2: Events, UI, and Stability. Resolves critical UI glitches, translation errors, and multiplayer network instability. — Adds radar enhancements, radio updates, and improved navigation tools for traders.",
        startPageId = "cat_fixes",
        audiences = { "DynamicTradingV2" },
        sortOrder = 4,
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
                description = "Resolves critical UI glitches, translation errors, and multiplayer network instability.",
            },
        },
        pages = {
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolves critical UI glitches, translation errors, and multiplayer network instability." },
                    { type = "heading", id = "item_item_2026_02_11_dynamictradingv2", level = 2, text = "Trading Network UI Fixes and Refactoring" },
                    { type = "paragraph", text = "- Fixed overlapping trader UI elements by implementing a stencil wrapper.\n- **Reduced log spam** caused by visibility checks during trader despawn events.\n- Decoupled core trading logic to improve mod stability and future updates.\n- Added support for translations and a more flexible configuration manager." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves visual glitches and improves system stability for traders." },
                    { type = "heading", id = "item_item_2026_02_10_dynamictradingv2", level = 2, text = "Dynamic Trading UI & Multiplayer Fixes" },
                    { type = "paragraph", text = "* The trading window now includes a new info tab and **persistent event markers** for better tracking.\n* Traders will explicitly refuse trades while resting instead of simply hiding their interface.\n* Fixed critical multiplayer issues where item attributes failed to apply correctly during trades.\n* Optimized performance by preventing unnecessary checks when the trading window is closed." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced trading stability and new information features for better player interaction." },
                },
            },
            {
                id = "cat_qol",
                chapterId = "release_notes",
                title = "QoL",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "QoL Highlights", text = "Adds radar enhancements, radio updates, and improved navigation tools for traders." },
                    { type = "heading", id = "item_item_2026_02_09_dynamictradingv2", level = 2, text = "Dynamic Trading Radar and Radio UI Updates" },
                    { type = "paragraph", text = "- **Location information is now displayed** directly within the radar user interface.\n- A new dedicated location tab has been added to the radio menu for easier access.\n- Underlying item and archetype registration systems were refactored for better stability." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhanced trading navigation with new location data across radar and radio interfaces." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Includes general refactoring and backend updates to support the new systems." },
                    { type = "heading", id = "item_item_2026_02_12_dynamictradingv2", level = 2, text = "Dynamic Trading V2 Event System Launch" },
                    { type = "paragraph", text = "* Traders now feature a new event system that reacts to **global heat** and dynamic loading.\n* Fixed trader message display issues and restored full **color UI support** in V2.\n* Added Louisville base spawn options and reorganized sandbox settings for easier access." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now react to global heat and launch dynamic events with new UI support." },
                },
            },
        },
    })
end
