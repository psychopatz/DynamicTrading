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
    }
}

-- Debug Log to confirm the file was loaded during server startup
print("[Dynamic Trading] Loaded Rosewood Spawn Locations: " .. #DT_FactionLocations.Rosewood .. " spots registered.")