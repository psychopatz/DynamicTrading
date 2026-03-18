-- ==============================================================================
-- DTNPC_ClientCache.lua
-- Management of local NPC cache and npcData data.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {} -- Keyed by UUID
DTNPCClient.OutfitIDToUUID = {} -- Maps outfit IDs to UUIDs
DTNPCClient.ProcessedZombies = {} -- Tracks visual application
DTNPCClient.LocalControlled = {} -- Tracks locally controlled NPCs
DTNPCClient.MetadataCache = {} -- Far NPC metadata for radar/faction intel
DTNPCClient.VISUAL_CHECK_RATE = 60 -- Ticks between visual checks

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
    
    local outfitID = zombie:getPersistentOutfitID()
    uuid = DTNPCClient.OutfitIDToUUID[outfitID]
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

function DTNPCClient.CacheData(uuid, outfitID, npcData)
    if not uuid or not npcData then return end
    
    DTNPCClient.NPCCache[uuid] = {
        npcData = npcData,
        lastSync = DTNPCClient.GetTimestamp()
    }
    
    if outfitID then
        DTNPCClient.OutfitIDToUUID[outfitID] = uuid
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Cache", "Cached NPC data for: " .. (npcData.name or uuid) .. " (UUID: " .. uuid .. ")")
end

-- Deprecated: Use DTNPCClient.CacheData
function DTNPCClient.CacheBrain(uuid, outfitID, npcData)
    DTNPCClient.CacheData(uuid, outfitID, npcData)
end

function DTNPCClient.RemoveFromCache(uuid, outfitID)
    if uuid then
        DTNPCClient.NPCCache[uuid] = nil
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
        DTNPCClient.MetadataCache[uuid] = nil
        if DTNPCClient.UntrackNPCForHealthBars then
            DTNPCClient.UntrackNPCForHealthBars(uuid, outfitID)
        end
        if DTNPCClient.UntrackNPCAmbientDialogue then
            DTNPCClient.UntrackNPCAmbientDialogue(uuid, outfitID)
        end
        DynamicTrading.Log("DTV2", "NPC", "Cache", "Removed from cache: " .. uuid)
    end
    
    if outfitID then
        DTNPCClient.OutfitIDToUUID[outfitID] = nil
    end
end

function DTNPCClient.GetTableSize(t)
    if not t then return 0 end
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
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
