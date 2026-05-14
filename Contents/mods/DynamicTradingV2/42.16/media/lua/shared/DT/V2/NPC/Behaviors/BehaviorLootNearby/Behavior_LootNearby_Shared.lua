-- ==============================================================================
-- Behavior_LootNearby_Shared.lua
-- Shared constants and utility helpers for loot search behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}

local LootNearby = DTNPCLogic.Internal.LootNearby
local modules = LootNearby.Modules or {}
local Constants = LootNearby.Constants or {}

LootNearby.Modules = modules
LootNearby.Constants = Constants

if modules.Shared then
    return
end

modules.Shared = true

Constants.LOOT_THREAT_RADIUS = 10
Constants.LOOT_THREAT_LEASH_BONUS = 2
Constants.LOOT_DEBUG_ENABLED = true
Constants.LOOT_DISCOVERY_DWELL_MS = 900
Constants.LOOT_FORCE_PHASE_STALL_TICKS = 42
Constants.LOOT_FORCE_PHASE_DISTANCE = 1.15
Constants.LOOT_APPROACH_TIMEOUT_MS = 5000

function LootNearby.BuildPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

function LootNearby.GetDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

function LootNearby.NowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end
    return 0
end

function LootNearby.NormalizeLootConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    return {
        radius = math.max(2, math.min(25, math.floor(tonumber(npcData and npcData.dcLootRadius or config.radius) or 10))),
        includeLooseWorldItems = config.includeLooseWorldItems ~= false,
        includeGroundContainers = config.includeGroundContainers ~= false,
        includeFurnitureContainers = config.includeFurnitureContainers ~= false,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
    }
end

function LootNearby.FormatSourceConfigDebug(config)
    if type(config) ~= "table" then
        return "no-config"
    end

    return table.concat({
        "radius=" .. tostring(config.radius or "nil"),
        "groundItems=" .. tostring(config.includeLooseWorldItems ~= false),
        "groundBags=" .. tostring(config.includeGroundContainers ~= false),
        "furniture=" .. tostring(config.includeFurnitureContainers ~= false),
        "corpses=" .. tostring(config.includeCorpseContainers ~= false),
        "vehicles=" .. tostring(config.includeVehicleContainers ~= false),
    }, " ")
end

function LootNearby.ClearLootTarget(npcData, nextStatus)
    if not npcData then
        return
    end

    npcData.dcLootTarget = nil
    npcData.dcLootTargetKey = nil
    npcData.dcLootMoveBlockedTicks = 0
    npcData.isMovingState = false
    if nextStatus ~= nil then
        npcData.dcLootStatus = nextStatus
    end
end

function LootNearby.GetColonyApis()
    local colony = DC_Colony or nil
    return {
        registry = colony and colony.Registry or nil,
        network = colony and colony.Network or nil,
    }
end

function LootNearby.GetLinkedWorker(npcData)
    local apis = LootNearby.GetColonyApis()
    local registry = apis.registry
    if not registry or not registry.GetWorker or not npcData or not npcData.linkedWorkerID then
        return nil, apis
    end

    return registry.GetWorker(npcData.linkedWorkerID), apis
end
