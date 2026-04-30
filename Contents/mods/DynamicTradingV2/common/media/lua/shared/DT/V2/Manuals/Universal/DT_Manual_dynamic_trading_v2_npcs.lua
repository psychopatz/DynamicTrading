-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dynamic_trading_v2_npcs",
--   "module": "DynamicTradingV2",
--   "title": "FieldTrader Discovery",
--   "description": "How to find and track physical NPCs in the world using your radio.",
--   "start_page_id": "spawning_logic",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 1,
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
--       "id": "npc_spawning",
--       "title": "Spawning Behaviors",
--       "description": "Understanding where and how traders appear."
--     },
--     {
--       "id": "radar_equipment",
--       "title": "Radar & Radius",
--       "description": "Using hardware to locate physical NPCs."
--     },
--     {
--       "id": "interaction",
--       "title": "Meeting the Trader",
--       "description": "Distances, expiry, and behaviors."
--     }
--   ],
--   "pages": [
--     {
--       "id": "spawning_logic",
--       "chapter_id": "npc_spawning",
--       "title": "The Physics of Spawning",
--       "keywords": [
--         "spawn",
--         "independent",
--         "faction",
--         "towns",
--         "nomadic"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "spawn-mechanics",
--           "level": 1,
--           "text": "Finding the Merchant"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dynamic_trading_v2_npcs/image_95b2ead4ac.png",
--           "caption": "",
--           "width": 220,
--           "height": 140,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "In the V2 system, traders are physical actors in the world. Their location is dictated by their affiliation understanding this logic is key to mastering your trade routes."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Independent Traders: These lone wolves are nomadic and tend to spawn in the general vicinity of active players. They offer a baseline market but move frequently.",
--             "Faction Traders: These specialists are anchored to their dedicated towns or base locations. If a faction controls Muldraugh, their merchants will primarily stay within those borders. Or Might even reach out to your location sometimes.",
--             "If you befriend them more, you will have a chance to recruit them to your roster if you got the colonies addon"
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Operational Note",
--           "text": "Faction traders have much stronger standing requirements but often provide bulk supplies that independent roamers simply cannot carry."
--         }
--       ]
--     },
--     {
--       "id": "radar_radius",
--       "chapter_id": "radar_equipment",
--       "title": "The Trader Radar",
--       "keywords": [
--         "radar",
--         "radius",
--         "range",
--         "walkie",
--         "ham"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "radar-range",
--           "level": 1,
--           "text": "Locating the Signal"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dynamic_trading_v2_npcs/image_3792763473.png",
--           "caption": "",
--           "width": 240,
--           "height": 153,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "The Trader Radar UI allows you to scan for physical traders within your radio broadcast range. This range is purely dictated by your equipment type."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Handheld Walkies: Portable but limited. A standard US Army Walkie Talkie provides roughly 10,000m to 16,000m of radar coverage.",
--             "HAM Stations: Massive coverage expansion. High-power base stations can reveal traders across almost the entire county."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "warn",
--           "title": "Signal Strength",
--           "text": "The further away a trader is, the weaker their signal will appear on your radar. If you see [SIGNAL WEAK], expect the UI to poll slower and updates to be less frequent."
--         }
--       ]
--     },
--     {
--       "id": "behavior_interaction",
--       "chapter_id": "interaction",
--       "title": "Distance & Behaviors",
--       "keywords": [
--         "behavior",
--         "distance",
--         "expiry",
--         "stationary",
--         "callable"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "tracking-data",
--           "level": 1,
--           "text": "Radar Intelligence"
--         },
--         {
--           "type": "paragraph",
--           "text": "Your radar tracks the physical state of the merchant across three tabs: Stationary (settled traders), Callable (those you can hail or your companions(Currently broken in MP so i just removed it temporarily)), and Quest (trader that needs help,special delivery targets, etc(Partially implemented))."
--         },
--         {
--           "type": "paragraph",
--           "text": "Each entry shows the exact distance (e.g., 300m or 400m) and an Expiry Timer. Physical traders are not permanent they will pack up their bags and move to a new sector once their timer (typically 16-18 hours) hits zero."
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Travel Tip",
--           "text": "Use the LOCATE button to mark a trader on your map, but make sure you have enough time to reach them before their signal expires!"
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dynamic_trading_v2_npcs", {
        title = "FieldTrader Discovery",
        description = "How to find and track physical NPCs in the world using your radio.",
        startPageId = "spawning_logic",
        audiences = { "DynamicTradingV2" },
        sortOrder = 1,
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
                id = "npc_spawning",
                title = "Spawning Behaviors",
                description = "Understanding where and how traders appear.",
            },
            {
                id = "radar_equipment",
                title = "Radar & Radius",
                description = "Using hardware to locate physical NPCs.",
            },
            {
                id = "interaction",
                title = "Meeting the Trader",
                description = "Distances, expiry, and behaviors.",
            },
        },
        pages = {
            {
                id = "spawning_logic",
                chapterId = "npc_spawning",
                title = "The Physics of Spawning",
                keywords = { "spawn", "independent", "faction", "towns", "nomadic" },
                blocks = {
                    { type = "heading", id = "spawn-mechanics", level = 1, text = "Finding the Merchant" },
                    { type = "image", path = "media/ui/Manuals/dynamic_trading_v2_npcs/image_95b2ead4ac.png", caption = "", width = 220, height = 140 },
                    { type = "paragraph", text = "In the V2 system, traders are physical actors in the world. Their location is dictated by their affiliation understanding this logic is key to mastering your trade routes." },
                    { type = "bullet_list", items = { "Independent Traders: These lone wolves are nomadic and tend to spawn in the general vicinity of active players. They offer a baseline market but move frequently.", "Faction Traders: These specialists are anchored to their dedicated towns or base locations. If a faction controls Muldraugh, their merchants will primarily stay within those borders. Or Might even reach out to your location sometimes.", "If you befriend them more, you will have a chance to recruit them to your roster if you got the colonies addon" } },
                    { type = "callout", tone = "info", title = "Operational Note", text = "Faction traders have much stronger standing requirements but often provide bulk supplies that independent roamers simply cannot carry." },
                },
            },
            {
                id = "radar_radius",
                chapterId = "radar_equipment",
                title = "The Trader Radar",
                keywords = { "radar", "radius", "range", "walkie", "ham" },
                blocks = {
                    { type = "heading", id = "radar-range", level = 1, text = "Locating the Signal" },
                    { type = "image", path = "media/ui/Manuals/dynamic_trading_v2_npcs/image_3792763473.png", caption = "", width = 240, height = 153 },
                    { type = "paragraph", text = "The Trader Radar UI allows you to scan for physical traders within your radio broadcast range. This range is purely dictated by your equipment type." },
                    { type = "bullet_list", items = { "Handheld Walkies: Portable but limited. A standard US Army Walkie Talkie provides roughly 10,000m to 16,000m of radar coverage.", "HAM Stations: Massive coverage expansion. High-power base stations can reveal traders across almost the entire county." } },
                    { type = "callout", tone = "warn", title = "Signal Strength", text = "The further away a trader is, the weaker their signal will appear on your radar. If you see [SIGNAL WEAK], expect the UI to poll slower and updates to be less frequent." },
                },
            },
            {
                id = "behavior_interaction",
                chapterId = "interaction",
                title = "Distance & Behaviors",
                keywords = { "behavior", "distance", "expiry", "stationary", "callable" },
                blocks = {
                    { type = "heading", id = "tracking-data", level = 1, text = "Radar Intelligence" },
                    { type = "paragraph", text = "Your radar tracks the physical state of the merchant across three tabs: Stationary (settled traders), Callable (those you can hail or your companions(Currently broken in MP so i just removed it temporarily)), and Quest (trader that needs help,special delivery targets, etc(Partially implemented))." },
                    { type = "paragraph", text = "Each entry shows the exact distance (e.g., 300m or 400m) and an Expiry Timer. Physical traders are not permanent they will pack up their bags and move to a new sector once their timer (typically 16-18 hours) hits zero." },
                    { type = "callout", tone = "info", title = "Travel Tip", text = "Use the LOCATE button to mark a trader on your map, but make sure you have enough time to reach them before their signal expires!" },
                },
            },
        },
    })
end
