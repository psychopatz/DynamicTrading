--[[
    =============================================================================
    DYNAMIC TRADING - ARCHETYPE CONFIGURATION GUIDE
    =============================================================================
    
    This file defines the specific "Personalities" of traders found via radio.
    You can modify existing traders or add your own by following the format below.

    HOW TO REGISTER A NEW TRADER:
    -------------------------------------------------------------------------
    DynamicTrading.RegisterArchetype("UniqueID", {
        name = "Display Name",      -- The name shown in the UI (e.g., "Farmer", "Gunrunner")

        -- [WHAT THEY SELL]
        -- Key = Tag Name, Value = 'Slots' or Weight. 
        -- Higher numbers mean the trader will generate MORE items of this category.
        allocations = {
            ["Food"] = 5,           -- High chance for Food
            ["Medical"] = 2         -- Low chance for Meds
        },

        -- [WHAT THEY WANT] (Price Bonus)
        -- Key = Tag Name, Value = Price Multiplier.
        -- 1.2 = Pays +20% more. 1.5 = Pays +50% more.
        wants = {
            ["Seed"] = 1.5,         -- Loves Seeds
            ["Tool"] = 1.2          -- Likes Tools
        },

        -- [WHAT THEY HATE]
        -- List of Tags this trader will NEVER sell and usually won't buy.
        forbid = { "Weapon", "Alcohol", "Junk" }
    })

    Available Tags can be found in the /media/lua/shared/DTItems/ folders.
    (e.g., "Ammo", "Medical", "Luxury", "Construction", "Fresh", "Canned", etc.)
    =============================================================================
]]
DynamicTrading = DynamicTrading or {}
if not DynamicTrading.Archetypes then
    print("[DynamicTrading] Initializing Archetype Table...")
    DynamicTrading.Archetypes = {}
end

require "DynamicTrading_Config"

print("[DynamicTrading] Booting Archetype Registry...")

local archetypesToLoad = {
    "General", "Farmer", "Butcher", "Doctor", "Mechanic",
    "Survivalist", "Gunrunner", "Foreman", "Scavenger", "Tailor",
    "Electrician", "Welder", "Chef", "Herbalist", "Smuggler",
    "Librarian", "Angler", "Sheriff", "Bartender", "Teacher",
    "Hunter", "Quartermaster", "Musician", "Janitor", "Carpenter",
    "Pawnbroker", "Pyro", "Athlete", "Pharmacist", "Hiker",
    "Burglar", "Blacksmith", "Tribal", "Painter", "RoadWarrior",
    "Designer", "Office", "Geek", "Brewer", "Demo"
}

-- Registry Function (Standalone definition to ensure it exists before loading)
if not DynamicTrading.RegisterArchetype then
    print("[DynamicTrading] Registering Archetype Function...")
    function DynamicTrading.RegisterArchetype(id, data)
        if not id or not data then return end
        DynamicTrading.Archetypes[id] = data
        -- print("  - Registered: " .. id)
    end
end

-- Registry Function
function DynamicTrading.LoadArchetypes()
    print("[DynamicTrading] Loading " .. #archetypesToLoad .. " decoupled archetypes...")
    local successCount = 0
    
    for _, id in ipairs(archetypesToLoad) do
        local path = "Archetypes/" .. id .. "/Items/trade"
        local success, err = pcall(function() require(path) end)
        
        if success then
            successCount = successCount + 1
        else
            print("[DynamicTrading] WARNING: Failed to load archetype [" .. id .. "] at path: media/lua/shared/" .. path .. ".lua")
            print("  - Reason: " .. tostring(err))
        end
    end
    
    local finalCount = 0
    if DynamicTrading.Archetypes then
        for _ in pairs(DynamicTrading.Archetypes) do finalCount = finalCount + 1 end
    end
    print("[DynamicTrading] Registry Update Complete: " .. finalCount .. " archetypes registered total (" .. successCount .. " loaded this pass).")
end

-- Execute Loading
DynamicTrading.LoadArchetypes()

print("[DynamicTrading] Archetype Boot Sequence Complete.")