-- ==============================================================================
-- media/lua/server/Spawn/Faction/Riverside.lua
-- Data Definition: Riverside Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.Riverside = {
    {
        name = "Riverside Police Station",
        coords = { x = 6540, y = 5275, z = 0 },
        description = "Secure facility near the Riverside school."
    },
    {
        name = "Riverside Gated Community",
        coords = { x = 4920, y = 6120, z = 0 },
        description = "High-end housing with a lot of space."
    },
    {
        name = "Riverside Post Office",
        coords = { x = 6610, y = 5210, z = 0 },
        description = "A central hub in Riverside."
    }
}

print("[Dynamic Trading] Loaded Riverside Spawn Locations: " .. #DT_FactionLocations.Riverside .. " spots registered.")
