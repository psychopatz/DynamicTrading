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
                uuid = DTNPCManager.GenerateSoulID(npcData.name)
                DynamicTrading.Log("DTV2", "NPC", "Soul", "Generated new Soul ID for NPC: " .. (npcData.name or "Unknown") .. " - " .. uuid)
            else
                DynamicTrading.Log("DTV2", "NPC", "Soul", "Found existing UUID from outfit mapping: " .. uuid)
            end
        else
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Found UUID in zombie modData: " .. uuid)
        end
        
        npcData.uuid = uuid
    end
    
    -- Store UUID in zombie modData for future lookups
    local modData = zombie:getModData()
    modData.DTNPC_UUID = uuid
    
    -- Check for duplicate registration
    if DTNPCManager.PendingRegistrations[uuid] then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Registration for UUID " .. uuid .. " already in progress. Skipping duplicate.")
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
    
    DynamicTrading.Log("DTV2", "NPC", "Register", "Registered NPC: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ", OutfitID: " .. outfitID .. ") at " .. npcData.lastX .. "," .. npcData.lastY .. "," .. npcData.lastZ)
end

function DTNPCManager.ReclaimZombie(zombie, npcData, reason)
    if not zombie or not npcData then return nil end

    local modData = zombie:getModData()
    local uuid = npcData.uuid or modData.DTNPC_UUID or DTNPCManager.GetUUIDFromOutfitID(zombie:getPersistentOutfitID())
    if not uuid then return nil end

    npcData.uuid = uuid
    if not npcData.visualID then
        npcData.visualID = ZombRand(1000000)
    end

    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)

    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    modData.DTNPCVisualID = npcData.visualID

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:DoZombieStats()
        zombie:setHealth(2)
    end

    zombie:resetModelNextFrame()

    DTNPCManager.Register(zombie, npcData)

    if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "reclaim_" .. tostring(uuid),
            "Process=reclaim_existing_zombie uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or "Unknown") ..
                " reason=" .. tostring(reason or "repair") ..
                " outfitID=" .. tostring(zombie:getPersistentOutfitID()) ..
                " visualID=" .. tostring(npcData.visualID),
            true
        )
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Adopt",
        "Reclaimed existing world zombie for " .. (npcData.name or uuid) .. " (" .. (reason or "repair") .. ")"
    )

    return zombie
end

function DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus, removalContext)
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
        if DynamicTrading_Roster and status ~= nil then
            DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
        end

        -- Remove from database
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        DTNPCManager.Save()
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Removed NPC data from world tracker: " .. (npcData.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCServerCore and DTNPCServerCore.NotifyRemoval then
            DTNPCServerCore.NotifyRemoval(uuid, npcData.currentOutfitID, npcData.name, removalContext)
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
            DynamicTrading.Log("DTV2", "NPC", "Status", "Status change to " .. status .. " requires world removal.")
            DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus) -- PASS ALL DATA
        end
        
        -- Clean up physical zombie if it exists
        if DTNPCServerCore and DTNPCServerCore.FindZombieByUUID then
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                DynamicTrading.Log("DTV2", "NPC", "Remove", "Forcefully removed physical zombie for Away/Dead state: " .. uuid)
            end
        end
    end
end

function DTNPCManager.Unregister(zombie)
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    local removalContext = nil
    local attacker = zombie and zombie:getAttackedBy() or nil
    if attacker and instanceof(attacker, "IsoPlayer") then
        removalContext = {
            killerUsername = attacker.getUsername and attacker:getUsername() or nil,
            killerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        }
    end
    
    if uuid and DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        if not removalContext and npcData.lastPlayerAttackerUsername then
            local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
            if not elapsed or elapsed <= 15000 then
                removalContext = {
                    killerUsername = npcData.lastPlayerAttackerUsername,
                    killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                }
            end
        end
        DynamicTrading.Log("DTV2", "NPC", "Death", "NPC Died: " .. (npcData.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
    else
        -- Fallback: try outfit ID
        local outfitID = zombie:getPersistentOutfitID()
        local fallbackUUID = DTNPCManager.GetUUIDFromOutfitID(outfitID)
        if fallbackUUID and DTNPCManager.Data[fallbackUUID] then
            local npcData = DTNPCManager.Data[fallbackUUID]
            if not removalContext and npcData.lastPlayerAttackerUsername then
                local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
                if not elapsed or elapsed <= 15000 then
                    removalContext = {
                        killerUsername = npcData.lastPlayerAttackerUsername,
                        killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                    }
                end
            end
            DynamicTrading.Log("DTV2", "NPC", "Death", "NPC Died (fallback lookup): " .. (npcData.name or fallbackUUID))
            DTNPCManager.RemoveData(fallbackUUID, "Dead", nil, nil, removalContext)
        end
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)
