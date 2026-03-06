-- ==============================================================================
-- DTNPC_ServerCore_Sync.lua
-- Multiplayer synchronization functions for NPCs.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

function DTNPCServerCore.SyncToAllClients(zombie, brain)
    if not zombie or not brain then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = brain.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    if isServer() then
        sendServerCommand("DTNPC", "SyncNPC", syncData)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
    
    print("[DTNPC] Synced NPC: " .. (brain.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
end

function DTNPCServerCore.SyncToPlayer(player, zombie, brain)
    if not player or not zombie or not brain then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    local uuid = brain.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = brain.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        outfitID = outfitID,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    if isServer() or isClient() then
        sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
    
    print("[DTNPC] Synced NPC to player: " .. (brain.name or uuid))
end

function DTNPCServerCore.BroadcastPosition(zombie, brain)
    if not zombie or not brain then return end
    
    local uuid = brain.uuid
    local posData = {
        uuid = uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        state = brain.state
    }
    
    if isServer() then
        sendServerCommand("DTNPC", "UpdatePosition", posData)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "UpdatePosition", posData)
    end
end

function DTNPCServerCore.NotifyRemoval(uuid, outfitID, name)
    if not uuid then return end
    
    local data = { uuid = uuid, outfitID = outfitID, name = name }
    
    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPC", data)
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPC", data)
    end
    
    print("[DTNPC] Notified removal: " .. (name or uuid))
end
