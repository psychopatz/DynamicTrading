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
        end
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
