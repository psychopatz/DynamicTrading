-- ==============================================================================
-- media/lua/server/Spawn/Faction/WestPoint.lua
-- Data Definition: West Point Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.WestPoint = {
    {
        name = "West Point Police Station",
        coords = { x = 11905, y = 6932, z = 0 },
        description = "A strong base in the heart of West Point."
    },
    {
        name = "West Point Hardware Store",
        coords = { x = 11846, y = 6876, z = 0 },
        description = "Full of tools and supplies, a strategic asset."
    },
    {
        name = "Enigma Books",
        coords = { x = 12053, y = 6736, z = 0 },
        description = "A quiet place for intellectuals or book-loving survivors."
    }
}

print("[Dynamic Trading] Loaded West Point Spawn Locations: " .. #DT_FactionLocations.WestPoint .. " spots registered.")
