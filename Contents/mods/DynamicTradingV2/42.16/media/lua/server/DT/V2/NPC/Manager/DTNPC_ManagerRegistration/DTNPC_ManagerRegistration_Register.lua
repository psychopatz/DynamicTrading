-- ==============================================================================
-- DTNPC_ManagerRegistration_Register.lua
-- NPC registration flow.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

function DTNPCManager.Register(zombie, npcData)
    if not zombie or not npcData then return end
    if npcData.status == "Dead" then return end

    local bodyInstanceID = zombie:getPersistentOutfitID()

    local uuid = npcData.uuid
    if not uuid then
        local modData = zombie:getModData()
        uuid = modData.DTNPC_UUID

        if not uuid then
            uuid = DTNPCManager.GenerateSoulID(npcData.name)
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Generated new Soul ID for NPC: " .. (npcData.name or "Unknown") .. " - " .. uuid)
        else
            DynamicTrading.Log("DTV2", "NPC", "Soul", "Found UUID in zombie modData: " .. uuid)
        end

        npcData.uuid = uuid
    end

    local modData = zombie:getModData()
    modData.DTNPC_UUID = uuid
    modData.DTNPC_Data = npcData
    modData.IsDTNPC = true
    if npcData.visualID then
        modData.DTNPCVisualID = npcData.visualID
    end
    modData.DTNPCPresenceRevision = DTNPCManager.GetPresenceRevision(npcData)

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end

    if DTNPCManager.PendingRegistrations[uuid] then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Registration for UUID " .. uuid .. " already in progress. Skipping duplicate.")
        return
    end

    DTNPCManager.BodyInstanceIDToUUID[bodyInstanceID] = uuid
    DTNPCManager.PendingRegistrations[uuid] = true

    DTNPCManager.EnsurePresenceRevision(npcData)
    npcData.currentBodyInstanceID = bodyInstanceID
    npcData.startupBodyInstanceHint = nil
    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.health = zombie:getHealth()
    npcData.registeredTime = os.time()

    DTNPCManager.Data[uuid] = npcData
    DTNPCManager.Save()

    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.ClearThreat then
        DTNPC_ZombieAggro.ClearThreat(uuid)
    end

    if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
        DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
    end

    DTNPCManager.PendingRegistrations[uuid] = nil

    DynamicTrading.Log("DTV2", "NPC", "Register", "Registered NPC: " .. (npcData.name or "Unknown") .. " (UUID: " .. uuid .. ", BodyInstanceID: " .. bodyInstanceID .. ") at " .. npcData.lastX .. "," .. npcData.lastY .. "," .. npcData.lastZ)
end
