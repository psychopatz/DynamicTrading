-- ==============================================================================
-- DTNPC_ServerCore_Summon.lua
-- Summoning/teleporting NPCs to player location.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- SUMMON FUNCTION
-- ==============================================================================

function DTNPCServerCore.SummonAll(player)
    if not DTNPCManager then return end
    local username = player:getUsername()
    local cell = getCell()
    local toTeleport = {}
    local toRecreate = {}
    
    print("[DTNPC] Summoning NPCs for player: " .. username)
    
    for uuid, npcData in pairs(DTNPCManager.Data) do
        if npcData.master == username then
            local foundObj = DTNPCServerCore.FindZombieByUUID(uuid)
            
            if foundObj then
                table.insert(toTeleport, {zombie = foundObj, npcData = npcData})
                print("[DTNPC] Found existing NPC to teleport: " .. (npcData.name or uuid))
            else
                table.insert(toRecreate, {uuid = uuid, npcData = npcData})
                print("[DTNPC] NPC not found in world, will recreate: " .. (npcData.name or uuid))
            end
        end
    end
    
    for _, data in ipairs(toTeleport) do
        local npc = data.zombie
        local npcData = data.npcData
        
        npc:setX(player:getX() + 1)
        npc:setY(player:getY() + 1)
        npc:setZ(player:getZ())
        npc:setLastX(player:getX())
        npc:setLastY(player:getY())
        
        npcData.lastX = math.floor(npc:getX())
        npcData.lastY = math.floor(npc:getY())
        npcData.lastZ = math.floor(npc:getZ())
        DTNPCServerCore.SyncToAllClients(npc, npcData)
    end
    
    for _, data in ipairs(toRecreate) do
        DTNPCServerCore.RespawnNPC(data.npcData, data.uuid)
    end
    
    print("[DTNPC] Summon complete. Teleported: " .. #toTeleport .. ", Recreated: " .. #toRecreate)
end
