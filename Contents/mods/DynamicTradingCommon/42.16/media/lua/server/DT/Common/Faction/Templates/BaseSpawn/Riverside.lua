-- ==============================================================================
-- media/lua/server/Spawn/Faction/Riverside.lua
-- Data Definition: Riverside Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.Riverside = {
    {
        name = "Riverside Police Station",
        coords = { x = 6079, y = 5267, z = 0 },
        description = "Small station; vital for early firearms and includes a new basement."
    },
    {
        name = "Riverside School",
        coords = { x = 6115, y = 5435, z = 0 },
        description = "Massive resource for books and backpacks; safe space for B42 farming."
    },
    {
        name = "Post Office",
        coords = { x = 6315, y = 5265, z = 0 },
        description = "Primary source for skill books and magazines."
    },
    {
        name = "Enigma Books",
        coords = { x = 6429, y = 5267, z = 0 },
        description = "Educational loot hub located within the main strip mall."
    },
    {
        name = "Riverside Cemetery",
        coords = { x = 5710, y = 5334, z = 0 },
        description = "A quiet, open area on the western edge suitable for low-heat bases."
    },

    -- RETAIL & COMMERCIAL HUBS
    {
        name = "GigaMart",
        coords = { x = 6510, y = 5285, z = 0 },
        description = "The primary food and refrigeration hub for the Riverside district."
    },
    {
        name = "Pharmahug Pharmacy",
        coords = { x = 6468, y = 5266, z = 0 },
        description = "Crucial for medical supplies and first-aid kits."
    },
    {
        name = "Hardware Store",
        coords = { x = 6385, y = 5265, z = 0 },
        description = "High-tier tools and materials for new B42 crafting stations."
    },
    {
        name = "Bar & Grill",
        coords = { x = 6545, y = 5220, z = 0 },
        description = "Waterfront restaurant with food stocks and kitchen supplies."
    },
    {
        name = "Yacht Club",
        coords = { x = 6600, y = 5140, z = 0 },
        description = "Riverside waterfront landmark with unique loot and high visibility."
    },

    -- RESIDENTIAL & OUTSKIRTS
    {
        name = "Riverside Gated Community",
        coords = { x = 4920, y = 6120, z = 0 },
        description = "High-end housing with fortified fencing and ample residential loot."
    },
    {
        name = "Public Restrooms (West)",
        coords = { x = 3677, y = 5763, z = 0 },
        description = "Western outskirts landmark; useful for long-distance scouting."
    }
}

DynamicTrading.Log("DTCommons", "Init", "Faction", "Loaded Riverside Spawn Locations: " .. #DT_FactionLocations.Riverside .. " spots registered")
