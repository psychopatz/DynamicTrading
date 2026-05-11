-- ==============================================================================
-- DTNPC_ProtectTargeting_Relations.lua
-- Relationship and hostility helpers for DTNPC protect targeting.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local isFriendlyAuthorityPlayer = Internal.isFriendlyAuthorityPlayer

local function getThreatPlayers()
    local players = {}

    if DTNPCLogic and DTNPCLogic.GetActivePlayers then
        local snapshot = DTNPCLogic.GetActivePlayers()
        for i = 1, #(snapshot or {}) do
            local player = snapshot[i]
            if player then
                players[#players + 1] = player
            end
        end
        if #players > 0 then
            return players
        end
    end

    local online = getOnlinePlayers and getOnlinePlayers() or nil
    if online then
        for i = 0, online:size() - 1 do
            local player = online:get(i)
            if player then
                players[#players + 1] = player
            end
        end
        if #players > 0 then
            return players
        end
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if player then
        players[1] = player
    end

    return players
end

local function getFactionReputationForPlayer(npcData, player)
    if not npcData or not npcData.factionID or not player then
        return 0
    end
    if not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return 0
    end

    local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
    if not faction then
        return 0
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return 0
    end

    local disposition = type(faction.playerDisposition) == "table" and faction.playerDisposition or nil
    if disposition and disposition[username] ~= nil then
        return tonumber(disposition[username]) or 0
    end

    return tonumber(faction.playerDispositionDefault) or 0
end

local function isHostilePlayerForNPC(npcData, player)
    if not npcData or not player or player:isDead() then
        return false
    end

    if isFriendlyAuthorityPlayer and isFriendlyAuthorityPlayer(npcData, player) then
        return false
    end

    local threshold = tonumber(DTNPCProtect.CONFIG.AggressivePlayerRepThreshold)
        or tonumber(DTNPCProtect.CONFIG.HostilePlayerRepThreshold)
        or -10
    return getFactionReputationForPlayer(npcData, player) <= threshold
end

local function getDTNPCDataFromZombie(zombie)
    local modData = zombie and zombie.getModData and zombie:getModData() or nil
    if not (modData and modData.IsDTNPC == true) then
        return nil, nil
    end

    local targetData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (targetData and targetData.uuid)
    if (not targetData) and uuid and DTNPCManager and DTNPCManager.Data then
        targetData = DTNPCManager.Data[uuid]
    end
    return targetData, uuid
end

local function isCompanionLike(npcData)
    if not npcData then
        return false
    end
    return tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        or npcData.linkedWorkerID ~= nil
        or npcData.masterID ~= nil
        or (npcData.master and tostring(npcData.master) ~= "")
end

local function isBanditLike(npcData)
    return npcData
        and (npcData.isBandit == true
            or npcData.banditGroupID ~= nil
            or npcData.raidHostileFaction == true
            or tostring(npcData.factionID or "") == "Bandits")
end

local function shareOwnerOrMaster(left, right)
    if not left or not right then
        return false
    end

    local leftID = left.masterID or left.ownerOnlineID
    local rightID = right.masterID or right.ownerOnlineID
    if leftID ~= nil and rightID ~= nil and tonumber(leftID) == tonumber(rightID) then
        return true
    end

    local leftName = left.master or left.ownerUsername or left.dcCompanionOwner
    local rightName = right.master or right.ownerUsername or right.dcCompanionOwner
    return leftName ~= nil
        and rightName ~= nil
        and tostring(leftName) ~= ""
        and tostring(leftName) == tostring(rightName)
end

local function targetIsHostileToOwner(npcData, targetData)
    if not npcData or not targetData then
        return false
    end

    local ownerID = npcData.masterID or npcData.ownerOnlineID
    if ownerID ~= nil and targetData.lastPlayerAttackerOnlineID ~= nil
        and tonumber(ownerID) == tonumber(targetData.lastPlayerAttackerOnlineID) then
        return true
    end

    local ownerName = npcData.master or npcData.ownerUsername or npcData.dcCompanionOwner
    if ownerName ~= nil and tostring(ownerName) ~= ""
        and targetData.lastPlayerAttackerUsername ~= nil
        and tostring(ownerName) == tostring(targetData.lastPlayerAttackerUsername) then
        return true
    end

    return false
end

local function isDTNPCHostileToNPC(npcData, targetData)
    if not npcData or not targetData then
        return false
    end
    if targetData.incapState == "Active" or targetData.state == "Incapacitated" then
        return false
    end
    if shareOwnerOrMaster(npcData, targetData) then
        return false
    end

    if isCompanionLike(npcData) and targetData.isHostile == true then
        return true
    end
    if isCompanionLike(npcData) and targetIsHostileToOwner(npcData, targetData) then
        return true
    end
    if isBanditLike(targetData) and not isBanditLike(npcData) then
        return true
    end
    if isBanditLike(npcData) and not isBanditLike(targetData) then
        return true
    end
    if isBanditLike(npcData) and isCompanionLike(targetData) then
        return true
    end
    if targetData.isHostile == true and targetData.combatTargetID then
        return true
    end

    local leftFaction = tostring(npcData.factionID or "")
    local rightFaction = tostring(targetData.factionID or "")
    if leftFaction ~= "" and rightFaction ~= "" and leftFaction ~= rightFaction then
        if targetData.raidHostileFaction == true or npcData.raidHostileFaction == true then
            return true
        end
    end

    return false
end

Internal.GetThreatPlayers = getThreatPlayers
Internal.GetFactionReputationForPlayer = getFactionReputationForPlayer
Internal.IsHostilePlayerForNPC = isHostilePlayerForNPC
Internal.GetDTNPCDataFromZombie = getDTNPCDataFromZombie
Internal.IsDTNPCHostileToNPC = isDTNPCHostileToNPC

DTNPCProtect.IsDTNPCHostileToNPC = isDTNPCHostileToNPC
