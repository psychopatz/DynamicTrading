-- ==============================================================================
-- DTNPC_ClientCache.lua
-- Management of local NPC cache and brain data.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.NPCCache = {} -- Keyed by UUID
DTNPCClient.OutfitIDToUUID = {} -- Maps outfit IDs to UUIDs
DTNPCClient.ProcessedZombies = {} -- Tracks visual application
DTNPCClient.LocalControlled = {} -- Tracks locally controlled NPCs
DTNPCClient.VISUAL_CHECK_RATE = 60 -- Ticks between visual checks

function DTNPCClient.GetBrain(zombie)
    if not zombie then return nil end
    
    local modData = zombie:getModData()
    if modData and modData.DTNPCBrain then
        return modData.DTNPCBrain
    end
    
    local uuid = modData.DTNPC_UUID
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].brain
    end
    
    local outfitID = zombie:getPersistentOutfitID()
    uuid = DTNPCClient.OutfitIDToUUID[outfitID]
    if uuid and DTNPCClient.NPCCache[uuid] then
        return DTNPCClient.NPCCache[uuid].brain
    end
    
    return nil
end

function DTNPCClient.CacheBrain(uuid, outfitID, brain)
    if not uuid or not brain then return end
    
    DTNPCClient.NPCCache[uuid] = {
        brain = brain,
        lastSync = getTimestampMs()
    }
    
    if outfitID then
        DTNPCClient.OutfitIDToUUID[outfitID] = uuid
    end
    
    print("[DTNPC-Client] Cached brain for: " .. (brain.name or uuid) .. " (UUID: " .. uuid .. ")")
end

function DTNPCClient.RemoveFromCache(uuid, outfitID)
    if uuid then
        DTNPCClient.NPCCache[uuid] = nil
        DTNPCClient.ProcessedZombies[uuid] = nil
        DTNPCClient.LocalControlled[uuid] = nil
        print("[DTNPC-Client] Removed from cache: " .. uuid)
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
