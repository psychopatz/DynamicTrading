-- ==============================================================================
-- DTNPC_ClientSync_Cache.lua
-- Management of local NPC cache and npcData data.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync
local modules = ClientSync.Modules or {}

ClientSync.Modules = modules

if modules.Cache then
    return
end

modules.Cache = true

local function isLiveZombieUsable(zombie)
    return zombie ~= nil and (not zombie.isDead or not zombie:isDead())
end

DTNPCClient.NPCCache = DTNPCClient.NPCCache or {} -- Keyed by UUID
DTNPCClient.BodyInstanceIDToUUID = DTNPCClient.BodyInstanceIDToUUID or {}
DTNPCClient.ProcessedZombies = DTNPCClient.ProcessedZombies or {} -- Tracks visual application
DTNPCClient.LocalControlled = DTNPCClient.LocalControlled or {} -- Tracks locally controlled NPCs
DTNPCClient.MetadataCache = DTNPCClient.MetadataCache or {} -- Far NPC metadata for radar/faction intel
DTNPCClient.PresenceRevisions = DTNPCClient.PresenceRevisions or {} -- Highest accepted physical-instance revision per UUID
DTNPCClient.LiveZombiesByUUID = DTNPCClient.LiveZombiesByUUID or {}
DTNPCClient.LiveZombiesByBodyInstanceID = DTNPCClient.LiveZombiesByBodyInstanceID or {}
DTNPCClient.VISUAL_CHECK_RATE = 60 -- Ticks between visual checks
DTNPCClient.NEARBY_SYNC_CHECK_RATE = 15 -- Ticks between MP nearby-sync checks
DTNPCClient.NEARBY_SYNC_MIN_INTERVAL_MS = 2000
DTNPCClient.NEARBY_SYNC_RECOVERY_INTERVAL_MS = 750
DTNPCClient.NEARBY_SYNC_STALE_INTERVAL_MS = 15000
DTNPCClient.NEARBY_SYNC_MOVE_THRESHOLD = 45
DTNPCClient.NEARBY_SYNC_NEAR_RADIUS = 350
DTNPCClient.NEARBY_SYNC_METADATA_RADIUS = 1000
DTNPCClient.LastNearbySyncX = nil
DTNPCClient.LastNearbySyncY = nil
DTNPCClient.LastNearbySyncZ = nil
DTNPCClient.LastNearbySyncTime = DTNPCClient.LastNearbySyncTime or 0
DTNPCClient.PendingNearbySyncReason = nil

function DTNPCClient.GetNPCData(zombie)
    if not zombie then return nil end

    local modData = zombie:getModData()
    if modData and modData.DTNPC_Data then
        return modData.DTNPC_Data
    end

    -- Backward Compatibility: Check old Brain key
    if modData and modData.DTNPCBrain then
        return modData.DTNPCBrain
    end

    local uuid = modData.DTNPC_UUID
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].npcData
    end

    local bodyInstanceID = zombie:getPersistentOutfitID()
    uuid = DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID]
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].npcData
    end

    return nil
end

-- Deprecated: Use DTNPCClient.GetNPCData
function DTNPCClient.GetData(zombie)
    return DTNPCClient.GetNPCData(zombie)
end

function DTNPCClient.GetTimestamp()
    return os.time()
end

function DTNPCClient.GetLiveZombieByUUID(uuid)
    local zombie = uuid and DTNPCClient.LiveZombiesByUUID[uuid] or nil
    if isLiveZombieUsable(zombie) then
        return zombie
    end

    if uuid then
        DTNPCClient.LiveZombiesByUUID[uuid] = nil
    end
    return nil
end

function DTNPCClient.GetLiveZombieByBodyInstanceID(bodyInstanceID)
    local zombie = bodyInstanceID and DTNPCClient.LiveZombiesByBodyInstanceID[bodyInstanceID] or nil
    if isLiveZombieUsable(zombie) then
        return zombie
    end

    if bodyInstanceID then
        DTNPCClient.LiveZombiesByBodyInstanceID[bodyInstanceID] = nil
    end
    return nil
end

function DTNPCClient.CacheLiveZombie(uuid, zombie)
    if not uuid or not isLiveZombieUsable(zombie) then
        return nil
    end

    local bodyInstanceID = zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
    DTNPCClient.LiveZombiesByUUID[uuid] = zombie
    if bodyInstanceID then
        DTNPCClient.LiveZombiesByBodyInstanceID[bodyInstanceID] = zombie
    end
    return zombie
end

function DTNPCClient.UncacheLiveZombie(uuid, bodyInstanceID)
    if uuid then
        local trackedZombie = DTNPCClient.LiveZombiesByUUID[uuid]
        if trackedZombie and trackedZombie.getPersistentOutfitID then
            local trackedBodyInstanceID = trackedZombie:getPersistentOutfitID()
            if trackedBodyInstanceID then
                DTNPCClient.LiveZombiesByBodyInstanceID[trackedBodyInstanceID] = nil
            end
        end
        DTNPCClient.LiveZombiesByUUID[uuid] = nil
    end

    if bodyInstanceID then
        DTNPCClient.LiveZombiesByBodyInstanceID[bodyInstanceID] = nil
    end
end

