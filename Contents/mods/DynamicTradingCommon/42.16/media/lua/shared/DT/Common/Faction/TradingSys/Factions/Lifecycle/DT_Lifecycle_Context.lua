require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"

local BuildingInit = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingInit"

local Lifecycle = {}

local context = {
    Lifecycle = Lifecycle,
    BuildingInit = BuildingInit,
    MOD_DATA_KEY = "DynamicTrading_Factions",
    EXPLORATION_DATA_KEY = "DynamicTrading_Exploration",
    IS_SERVER_RUNTIME = (not isClient()) or isServer(),
    deferredBootstrapPending = false,
    deferredBootstrapTickCounter = 0,
    deferredTownQueue = {},
    townVisitTickCounter = 0,
    processDeferredTownQueue = nil,
}

if context.IS_SERVER_RUNTIME then
    require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"
    require "DT/Common/Faction/Templates/BaseSpawn/DT_FactionLocationManager"
    require "DT/Common/Faction/Templates/FactionNames/DT_FactionNames"
    require "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState"
end

function context.buildTownFactionID(townName)
    local prefix = tostring(townName or "Town")
    prefix = prefix:gsub("%s+", "")
    prefix = prefix:gsub("[^%w_]", "")
    if prefix == "" then
        prefix = "Town"
    end
    return prefix .. "_" .. tostring(100000 + ZombRand(900000))
end

function context.normalizeTownKey(value)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

function context.ensureGeolocatorReady()
    return context.IS_SERVER_RUNTIME
        and DT_GeolocatorSystem
        and DT_GeolocatorSystem.EnsureBuildingsLoaded
        and DT_GeolocatorSystem.EnsureBuildingsLoaded(true, true)
end

function context.getConfiguredColonyWealth()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.ColonyWealth) or nil
    if configured == nil then
        return 10000
    end
    return math.max(0, math.floor(configured))
end

return context
