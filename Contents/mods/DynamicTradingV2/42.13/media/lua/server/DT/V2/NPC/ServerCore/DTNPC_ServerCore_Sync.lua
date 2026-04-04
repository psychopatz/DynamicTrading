-- ==============================================================================
-- DTNPC_ServerCore_Sync.lua
-- Multiplayer synchronization functions for NPCs.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

DTNPCServerCore.BROADCAST_RANGES = DTNPCServerCore.BROADCAST_RANGES or {
    CLOSE = 200,
    MEDIUM = 350,
    FAR = 500,
}

local function getActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end

    local players = {}
    local online = getOnlinePlayers()
    if online then
        for i = 0, online:size() - 1 do
            local p = online:get(i)
            if p then table.insert(players, p) end
        end
    end
    return players
end

local function sendToNearbyPlayers(command, data, x, y, z, range)
    local players = getActivePlayers()
    local sent = 0

    for _, player in ipairs(players) do
        local dx = player:getX() - x
        local dy = player:getY() - y
        local dz = player:getZ() - z
        local dist = math.sqrt(dx * dx + dy * dy)

        -- Strict visibility: only nearby players get world-sync data.
        if math.abs(dz) <= 1 and dist <= range then
            sendServerCommand(player, "DTNPC", command, data)
            sent = sent + 1
        end
    end

    return sent, #players
end

-- ==============================================================================
-- MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

function DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if not zombie or not npcData then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() then
        local sent, total = sendToNearbyPlayers(
            "SyncNPC",
            syncData,
            syncData.x,
            syncData.y,
            syncData.z,
            DTNPCServerCore.BROADCAST_RANGES.MEDIUM
        )
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y .. " [" .. sent .. "/" .. total .. " players]")
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
    end
end

function DTNPCServerCore.SyncToPlayer(player, zombie, npcData)
    if not player or not zombie or not npcData then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() or isClient() then
        sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC to player: " .. (npcData.name or uuid))
end

function DTNPCServerCore.BroadcastPosition(zombie, npcData, forceUpdate)
    if not zombie or not npcData then return end
    
    local uuid = npcData.uuid
    local tier = nil
    if forceUpdate ~= true then
        local shouldUpdate
        shouldUpdate, tier = DTNPC_DistanceFrequency.ShouldUpdateNPC(uuid)
        if not shouldUpdate then
            return
        end
    else
        tier = "forced"
    end

    local posData = {
        uuid = uuid,
        bodyInstanceID = zombie:getPersistentOutfitID(),
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        combatHealthCurrent = npcData.combatHealth and npcData.combatHealth.current or nil,
        combatHealthMax = npcData.combatHealth and npcData.combatHealth.max or nil,
        combatHealthEnabled = npcData.combatHealth and npcData.combatHealth.enabled or nil,
        state = npcData.state,
        status = npcData.status,
        combatOrder = npcData.combatOrder,
        protectNoticeSerial = npcData.protectNoticeSerial,
        protectNoticeText = npcData.protectNoticeText,
        protectNoticeSentiment = npcData.protectNoticeSentiment,
        protectNoticeDialogueStatus = npcData.protectNoticeDialogueStatus,
        protectNoticeDialogueState = npcData.protectNoticeDialogueState,
        tier = tier
    }
    
    if isServer() then
        sendToNearbyPlayers(
            "UpdatePosition",
            posData,
            posData.x,
            posData.y,
            posData.z,
            DTNPCServerCore.BROADCAST_RANGES.CLOSE
        )
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "UpdatePosition", posData)
    end
end

function DTNPCServerCore.NotifyRemoval(uuid, bodyInstanceID, name, removalReason, removalContext)
    if not uuid then return end
    
    local data = { uuid = uuid, bodyInstanceID = bodyInstanceID, name = name, removalReason = removalReason }
    if removalContext then
        data.killerUsername = removalContext.killerUsername
        data.killerOnlineID = removalContext.killerOnlineID
    end
    
    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPC", data)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPC", data)
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Remove", "Notified removal: " .. (name or uuid))
end

function DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID)
    if not bodyInstanceID then return end

    local data = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
    }

    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPCInstance", data)
    else
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPCInstance", data)
    end
end
