-- ==============================================================================
-- DTNPC_LootSearchShared_Sync.lua
-- Sync payload and commander-notification helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Sync then
    return
end

DTNPCLootSearch.Modules.Sync = true

local Internal = DTNPCLootSearch.Internal
local Constants = Internal.Constants

function Internal.buildSyncSources(anchor, npcData, state)
    local sources = {}
    if anchor then
        local scannedSources = DTNPCLootSearch.GetCachedNearbySources(anchor, npcData, false, true)
        for _, source in ipairs(scannedSources or {}) do
            sources[#sources + 1] = Internal.serializeSource(source)
        end
    else
        for _, source in pairs(state.discoveredSources or {}) do
            sources[#sources + 1] = source
        end
    end

    table.sort(sources, function(left, right)
        local leftDistance = tonumber(left and left.distance) or math.huge
        local rightDistance = tonumber(right and right.distance) or math.huge
        if math.abs(leftDistance - rightDistance) > 0.05 then
            return leftDistance < rightDistance
        end

        local leftTime = tonumber(left and left.discoveredAt) or 0
        local rightTime = tonumber(right and right.discoveredAt) or 0
        if leftTime ~= rightTime then
            return leftTime > rightTime
        end
        return tostring(left and left.key or "") < tostring(right and right.key or "")
    end)

    return sources
end

function DTNPCLootSearch.BuildSyncPayload(npcData, sourceKey, autoOpen, anchor)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return {
            uuid = npcData and npcData.uuid or nil,
            npcName = npcData and npcData.name or nil,
            state = npcData and npcData.state or nil,
            status = npcData and npcData.dcLootStatus or nil,
            currentSourceKey = nil,
            autoOpen = autoOpen == true,
            sources = {},
            collectEvent = nil,
            dynamicColoniesExclusive = true,
        }
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local worker, apis = Internal.getLinkedWorker(npcData)
    local resolvedAnchor = anchor or Internal.findOnlinePlayer(Internal.getCommanderUsername(npcData, worker))
    local sources = Internal.buildSyncSources(resolvedAnchor, npcData, state)

    return {
        uuid = npcData.uuid,
        npcName = npcData.name,
        state = npcData.state,
        status = npcData.dcLootStatus,
        currentSourceKey = sourceKey or state.currentSourceKey,
        autoOpen = autoOpen == true,
        sources = sources,
        workerCarry = Internal.getWorkerCarryState(worker, apis),
        collectEvent = type(state.lastCollectEvent) == "table" and Internal.copyTableShallow(state.lastCollectEvent) or nil,
        dynamicColoniesExclusive = true,
    }
end

function DTNPCLootSearch.SendSyncToCommander(npcData, worker, sourceKey, autoOpen)
    if isClient() and not isServer() then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local currentTime = Internal.nowMillis()
    if autoOpen ~= true and currentTime > 0 and (currentTime - (state.lastSyncAt or 0)) < Constants.SEARCH_SYNC_COOLDOWN_MS then
        return false
    end

    local player = Internal.findOnlinePlayer(Internal.getCommanderUsername(npcData, worker))
    if not player then
        return false
    end

    state.lastSyncAt = currentTime
    local payload = DTNPCLootSearch.BuildSyncPayload(npcData, sourceKey, autoOpen, player)
    if DTNPCServerCore and DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DTNPC", "LootSearchSync", payload)
    return true
end
