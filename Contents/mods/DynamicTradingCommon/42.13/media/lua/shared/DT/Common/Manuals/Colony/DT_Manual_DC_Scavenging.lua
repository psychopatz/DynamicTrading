-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dc_scavenging",
--   "title": "Scavenger's Field Guide",
--   "description": "Operational notes on site profiles, tool unlocks, carry limits, and reliable scavenging runs.",
--   "audiences": ["colony"],
--   "start_page_id": "scavenge_overview",
--   "chapters": [
--     {
--       "id": "field_basics",
--       "title": "Field Basics",
--       "description": "Understanding site profiles, capability tiers, and how loot pools unlock."
--     },
--     {
--       "id": "trip_management",
--       "title": "Trip Management",
--       "description": "Managing travel flow, carry limits, and how to read scavenger output."
--     }
--   ],
--   "pages": [
--     {
--       "id": "scavenge_overview",
--       "chapter_id": "field_basics",
--       "title": "Scavenge System Overview",
--       "keywords": ["scavenge", "scavenging", "site", "loot", "tier"],
--       "blocks": [
--         { "type": "heading", "id": "scavenge-core-loop", "level": 1, "text": "How Scavenging Works" },
--         { "type": "paragraph", "text": "The scavenging job runs through four layers: site profile, capability unlocks, search efficiency, and haul weight. A worker first needs a good location, then the right tools to access better loot pools, then enough efficiency to complete rolls quickly, and finally enough carrying capacity to bring the results home." },
--         { "type": "heading", "id": "site-profile", "level": 2, "text": "1. Site Profile" },
--         { "type": "paragraph", "text": "The assigned work site decides what categories of loot are even possible. Houses lean toward food, books, clothing, and household parts. Warehouses favor materials and hardware. Specialist locations like pharmacies, gun stores, or electronics areas bias their own loot pools." },
--         { "type": "heading", "id": "capability-unlocks", "level": 2, "text": "2. Capability Unlocks" },
--         { "type": "paragraph", "text": "Tools do not directly create rare loot. They unlock the sub-pools a worker is allowed to reach once they arrive at a site." },
--         { "type": "bullet_list", "items": [
--             "Access tools: crowbar, screwdriver, and sledgehammer open locked or secured locations.",
--             "Extraction tools: hammer, saw, pipe wrench, propane torch, and welding mask unlock dismantle and salvage pools.",
--             "Hauling tools: bags, garbage bags, sandbags, and rope improve quantity and carrying efficiency.",
--             "Utility tools: flashlights, maps, and pens improve speed and reduce bad search rolls."
--         ]},
--         { "type": "heading", "id": "scavenge-tiers", "level": 2, "text": "3. Scavenge Tiers" },
--         { "type": "bullet_list", "items": [
--             "Tier 0: open containers only.",
--             "Tier 1: locked entry and general goods.",
--             "Tier 2: stripping furniture and raw materials.",
--             "Tier 3: secure stores, industrial salvage, and high-value pools."
--         ]},
--         { "type": "callout", "tone": "info", "title": "Field Rule", "text": "Better gear broadens what can be reached. It does not bypass the location's own loot identity." }
--       ]
--     },
--     {
--       "id": "trip_flow",
--       "chapter_id": "trip_management",
--       "title": "Trip Flow & Carry Weight",
--       "keywords": ["trip", "away", "carry", "haul", "weight", "return"],
--       "blocks": [
--         { "type": "heading", "id": "search-efficiency", "level": 1, "text": "Search Efficiency" },
--         { "type": "paragraph", "text": "Flashlights improve dark-site search speed. Maps and pens help prevent duplicate pool picks. Bags and bulk tools increase how much can be brought back, but they do not improve loot quality on their own. The scavenge bar tracks total work needed for the next roll, while speed decides how quickly that work completes." },
--         { "type": "heading", "id": "trip-states", "level": 2, "text": "Trip States" },
--         { "type": "paragraph", "text": "Scavengers run finite trips. They leave Home, travel Away to the site, spend time Scavenging there, then travel Away again on the return leg to unload their haul." },
--         { "type": "paragraph", "text": "Found loot first enters the worker's active haul. When the pack is full, supplies run low, or you recall the worker, the trip ends and they head home with what they managed to collect." },
--         { "type": "bullet_list", "items": [
--             "Continuous work keeps repeating the assigned job until you press Stop Job.",
--             "Scavengers still wait for provisions, tools, and warehouse space before heading out again.",
--             "Only the active haul is weight-limited. Provisions and equipment do not count toward haul weight.",
--             "Container reduction applies before leftover weight hits the worker's body carry limit."
--         ]},
--         { "type": "callout", "tone": "warn", "title": "Important", "text": "If you want every worker to stay out longer before returning, increase colony carry-weight support and give them proper containers." }
--       ]
--     },
--     {
--       "id": "practical_loadouts",
--       "chapter_id": "trip_management",
--       "title": "Practical Loadouts",
--       "keywords": ["tips", "loadout", "flashlight", "crowbar", "backpack", "haul"],
--       "blocks": [
--         { "type": "heading", "id": "field-loadouts", "level": 1, "text": "Reliable Setups" },
--         { "type": "bullet_list", "items": [
--             "Pair a crowbar with a flashlight for dependable house runs.",
--             "Use a hammer plus saw when you need building materials.",
--             "Use a torch plus welding mask for warehouse and industrial salvage.",
--             "Give scavengers backpacks or duffels if you want longer runs before they have to unload."
--         ]},
--         { "type": "heading", "id": "ui-reading", "level": 2, "text": "Reading The UI" },
--         { "type": "paragraph", "text": "Compare Carry Load, Base Carry Limit, and Raw Carry Allowance in the worker details panel to see how much their bags are helping. In the supply window, the Haul tab shows what has already been stored at home and is ready to collect." },
--         { "type": "callout", "tone": "info", "title": "Quick Access", "text": "Dynamic Colonies help buttons can open this manual directly, so search terms like scavenge, haul, carry, or tier will bring you back here fast." }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dc_scavenging", {
        title = "Scavenger's Field Guide",
        description = "Operational notes on site profiles, tool unlocks, carry limits, and reliable scavenging runs.",
        audiences = { "colony" },
        startPageId = "scavenge_overview",
        chapters = {
            {
                id = "field_basics",
                title = "Field Basics",
                description = "Understanding site profiles, capability tiers, and how loot pools unlock.",
            },
            {
                id = "trip_management",
                title = "Trip Management",
                description = "Managing travel flow, carry limits, and how to read scavenger output.",
            },
        },
        pages = {
            {
                id = "scavenge_overview",
                chapterId = "field_basics",
                title = "Scavenge System Overview",
                keywords = { "scavenge", "scavenging", "site", "loot", "tier" },
                blocks = {
                    { type = "heading", id = "scavenge-core-loop", level = 1, text = "How Scavenging Works" },
                    { type = "paragraph", text = "The scavenging job runs through four layers: site profile, capability unlocks, search efficiency, and haul weight. A worker first needs a good location, then the right tools to access better loot pools, then enough efficiency to complete rolls quickly, and finally enough carrying capacity to bring the results home." },
                    { type = "heading", id = "site-profile", level = 2, text = "1. Site Profile" },
                    { type = "paragraph", text = "The assigned work site decides what categories of loot are even possible. Houses lean toward food, books, clothing, and household parts. Warehouses favor materials and hardware. Specialist locations like pharmacies, gun stores, or electronics areas bias their own loot pools." },
                    { type = "heading", id = "capability-unlocks", level = 2, text = "2. Capability Unlocks" },
                    { type = "paragraph", text = "Tools do not directly create rare loot. They unlock the sub-pools a worker is allowed to reach once they arrive at a site." },
                    { type = "bullet_list", items = {
                        "Access tools: crowbar, screwdriver, and sledgehammer open locked or secured locations.",
                        "Extraction tools: hammer, saw, pipe wrench, propane torch, and welding mask unlock dismantle and salvage pools.",
                        "Hauling tools: bags, garbage bags, sandbags, and rope improve quantity and carrying efficiency.",
                        "Utility tools: flashlights, maps, and pens improve speed and reduce bad search rolls."
                    } },
                    { type = "heading", id = "scavenge-tiers", level = 2, text = "3. Scavenge Tiers" },
                    { type = "bullet_list", items = {
                        "Tier 0: open containers only.",
                        "Tier 1: locked entry and general goods.",
                        "Tier 2: stripping furniture and raw materials.",
                        "Tier 3: secure stores, industrial salvage, and high-value pools."
                    } },
                    { type = "callout", tone = "info", title = "Field Rule", text = "Better gear broadens what can be reached. It does not bypass the location's own loot identity." },
                },
            },
            {
                id = "trip_flow",
                chapterId = "trip_management",
                title = "Trip Flow & Carry Weight",
                keywords = { "trip", "away", "carry", "haul", "weight", "return" },
                blocks = {
                    { type = "heading", id = "search-efficiency", level = 1, text = "Search Efficiency" },
                    { type = "paragraph", text = "Flashlights improve dark-site search speed. Maps and pens help prevent duplicate pool picks. Bags and bulk tools increase how much can be brought back, but they do not improve loot quality on their own. The scavenge bar tracks total work needed for the next roll, while speed decides how quickly that work completes." },
                    { type = "heading", id = "trip-states", level = 2, text = "Trip States" },
                    { type = "paragraph", text = "Scavengers run finite trips. They leave Home, travel Away to the site, spend time Scavenging there, then travel Away again on the return leg to unload their haul." },
                    { type = "paragraph", text = "Found loot first enters the worker's active haul. When the pack is full, supplies run low, or you recall the worker, the trip ends and they head home with what they managed to collect." },
                    { type = "bullet_list", items = {
                        "Continuous work keeps repeating the assigned job until you press Stop Job.",
                        "Scavengers still wait for provisions, tools, and warehouse space before heading out again.",
                        "Only the active haul is weight-limited. Provisions and equipment do not count toward haul weight.",
                        "Container reduction applies before leftover weight hits the worker's body carry limit."
                    } },
                    { type = "callout", tone = "warn", title = "Important", text = "If you want every worker to stay out longer before returning, increase colony carry-weight support and give them proper containers." },
                },
            },
            {
                id = "practical_loadouts",
                chapterId = "trip_management",
                title = "Practical Loadouts",
                keywords = { "tips", "loadout", "flashlight", "crowbar", "backpack", "haul" },
                blocks = {
                    { type = "heading", id = "field-loadouts", level = 1, text = "Reliable Setups" },
                    { type = "bullet_list", items = {
                        "Pair a crowbar with a flashlight for dependable house runs.",
                        "Use a hammer plus saw when you need building materials.",
                        "Use a torch plus welding mask for warehouse and industrial salvage.",
                        "Give scavengers backpacks or duffels if you want longer runs before they have to unload."
                    } },
                    { type = "heading", id = "ui-reading", level = 2, text = "Reading The UI" },
                    { type = "paragraph", text = "Compare Carry Load, Base Carry Limit, and Raw Carry Allowance in the worker details panel to see how much their bags are helping. In the supply window, the Haul tab shows what has already been stored at home and is ready to collect." },
                    { type = "callout", tone = "info", title = "Quick Access", text = "Dynamic Colonies help buttons can open this manual directly, so search terms like scavenge, haul, carry, or tier will bring you back here fast." },
                },
            },
        },
    })
end
