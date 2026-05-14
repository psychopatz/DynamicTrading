-- ==============================================================================
-- DTNPC_LootSearchShared_Colony.lua
-- Dynamic Colonies integration helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Colony then
    return
end

DTNPCLootSearch.Modules.Colony = true

local Internal = DTNPCLootSearch.Internal

function Internal.getColonyApis()
    local colony = DC_Colony or nil
    return {
        registry = colony and colony.Registry or nil,
        network = colony and colony.Network or nil,
    }
end

function Internal.getLinkedWorker(npcData)
    local apis = Internal.getColonyApis()
    local registry = apis.registry
    if not registry or not registry.GetWorker or not npcData or not npcData.linkedWorkerID then
        return nil, apis
    end

    return registry.GetWorker(npcData.linkedWorkerID), apis
end

function Internal.getWorkerCarryState(worker, apis)
    local registry = apis and apis.registry or nil
    local state = registry and registry.GetInventoryWeightState and registry.GetInventoryWeightState(worker) or nil
    if not state then
        return nil
    end

    return {
        usedWeight = math.max(0, tonumber(state.usedWeight) or 0),
        maxWeight = math.max(0, tonumber(state.maxWeight) or 0),
        remainingWeight = math.max(0, tonumber(state.remainingWeight) or 0),
    }
end

function Internal.findOnlinePlayer(username)
    local resolved = tostring(username or "")
    if resolved == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and player:getUsername() == resolved then
                return player
            end
        end
    end

    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer and localPlayer.getUsername and localPlayer:getUsername() == resolved then
        return localPlayer
    end

    return nil
end

function Internal.getCommanderUsername(npcData, worker)
    if npcData and tostring(npcData.dcCommanderUsername or "") ~= "" then
        return tostring(npcData.dcCommanderUsername)
    end
    if npcData and tostring(npcData.master or "") ~= "" then
        return tostring(npcData.master)
    end
    if worker and tostring(worker.ownerUsername or "") ~= "" then
        return tostring(worker.ownerUsername)
    end
    return nil
end

function Internal.normalizeConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    return {
        radius = Internal.clamp(npcData and npcData.dcLootRadius or config.radius or 8, 2, 25),
        includeLooseWorldItems = config.includeLooseWorldItems ~= false,
        includeGroundContainers = config.includeGroundContainers ~= false,
        includeFurnitureContainers = config.includeFurnitureContainers ~= false,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
    }
end

function DTNPCLootSearch.ResolveWorker(npcData)
    return Internal.getLinkedWorker(npcData)
end

function DTNPCLootSearch.GetWorkerCarryState(npcData)
    local worker, apis = Internal.getLinkedWorker(npcData)
    return Internal.getWorkerCarryState(worker, apis)
end
