-- ==============================================================================
-- DTNPC_ServerCoreArrival_Materialize.lua
-- World-body materialization helpers for DTNPC server arrival modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreArrival.Internal

function Internal.FinalizeWorldIndex(uuid, zombie, npcData, reusedLiveBody)
    if not uuid or not zombie or not npcData then
        return
    end

    if reusedLiveBody == true then
        if DTNPC and DTNPC.AttachData then
            DTNPC.AttachData(zombie, npcData)
        end
        if DTNPC and DTNPC.ApplyVisuals then
            DTNPC.ApplyVisuals(zombie, npcData)
        end
        if DTNPCManager and DTNPCManager.Register then
            DTNPCManager.Register(zombie, npcData)
        end
        if DTNPCServerCore.SyncToAllClients then
            DTNPCServerCore.SyncToAllClients(zombie, npcData)
        end
    end

    if DTNPC_SpatialHash and DTNPC_SpatialHash.InsertNPC then
        DTNPC_SpatialHash.InsertNPC(uuid, npcData.lastX, npcData.lastY, npcData.lastZ or 0, nil)
    end
    if DTNPC_DistanceFrequency and DTNPC_DistanceFrequency.InitializeNPC then
        DTNPC_DistanceFrequency.InitializeNPC(uuid)
    end
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

function Internal.MaterializeBodyAtSquare(uuid, npcData, square, options)
    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil

    if zombie and DTNPCServerCore.PruneDuplicateZombies then
        zombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, zombie, "arrival-live")
    end

    if zombie then
        zombie:setX(square:getX())
        zombie:setY(square:getY())
        zombie:setZ(square:getZ())
        zombie:setLastX(square:getX())
        zombie:setLastY(square:getY())
        if DTNPC and DTNPC.AttachData then
            DTNPC.AttachData(zombie, npcData)
        end
        if DTNPC and DTNPC.ApplyVisuals then
            DTNPC.ApplyVisuals(zombie, npcData)
        end
        if not zombie:isUseless() then
            zombie:setUseless(true)
        end
        return zombie, npcData, true
    end

    if DTNPCServerCore.RespawnNPC then
        local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, uuid)
        return spawnedZombie, spawnedData, false
    end

    return nil, npcData, false
end
