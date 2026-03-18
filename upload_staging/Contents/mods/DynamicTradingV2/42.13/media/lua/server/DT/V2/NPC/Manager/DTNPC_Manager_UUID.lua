-- ==============================================================================
-- DTNPC_Manager_UUID.lua
-- UUID generation and lookup utilities.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.GenerateSoulID(name)
    -- Sanitize name: remove spaces and non-alphanumeric characters
    local sanitizedName = "Unknown"
    if name then
        sanitizedName = name:gsub("%s+", ""):gsub("[^%a%d]", "")
    end
    
    -- Generate 4-character hex suffix
    local suffix = ""
    local hexChars = "0123456789abcdef"
    for i = 1, 4 do
        local rand = ZombRand(1, 17)
        suffix = suffix .. hexChars:sub(rand, rand)
    end
    
    -- We return just the ID part. 
    -- The Roster system prepends "DTSOUL_" for ModData keying.
    return sanitizedName .. "_" .. suffix
end

-- Backward compatibility alias
DTNPCManager.GenerateUUID = DTNPCManager.GenerateSoulID

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
