-- ==============================================================================
-- DTNPC_Manager_UUID.lua
-- UUID generation and lookup utilities.
-- ==============================================================================

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.GenerateUUID()
    -- Simple UUID generation
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and ZombRand(0, 16) or ZombRand(8, 12)
        return string.format('%x', v)
    end)
end

function DTNPCManager.GetUUIDFromOutfitID(outfitID)
    return DTNPCManager.OutfitIDToUUID[outfitID]
end

function DTNPCManager.GetUUIDFromZombie(zombie)
    if not zombie then return nil end
    
    -- First check modData for UUID
    local modData = zombie:getModData()
    if modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end
    
    -- Fallback: check outfit ID mapping
    local outfitID = zombie:getPersistentOutfitID()
    return DTNPCManager.GetUUIDFromOutfitID(outfitID)
end
