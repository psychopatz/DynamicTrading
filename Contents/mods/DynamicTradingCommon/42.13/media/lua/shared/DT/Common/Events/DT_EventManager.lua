-- =============================================================================
--  DT_EventManager.lua
-- =============================================================================
--  Shared Event Manager for Dynamic Trading V1 and V2.
-- =============================================================================

require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = {}
DynamicTrading.Events.Registry = {}
DynamicTrading.Events.ActiveEvents = {} 

-- =============================================================================
-- 1. REGISTRATION API
-- =============================================================================
function DynamicTrading.Events.Register(id, data)
    if not id or not data then return end
    -- Default to "flash" if not explicitly set
    if not data.type then data.type = "flash" end
    DynamicTrading.Events.Registry[id] = data
end

-- =============================================================================
-- 2. ECONOMY HOOKS (GETTERS)
-- =============================================================================

function DynamicTrading.Events.GetPriceModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].price then
                    multiplier = multiplier * event.effects[tag].price
                end
            end
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetVolumeModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].vol then
                    multiplier = multiplier * event.effects[tag].vol
                end
            end
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetSystemModifier(key)
    local multiplier = 1.0
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.system and event.system[key] then
            multiplier = multiplier * event.system[key]
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetInjections()
    local injections = {}
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.inject then
            for tag, count in pairs(event.inject) do
                injections[tag] = (injections[tag] or 0) + count
            end
        end
    end
    return injections
end

function DynamicTrading.Events.GetFlashCandidates()
    local candidates = {}
    for id, event in pairs(DynamicTrading.Events.Registry) do
        if event.type == "flash" then
            local success, shouldSpawn = pcall(function()
                if event.canSpawn then return event.canSpawn() end
                return true
            end)
            
            if success and shouldSpawn == true then
                table.insert(candidates, id)
            end
        end
    end
    return candidates
end

-- =============================================================================
-- 3. LOAD DEFINITIONS
-- =============================================================================

-- Meta - Positive
require "DT/Common/Events/Meta/Positive/NatureReclamation"

-- Meta - Negative
require "DT/Common/Events/Meta/Negative/WaterFail"
require "DT/Common/Events/Meta/Negative/PowerFail"
require "DT/Common/Events/Meta/Negative/GreatRot"
require "DT/Common/Events/Meta/Negative/HygieneCollapse"
require "DT/Common/Events/Meta/Negative/BallisticExhaustion"
require "DT/Common/Events/Meta/Negative/ManufacturingHalt"
require "DT/Common/Events/Meta/Negative/KnowledgeGap"
require "DT/Common/Events/Meta/Negative/IronAge"
require "DT/Common/Events/Meta/Negative/FuelCrisis"
require "DT/Common/Events/Meta/Negative/SignalDecay"

-- Seasonal - Positive
require "DT/Common/Events/Seasonal/Positive/Harvest"
require "DT/Common/Events/Seasonal/Positive/Spring"

-- Seasonal - Negative
require "DT/Common/Events/Seasonal/Negative/Winter"
require "DT/Common/Events/Seasonal/Negative/Heatwave"

-- Flash - Positive
require "DT/Common/Events/Flash/Positive/Surplus"
require "DT/Common/Events/Flash/Positive/HospitalFound"
require "DT/Common/Events/Flash/Positive/FishingTourney"
require "DT/Common/Events/Flash/Positive/HuntingSeason"
require "DT/Common/Events/Flash/Positive/ConstructionBoom"
require "DT/Common/Events/Flash/Positive/SalvageOp"
require "DT/Common/Events/Flash/Positive/GoldRush"
require "DT/Common/Events/Flash/Positive/Smugglers"
require "DT/Common/Events/Flash/Positive/Celebration"
require "DT/Common/Events/Flash/Positive/SchoolStart"
require "DT/Common/Events/Flash/Positive/TechBoom"
require "DT/Common/Events/Flash/Positive/MechanicFair"
require "DT/Common/Events/Flash/Positive/FireSale"
require "DT/Common/Events/Flash/Positive/CaravanArrival"
require "DT/Common/Events/Flash/Positive/AtmosphericClear"
require "DT/Common/Events/Flash/Positive/RadioClub"
require "DT/Common/Events/Flash/Positive/EmergencyNet"
require "DT/Common/Events/Flash/Positive/FreeMarket"

-- Flash - Negative
require "DT/Common/Events/Flash/Negative/Warzone"
require "DT/Common/Events/Flash/Negative/Outbreak"
require "DT/Common/Events/Flash/Negative/Famine"
require "DT/Common/Events/Flash/Negative/FuelShortage"
require "DT/Common/Events/Flash/Negative/CrimeWave"
require "DT/Common/Events/Flash/Negative/SolarFlare"
require "DT/Common/Events/Flash/Negative/Inflation"
require "DT/Common/Events/Flash/Negative/SignalJamming"
require "DT/Common/Events/Flash/Negative/WitchHunt"
require "DT/Common/Events/Flash/Negative/ElectricalStorm"
require "DT/Common/Events/Flash/Negative/BridgeCollapse"
require "DT/Common/Events/Flash/Negative/PanicBroadcast"

print("[DynamicTrading] Common Event Manager Initialized.")
