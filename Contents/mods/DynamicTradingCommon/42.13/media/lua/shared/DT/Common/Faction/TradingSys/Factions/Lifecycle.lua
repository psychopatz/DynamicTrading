-- ==============================================================================
-- Factions/Lifecycle.lua
-- Logic: Faction Initialization, Creation, and Roster Generation.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/Templates/BaseSpawn/DT_FactionLocationManager"
require "DT/Common/Faction/Templates/FactionNames/DT_FactionNames"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"

local Lifecycle = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function Lifecycle.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end

    local data = ModData.get(MOD_DATA_KEY)
    
    -- 1. Create the nomadic failsafe faction if it doesn't exist
    if not data["Independent"] then
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 10,
            isNomadic = true
        })
    end

    -- 2. Check if we need to repopulate towns
    -- We do this if ONLY "Independent" exists or if there are NO town factions
    local townFactionCount = 0
    for id, f in pairs(data) do
        if id ~= "Independent" then
            townFactionCount = townFactionCount + 1
        end
    end

    if townFactionCount == 0 then
        print("DT: No town factions found, triggering initial population...")
        DynamicTrading_Factions.RepopulateTowns()
    end

    -- 3. Data Integrity: Ensure proper data types for existing factions
    for id, f in pairs(data) do
        -- Fallback: ensure reputation is a table
        if type(f.reputation) ~= "table" then
            f.reputation = {}
        end
        
        if type(f.wealth) ~= "number" then
            f.wealth = 1000
        end

        if not f.ActiveFlashEvent then
            f.ActiveFlashEvent = { id = nil, expires = 0 }
        end

        if not f.consecutiveStableDays then
            f.consecutiveStableDays = 0
        end
    end

    ModData.transmit(MOD_DATA_KEY)
end

function Lifecycle.RepopulateTowns()
     if DT_FactionLocations then
        for townName, _ in pairs(DT_FactionLocations) do
            local maxFactions = SandboxVars.DynamicTrading.MaxFactionsPerTown or 2
            for i=1, maxFactions do
                -- We generate unique IDs for each faction instance
                local factionID = townName .. "_" .. tostring(100000 + ZombRand(900000))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars.DynamicTrading.FactionStartPop or 3
                })
            end
        end
    end
end

-- ==========================================================
-- 2. FACTION CREATION
-- ==========================================================
function Lifecycle.CreateFaction(factionID, initialData)
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end
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
            assignedHome = DT_FactionLocationManager.AssignHome(factionID, initialData.town)
        end

        -- B. Construct the Faction Object
        data[factionID] = {
            id = factionID,
            name = displayName, -- The "flavor" name (The Iron Vanguard)
            town = initialData.town, -- Keep track of which town this faction belongs to
            homeCoords = assignedHome, -- The "physical" base (Rosewood Fire Station)
            stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25 },
            state = initialData.state or "Stable",
            memberCount = initialData.memberCount or (SandboxVars.DynamicTrading.FactionStartPop or 10),
            wealth = initialData.wealth or 1000, -- Stores the total money of all the traders in the faction
            reputation = initialData.reputation or {}, -- [Username] = Integer
            starvationDays = 0, -- Track days without food
            consecutiveStableDays = 0, -- Track how long they've been stable (for wildcard triggers)
            ActiveFlashEvent = { id = nil, expires = 0 } -- id = event string, expires = world age hour
        }
        
        -- Generate Initial Roster in DynamicTrading_Roster
        DynamicTrading_Factions.GenerateRoster(factionID)

        ModData.transmit(MOD_DATA_KEY)
        
        local homeLog = assignedHome and ("at " .. assignedHome.name) or "Nomadic"
        print("DT: Created Faction [" .. factionID .. "] Known as '" .. displayName .. "' " .. homeLog)
    else
        print("DT: Faction ID [" .. factionID .. "] already exists in database.")
    end
end

-- ==========================================================
-- 2.1 HELPER: ROSTER GENERATION
-- ==========================================================
function Lifecycle.GenerateRoster(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if not faction then return end
    
    -- Clear any existing souls if we are generating fresh
    DynamicTrading_Roster.ClearSouls(factionID)
    
    local archetypes = {} 
    for id, _ in pairs(DynamicTrading.Archetypes) do
        table.insert(archetypes, id)
    end
    
    if #archetypes == 0 then return end
    
    local home = faction.homeCoords
    local scatterRange = 10 -- +/- 10 tiles

    for i=1, faction.memberCount do
        local randomArch = archetypes[ZombRand(#archetypes) + 1]
        
        -- Scattered Home logic
        local scatteredHome = nil
        if home and home.x then
            scatteredHome = {
                x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                z = home.z or 0
            }
        end
        
        DynamicTrading_Roster.AddSoul(factionID, randomArch, scatteredHome)
    end
end

return Lifecycle
