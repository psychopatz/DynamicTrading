-- Server Side Only Check Removed to allow Shared Access (Sim functions guarded instead)


require "DT/Common/Config"

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
        },
        GlobalHeat = {},
        DeflatedGlobal = {}
    },
    Spectrum = {
        assignedFrequencies = {},
        rangeMin = 88.0,
        rangeMax = 108.0
    },
    EventSystem = {
        activeEvents = {}, -- [id] = { expires = -1 }
        lastEventDay = 0
    }
}

function DynamicTrading_Engine.Init()
    -- Server/Authority Logic Only
    if isClient() and not isServer() then
        -- Client: Request data to ensure sync
        if ModData.request then 
            ModData.request(MOD_DATA_KEY)
            -- print("DT Engine: Client requested ModData sync.")
        end
        return 
    end

    local data = ModData.get(MOD_DATA_KEY)
    if not data then
        print("DynamicTrading: Initializing Engine Data...")
        data = defaultData
        ModData.add(MOD_DATA_KEY, data)
        ModData.transmit(MOD_DATA_KEY)
    else
        -- Integrity Check / Migration (Recursive-lite for V2 economic fields)
        for k, v in pairs(defaultData) do
            if data[k] == nil then 
                data[k] = v 
            elseif type(v) == "table" then
                -- Check one level deeper for specific important sub-tables
                for subK, subV in pairs(v) do
                    if data[k][subK] == nil then
                        data[k][subK] = subV
                        print("DT Engine: Migrating missing field [" .. k .. "." .. subK .. "]")
                    end
                end
            end
        end
    end
end

function DynamicTrading_Engine.GetEngineData()
    return ModData.get(MOD_DATA_KEY)
end

function DynamicTrading_Engine.OnTick()
    -- Server/Authority Logic Only
    if isClient() and not isServer() then return end

    local gameTime = getGameTime()
    local data = DynamicTrading_Engine.GetEngineData()
    if not data then return end

    -- Hourly Tick
    local currentHour = math.floor(gameTime:getWorldAgeHours())
    if currentHour > data.SimState.lastHourTick then
        data.SimState.lastHourTick = currentHour
        
        -- Trigger Hourly Signals
        triggerEvent("OnDynamicTradingHourlyTick", currentHour)
        
        ModData.transmit(MOD_DATA_KEY)
    end

    -- Daily Tick
    local currentDay = gameTime:getDaysSurvived()
    if currentDay > data.SimState.lastSimulationDay then
        data.SimState.lastSimulationDay = currentDay
        
        -- Generate Daily Recruits
        local recruitCount = SandboxVars.DynamicTrading.GlobalRecruitCount or 5
        
        -- Apply Event Modifiers
        if DynamicTrading.Events and DynamicTrading.Events.GetDemographicsModifier then
            local mult = DynamicTrading.Events.GetDemographicsModifier("recruitMult")
            if mult ~= 1.0 then
                local old = recruitCount
                recruitCount = math.floor(recruitCount * mult)
                -- print("DT Engine: Recruit Count modified by events: " .. old .. " -> " .. recruitCount)
            end
        end

        data.Demographics.availableRecruits = recruitCount
        print("DT Engine: generated " .. recruitCount .. " global recruits for Day " .. currentDay)
        
        -- Trigger Daily Economy Simulation
        DynamicTrading_Engine.RunDailySimulation()
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Engine.RunDailySimulation()
    -- Server/Authority Logic Only
    if isClient() and not isServer() then return end

    print("DynamicTrading: Running Daily Simulation Signals...")
    
    local data = DynamicTrading_Engine.GetEngineData()
    if data then
        -- 1. Heat Decay (Inflation Recovery)
        local decayRate = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.InflationDecay) or 0.1
        local retention = 1.0 - decayRate
        if retention < 0 then retention = 0 end

        if data.WorldEconomy.GlobalHeat then
            print("[DT Engine] Daily Heat Decay Starting (Rate: " .. tostring(decayRate) .. ")")
            for cat, val in pairs(data.WorldEconomy.GlobalHeat) do
                if val ~= 0 then
                    local oldVal = val
                    data.WorldEconomy.GlobalHeat[cat] = val * retention
                    -- Clamp to zero if negligible
                    if math.abs(data.WorldEconomy.GlobalHeat[cat]) < 0.01 then 
                        data.WorldEconomy.GlobalHeat[cat] = 0 
                    end
                    if oldVal ~= data.WorldEconomy.GlobalHeat[cat] then
                        print("  > Category: " .. tostring(cat) .. " | Heat: " .. tostring(oldVal) .. " -> " .. tostring(data.WorldEconomy.GlobalHeat[cat]))
                    end
                end
            end
        end

        -- 2. Reset Daily Deflation Checklist
        data.WorldEconomy.DeflatedGlobal = {}

        -- 3. Proceed with existing Event Ticks
        if DynamicTrading.Events and DynamicTrading.Events.Tick then
            DynamicTrading.Events.Tick(data)
        end
    end

    -- Broadcast daily simulation signal
    -- Modules like Factions should hook into this via Events.OnDynamicTradingDailySimulation
    triggerEvent("OnDynamicTradingDailySimulation")