function DTNPCClient.ClearBodyInstanceMappingsForUUID(uuid, keepBodyInstanceID)
    if not uuid or not DTNPCClient.BodyInstanceIDToUUID then return end

    for mappedBodyInstanceID, mappedUUID in pairs(DTNPCClient.BodyInstanceIDToUUID) do
        if mappedUUID == uuid and mappedBodyInstanceID ~= keepBodyInstanceID then
            DTNPCClient.BodyInstanceIDToUUID[mappedBodyInstanceID] = nil
            DTNPCClient.LiveZombiesByBodyInstanceID[mappedBodyInstanceID] = nil
        end
    end
end

function DTNPCClient.GetPresenceRevision(uuid)
    if not uuid then
        return 0
    end

    return math.max(0, math.floor(tonumber(DTNPCClient.PresenceRevisions[uuid]) or 0))
end

function DTNPCClient.SetPresenceRevision(uuid, revision)
    if not uuid then
        return 0
    end

    local normalized = math.max(0, math.floor(tonumber(revision) or 0))
    local current = DTNPCClient.GetPresenceRevision(uuid)
    if normalized > current then
        DTNPCClient.PresenceRevisions[uuid] = normalized
        return normalized
    end

    if DTNPCClient.PresenceRevisions[uuid] == nil then
        DTNPCClient.PresenceRevisions[uuid] = current
    end
    return current
end

function DTNPCClient.ShouldAcceptPresenceRevision(uuid, revision)
    if not uuid then
        return false
    end

    local normalized = math.max(0, math.floor(tonumber(revision) or 0))
    return normalized >= DTNPCClient.GetPresenceRevision(uuid)
end

function DTNPCClient.CacheData(uuid, bodyInstanceID, npcData)
    if not uuid or not npcData then return end

    bodyInstanceID = bodyInstanceID or npcData.currentBodyInstanceID or npcData.bodyInstanceID
    local presenceRevision = DTNPCClient.SetPresenceRevision(uuid, npcData.presenceRevision)
    npcData.presenceRevision = presenceRevision

    if bodyInstanceID then
        npcData.currentBodyInstanceID = bodyInstanceID
        if DTNPCClient.ClearBodyInstanceMappingsForUUID then
            DTNPCClient.ClearBodyInstanceMappingsForUUID(uuid, bodyInstanceID)
        end
    end

    DTNPCClient.NPCCache[uuid] = {
        npcData = npcData,
        lastSync = DTNPCClient.GetTimestamp(),
        presenceRevision = presenceRevision,
    }

    if bodyInstanceID then
        DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = uuid
    end

    DynamicTrading.Log("DTV2", "NPC", "Cache", "Cached NPC data for: " .. (npcData.name or uuid) .. " (UUID: " .. uuid .. ")")
end

-- Deprecated: Use DTNPCClient.CacheData
function DTNPCClient.CacheBrain(uuid, bodyInstanceID, npcData)
    DTNPCClient.CacheData(uuid, bodyInstanceID, npcData)
end

function DTNPCClient.RemoveFromCache(uuid, bodyInstanceID)
    if uuid then
        if DTNPCClient.ClearBodyInstanceMappingsForUUID then
            DTNPCClient.ClearBodyInstanceMappingsForUUID(uuid, nil)
        end
        DTNPCClient.UncacheLiveZombie(uuid, bodyInstanceID)
        DTNPCClient.NPCCache[uuid] = nil
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
        DTNPCClient.MetadataCache[uuid] = nil
        if DTNPCClient.UntrackNPCForHealthBars then
            DTNPCClient.UntrackNPCForHealthBars(uuid, bodyInstanceID)
        end
        if DTNPCClient.UntrackNPCAmbientDialogue then
            DTNPCClient.UntrackNPCAmbientDialogue(uuid, bodyInstanceID)
        end
        DynamicTrading.Log("DTV2", "NPC", "Cache", "Removed from cache: " .. uuid)
    elseif bodyInstanceID then
        DTNPCClient.UncacheLiveZombie(nil, bodyInstanceID)
    end

    if bodyInstanceID then
        DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = nil
    end
end

function DTNPCClient.GetTableSize(t)
    if not t then return 0 end
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end

function DTNPCClient.ResetSessionState(reason)
    DTNPCClient.NPCCache = {}
    DTNPCClient.BodyInstanceIDToUUID = {}
    DTNPCClient.ProcessedZombies = {}
    DTNPCClient.LocalControlled = {}
    DTNPCClient.MetadataCache = {}
    DTNPCClient.PresenceRevisions = {}
    DTNPCClient.LiveZombiesByUUID = {}
    DTNPCClient.LiveZombiesByBodyInstanceID = {}
    DTNPCClient.hasSyncedOnce = false
    DTNPCClient.LastNearbySyncX = nil
    DTNPCClient.LastNearbySyncY = nil
    DTNPCClient.LastNearbySyncZ = nil
    DTNPCClient.LastNearbySyncTime = 0
    DTNPCClient.PendingNearbySyncReason = tostring(reason or "unknown")
    DTNPCClient.nearbySyncCheckCounter = 0

    if DTNPC_ClientInterpolation and DTNPC_ClientInterpolation.ClearAll then
        DTNPC_ClientInterpolation.ClearAll()
    end

    DynamicTrading.Log("DTV2", "NPC", "Cache", "Reset client NPC session state (" .. tostring(reason or "unknown") .. ")")
end

function DTNPCClient.CacheMetadata(uuid, metadata)
    if not uuid or not metadata then return end
    DTNPCClient.MetadataCache[uuid] = metadata
end

function DTNPCClient.GetMetadata(uuid)
    return DTNPCClient.MetadataCache[uuid]
end

function DTNPCClient.GetAllMetadata()
    return DTNPCClient.MetadataCache
end
