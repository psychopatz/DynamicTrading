-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dynamic_trading_radio_tiers",
--   "module": "DynamicTradingCommon",
--   "title": "Hardware Tier List",
--   "description": "Comprehensive guide to all ten tiers of radio technology.",
--   "start_page_id": "tier_overview",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 2,
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
--       "id": "tier_list",
--       "title": "Hardware Tiers",
--       "description": "Detailed breakdown of the 10 tiers of signals."
--     },
--     {
--       "id": "acquisition",
--       "title": "Finding Equipment",
--       "description": "Where to source better technology."
--     }
--   ],
--   "pages": [
--     {
--       "id": "tier_overview",
--       "chapter_id": "tier_list",
--       "title": "Ten Tiers of Technology",
--       "keywords": [
--         "tiers",
--         "power",
--         "capacity",
--         "military",
--         "ham"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "hardware-selection",
--           "level": 1,
--           "text": "The 10 Tiers of Signals"
--         },
--         {
--           "type": "paragraph",
--           "text": "Radio gear ranges from scavenged toys to high-end military manpacks. Each of the ten tiers offers two critical improvements that change how you interact with the wasteland."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Signal Reach: Higher tiers cut through the static, allowing you to find traders further out in the exclusion zone.",
--             "Signal Channels: Better hardware can maintain more trader frequencies at once without losing the lock."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Field Observation",
--           "text": "The Tier 10 Military Ham Radio is a beast. I managed to lock onto 20 different traders from a single rooftop in Louisville. Keep an eye out in military outposts."
--         }
--       ]
--     },
--     {
--       "id": "tier_scrounging",
--       "chapter_id": "acquisition",
--       "title": "Scavenging for Comms",
--       "keywords": [
--         "scavenge",
--         "find",
--         "looting",
--         "location"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "sourcing-gear",
--           "level": 1,
--           "text": "Where to Look"
--         },
--         {
--           "type": "paragraph",
--           "text": "Higher tier gear is rare and often found in specialized locations. Low-tier walkie-talkies can be found in residential areas, while high-tier HAM and military radios are restricted to secure facilities."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Tiers 1-3: Residential homes, electronic stores, and toy crates.",
--             "Tiers 4-7: Police stations, emergency vehicle trunks, and small communications towers.",
--             "Tiers 8-10: Military checkpoints, research facilities, and high-frequency military bunkers."
--           ]
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dynamic_trading_radio_tiers", {
        title = "Hardware Tier List",
        description = "Comprehensive guide to all ten tiers of radio technology.",
        startPageId = "tier_overview",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 2,
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
                id = "tier_list",
                title = "Hardware Tiers",
                description = "Detailed breakdown of the 10 tiers of signals.",
            },
            {
                id = "acquisition",
                title = "Finding Equipment",
                description = "Where to source better technology.",
            },
        },
        pages = {
            {
                id = "tier_overview",
                chapterId = "tier_list",
                title = "Ten Tiers of Technology",
                keywords = { "tiers", "power", "capacity", "military", "ham" },
                blocks = {
                    { type = "heading", id = "hardware-selection", level = 1, text = "The 10 Tiers of Signals" },
                    { type = "paragraph", text = "Radio gear ranges from scavenged toys to high-end military manpacks. Each of the ten tiers offers two critical improvements that change how you interact with the wasteland." },
                    { type = "bullet_list", items = { "Signal Reach: Higher tiers cut through the static, allowing you to find traders further out in the exclusion zone.", "Signal Channels: Better hardware can maintain more trader frequencies at once without losing the lock." } },
                    { type = "callout", tone = "info", title = "Field Observation", text = "The Tier 10 Military Ham Radio is a beast. I managed to lock onto 20 different traders from a single rooftop in Louisville. Keep an eye out in military outposts." },
                },
            },
            {
                id = "tier_scrounging",
                chapterId = "acquisition",
                title = "Scavenging for Comms",
                keywords = { "scavenge", "find", "looting", "location" },
                blocks = {
                    { type = "heading", id = "sourcing-gear", level = 1, text = "Where to Look" },
                    { type = "paragraph", text = "Higher tier gear is rare and often found in specialized locations. Low-tier walkie-talkies can be found in residential areas, while high-tier HAM and military radios are restricted to secure facilities." },
                    { type = "bullet_list", items = { "Tiers 1-3: Residential homes, electronic stores, and toy crates.", "Tiers 4-7: Police stations, emergency vehicle trunks, and small communications towers.", "Tiers 8-10: Military checkpoints, research facilities, and high-frequency military bunkers." } },
                },
            },
        },
    })
end
