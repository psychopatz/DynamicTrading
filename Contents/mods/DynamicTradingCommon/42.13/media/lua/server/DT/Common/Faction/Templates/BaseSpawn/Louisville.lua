-- ==============================================================================
-- media/lua/server/Spawn/Faction/Louisville.lua
-- Data Definition: Louisville Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.Louisville = {
    {
        name = "Jim’s Autoshop",
        coords = { x = 12226, y = 1373, z = 0 },
        description = "Medium-sized auto shop with multiple service bays, tool benches, and a solid supply of car parts and repair equipment."
    },
    {
        name = "Stars and Stripes",
        coords = { x = 13558, y = 1269, z = 0 },
        description = "Gun store located inside Grand Ohio Mall. Large selection of firearms, ammunition, and tactical gear."
    },
    {
        name = "E.P Tools Grand Ohio Mall",
        coords = { x = 13526, y = 1319, z = 2 },
        description = "E.P Tools branch within the mall offering construction materials, tools, and maintenance supplies."
    },
    {
        name = "Giga Mart",
        coords = { x = 13466, y = 3058, z = 0 },
        description = "Large supermarket carrying food, clothing, tools, and basic construction materials."
    },
    {
        name = "American Tire",
        coords = { x = 13287, y = 2974, z = 0 },
        description = "Spacious tire and automotive shop with a wide range of tires and vehicle components."
    },
    {
        name = "Louisville General Hospital",
        coords = { x = 12947, y = 2083, z = 0 },
        description = "Multi-floor hospital complex containing medical equipment, pharmaceuticals, and treatment rooms."
    },
    {
        name = "EgenerEX HQ and factory",
        coords = { x = 12205, y = 2083, z = 0 },
        description = "Battery manufacturing facility with storage areas for batteries and electronic components."
    },
    {
        name = "Spiffo’s Hq and Restaurant",
        coords = { x = 12715, y = 2083, z = 0 },
        description = "Large flagship Spiffo’s location with restaurant space and bulk food storage."
    }
}

print("[Dynamic Trading] Loaded Louisville Spawn Locations: " .. #DT_FactionLocations.Louisville .. " spots registered.")
