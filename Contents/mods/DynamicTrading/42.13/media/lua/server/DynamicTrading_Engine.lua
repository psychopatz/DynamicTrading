if isClient() then return end -- Server Side Only

DynamicTrading_Engine = {}
local MOD_DATA_KEY = "DynamicTrading_Engine_v1.1"

-- Default Schema
local defaultData = {
    SimState = {
        lastSimulationDay = 0,
        lastHourTick = 0,
        systemLock = false
    },
    Demographics = {
        availableRecruits = 5,
        migrationRate = 1,
        attritionRate = 0.05
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
        -- Trigger Daily Economy Simulation
        DynamicTrading_Engine.RunDailySimulation()
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Engine.RunDailySimulation()
    print("DynamicTrading: Running Daily Simulation...")
    -- Placeholder for calling Faction updates
    if DynamicTrading_Factions then
        DynamicTrading_Factions.UpdateDaily()
    end
end

-- Hook into Game Events
Events.OnInitGlobalModData.Add(DynamicTrading_Engine.Init)
Events.OnTick.Add(DynamicTrading_Engine.OnTick)
