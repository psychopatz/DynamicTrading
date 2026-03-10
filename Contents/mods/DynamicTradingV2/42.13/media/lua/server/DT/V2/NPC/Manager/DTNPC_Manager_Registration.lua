-- ==============================================================================
-- DTNPC_Manager_Registration.lua
-- NPC Registration, Removal, Status, and Unregister (death) logic.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.Register(zombie, npcData)
    if not zombie or not npcData then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    
    -- Get or create UUID
    local uuid = npcData.uuid
    if not uuid then
        -- Check if this zombie already has a UUID in modData
        local modData = zombie:getModData()
        uuid = modData.DTNPC_UUID
        
        if not uuid then
            -- Check outfit ID mapping (in case of respawn)
            uuid = DTNPCManager.GetUUIDFromOutfitID(outfitID)
            
            if not uuid then
                -- Brand new NPC, generate UUID
                uuid = DTNPCManager.GenerateUUID()
                print("[DTNPC] Generated new UUID for NPC: " .. (npcData.name or "Unknown") .. " - " .. uuid)
            else
                print("[DTNPC] Found existing UUID from outfit mapping: " .. uuid)
            end
        else
            print("[DTNPC] Found UUID in zombie modData: " .. uuid)
        end
        
        npcData.uuid = uuid
    end
    
    -- Store UUID in zombie modData for future lookups
    local modData = zombie:getModData()
    modData.DTNPC_UUID = uuid
    
    -- Check for duplicate registration
    if DTNPCManager.PendingRegistrations[uuid] then
        print("[DTNPC] WARNING: Registration for UUID " .. uuid .. " already in progress. Skipping duplicate.")
        return
    end
    
    -- Update outfit ID mapping
    DTNPCManager.OutfitIDToUUID[outfitID] = uuid
    
    DTNPCManager.PendingRegistrations[uuid] = true
    
    -- Update npcData data
    npcData.currentOutfitID = outfitID
    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = zombie:getHealth()
    npcData.registeredTime = os.time()
    
    -- Store in database by UUID
    DTNPCManager.Data[uuid] = npcData
    DTNPCManager.Save()
    
    DTNPCManager.PendingRegistrations[uuid] = nil
    
    print("[DTNPC] Registered NPC: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ", OutfitID: " .. outfitID .. ") at " .. npcData.lastX .. "," .. npcData.lastY .. "," .. npcData.lastZ)
end

function DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
    if DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        
        -- Remove from outfit mapping
        if npcData.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[npcData.currentOutfitID] = nil
        end
        
        -- Remove from spatial hash
        if DTNPC_SpatialHash and DTNPC_SpatialHash.RemoveNPC then
            DTNPC_SpatialHash.RemoveNPC(uuid)
        end
        
        -- Remove from distance frequency tracker
        if DTNPC_DistanceFrequency and DTNPC_DistanceFrequency.RemoveNPC then
            DTNPC_DistanceFrequency.RemoveNPC(uuid)
        end
        
        -- Update persistent status in Roster
        if DynamicTrading_Roster and status then
            DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
        end

        -- Remove from database
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        DTNPCManager.Save()
        
        print("[DTNPC] Removed NPC data from world tracker: " .. (npcData.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCServerCore and DTNPCServerCore.NotifyRemoval then
            DTNPCServerCore.NotifyRemoval(uuid, npcData.currentOutfitID, npcData.name)
        end
    end
end

function DTNPCManager.SetNPCStatus(uuid, status, returnTime, returnStatus)
    -- 1. Always update the persistent Roster (Bridge)
    if DynamicTrading_Roster then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end

    -- 2. If the status implies they are "Away" or "Dead", clean up physical presence
    if status == "Away" or status == "Dead" then
        if DTNPCManager.Data[uuid] then
            print("[DTNPC] Status change to " .. status .. " requires world removal.")
            DTNPCManager.RemoveData(uuid) -- No arguments to avoid recursion loop
        end
        
        -- Clean up physical zombie if it exists
        if DTNPCServerCore and DTNPCServerCore.FindZombieByUUID then
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                print("[DTNPC] Forcefully removed physical zombie for Away/Dead state: " .. uuid)
            end
        end
    end
end

function DTNPCManager.Unregister(zombie)
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    
    if uuid and DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        print("[DTNPC] NPC Died: " .. (npcData.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead")
    else
        -- Fallback: try outfit ID
        local outfitID = zombie:getPersistentOutfitID()
        local fallbackUUID = DTNPCManager.GetUUIDFromOutfitID(outfitID)
        if fallbackUUID and DTNPCManager.Data[fallbackUUID] then
            local npcData = DTNPCManager.Data[fallbackUUID]
            print("[DTNPC] NPC Died (fallback lookup): " .. (npcData.name or fallbackUUID))
            DTNPCManager.RemoveData(fallbackUUID, "Dead")
        end
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)
