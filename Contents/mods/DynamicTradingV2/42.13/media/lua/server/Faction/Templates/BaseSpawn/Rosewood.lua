-- ==============================================================================
-- media/lua/server/Spawn/Faction/Rosewood.lua
-- Data Definition: Rosewood Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

-- Initialize the global registry if it doesn't exist yet
DT_FactionLocations = DT_FactionLocations or {}

-- Create a specific entry for Rosewood to keep things organized
DT_FactionLocations.Rosewood = {
DT_FactionLocations.Rosewood = {
    -- CIVIC & PUBLIC SERVICES
    {
        name = "Rosewood Fire Station",
        coords = { x = 8147, y = 11745, z = 0 },
        description = "Premier base location; updated with B42 crafting tool spawns."
    },
    {
        name = "Rosewood Police Station",
        coords = { x = 8081, y = 11745, z = 0 },
        description = "Highly secure; features a redesigned B42 armory and basement."
    },
    {
        name = "Rosewood Courthouse",
        coords = { x = 8147, y = 11625, z = 0 },
        description = "Large-scale facility with high-tier electronics and office supplies."
    },
    {
        name = "Rosewood School",
        coords = { x = 8264, y = 11500, z = 0 },
        description = "Massive book repository with a new storm shelter basement entrance."
    },
    {
        name = "Rosewood Medical",
        coords = { x = 8045, y = 11585, z = 0 },
        description = "Essential hub for B42 medical items and clinical supplies."
    },

    -- COMMERCIAL & INDUSTRIAL
    {
        name = "Fossoil Gas Station",
        coords = { x = 8165, y = 11275, z = 0 },
        description = "Strategic fuel source and automotive repair workshop."
    },
    {
        name = "Rosewood Construction Site",
        coords = { x = 8285, y = 11750, z = 0 },
        description = "Industrial zone containing heavy construction and metalworking tools."
    },
    {
        name = "Book World",
        coords = { x = 8050, y = 11540, z = 0 },
        description = "Critical for B42 specialized crafting and blacksmithing recipes."
    },

    -- B42 EXPANSION & HIGH-VALUE SPOTS
    {
        name = "Blacksmith’s Cabin",
        coords = { x = 7420, y = 11800, z = 0 }, -- Located West of Prison
        description = "New B42 POI dedicated to primitive crafting and early iron-working."
    },
    {
        name = "Northwest Farm (Livestock)",
        coords = { x = 7540, y = 11150, z = 0 },
        description = "Features 2026 livestock sheds for animal husbandry systems."
    },
    {
        name = "Rosewood Prison Armory",
        coords = { x = 7720, y = 11850, z = 0 },
        description = "Extremely high-risk area with the highest concentration of tactical gear."
    },
    {
        name = "Gated Community (North)",
        coords = { x = 8050, y = 11100, z = 0 },
        description = "Residential zone containing several new B42 static basements."
    }
}

-- Debug Log to confirm the file was loaded during server startup
print("[Dynamic Trading] Loaded Rosewood Spawn Locations: " .. #DT_FactionLocations.Rosewood .. " spots registered.")