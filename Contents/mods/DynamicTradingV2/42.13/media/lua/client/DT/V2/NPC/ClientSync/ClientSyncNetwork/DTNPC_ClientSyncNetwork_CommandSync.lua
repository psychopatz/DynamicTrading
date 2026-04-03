-- ==============================================================================
-- Sync command handlers for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Helpers = Network.Helpers or {}
local Handlers = Network.Handlers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Helpers
Network.Handlers = Handlers

if Network.Modules.CommandSync then
    return
end

Network.Modules.CommandSync = true

function Handlers.HandleSyncNPC(args)
    if not args or not args.uuid or not args.npcData then
        return
    end

    local uuid = args.uuid
    local outfitID = args.outfitID

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncNPC for: " .. (args.npcData.name or uuid))

    DTNPCClient.CacheData(uuid, outfitID, args.npcData)
    if DTNPCClient.RemoveDuplicateLocalZombies and outfitID then
        DTNPCClient.RemoveDuplicateLocalZombies(uuid, outfitID)
    end
    Helpers.TrackNPCSystems(nil, args.npcData, uuid, outfitID)
    Helpers.RecordInterpolation(uuid, args.x, args.y, args.z)

    local zombie = Helpers.FindZombieByIdentifiers(uuid, outfitID)
    if zombie then
        DTNPCClient.ApplyVisualsToNPC(zombie, args.npcData)
        DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        DTNPCClient.ProcessedZombies[uuid] = true

        local cached = DTNPCClient.NPCCache[uuid]
        Helpers.SetReportedState(cached, args.npcData)

        DynamicTrading.Log("DTV2", "NPC", "Sync", "Applied visuals to zombie: " .. uuid)
    else
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Zombie not in world yet, cached for later: " .. uuid)
    end
end

function Handlers.HandleSyncAllNPCs(args)
    if not args or not args.npcs then
        return
    end

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))

    for uuid, npcData in pairs(args.npcs) do
        local outfitID = npcData.currentOutfitID

        DTNPCClient.CacheData(uuid, outfitID, npcData)
        if DTNPCClient.RemoveDuplicateLocalZombies and outfitID then
            DTNPCClient.RemoveDuplicateLocalZombies(uuid, outfitID)
        end
        Helpers.TrackNPCSystems(nil, npcData, uuid, outfitID)

        local zombie = Helpers.FindZombieByIdentifiers(uuid, outfitID)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, npcData)
            DTNPCClient.ProcessedZombies[uuid] = true

            local cached = DTNPCClient.NPCCache[uuid]
            Helpers.SetReportedState(cached, npcData)
        end
    end
end

function Handlers.HandleSyncNearbyNPCs(args)
    if not args then
        return
    end

    local nearbyCount = 0
    local metadataCount = 0

    for uuid, npcData in pairs(args.nearby or {}) do
        if npcData and npcData.npcData then
            local outfitID = npcData.outfitID

            DTNPCClient.CacheData(uuid, outfitID, npcData.npcData)
            if DTNPCClient.RemoveDuplicateLocalZombies and outfitID then
                DTNPCClient.RemoveDuplicateLocalZombies(uuid, outfitID)
            end
            Helpers.TrackNPCSystems(nil, npcData.npcData, uuid, outfitID)

            local x = npcData.x or npcData.npcData.lastX
            local y = npcData.y or npcData.npcData.lastY
            local z = npcData.z or npcData.npcData.lastZ or 0
            Helpers.RecordInterpolation(uuid, x, y, z)

            local zombie = Helpers.FindZombieByIdentifiers(uuid, outfitID)
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, npcData.npcData)
                DTNPCClient.ReconcilePosition(zombie, x, y, z)
                DTNPCClient.ProcessedZombies[uuid] = true
            end

            nearbyCount = nearbyCount + 1
        end
    end

    for uuid, meta in pairs(args.metadata or {}) do
        if DT_V2_RadarManager and DT_V2_RadarManager.OnMetadataReceived then
            DT_V2_RadarManager.OnMetadataReceived(uuid, meta)
        else
            DTNPCClient.CacheMetadata(uuid, meta)
        end
        metadataCount = metadataCount + 1
    end

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncNearbyNPCs: nearby=" .. nearbyCount .. ", metadata=" .. metadataCount)
end
