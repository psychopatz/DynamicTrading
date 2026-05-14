-- ==============================================================================
-- DTNPC_LootSearch_Server.lua
-- Server handlers for loot search UI commands.
-- ==============================================================================

DTNPCLootSearchServer = DTNPCLootSearchServer or {}

if DTNPCLootSearchServer.Loaded then
    return
end

DTNPCLootSearchServer.Loaded = true

require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared"

local function copyTable(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, entry in pairs(value) do
        result[key] = copyTable(entry)
    end
    return result
end

function DTNPCLootSearchServer.Open(player, args)
    local uuid = args and args.uuid or nil
    if not uuid or not DTNPCServerCore or not DTNPCServerCore.GetNPCDataByUUID then
        return false
    end

    local _, npcData = DTNPCServerCore.GetNPCDataByUUID(uuid)
    if not npcData then
        return false
    end

    local worker = DTNPCLootSearch.ResolveWorker(npcData)
    local payload = DTNPCLootSearch.BuildSyncPayload(npcData, nil, true, player)
    if DTNPCServerCore and DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DTNPC", "LootSearchSync", payload)
    DTNPCLootSearch.SendSyncToCommander(npcData, worker, nil, true)
    return true
end

function DTNPCLootSearchServer.Collect(player, args)
    local uuid = args and args.uuid or nil
    local sourceKey = args and args.sourceKey or nil
    local itemKeys = type(args and args.itemKeys) == "table" and args.itemKeys or nil
    if not uuid or not sourceKey or not itemKeys or #itemKeys <= 0 or not DTNPCServerCore or not DTNPCServerCore.GetNPCDataByUUID then
        return false
    end

    local _, npcData = DTNPCServerCore.GetNPCDataByUUID(uuid)
    if not npcData then
        return false
    end

    local changed, collectedCount = DTNPCLootSearch.CollectItemsImmediately(
        player,
        nil,
        npcData,
        sourceKey,
        itemKeys,
        player and player.getUsername and player:getUsername() or nil
    )
    if not changed then
        return false
    end

    if DTNPCServerCore.UpdateNPCByUUID then
        DTNPCServerCore.UpdateNPCByUUID(uuid, {
            dcLootSearch = copyTable(npcData.dcLootSearch),
            dcLootStatus = npcData.dcLootStatus or (collectedCount > 0 and "looting" or "collecting"),
            state = "LootNearby",
        }, true)
    end

    local payload = DTNPCLootSearch.BuildSyncPayload(npcData, sourceKey, true, player)
    if DTNPCServerCore and DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DTNPC", "LootSearchSync", payload)
    return true
end
