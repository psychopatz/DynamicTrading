-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dynamic_trading_radio_tech",
--   "module": "DynamicTradingCommon",
--   "title": "Signal Hardware Compar",
--   "description": "Analysis of Handhelds vs HAM radios and their signal multipliers.",
--   "start_page_id": "hardware_types",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 3,
--   "release_version": "",
--   "popup_version": "",
--   "auto_open_on_update": false,
--   "is_whats_new": false,
--   "manual_type": "manual",
--   "show_in_library": true,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "Universal",
--   "chapters": [
--     {
--       "id": "hardware_classes",
--       "title": "Hardware Classes",
--       "description": "Distinguishing Walkies from Base Stations."
--     },
--     {
--       "id": "multipliers",
--       "title": "Performance Multipliers",
--       "description": "How power and capacity scaling works."
--     }
--   ],
--   "pages": [
--     {
--       "id": "hardware_types",
--       "chapter_id": "hardware_classes",
--       "title": "Handhelds vs. Base Stations",
--       "keywords": [
--         "walkie",
--         "ham",
--         "radio",
--         "mobile",
--         "base"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "device-types",
--           "level": 1,
--           "text": "The Two Classes of Comms"
--         },
--         {
--           "type": "paragraph",
--           "text": "Not all signals are created equal. In the wasteland, your choice of hardware dictates whether you are catching local chatter or monitoring the entire state. There are two primary classes of radio technology."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Handheld Radios (Walkie-Talkies): Designed for portability. They have lower power output and limited channel capacity, making them best for close-range survival.",
--             "Base Stations (HAM & Military): Massive, heavy units that require a fixed location or a dedicated vehicle. These units offer the highest multipliers for both range and signal stability."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Operational Note",
--           "text": "Base Stations often require a direct power grid connection or heavy-duty batteries to maintain their high-performance signals."
--         }
--       ]
--     },
--     {
--       "id": "multiplier_breakdown",
--       "chapter_id": "multipliers",
--       "title": "Multipliers & Capacity",
--       "keywords": [
--         "power",
--         "capacity",
--         "multipliers",
--         "scaling"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "power-scaling",
--           "level": 1,
--           "text": "Signal Power Multipliers"
--         },
--         {
--           "type": "paragraph",
--           "text": "Your hardware type applies a direct multiplier to your discovery success rate. This is visualised at the top of your radio interface as Signal Power."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Walkie-Talkies (x0.5 - x1.2): Best for scanning the immediate town. They struggle with deep-woods or cross-county signals.",
--             "HAM Radios (x1.5 - x2.5): The gold standard for traders. High power allows for constant signal acquisition across the Exclusion Zone.",
--             "Military Grade (x3.0+): Experimental hardware that ignores most atmospheric interference."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "capacity-scaling",
--           "level": 2,
--           "text": "Channel Capacity"
--         },
--         {
--           "type": "paragraph",
--           "text": "Hardware also plateaus based on how many concurrent frequencies it can lock. This is your Channel Capacity."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Civilian Models: Usually capped at 3-5 active signals. You will have to discard old signals frequently.",
--             "Industrial/HAM: Can track 10-15 signals simultaneously without losing the lock.",
--             "High-Tier Military: Capable of maintaining 20+ active frequencies in the Network Log."
--           ]
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dynamic_trading_radio_tech", {
        title = "Signal Hardware Compar",
        description = "Analysis of Handhelds vs HAM radios and their signal multipliers.",
        startPageId = "hardware_types",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 3,
        releaseVersion = "",
        popupVersion = "",
        autoOpenOnUpdate = false,
        isWhatsNew = false,
        manualType = "manual",
        showInLibrary = true,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "hardware_classes",
                title = "Hardware Classes",
                description = "Distinguishing Walkies from Base Stations.",
            },
            {
                id = "multipliers",
                title = "Performance Multipliers",
                description = "How power and capacity scaling works.",
            },
        },
        pages = {
            {
                id = "hardware_types",
                chapterId = "hardware_classes",
                title = "Handhelds vs. Base Stations",
                keywords = { "walkie", "ham", "radio", "mobile", "base" },
                blocks = {
                    { type = "heading", id = "device-types", level = 1, text = "The Two Classes of Comms" },
                    { type = "paragraph", text = "Not all signals are created equal. In the wasteland, your choice of hardware dictates whether you are catching local chatter or monitoring the entire state. There are two primary classes of radio technology." },
                    { type = "bullet_list", items = { "Handheld Radios (Walkie-Talkies): Designed for portability. They have lower power output and limited channel capacity, making them best for close-range survival.", "Base Stations (HAM & Military): Massive, heavy units that require a fixed location or a dedicated vehicle. These units offer the highest multipliers for both range and signal stability." } },
                    { type = "callout", tone = "info", title = "Operational Note", text = "Base Stations often require a direct power grid connection or heavy-duty batteries to maintain their high-performance signals." },
                },
            },
            {
                id = "multiplier_breakdown",
                chapterId = "multipliers",
                title = "Multipliers & Capacity",
                keywords = { "power", "capacity", "multipliers", "scaling" },
                blocks = {
                    { type = "heading", id = "power-scaling", level = 1, text = "Signal Power Multipliers" },
                    { type = "paragraph", text = "Your hardware type applies a direct multiplier to your discovery success rate. This is visualised at the top of your radio interface as Signal Power." },
                    { type = "bullet_list", items = { "Walkie-Talkies (x0.5 - x1.2): Best for scanning the immediate town. They struggle with deep-woods or cross-county signals.", "HAM Radios (x1.5 - x2.5): The gold standard for traders. High power allows for constant signal acquisition across the Exclusion Zone.", "Military Grade (x3.0+): Experimental hardware that ignores most atmospheric interference." } },
                    { type = "heading", id = "capacity-scaling", level = 2, text = "Channel Capacity" },
                    { type = "paragraph", text = "Hardware also plateaus based on how many concurrent frequencies it can lock. This is your Channel Capacity." },
                    { type = "bullet_list", items = { "Civilian Models: Usually capped at 3-5 active signals. You will have to discard old signals frequently.", "Industrial/HAM: Can track 10-15 signals simultaneously without losing the lock.", "High-Tier Military: Capable of maintaining 20+ active frequencies in the Network Log." } },
                },
            },
        },
    })
end
