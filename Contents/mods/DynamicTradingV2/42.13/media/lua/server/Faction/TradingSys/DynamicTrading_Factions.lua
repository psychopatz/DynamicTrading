-- ==============================================================================
-- media/lua/server/DynamicTrading_Factions.lua
-- Logic: Managing Faction Identity, Stockpiles, and Home Bases.
-- Build 42 Compatible.
-- ==============================================================================

if isClient() then return end -- Server Side Only

-- Required modules
require "DynamicTrading_Engine"
require "DT_FactionLocationManager"
require "Faction/DT_FactionNames" -- Our new naming engine

DynamicTrading_Factions = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function DynamicTrading_Factions.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
        -- Create the nomadic failsafe faction immediately
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 50,
            isNomadic = true
        })
        ModData.transmit(MOD_DATA_KEY)
    end
end

-- ==========================================================
-- 2. FACTION CREATION
-- ==========================================================
function DynamicTrading_Factions.CreateFaction(factionID, initialData)
    local data = ModData.get(MOD_DATA_KEY)
    initialData = initialData or {}
    
    if not data[factionID] then
        local displayName = ""
        local assignedHome = nil

        -- A. Handle Naming & Home Assignment
        if factionID == "Independent" or initialData.isNomadic then
            displayName = "Independent Traders"
            assignedHome = nil -- Nomads have no home base
        else
            -- Use our new dynamic naming engine
            displayName = DT_FactionNames.Generate()
            -- Ask the location manager for a physical base
            assignedHome = DT_FactionLocationManager.AssignHome(factionID)
        end

        -- B. Construct the Faction Object
        data[factionID] = {
            id = factionID,
            name = displayName, -- The "flavor" name (The Iron Vanguard)
            homeCoords = assignedHome, -- The "physical" base (Rosewood Fire Station)
            stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25 },
            state = initialData.state or "Stable",
            memberCount = initialData.memberCount or 5,
            reputation = {} -- [Username] = Integer
        }

        ModData.transmit(MOD_DATA_KEY)
        
        local homeLog = assignedHome and ("at " .. assignedHome.name) or "Nomadic"
        print("DT: Created Faction [" .. factionID .. "] Known as '" .. displayName .. "' " .. homeLog)
    else
        print("DT: Faction ID [" .. factionID .. "] already exists in database.")
    end
end

-- ==========================================================
-- 3. GETTERS
-- ==========================================================
function DynamicTrading_Factions.GetFaction(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    return data[factionID]
end

-- ==========================================================
-- 4. DAILY SIMULATION
-- ==========================================================
function DynamicTrading_Factions.UpdateDaily()
    local data = ModData.get(MOD_DATA_KEY)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local consumption = engineData and engineData.WorldEconomy.consumptionMods or { food=1, ammo=1 }

    for id, faction in pairs(data) do
        -- 1. Food Consumption
        local dailyBurn = faction.memberCount * 2.0 * (consumption.food or 1.0)
        faction.stockpile.food = math.max(0, faction.stockpile.food - dailyBurn)

        -- 2. State Shifts
        if faction.stockpile.food <= 0 then
            faction.state = "Starving"
        elseif faction.stockpile.food < (faction.memberCount * 10) then
            faction.state = "Vulnerable"
        else
            faction.state = "Stable"
        end

        -- 3. Nomadic Maintenance (Nomads don't starve to death as easily)
        if id == "Independent" then
            faction.stockpile.food = math.max(faction.stockpile.food, 250)
            faction.state = "Stable"
        end
    end
    
    ModData.transmit(MOD_DATA_KEY)
    print("DT: Daily Faction Simulation Updated.")
end

-- ==========================================================
-- 5. STOCKPILE INTERACTION
-- ==========================================================
function DynamicTrading_Factions.ModifyStockpile(factionID, resource, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction and faction.stockpile[resource] then
        faction.stockpile[resource] = math.max(0, faction.stockpile[resource] + amount)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

Events.OnInitGlobalModData.Add(DynamicTrading_Factions.Init)