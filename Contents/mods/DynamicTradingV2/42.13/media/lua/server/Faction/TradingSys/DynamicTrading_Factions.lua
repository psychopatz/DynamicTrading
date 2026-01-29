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
require "DT_V2_Config"
require "03_DynamicTrading_Archetypes" -- To access Archetype allocations
require "DynamicTrading_Roster"

DynamicTrading_Factions = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function DynamicTrading_Factions.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end

    local data = ModData.get(MOD_DATA_KEY)
    
    -- 1. Create the nomadic failsafe faction if it doesn't exist
    if not data["Independent"] then
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 50,
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

    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Factions.RepopulateTowns()
     if DT_FactionLocations then
        for townName, _ in pairs(DT_FactionLocations) do
            local maxFactions = SandboxVars.DynamicTrading.MaxFactionsPerTown or 2
            for i=1, maxFactions do
                -- We generate unique IDs for each faction instance
                local factionID = townName .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars.DynamicTrading.FactionStartPop or 10
                })
            end
        end
    end
end

-- ==========================================================
-- 2. FACTION CREATION
-- ==========================================================
function DynamicTrading_Factions.CreateFaction(factionID, initialData)
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
            assignedHome = DT_FactionLocationManager.AssignHome(factionID)
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
            starvationDays = 0, -- Track days without food
            reputation = {} -- [Username] = Integer
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
function DynamicTrading_Factions.GenerateRoster(factionID)
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
    
    for i=1, faction.memberCount do
        local randomArch = archetypes[ZombRand(#archetypes) + 1]
        DynamicTrading_Roster.AddSoul(factionID, randomArch)
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
    local Sandbox = SandboxVars.DynamicTrading
    
    local consumptionMult = Sandbox.FactionDailyConsumption or 1.0
    local deathThreshold = Sandbox.FactionDeathThreshold or 3
    local growthChance = Sandbox.FactionGrowthChance or 50
    
    local factionsToRemove = {}

    for id, faction in pairs(data) do
        -- 0. CALCULATE PRODUCTION (Based on Roster)
        local production = { food=0, ammo=0, meds=0, fuel=0 }
        local souls = DynamicTrading_Roster.GetSouls(id)
        
        for _, archID in ipairs(souls) do
            local archData = DynamicTrading.Archetypes[archID]
            if archData and archData.allocations then
                for tag, score in pairs(archData.allocations) do
                    local resourceType = DynamicTrading.V2.Config.ResourceMap[tag]
                    if resourceType then
                         -- Score * Multiplier (e.g., 6 * 2.0 = 12 units)
                        production[resourceType] = production[resourceType] + (score * DynamicTrading.V2.Config.Sim.ProductionMultiplier)
                    end
                end
            end
        end
        
        -- Add Production to Stockpile
        if not faction.stockpile then faction.stockpile = { food=0, ammo=0, meds=0, fuel=0 } end
        for res, amt in pairs(production) do
            faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
        end

        -- 1. CONSUMPTION
        local consumes = DynamicTrading.V2.Config.Sim.BaseConsumption
        if consumes then
            local foodBurn = faction.memberCount * (consumes.food or 1) * consumptionMult
            local medsBurn = faction.memberCount * (consumes.meds or 0.1) * consumptionMult
            
            faction.stockpile.food = (faction.stockpile.food or 0) - foodBurn
            faction.stockpile.meds = (faction.stockpile.meds or 0) - medsBurn
            -- Ammo/Fuel are consumed less reliably, maybe only if "At War" (future), for now base burn
            
            -- 2. STARVATION & DEATH
            if faction.stockpile.food < 0 then
                faction.stockpile.food = 0 -- Clamp
                faction.starvationDays = faction.starvationDays + 1
                
                if faction.starvationDays >= deathThreshold then
                    -- Kill people
                    local deaths = math.ceil(faction.memberCount * DynamicTrading.V2.Config.Sim.DeathRate)
                    deaths = math.max(1, deaths) -- At least 1 dies
                    faction.memberCount = faction.memberCount - deaths
                    
                    -- Remove from roster in Roster module
                    DynamicTrading_Roster.RemoveSoul(id, deaths)
                    
                    print("DT Faction ["..faction.name.."] is STARVING! Lost " .. deaths .. " souls.")
                end
            else
                faction.starvationDays = 0 -- Reset if they have food
            end
            
            -- CHECK FACTION DEATH
            if faction.memberCount <= 0 then
                print("DT Faction ["..faction.name.."] has DIED OUT.")
                table.insert(factionsToRemove, id)
            else
                -- 3. GROWTH (If not starving and has surplus)
                -- Surplus check: Enough food for X days?
                local surplusFood = (faction.stockpile.food or 0) > (faction.memberCount * (consumes.food or 1) * 7) -- 1 Week buffer
                
                if surplusFood and ZombRand(100) < growthChance then
                    -- Assign random class
                    local archetypes = {}
                    for aid, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, aid) end
                    
                    if #archetypes > 0 and DynamicTrading_Engine.ConsumeRecruit() then
                        faction.memberCount = faction.memberCount + 1
                        local newRecruit = archetypes[ZombRand(#archetypes)+1]
                        
                        -- Add to roster in Roster module
                        DynamicTrading_Roster.AddSoul(id, newRecruit)
                        
                        -- Growth Cost (Initial Setup)
                        faction.stockpile.food = faction.stockpile.food - DynamicTrading.V2.Config.Sim.RecruitCost.food
                        
                        print("DT Faction ["..faction.name.."] RECRUITED a new " .. tostring(newRecruit))
                    end
                end
                
                -- Update State Label
                if faction.starvationDays > 0 then
                    faction.state = "Starving"
                elseif (faction.stockpile.food or 0) < (faction.memberCount * 5) then
                    faction.state = "Vulnerable"
                else
                    faction.state = "Stable"
                end
            end
            
            -- Nomadic Failsafe Adjustment
            if id == "Independent" then
                faction.memberCount = math.max(faction.memberCount, 10) -- Nomads replenish mysteriously
                faction.state = "Stable"
                faction.stockpile.food = math.max(faction.stockpile.food or 0, 500)
                faction.wealth = math.max(faction.wealth or 0, 5000) -- Nomads are wealthy
            else
                -- Basic Wealth Simulation: Factions earn small revenue from internal trading/scavenging
                -- We can scale this based on member count
                local dailyEarn = faction.memberCount * 50
                faction.wealth = (faction.wealth or 0) + dailyEarn
            end
        else
            print("DT ERROR: BaseConsumption not found in config for simulation!")
        end
    end
    
    -- Cleanup Dead Factions
    for _, deadID in ipairs(factionsToRemove) do
        data[deadID] = nil
        DynamicTrading_Roster.ClearSouls(deadID) -- Remove their souls from Roster too
    end

    -- DYNAMIC RESPAWNING (Long game stability)
    if DT_FactionLocations then
        local respawnChance = Sandbox.FactionRespawnChance or 10
        local maxFactions = Sandbox.MaxFactionsPerTown or 2
        
        for townName, _ in pairs(DT_FactionLocations) do
            -- Count existing factions in this town
            local count = 0
            for _, f in pairs(data) do
                if f.town == townName then count = count + 1 end
            end
            
            if count < maxFactions and ZombRand(100) < respawnChance then
                -- New faction arrives!
                local factionID = townName .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars.DynamicTrading.FactionStartPop or 10
                })
                print("DT: A new faction has moved into " .. townName)
            end
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

function DynamicTrading_Factions.ModifyWealth(factionID, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction then
        faction.wealth = math.max(0, (faction.wealth or 0) + amount)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

Events.OnInitGlobalModData.Add(DynamicTrading_Factions.Init)