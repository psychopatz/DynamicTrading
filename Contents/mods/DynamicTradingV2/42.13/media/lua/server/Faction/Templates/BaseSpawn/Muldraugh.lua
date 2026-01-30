-- ==============================================================================
-- media/lua/server/Spawn/Faction/Muldraugh.lua
-- Data Definition: Muldraugh Faction Base Locations
-- Build 42 Compatible
-- ==============================================================================

DT_FactionLocations = DT_FactionLocations or {}

DT_FactionLocations.Muldraugh = {
    {
        name = "Muldraugh Police Station",
        coords = { x = 10636, y = 10411, z = 0 },
        description = "Features a new morgue and basement; high tactical value."
    },
    {
        name = "Cortman Medical",
        coords = { x = 10876, y = 10030, z = 0 },
        description = "Significantly expanded clinic with high-density medical loot."
    },
    {
        name = "Muldraugh Elementary School",
        coords = { x = 10640, y = 10160, z = 0 },
        description = "Fortified yard and a new storm shelter basement."
    },
    {
        name = "Sunstar Motel",
        coords = { x = 10628, y = 9815, z = 0 },
        description = "Multi-room residential complex ideal for large early-game factions."
    },
    {
        name = "Knox Bank",
        coords = { x = 10738, y = 9432, z = 0 },
        description = "High-tier loot location featuring a static vault basement."
    },
    {
        name = "Muldraugh Fire Department",
        coords = { x = 10595, y = 10550, z = 0 },
        description = "Essential hub for high-value tools and emergency medical supplies."
    },
    {
        name = "Greene’s Grocery",
        coords = { x = 10607, y = 10256, z = 0 },
        description = "Central food distribution hub for the town interior."
    },

    -- INDUSTRIAL & CRAFTING (Blacksmithing Hubs)
    {
        name = "McCoy Logging Co. (Main)",
        coords = { x = 11030, y = 9250, z = 0 },
        description = "Primary industrial site for B42 crafting and timber processing."
    },
    {
        name = "L&B Warehouse",
        coords = { x = 10716, y = 10438, z = 0 },
        description = "Optimized for blacksmithing stations and heavy metalworking."
    },
    {
        name = "U-Store It Self-Storage",
        coords = { x = 10686, y = 9830, z = 0 },
        description = "High density of generators and rare metalworking equipment."
    },
    {
        name = "Mass-Genfac Co.",
        coords = { x = 10530, y = 9560, z = 0 },
        description = "Major industrial facility on the outskirts; prime for heavy industry."
    },

    -- ENTERTAINMENT & RURAL EXPANSION
    {
        name = "The Rusty Rifle Bar",
        coords = { x = 10750, y = 10588, z = 0 },
        description = "Southern social hub featuring a 100% spawn chance cellar."
    },
    {
        name = "Muldraugh North Lakehouse",
        coords = { x = 10967, y = 8592, z = 0 },
        description = "Secluded base offering sustainable fishing and water access."
    },
    {
        name = "Western Livestock Farm",
        coords = { x = 10200, y = 10000, z = 0 }, -- Estimated coord for West of Main Road
        description = "Dedicated site for the B42 animal husbandry systems."
    },
    {
        name = "Military Checkpoint South",
        coords = { x = 10660, y = 10900, z = 0 }, -- Estimated southern outskirts
        description = "Tactical outpost for high-tier military gear and weaponry."
    }
}

print("[Dynamic Trading] Loaded Muldraugh Spawn Locations: " .. #DT_FactionLocations.Muldraugh .. " spots registered.")
