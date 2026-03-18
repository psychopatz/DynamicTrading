-- ==============================================================================
-- DTNPC_ServerCore_Utilities.lua
-- Helper functions for finding NPCs in the world.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- FINDER FUNCTIONS
-- ==============================================================================

function DTNPCServerCore.FindZombieByUUID(uuid)
    if not uuid then return nil end

    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            if modData.DTNPC_UUID == uuid then
                return zombie
            end

            local npcData = modData.DTNPC_Data or modData.DTNPCBrain
            if npcData and npcData.uuid == uuid then
                return zombie
            end
        end
    end

    local savedData = nil
    if DTNPCManager and DTNPCManager.Data then
        savedData = DTNPCManager.Data[uuid]
    end
    if not savedData and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        savedData = DynamicTrading_Roster.GetSoul(uuid)
    end

    local outfitID = savedData and savedData.currentOutfitID
    if outfitID then
        if DTNPCManager and DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
            DTNPCManager.RespawnDebug.Log(
                "find_uuid_outfit_fallback_" .. tostring(uuid),
                "Process=find_zombie_by_uuid route=outfit_fallback uuid=" .. tostring(uuid) ..
                    " savedOutfitID=" .. tostring(outfitID)
            )
        end
        return DTNPCServerCore.FindZombieByOutfitID(outfitID)
    end
    
    return nil
end

function DTNPCServerCore.FindZombieByOutfitID(outfitID)
    local cell = getCell()
    if not cell then return nil end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return nil end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and zombie:getPersistentOutfitID() == outfitID then
            return zombie
        end
    end
    
    return nil
end
