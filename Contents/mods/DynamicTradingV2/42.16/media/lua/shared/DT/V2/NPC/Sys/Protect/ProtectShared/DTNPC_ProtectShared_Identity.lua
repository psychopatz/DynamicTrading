-- ==============================================================================
-- DTNPC_ProtectShared_Identity.lua
-- Shared runtime identity helpers for DTNPC protect modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function getZombieRuntimeID(zombie)
    if not zombie then
        return nil
    end

    local outfitID = zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
    if outfitID and outfitID ~= 0 then
        return "outfit:" .. tostring(outfitID)
    end

    local objectID = zombie.getID and zombie:getID() or nil
    if objectID then
        return "id:" .. tostring(objectID)
    end

    return tostring(zombie)
end

local function getPlayerRuntimeID(player)
    if not player then
        return nil
    end

    local onlineID = player.getOnlineID and player:getOnlineID() or nil
    if onlineID and onlineID ~= 0 then
        return "online:" .. tostring(onlineID)
    end

    local username = player.getUsername and player:getUsername() or nil
    if username and username ~= "" then
        return "user:" .. tostring(username)
    end

    return "player:" .. tostring(player)
end

Internal.getZombieRuntimeID = getZombieRuntimeID
Internal.getPlayerRuntimeID = getPlayerRuntimeID

DTNPCProtect.GetPlayerRuntimeID = getPlayerRuntimeID