end

function DynamicTrading_Engine.UpdateHeat(category, amount)
    -- Guard removed to allow MP Host/Server execution from TradeHandlers
    -- (TradeHandlers is already authority-checked)
    
    if not category or category == "Misc" then return end
    
    local data = DynamicTrading_Engine.GetEngineData()
    if not data then return end
    -- Initialise GlobalHeat if missing (Safety)
    if not data.WorldEconomy.GlobalHeat then data.WorldEconomy.GlobalHeat = {} end

    local current = data.WorldEconomy.GlobalHeat[category] or 0
    data.WorldEconomy.GlobalHeat[category] = current + amount
    
    -- Safety Clamps (Shared with V1 logic)
    if data.WorldEconomy.GlobalHeat[category] > 2.0 then data.WorldEconomy.GlobalHeat[category] = 2.0 end
    if data.WorldEconomy.GlobalHeat[category] < -0.8 then data.WorldEconomy.GlobalHeat[category] = -0.8 end
    
    if DynamicTrading.Debug or amount ~= 0 then
        print("[DT Engine] UpdateHeat: " .. tostring(category) .. " | Change: " .. tostring(amount) .. " | New: " .. tostring(data.WorldEconomy.GlobalHeat[category]))
        -- Debug: Log Sync Trigger
        -- print("[DT Engine] Transmitting ModData...")
    end
    
    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Engine.ConsumeRecruit()
    -- Guard removed to allow MP Host execution
    local data = DynamicTrading_Engine.GetEngineData()
    if data and data.Demographics.availableRecruits > 0 then
        data.Demographics.availableRecruits = data.Demographics.availableRecruits - 1
        return true
    end
    return false
end

-- =============================================================================
-- EVENT-AWARE GETTERS (WORLD ECONOMY)
-- =============================================================================

function DynamicTrading_Engine.GetScavengeEfficiency()
    local data = DynamicTrading_Engine.GetEngineData()
    local base = data and data.WorldEconomy.scavengeEfficiency or 1.0
    
    if DynamicTrading.Events and DynamicTrading.Events.GetWorldModifier then
        return base * DynamicTrading.Events.GetWorldModifier("scavengeEfficiencyMult")
    end
    return base
end

function DynamicTrading_Engine.GetConsumptionModifier(resourceType)
    local data = DynamicTrading_Engine.GetEngineData()
    local base = 1.0
    if data and data.WorldEconomy.consumptionMods then
        base = data.WorldEconomy.consumptionMods[resourceType] or 1.0
    end
    
    if DynamicTrading.Events and DynamicTrading.Events.GetWorldModifier then
        return base * DynamicTrading.Events.GetWorldModifier("consumptionMults", resourceType)
    end
    return base
end

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if key == MOD_DATA_KEY then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

-- Hook into Game Events
Events.OnInitGlobalModData.Add(DynamicTrading_Engine.Init)
Events.OnTick.Add(DynamicTrading_Engine.OnTick)
