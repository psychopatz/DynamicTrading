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
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)
    local shouldAccept, presenceRevision = Helpers.ShouldAcceptPresence(uuid, args)
    if not shouldAccept then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Sync",
            "Ignored stale SyncNPC uuid=" .. tostring(uuid)
                .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                .. " presenceRevision=" .. tostring(presenceRevision)
                .. " cachedRevision=" .. tostring(DTNPCClient.GetPresenceRevision and DTNPCClient.GetPresenceRevision(uuid) or 0)
        )
        return
    end
    args.npcData.presenceRevision = presenceRevision

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Sync",
        "Received SyncNPC name=" .. tostring(args.npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
            .. " presenceRevision=" .. tostring(presenceRevision)
            .. " pos=" .. tostring(args.x) .. "," .. tostring(args.y) .. "," .. tostring(args.z)
            .. " customCurrent=" .. tostring(args.npcData.combatHealth and args.npcData.combatHealth.current or nil)
            .. " customMax=" .. tostring(args.npcData.combatHealth and args.npcData.combatHealth.max or nil)
    )

    DTNPCClient.CacheData(uuid, bodyInstanceID, args.npcData)
    if DTNPCClient.RemoveDuplicateLocalZombies and bodyInstanceID then
        DTNPCClient.RemoveDuplicateLocalZombies(uuid, bodyInstanceID)
    end
    Helpers.TrackNPCSystems(nil, args.npcData, uuid, bodyInstanceID)
    Helpers.RecordInterpolation(uuid, args.x, args.y, args.z, nil, args.motionHint)

    local zombie = Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
    local cached = DTNPCClient.NPCCache[uuid]
    if zombie then
        if DTNPCClient.CacheLiveZombie then
            DTNPCClient.CacheLiveZombie(uuid, zombie)
        end
        DTNPCClient.ApplyVisualsToNPC(zombie, args.npcData)
        DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        DTNPCClient.ProcessedZombies[uuid] = true

        if cached then
            cached.awaitingWorldZombieSince = nil
            cached.awaitingWorldZombieLoggedAt = nil
        end
        Helpers.SetReportedState(cached, args.npcData)

        DynamicTrading.Log("DTV2", "NPC", "Sync", "Applied visuals to zombie: " .. uuid)
    else
        if cached then
            cached.awaitingWorldZombieSince = cached.awaitingWorldZombieSince or getTimeInMillis()
            cached.awaitingWorldZombieLoggedAt = nil
        end
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "SyncNPC cached without live zombie uuid=" .. tostring(uuid)
                .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                .. " pos=" .. tostring(args.x) .. "," .. tostring(args.y) .. "," .. tostring(args.z)
        )
    end
end

function Handlers.HandleSyncAllNPCs(args)
    if not args or not args.npcs then
        return
    end

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncAllNPCs. Count: " .. DTNPCClient.GetTableSize(args.npcs))

    for uuid, npcData in pairs(args.npcs) do
        local bodyInstanceID = npcData.currentBodyInstanceID
        local shouldAccept, presenceRevision = Helpers.ShouldAcceptPresence(uuid, npcData)
        if shouldAccept then
            npcData.presenceRevision = presenceRevision

            DTNPCClient.CacheData(uuid, bodyInstanceID, npcData)
            if DTNPCClient.RemoveDuplicateLocalZombies and bodyInstanceID then
                DTNPCClient.RemoveDuplicateLocalZombies(uuid, bodyInstanceID)
            end
            Helpers.TrackNPCSystems(nil, npcData, uuid, bodyInstanceID)

            local zombie = Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
            if zombie then
                if DTNPCClient.CacheLiveZombie then
                    DTNPCClient.CacheLiveZombie(uuid, zombie)
                end
                DTNPCClient.ApplyVisualsToNPC(zombie, npcData)
                DTNPCClient.ProcessedZombies[uuid] = true

                local cached = DTNPCClient.NPCCache[uuid]
                Helpers.SetReportedState(cached, npcData)
            end
        end
    end
end

function Handlers.HandleSyncNearbyNPCs(args)
    if not args then
        return
    end

    local nearbyCount = 0
    local metadataCount = 0
    local missingLiveZombie = false

    for uuid, npcData in pairs(args.nearby or {}) do
        if npcData and npcData.npcData then
            local bodyInstanceID = Helpers.ResolveBodyInstanceID(npcData)
            local shouldAccept, presenceRevision = Helpers.ShouldAcceptPresence(uuid, npcData)
            if shouldAccept then
                npcData.npcData.presenceRevision = presenceRevision

                DTNPCClient.CacheData(uuid, bodyInstanceID, npcData.npcData)
                if DTNPCClient.RemoveDuplicateLocalZombies and bodyInstanceID then
                    DTNPCClient.RemoveDuplicateLocalZombies(uuid, bodyInstanceID)
                end
                Helpers.TrackNPCSystems(nil, npcData.npcData, uuid, bodyInstanceID)

                local x = npcData.x or npcData.npcData.lastX
                local y = npcData.y or npcData.npcData.lastY
                local z = npcData.z or npcData.npcData.lastZ or 0
                Helpers.RecordInterpolation(uuid, x, y, z, nil, npcData.motionHint)

                local zombie = Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
                local cached = DTNPCClient.NPCCache[uuid]
                if zombie then
                    if DTNPCClient.CacheLiveZombie then
                        DTNPCClient.CacheLiveZombie(uuid, zombie)
                    end
                    DTNPCClient.ApplyVisualsToNPC(zombie, npcData.npcData)
                    DTNPCClient.ReconcilePosition(zombie, x, y, z)
                    DTNPCClient.ProcessedZombies[uuid] = true

                    if cached then
                        cached.awaitingWorldZombieSince = nil
                        cached.awaitingWorldZombieLoggedAt = nil
                    end
                    Helpers.SetReportedState(cached, npcData.npcData)
                elseif cached then
                    cached.awaitingWorldZombieSince = cached.awaitingWorldZombieSince or getTimeInMillis()
                    cached.awaitingWorldZombieLoggedAt = nil
                    missingLiveZombie = true
                end

                nearbyCount = nearbyCount + 1
            end
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

    if missingLiveZombie and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("nearby-missing-world-zombie")
    end

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Received SyncNearbyNPCs: nearby=" .. nearbyCount .. ", metadata=" .. metadataCount)
end
