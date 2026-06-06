-- ==============================================================================
-- DT_Dialogue_Ambient_Tracking.lua
-- Tracking, cache resolution, and lifecycle helpers for ambient dialogue.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig

function Ambient.CalculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function Ambient.GetNPCData(zombie)
    if DTNPCClient and DTNPCClient.GetNPCData then
        local npcData = DTNPCClient.GetNPCData(zombie)
        if npcData then
            return npcData
        end
    end

    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end

    return nil
end

function Ambient.GetCachedNPCData(uuid)
    local cacheEntry = DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
    return cacheEntry and cacheEntry.npcData or nil
end

function Ambient.DeriveUUID(zombie, npcData, uuid)
    if uuid then return uuid end
    if npcData and npcData.uuid then return npcData.uuid end
    if not zombie then return nil end

    local modData = zombie:getModData()
    if modData and modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end

    return tostring(zombie:getPersistentOutfitID())
end

function Ambient.CacheTextMetrics(entry, name)
    local safeName = name or "Unknown"
    if entry.name ~= safeName then
        entry.name = safeName
    end
end

function Ambient.TouchTrackedEntry(entry, zombie, npcData, bodyInstanceID, currentTime)
    if zombie then
        entry.zombie = zombie
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    end

    if bodyInstanceID then
        entry.bodyInstanceID = bodyInstanceID
    end

    if npcData then
        entry.npcData = npcData
        Ambient.CacheTextMetrics(entry, npcData.name)
    end

    entry.lastSeenAt = currentTime
end

function Ambient.GetTrackedEntry(uuid)
    local entry = DTNPCClient.DialogueAmbientTracked[uuid]
    if entry then
        return entry
    end

    entry = {
        uuid = uuid,
        name = "Unknown",
        lastSeenAt = getTimeInMillis(),
        nextResolveAt = 0,
        nextSpeakAt = nil,
        wasInRange = false,
        lastProtectNoticeSerial = -1,
    }
    DTNPCClient.DialogueAmbientTracked[uuid] = entry
    DTNPCClient.AmbientDialogueTracked = DTNPCClient.DialogueAmbientTracked
    return entry
end

function DTNPCClient.TrackNPCForAmbientDialogue(zombie, npcData, uuid, bodyInstanceID)
    local resolvedUUID = Ambient.DeriveUUID(zombie, npcData, uuid)
    if not resolvedUUID then return nil end

    local entry = Ambient.GetTrackedEntry(resolvedUUID)
    Ambient.TouchTrackedEntry(entry, zombie, npcData, bodyInstanceID, getTimeInMillis())
    return entry
end

function DTNPCClient.UntrackNPCAmbientDialogue(uuid, bodyInstanceID)
    local resolvedUUID = uuid

    if not resolvedUUID and bodyInstanceID and DTNPCClient.BodyInstanceIDToUUID then
        resolvedUUID = DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID]
    end
    if not resolvedUUID then return end

    DTNPCClient.DialogueAmbientTracked[resolvedUUID] = nil
    DTNPCClient.AmbientDialogueTracked = DTNPCClient.DialogueAmbientTracked

    for _, manager in pairs(DTNPCClient.DialogueAmbientManagers or DTNPCClient.AmbientDialogueManagers or {}) do
        if manager then
            manager.speechList[resolvedUUID] = nil
        end
    end
end

function Ambient.ResolveTrackedZombie(uuid, entry, currentTime)
    local zombie = entry.zombie

    if zombie and not zombie:isDead() then
        if DTNPCClient.DoesZombieMatchUUID and DTNPCClient.DoesZombieMatchUUID(zombie, uuid) then
            return zombie
        end
    end

    if currentTime < (entry.nextResolveAt or 0) then
        return nil
    end

    zombie = nil
    if DTNPCClient.FindZombieByUUID then
        zombie = DTNPCClient.FindZombieByUUID(uuid)
    end

    local bodyInstanceID = entry.bodyInstanceID
    if not zombie and bodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID then
        zombie = DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    entry.zombie = zombie
    if zombie then
        entry.nextResolveAt = currentTime
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    else
        entry.nextResolveAt = currentTime + Config.ResolveRetryMs
    end

    return zombie
end

function Ambient.IsTrackedEntryStale(entry, currentTime)
    local hasCache = entry.uuid and Ambient.GetCachedNPCData(entry.uuid) ~= nil
    local hasZombie = entry.zombie and not entry.zombie:isDead()
    return not hasCache and not hasZombie
        and (currentTime - (entry.lastSeenAt or 0)) > Config.StaleTrackMs
end
