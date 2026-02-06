-- ==============================================================================
-- media/lua/server/Spawn/Faction/WestPoint.lua
-- Data Definition: West Point Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.WestPoint = {
    {
        name = "West Point Police Station",
        coords = { x = 11897, y = 6942, z = 0 },
        description = "High-security hub now featuring a static basement armory."
    },
    {
        name = "West Point High School",
        coords = { x = 11342, y = 6774, z = 0 },
        description = "Massive resource for B42 skill books and sustainable cafeteria supplies."
    },
    {
        name = "West Point Town Hall",
        coords = { x = 11940, y = 6869, z = 0 },
        description = "Multi-floor landmark; ideal for office supplies and high-density electronics."
    },
    {
        name = "Fossoil Gas Station (Central)",
        coords = { x = 11830, y = 6870, z = 0 },
        description = "Primary fuel hub in the town center; essential for local vehicle maintenance."
    },

    -- COMMERCIAL & HIGH-TIER LOOT
    {
        name = "West Point Hardware Store",
        coords = { x = 11935, y = 6913, z = 0 },
        description = "Prime source for B42 blacksmithing and primitive crafting tools."
    },
    {
        name = "Guns Unlimited",
        coords = { x = 12060, y = 6700, z = 0 },
        description = "Heavily barricaded gun store; highest tactical loot density in the region."
    },
    {
        name = "GigaMart",
        coords = { x = 11900, y = 6700, z = 0 },
        description = "The largest food and refrigeration hub in the West Point district."
    },
    {
        name = "U-Store It Self-Storage",
        coords = { x = 12050, y = 7050, z = 0 },
        description = "Dozens of units containing generators, rare tools, and vehicle parts."
    },

    -- RESIDENTIAL & EXPANSION
    {
        name = "The Three-Mansion Complex",
        coords = { x = 10150, y = 6600, z = 0 },
        description = "Legendary riverside base with high fences and newly added B42 basements."
    },
    {
        name = "West Point Train Station",
        coords = { x = 12350, y = 6550, z = 0 }, -- B42 Railway Expansion POI
        description = "New B42 railway POI; significant for exploring the expanded map lines."
    },
    {
        name = "Factory Complex (SE)",
        coords = { x = 12100, y = 7300, z = 0 },
        description = "Massive industrial zone for heavy crafting and blacksmithing materials."
    },
    {
        name = "American Tire",
        coords = { x = 11800, y = 7000, z = 0 },
        description = "Essential workshop for high-tier vehicle maintenance and mechanical tools."
    }
}

print("[Dynamic Trading] Loaded West Point Spawn Locations: " .. #DT_FactionLocations.WestPoint .. " spots registered.")
