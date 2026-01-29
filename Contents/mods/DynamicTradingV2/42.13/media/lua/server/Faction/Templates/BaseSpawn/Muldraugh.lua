-- ==============================================================================
-- media/lua/server/Spawn/Faction/Muldraugh.lua
-- Data Definition: Muldraugh Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.Muldraugh = {
    {
        name = "Muldraugh Police Station",
        coords = { x = 10633, y = 10416, z = 0 },
        description = "A standard police station located along the main road."
    },
    {
        name = "Cortman Medical",
        coords = { x = 10860, y = 10034, z = 0 },
        description = "A small medical clinic, vital for health-oriented factions."
    }
}

print("[Dynamic Trading] Loaded Muldraugh Spawn Locations: " .. #DT_FactionLocations.Muldraugh .. " spots registered.")
