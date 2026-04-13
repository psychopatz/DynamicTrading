-- ==============================================================================
-- DTNPC_Lifecycle_Shared.lua
-- Shared lifecycle helpers for context, attacker, and persistence handoffs.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

function internal.nowMillis()
    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.nowMillis then
        return healthInternal.nowMillis()
    end

    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

function internal.copyContext(context)
    local copy = {}
    if type(context) == "table" then
        for key, value in pairs(context) do
            copy[key] = value
        end
    end
    return copy
end

function internal.getAttackerType(attacker)
    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.getAttackerType then
        return healthInternal.getAttackerType(attacker)
    end
    if not attacker then
        return nil
    end
    if instanceof and instanceof(attacker, "IsoPlayer") then
        return "player"
    end
    if instanceof and instanceof(attacker, "IsoZombie") then
        return "zombie"
    end
    return attacker.getObjectName and tostring(attacker:getObjectName()) or tostring(attacker)
end

function internal.getAttackerID(attacker)
    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.getAttackerID then
        return healthInternal.getAttackerID(attacker)
    end
    if not attacker then
        return nil
    end
    if attacker.getOnlineID then
        local onlineID = attacker:getOnlineID()
        if onlineID and onlineID ~= 0 then
            return "online:" .. tostring(onlineID)
        end
    end
    if attacker.getUsername then
        local username = attacker:getUsername()
        if username and username ~= "" then
            return "user:" .. tostring(username)
        end
    end
    if attacker.getPersistentOutfitID then
        local outfitID = attacker:getPersistentOutfitID()
        if outfitID and outfitID ~= 0 then
            return "outfit:" .. tostring(outfitID)
        end
    end
    if attacker.getID then
        local objectID = attacker:getID()
        if objectID and objectID ~= 0 then
            return "id:" .. tostring(objectID)
        end
    end
    return tostring(attacker)
end

function internal.buildKillerContext(attacker, npcData)
    if attacker and instanceof and instanceof(attacker, "IsoPlayer") then
        return {
            killerUsername = attacker.getUsername and attacker:getUsername() or nil,
            killerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        }
    end

    if npcData and npcData.lastPlayerAttackerUsername then
        return {
            killerUsername = npcData.lastPlayerAttackerUsername,
            killerOnlineID = npcData.lastPlayerAttackerOnlineID,
        }
    end

    return nil
end

function internal.saveSoulIfAvailable(uuid, npcData)
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and uuid and npcData then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
        return true
    end
    return false
end

function internal.getUUIDFromZombie(zombie)
    if DTNPCManager and DTNPCManager.GetUUIDFromZombie then
        return DTNPCManager.GetUUIDFromZombie(zombie)
    end
    local modData = zombie and zombie.getModData and zombie:getModData() or nil
    return modData and modData.DTNPC_UUID or nil
end

function internal.getLiveNPCData(uuid, fallbackData)
    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        return DTNPCManager.Data[uuid]
    end
    return fallbackData
end

function internal.isRemoteClient()
    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.isRemoteClient then
        return healthInternal.isRemoteClient()
    end
    return isClient and isClient() and not (isServer and isServer())
end
