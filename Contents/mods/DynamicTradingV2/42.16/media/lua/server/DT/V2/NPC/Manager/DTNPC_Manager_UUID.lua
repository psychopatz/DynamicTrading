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

function DTNPCManager.GetUUIDFromBodyInstanceID(bodyInstanceID)
    return DTNPCManager.BodyInstanceIDToUUID and DTNPCManager.BodyInstanceIDToUUID[bodyInstanceID] or nil
end

function DTNPCManager.GetPresenceRevision(npcData)
    if type(npcData) ~= "table" then
        return 0
    end

    return math.max(0, math.floor(tonumber(npcData.presenceRevision) or 0))
end

function DTNPCManager.EnsurePresenceRevision(npcData)
    if type(npcData) ~= "table" then
        return 0
    end

    local revision = DTNPCManager.GetPresenceRevision(npcData)
    npcData.presenceRevision = revision
    return revision
end

function DTNPCManager.BumpPresenceRevision(npcData)
    if type(npcData) ~= "table" then
        return 0
    end

    local revision = DTNPCManager.EnsurePresenceRevision(npcData) + 1
    npcData.presenceRevision = revision
    return revision
end

function DTNPCManager.IsPhysicalWorldStatus(status, npcData)
    local normalized = tostring(status or "")
    if normalized == "Resting" or normalized == "Working" or normalized == "Trading" then
        return true
    end

    if normalized == "Incapacitated" then
        return true
    end

    return type(npcData) == "table" and npcData.incapState == "Active"
end

function DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    if type(npcData) ~= "table" then
        return
    end

    local currentBodyInstanceID = npcData.currentBodyInstanceID
    if currentBodyInstanceID ~= nil then
        local bodyMap = DTNPCManager.BodyInstanceIDToUUID
        if bodyMap then
            bodyMap[currentBodyInstanceID] = nil
        end
    end

    npcData.currentBodyInstanceID = nil

    if bodyInstanceID ~= nil and tostring(npcData.startupBodyInstanceHint or "") == tostring(bodyInstanceID) then
        npcData.startupBodyInstanceHint = nil
    end
end

function DTNPCManager.GetUUIDFromZombie(zombie)
    if not zombie then return nil end
    
    -- First check modData for UUID
    local modData = zombie:getModData()
    if modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end
    
    -- Fallback: check outfit ID mapping
    local bodyInstanceID = zombie:getPersistentOutfitID()
    return DTNPCManager.GetUUIDFromBodyInstanceID(bodyInstanceID)
end
