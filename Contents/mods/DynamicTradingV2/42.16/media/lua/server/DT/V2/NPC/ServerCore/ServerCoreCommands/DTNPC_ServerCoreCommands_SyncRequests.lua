-- ==============================================================================
-- DTNPC_ServerCoreCommands_SyncRequests.lua
-- Sync request handlers for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreCommands.Internal
local Handlers = DTNPCServerCoreCommands.Handlers

Handlers.RequestSync = function(player)
    DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestSync from: " .. player:getUsername())
    if not DTNPCManager then
        return
    end

    local cell = getCell()
    if not cell then
        return
    end

    local zombieList = cell:getZombieList()
    if not zombieList then
        return
    end

    local syncCount = 0
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            if uuid then
                local npcData = DTNPCManager.Data[uuid]
                if npcData then
                    DTNPCServerCore.SyncToPlayer(player, zombie, npcData)
                    syncCount = syncCount + 1
                end
            end
        end
    end

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent " .. syncCount .. " nearby NPCs to: " .. player:getUsername())
end

Handlers.RequestFullSync = function(player)
    DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestFullSync from: " .. player:getUsername())
    if not DTNPCManager or not DTNPCManager.Data then
        return
    end

    local payload = { npcs = DTNPCManager.Data }
    if DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", payload)
    DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent full database (" .. DTNPCManager.GetTableSize(DTNPCManager.Data) .. " NPCs) to: " .. player:getUsername())
end

Handlers.RequestNearbySync = function(player, args)
    if not player then
        return
    end

    local px = args and args.x or player:getX()
    local py = args and args.y or player:getY()
    local pz = args and args.z or player:getZ()
    local nearRadius = args and args.nearRadius or 200
    local metadataRadius = args and args.metadataRadius or 1000

    local nearby = {}
    local metadata = {}

    local roster = ModData.get("DynamicTrading_Roster")
    local souls = roster and roster.Souls or nil

    if souls then
        for uuid, soul in pairs(souls) do
            local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
            local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
            local sz = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

            if sx and sy and math.abs((pz or 0) - sz) <= 1 then
                local dx = px - sx
                local dy = py - sy
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist <= nearRadius then
                    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
                    local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
                    if zombie and npcData and Internal.ShouldRecycleNearbyZombieForSync(zombie, uuid, npcData) then
                        zombie = Internal.RecycleNearbyZombieForSync(uuid, npcData, zombie, "nearby-sync")
                    end
                    if not zombie and npcData then
                        zombie = Internal.TryReclaimZombieFromStartupHint(uuid, npcData, soul)
                    end
                    if npcData and zombie then
                        nearby[uuid] = {
                            uuid = uuid,
                            bodyInstanceID = zombie:getPersistentOutfitID(),
                            presenceRevision = DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(npcData) or tonumber(npcData.presenceRevision) or 0,
                            x = zombie:getX(),
                            y = zombie:getY(),
                            z = zombie:getZ(),
                            npcData = npcData,
                        }
                    else
                        metadata[uuid] = Internal.BuildMetadataEntry(uuid, soul, npcData, player)
                    end
                elseif dist <= metadataRadius then
                    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
                    metadata[uuid] = Internal.BuildMetadataEntry(uuid, soul, npcData, player)
                end
            end
        end
    end

    local payload = {
        nearby = nearby,
        metadata = metadata,
        nearRadius = nearRadius,
        metadataRadius = metadataRadius,
    }
    if DTNPCServerCore.SanitizeNetworkData then
        payload = DTNPCServerCore.SanitizeNetworkData(payload)
    end
    sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", payload)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Sync",
        "Sent tiered sync to " .. player:getUsername()
            .. ": nearby=" .. Internal.CountTable(nearby)
            .. ", metadata=" .. Internal.CountTable(metadata)
    )
end
