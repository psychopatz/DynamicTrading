-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_v2_npcs",
--   "title": "Survivalist's Guide to Trading",
--   "description": "Scouting the streets and handling high-stakes deals with the few survivors left standing.",
--   "start_page_id": "v2_philosophy",
--   "chapters": [
--     { "id": "world_analysis", "title": "Scouting the Map", "description": "Reading the world to find where the players are." },
--     { "id": "npc_behavior", "title": "Handling the Locals", "description": "Understanding behavior, safety, and cooperation." }
--   ],
--   "pages": [
--     {
--       "id": "v2_philosophy",
--       "chapter_id": "world_analysis",
--       "title": "The Face-to-Face Deal",
--       "keywords": ["v2", "physical", "npc", "dangerous", "scout"],
--       "blocks": [
--         { "type": "heading", "id": "physical-trading", "level": 1, "text": "Leaving the Safehouse" },
--         { "type": "paragraph", "text": "V2 isn't for the faint of heart. It requires you to step out of your bunker and into the territory of others. You'll find traders nested in barricaded pharmacies, police stations, and remote hunting cabins. Every trade is a risk, but the rewards are far more personal." },
--         { "type": "image", "path": "media/ui/Portraits/Sheriff/Male/1.png", "caption": "Find them before the dead do.", "width": 128, "height": 128 }
--       ]
--     },
--     {
--       "id": "building_scanner_deep",
--       "chapter_id": "world_analysis",
--       "title": "Reading the Buildings",
--       "keywords": ["scanner", "pipeline", "locations", "rooms"],
--       "blocks": [
--         { "type": "heading", "id": "scanning-the-zone", "level": 1, "text": "Where They Settle" },
--         { "type": "paragraph", "text": "Survivors are smart; they settle where the resources are. The 'Scanner' identifies these spots through three methods:" },
--         { "type": "bullet_list", "items": [
--             "Urban Interiors: Look for medics in hospitals and mechanics in auto-shops. The building matches the man.",
--             "Wilderness Camps: Remote zones host the outcasts—hunters and gatherers who prefer the trees to the streets.",
--             "Roadside Stalls: Traveling merchants often set up temporary shops along the main highways between towns."
--         ]},
--         { "type": "heading", "id": "geo-intelligence", "level": 2, "text": "Know Your County" },
--         { "type": "paragraph", "text": "Traders are loyal to their roots. A Rosewood merchant won't spawn in Muldraugh. Understanding the borders of each county helps you predict which factions you'll encounter as you cross the map." }
--       ]
--     },
--     {
--       "id": "npc_states",
--       "chapter_id": "npc_behavior",
--       "title": "Merchant Manners",
--       "keywords": ["behavior", "guard", "idle", "trading", "dialogue"],
--       "blocks": [
--         { "type": "heading", "id": "living-breathing-traders", "level": 1, "text": "They Aren't Statues" },
--         { "type": "paragraph", "text": "NPCs in V2 have lives. They eat, they smoke, they sleep, and they watch the perimeter. When you approach, they'll switch to 'Trading' mode, but if a horde shows up, they'll drop the inventory and draw their weapons to 'Guard' the area." },
--         { "type": "callout", "tone": "info", "title": "Field Note", "text": "If a trader seems distracted, listen to their 'Ambient Dialogue'. They might be warning you about nearby threats or complaining about the recent meta events." }
--       ]
--     },
--     {
--       "id": "spatial_management",
--       "chapter_id": "npc_behavior",
--       "title": "Ghost in the Machine",
--       "keywords": ["spatial", "performance", "persistence", "management"],
--       "blocks": [
--         { "type": "heading", "id": "hibernation", "level": 1, "text": "The Vanishing Act" },
--         { "type": "paragraph", "text": "Don't be alarmed if a trader isn't there when you're miles away. To save resources, the world 'hibernates' NPCs when no one is watching. They'll reappear exactly where you left them, with the same stock and wealth, as soon as you step back into their neighborhood." }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_v2_npcs", {
        title = "Survivalist's Guide to Trading",
        description = "Scouting the streets and handling high-stakes deals with the few survivors left standing.",
        audiences = { "v2" },
        startPageId = "v2_philosophy",
        chapters = {
            { id = "world_analysis", title = "Scouting the Map", description = "Reading the world to find where the players are." },
            { id = "npc_behavior", title = "Handling the Locals", description = "Understanding behavior, safety, and cooperation." },
        },
        pages = {
            {
                id = "v2_philosophy",
                chapterId = "world_analysis",
                title = "The Face-to-Face Deal",
                keywords = { "v2", "physical", "npc", "dangerous", "scout" },
                blocks = {
                    { type = "heading", id = "physical-trading", level = 1, text = "Leaving the Safehouse" },
                    { type = "paragraph", text = "V2 isn't for the faint of heart. It requires you to step out of your bunker and into the territory of others. You'll find traders nested in barricaded pharmacies, police stations, and remote hunting cabins. Every trade is a risk, but the rewards are far more personal." },
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
                    { type = "bullet_list", items = {
                        "Urban Interiors: Look for medics in hospitals and mechanics in auto-shops. The building matches the man.",
                        "Wilderness Pipelines: Remote zones host the outcasts—hunters and gatherers who prefer the trees to the streets.",
                        "Road Pipelines: Scans transit routes for traveling merchants or roadside stalls."
                    } },
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
                    { type = "paragraph", text = "NPCs in V2 have lives. They eat, they smoke, they sleep, and they watch the perimeter. When you approach, they'll switch to 'Trading' mode, but if a horde shows up, they'll drop the inventory and draw their weapons to 'Guard' the area." },
                    { type = "callout", tone = "info", title = "Field Note", text = "If a trader seems distracted, listen to their 'Ambient Dialogue'. They might be warning you about nearby threats or complaining about the recent meta events." },
                },
            },
            {
                id = "spatial_management",
                chapterId = "npc_behavior",
                title = "Ghost in the Machine",
                keywords = { "spatial", "performance", "persistence", "management" },
                blocks = {
                    { type = "heading", id = "hibernation", level = 1, text = "The Vanishing Act" },
                    { type = "paragraph", text = "Don't be alarmed if a trader isn't there when you're miles away. To save resources, the world 'hibernates' NPCs when no one is watching. They'll reappear exactly where you left them, with the same stock and wealth, as soon as you step back into their neighborhood." },
                },
            },
        },
    })
end
