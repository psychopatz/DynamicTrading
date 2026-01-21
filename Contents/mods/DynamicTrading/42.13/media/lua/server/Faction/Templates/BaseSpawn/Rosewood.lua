-- ==============================================================================
-- media/lua/server/Spawn/Faction/Rosewood.lua
-- Data Definition: Rosewood Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

-- Initialize the global registry if it doesn't exist yet
DT_FactionLocations = DT_FactionLocations or {}

-- Create a specific entry for Rosewood to keep things organized
DT_FactionLocations.Rosewood = {
    {
        name = "Rosewood Fire Department",
        coords = { x = 8133, y = 11747, z = 0 },
        description = "A highly defensible brick building with plenty of garage space."
    },
    {
        name = "Rosewood Police Station",
        coords = { x = 8071, y = 11739, z = 0 },
        description = "A secure facility, though the cells might be a bit cramped for living."
    },
    {
        name = "Gated Community - Large House",
        coords = { x = 8035, y = 11520, z = 0 },
        description = "A luxury home surrounded by high fences, perfect for a wealthy faction."
    },
    {
        name = "Rosewood Construction Site",
        coords = { x = 8295, y = 11776, z = 0 },
        description = "An open-air base for those who don't mind the dust."
    },
    {
        name = "Fossoil Gas Station",
        coords = { x = 8121, y = 11277, z = 0 },
        description = "Critical infrastructure. Whoever holds the fuel holds the power."
    }
}

-- Debug Log to confirm the file was loaded during server startup
print("[Dynamic Trading] Loaded Rosewood Spawn Locations: " .. #DT_FactionLocations.Rosewood .. " spots registered.")