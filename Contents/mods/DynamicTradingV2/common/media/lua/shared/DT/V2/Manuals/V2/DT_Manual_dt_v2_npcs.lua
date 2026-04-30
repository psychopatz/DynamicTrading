-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_v2_npcs",
--   "module": "DynamicTradingV2",
--   "title": "Guide to Trading",
--   "description": "Scouting the streets and handling high-stakes deals",
--   "start_page_id": "v2_philosophy",
--   "audiences": [
--     "DynamicTradingV2"
--   ],
--   "sort_order": 100000,
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
--   "source_folder": "V2",
--   "chapters": [
--     {
--       "id": "world_analysis",
--       "title": "Scouting the Map",
--       "description": "Reading the world to find where the players are."
--     },
--     {
--       "id": "npc_behavior",
--       "title": "Handling the Locals",
--       "description": "Understanding behavior, safety, and cooperation."
--     }
--   ],
--   "pages": [
--     {
--       "id": "v2_philosophy",
--       "chapter_id": "world_analysis",
--       "title": "The Face-to-Face Deal",
--       "keywords": [
--         "v2",
--         "physical",
--         "npc",
--         "dangerous",
--         "scout"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "physical-trading",
--           "level": 1,
--           "text": "Leaving the Safehouse"
--         },
--         {
--           "type": "paragraph",
--           "text": "V2 isn't for the faint of heart. It requires you to step out of your bunker and into the territory of others. You'll find traders nested in barricaded pharmacies, police stations, and remote hunting cabins. Every trade is a risk, but the rewards are far more personal unlike V1.\n\nSo if you value Realism, V2 is the best version for you"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Portraits/Sheriff/Male/1.png",
--           "caption": "Find them before the dead do.",
--           "width": 128,
--           "height": 128,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.0
--         }
--       ]
--     },
--     {
--       "id": "building_scanner_deep",
--       "chapter_id": "world_analysis",
--       "title": "Reading the Buildings",
--       "keywords": [
--         "scanner",
--         "pipeline",
--         "locations",
--         "rooms"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "scanning-the-zone",
--           "level": 1,
--           "text": "Where They Settle"
--         },
--         {
--           "type": "paragraph",
--           "text": "Survivors are smart; they settle where the resources are. The 'Scanner' identifies these spots through three methods:"
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Urban Interiors: Look for medics in hospitals and mechanics in auto-shops. The building matches the man.",
--             "Wilderness Camps: Remote zones host the outcasts hunters and gatherers who prefer the trees to the streets.",
--             "Roadside Stalls: Traveling merchants often set up temporary shops along the main highways between towns."
--           ]
--         },
--         {
--           "type": "heading",
--           "id": "geo-intelligence",
--           "level": 2,
--           "text": "Know Your County"
--         },
--         {
--           "type": "paragraph",
--           "text": "Traders are loyal to their roots. A Rosewood merchant won't spawn in Muldraugh. Understanding the borders of each county helps you predict which factions you'll encounter as you cross the map."
--         }
--       ]
--     },
--     {
--       "id": "npc_states",
--       "chapter_id": "npc_behavior",
--       "title": "Merchant Manners",
--       "keywords": [
--         "behavior",
--         "guard",
--         "idle",
--         "trading",
--         "dialogue"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "living-breathing-traders",
--           "level": 1,
--           "text": "They Aren't Statues"
--         },
--         {
--           "type": "paragraph",
--           "text": "NPCs in V2 have lives. They eat, they smoke, they sleep, and they watch the perimeter. When they feel like it or need to restock their colony, they will go out of their base and set up temporary shop 'Trading' mode, when they feel like theyre tired, they will go Home to take rest to their base. You can go to their base to ask for some available quest or even befriend them. Just be careful, theyre commonly chatty and noisy that have a high chance to attract some hordes, theyre immune to zombies at this moment since I put them some zombie lotion for them to not get attacked :)"
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Field Note",
--           "text": "If a trader seems distracted, listen to their 'Ambient Dialogue'. They might be warning you about nearby threats or complaining about the recent meta events."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_v2_npcs", {
        title = "Guide to Trading",
        description = "Scouting the streets and handling high-stakes deals",
        startPageId = "v2_philosophy",
        audiences = { "DynamicTradingV2" },
        sortOrder = 100000,
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
                id = "world_analysis",
                title = "Scouting the Map",
                description = "Reading the world to find where the players are.",
            },
            {
                id = "npc_behavior",
                title = "Handling the Locals",
                description = "Understanding behavior, safety, and cooperation.",
            },
        },
        pages = {
            {
                id = "v2_philosophy",
                chapterId = "world_analysis",
                title = "The Face-to-Face Deal",
                keywords = { "v2", "physical", "npc", "dangerous", "scout" },
                blocks = {
                    { type = "heading", id = "physical-trading", level = 1, text = "Leaving the Safehouse" },
                    { type = "paragraph", text = "V2 isn't for the faint of heart. It requires you to step out of your bunker and into the territory of others. You'll find traders nested in barricaded pharmacies, police stations, and remote hunting cabins. Every trade is a risk, but the rewards are far more personal unlike V1.\n\nSo if you value Realism, V2 is the best version for you" },
                    { type = "image", path = "media/ui/Portraits/Sheriff/Male/1.png", caption = "Find them before the dead do.", width = 128, height = 128 },
                },
            },
            {
                id = "building_scanner_deep",
                chapterId = "world_analysis",
                title = "Reading the Buildings",
                keywords = { "scanner", "pipeline", "locations", "rooms" },
                blocks = {
                    { type = "heading", id = "scanning-the-zone", level = 1, text = "Where They Settle" },
                    { type = "paragraph", text = "Survivors are smart; they settle where the resources are. The 'Scanner' identifies these spots through three methods:" },
                    { type = "bullet_list", items = { "Urban Interiors: Look for medics in hospitals and mechanics in auto-shops. The building matches the man.", "Wilderness Camps: Remote zones host the outcasts hunters and gatherers who prefer the trees to the streets.", "Roadside Stalls: Traveling merchants often set up temporary shops along the main highways between towns." } },
                    { type = "heading", id = "geo-intelligence", level = 2, text = "Know Your County" },
                    { type = "paragraph", text = "Traders are loyal to their roots. A Rosewood merchant won't spawn in Muldraugh. Understanding the borders of each county helps you predict which factions you'll encounter as you cross the map." },
                },
            },
            {
                id = "npc_states",
                chapterId = "npc_behavior",
                title = "Merchant Manners",
                keywords = { "behavior", "guard", "idle", "trading", "dialogue" },
                blocks = {
                    { type = "heading", id = "living-breathing-traders", level = 1, text = "They Aren't Statues" },
                    { type = "paragraph", text = "NPCs in V2 have lives. They eat, they smoke, they sleep, and they watch the perimeter. When they feel like it or need to restock their colony, they will go out of their base and set up temporary shop 'Trading' mode, when they feel like theyre tired, they will go Home to take rest to their base. You can go to their base to ask for some available quest or even befriend them. Just be careful, theyre commonly chatty and noisy that have a high chance to attract some hordes, theyre immune to zombies at this moment since I put them some zombie lotion for them to not get attacked :)" },
                    { type = "callout", tone = "info", title = "Field Note", text = "If a trader seems distracted, listen to their 'Ambient Dialogue'. They might be warning you about nearby threats or complaining about the recent meta events." },
                },
            },
        },
    })
end
