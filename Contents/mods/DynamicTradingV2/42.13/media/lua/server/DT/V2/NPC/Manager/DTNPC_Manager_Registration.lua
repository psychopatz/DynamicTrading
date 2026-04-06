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
    if npcData.status == "Dead" then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    
    -- Get or create UUID
    local uuid = npcData.uuid
    if not uuid then
        -- Check if this zombie already has a UUID in modData
        local modData = zombie:getModData()
        uuid = modData.DTNPC_UUID
        
        if not uuid then
            -- Brand new NPC, generate UUID
            uuid = DTNPCManager.GenerateSoulID(npcData.name)
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Generated new Soul ID for NPC: " .. (npcData.name or "Unknown") .. " - " .. uuid)
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
    DTNPCManager.BodyInstanceIDToUUID[bodyInstanceID] = uuid
    
    DTNPCManager.PendingRegistrations[uuid] = true
    
    -- Update npcData data
    npcData.currentBodyInstanceID = bodyInstanceID
    npcData.startupBodyInstanceHint = nil
    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = zombie:getHealth()
    npcData.registeredTime = os.time()
    
    -- Store in database by UUID
    DTNPCManager.Data[uuid] = npcData
    DTNPCManager.Save()

    if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
        DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
    end
    
    DTNPCManager.PendingRegistrations[uuid] = nil
    
    DynamicTrading.Log("DTV2", "NPC", "Register", "Registered NPC: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ", BodyInstanceID: " .. bodyInstanceID .. ") at " .. npcData.lastX .. "," .. npcData.lastY .. "," .. npcData.lastZ)
end

function DTNPCManager.ReclaimZombie(zombie, npcData, reason)
    if not zombie or not npcData then return nil end
    if zombie:isDead() then return nil end
    if npcData.status == "Dead" then return nil end

    local modData = zombie:getModData()
    local uuid = npcData.uuid or modData.DTNPC_UUID
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
    end
    zombie:DoZombieStats()
    if DTNPCHealth and DTNPCHealth.InitializeForSpawn then
        DTNPCHealth.InitializeForSpawn(zombie, npcData, { resetCurrent = false })
    else
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
                " bodyInstanceID=" .. tostring(zombie:getPersistentOutfitID()) ..
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
        local currentBodyInstanceID = npcData.currentBodyInstanceID
        if currentBodyInstanceID then
            DTNPCManager.BodyInstanceIDToUUID[currentBodyInstanceID] = nil
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
        if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
            DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
        end
        DTNPCManager.Save()
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Removed NPC data from world tracker: " .. (npcData.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCServerCore and DTNPCServerCore.NotifyRemoval then
            DTNPCServerCore.NotifyRemoval(uuid, currentBodyInstanceID, npcData.name, status, removalContext)
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

local function saveSoulIfAvailable(uuid, npcData)
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and uuid and npcData then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
end

local function preserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData)
    if not zombie or not uuid or not npcData or npcData.incapState ~= "Active" then
        return false
    end

    local combatHealth = npcData.combatHealth
    local spawnedAt = tonumber(combatHealth and combatHealth.spawnInitializedAt) or 0
    local guardWindow = DTNPCHealth and tonumber(DTNPCHealth.SPAWN_FALLBACK_GUARD_MS) or 12000
    local now = getTimeInMillis and getTimeInMillis() or 0
    local ageMs = spawnedAt > 0 and (now - spawnedAt) or math.huge
    local attacker = zombie:getAttackedBy()

    if attacker or ageMs < 0 or ageMs > guardWindow then
        return false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Preserving suspicious incapacitated death for "
            .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " spawnAgeMs=" .. tostring(ageMs)
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(combatHealth and combatHealth.current or nil)
    )

    saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(uuid, "Incapacitated", nil, nil, nil)

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Recovered suspicious incapacitated death by respawning body: " .. tostring(npcData.name or uuid)
        )
        return true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Error",
        "Failed to recover suspicious incapacitated death, falling back to permanent death: " .. tostring(uuid)
    )
    return false
end

function DTNPCManager.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData then return false end

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = 2
    npcData.state = "Incapacitated"
    npcData.incapState = "Active"
    npcData.preIncapStatus = npcData.status or "Resting"
    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = nil
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil

    saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(uuid, "Incapacitated", nil, nil, removalContext)

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DynamicTrading.Log("DTV2", "NPC", "Death", "NPC incapacitated instead of dying: " .. (npcData.name or uuid))
        return true
    end

    DynamicTrading.Log("DTV2", "NPC", "Error", "Failed to respawn incapacitated NPC, falling back to death: " .. tostring(uuid))
    if DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Dead", nil, nil)
    end
    return false
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
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Unregister triggered for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " engineHealth=" .. tostring(zombie and zombie:getHealth() or nil)
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " incapState=" .. tostring(npcData.incapState)
                .. " state=" .. tostring(npcData.state)
                .. " status=" .. tostring(npcData.status)
        )
        if npcData.incapState == "Active" and preserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData) then
            return
        end

        if not removalContext and npcData.lastPlayerAttackerUsername then
            local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
            if not elapsed or elapsed <= 15000 then
                removalContext = {
                    killerUsername = npcData.lastPlayerAttackerUsername,
                    killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                }
            end
        end
        if npcData.incapState == "Active" then
            DynamicTrading.Log("DTV2", "NPC", "Death", "Incapacitated NPC killed for good: " .. (npcData.name or uuid))
            DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
            return
        end

        if DTNPCManager.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext) then
            return
        end

        DynamicTrading.Log("DTV2", "NPC", "Death", "NPC Died: " .. (npcData.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unregister ignored zombie with no authoritative UUID; refusing outfit-ID fallback.")
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)
