if isClient() then return end -- Server Side Only

require "DT_V2_Config"

DynamicTrading_Engine = {}
local MOD_DATA_KEY = "DynamicTrading_Engine_v2"

-- Default Schema
local defaultData = {
    SimState = {
        lastSimulationDay = 0,
        lastHourTick = 0,
        systemLock = false
    },
    Demographics = {
        availableRecruits = 0, -- Calculated daily based on Sandbox
        migrationRate = 1,     -- Unused currently
        attritionRate = 0.05   -- Unused currently
    },
    WorldEconomy = {
        scavengeEfficiency = 1.0,
        consumptionMods = {
            food = 1.0,
            ammo = 1.0,
            meds = 1.0,
            fuel = 1.0
        }
    },
    Spectrum = {
        assignedFrequencies = {},
        rangeMin = 88.0,
        rangeMax = 108.0
    }
}

function DynamicTrading_Engine.Init()
    local data = ModData.get(MOD_DATA_KEY)
    if not data then
        print("DynamicTrading: Initializing Engine Data...")
        data = defaultData
        ModData.add(MOD_DATA_KEY, data)
        ModData.transmit(MOD_DATA_KEY)
    else
        -- Integrity Check / Migration could go here
        -- Ensure all tables exist (simple merge for safety)
        for k, v in pairs(defaultData) do
            if data[k] == nil then data[k] = v end
        end
    end
end

function DynamicTrading_Engine.GetEngineData()
    return ModData.get(MOD_DATA_KEY)
end

function DynamicTrading_Engine.OnTick()
    local gameTime = getGameTime()
    local data = DynamicTrading_Engine.GetEngineData()
    if not data then return end

    -- Hourly Tick
    local currentHour = math.floor(gameTime:getWorldAgeHours())
    if currentHour > data.SimState.lastHourTick then
        data.SimState.lastHourTick = currentHour
        -- Trigger Hourly Events
        ModData.transmit(MOD_DATA_KEY)
    end

    -- Daily Tick
    local currentDay = gameTime:getDaysSurvived()
    if currentDay > data.SimState.lastSimulationDay then
        data.SimState.lastSimulationDay = currentDay
        
        -- Generate Daily Recruits (Sandbox Configurable)
        local recruitCount = SandboxVars.DynamicTrading.GlobalRecruitCount or 5
        data.Demographics.availableRecruits = recruitCount
        print("DT Engine: generated " .. recruitCount .. " global recruits for Day " .. currentDay)
        
        -- Trigger Daily Economy Simulation
        DynamicTrading_Engine.RunDailySimulation()
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Engine.RunDailySimulation()
    print("DynamicTrading: Running Daily Simulation...")
    
    -- 1. Faction Updates (Consumption, Production, Deaths)
    if DynamicTrading_Factions then
        DynamicTrading_Factions.UpdateDaily()
    end
    
    -- 2. Distribute Remaining Recruits (Growth)
    -- Factions request recruits in UpdateDaily -> we can process requests here if we want centralized logic,
    -- OR Factions can claim them directly if they run sequentially.
    -- For simplicity, Factions have already run and claimed recruits if logic is inside Factions.
    -- If we want centralized distribution, we would iterate factions here.
    -- Let's stick to Factions pulling from the pool for now to keep it modular.
end

function DynamicTrading_Engine.ConsumeRecruit()
    local data = DynamicTrading_Engine.GetEngineData()
    if data and data.Demographics.availableRecruits > 0 then
        data.Demographics.availableRecruits = data.Demographics.availableRecruits - 1
        return true
    end
    return false
end

-- Hook into Game Events
Events.OnInitGlobalModData.Add(DynamicTrading_Engine.Init)
Events.OnTick.Add(DynamicTrading_Engine.OnTick)
