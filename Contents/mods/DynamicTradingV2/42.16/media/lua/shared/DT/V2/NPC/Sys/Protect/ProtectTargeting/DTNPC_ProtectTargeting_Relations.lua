-- ==============================================================================
-- DTNPC_ProtectTargeting_Relations.lua
-- Relationship and hostility helpers for DTNPC protect targeting.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local isFriendlyAuthorityPlayer = Internal.isFriendlyAuthorityPlayer

local function normalizeIdentityText(value)
    local text = tostring(value or "")
    if text == "" then
        return nil
    end
    return text
end

local function resolvePlayerIdentity(player)
    if not player then
        return nil, nil
    end

    local username = player.getUsername and player:getUsername() or nil
    local onlineID = player.getOnlineID and player:getOnlineID() or nil
    if onlineID ~= nil then
        onlineID = tonumber(onlineID)
    end

    return normalizeIdentityText(username), onlineID
end

local function hasExplicitHostileTargeting(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if npcData.isHostile == true
        or npcData.raidHostileFaction == true
        or npcData.banditGroupID ~= nil
        or npcData.hostileNegotiationGroupID ~= nil then
        return true
    end

    local mode = tostring(npcData.tradeCycleMode or "")
    return mode == "robbery" or mode == "hostile_bribe"
end

local function resolveExplicitHostilePlayerIdentity(npcData)
    if not hasExplicitHostileTargeting(npcData) then
        return nil, nil
    end

    local idCandidates = {
        npcData.masterID,
        npcData.banditTargetOnlineID,
        npcData.tradeCycleTargetPlayerOnlineID,
        npcData.lastPlayerAttackerOnlineID,
        npcData.banditPausedTargetOnlineID,
    }
    local nameCandidates = {
        npcData.master,
        npcData.banditTargetUsername,
        npcData.tradeCycleTargetPlayerUsername,
        npcData.lastPlayerAttackerUsername,
        npcData.banditPausedTargetUsername,
    }

    local resolvedID = nil
    local index
    for index = 1, #idCandidates do
        local candidate = tonumber(idCandidates[index])
        if candidate ~= nil then
            resolvedID = candidate
            break
        end
    end

    local resolvedName = nil
    for index = 1, #nameCandidates do
        local candidate = normalizeIdentityText(nameCandidates[index])
        if candidate ~= nil then
            resolvedName = candidate
            break
        end
    end

    return resolvedName, resolvedID
end

local function isExplicitHostilePlayerForNPC(npcData, player)
    if not npcData or not player or player:isDead() then
        return false
    end

    local targetName, targetID = resolveExplicitHostilePlayerIdentity(npcData)
    if targetName == nil and targetID == nil then
        return false
    end

    local playerName, playerID = resolvePlayerIdentity(player)
    if targetID ~= nil and playerID ~= nil and targetID == playerID then
        return true
    end
    if targetName ~= nil and playerName ~= nil and targetName == playerName then
        return true
    end

    return false
end

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

    if DT_Reputation
        and DT_Reputation.GetEffectiveRep
        and DT_Reputation.EnsureLoaded
        and DT_Reputation.EnsureLoaded() then
        local rep = tonumber(DT_Reputation.GetEffectiveRep(npcData.uuid, npcData.factionID))
        if rep ~= nil then
            return rep
        end
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

local function isAlwaysHostileFaction(npcData)
    if not npcData or not npcData.factionID then
        return false
    end

    local faction = nil
    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
    end
    if not faction then
        local factionData = ModData and ModData.get and ModData.get("DynamicTrading_Factions") or nil
        faction = type(factionData) == "table" and factionData[npcData.factionID] or nil
    end

    return type(faction) == "table"
        and (faction.hostileToPlayers == true
            or faction.alwaysHostile == true
            or tostring(faction.factionType or "") == "bandit"
            or tostring(npcData.factionID or "") == "Bandits")
end

local function isGeneralHostileToPlayers(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    local mode = tostring(npcData.tradeCycleMode or "")
    return npcData.isBandit == true
        or npcData.raidHostileFaction == true
        or npcData.banditGroupID ~= nil
        or npcData.hostileNegotiationGroupID ~= nil
        or mode == "robbery"
        or mode == "hostile_bribe"
        or isAlwaysHostileFaction(npcData)
end

local function isHostilePlayerForNPC(npcData, player)
    if not npcData or not player or player:isDead() then
        return false
    end

    if isExplicitHostilePlayerForNPC(npcData, player) then
        return true
    end

    if isFriendlyAuthorityPlayer and isFriendlyAuthorityPlayer(npcData, player) then
        return false
    end

    if isGeneralHostileToPlayers(npcData) then
        return true
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

    local leftFaction = tostring(npcData.factionID or "")
    local rightFaction = tostring(targetData.factionID or "")
    if isBanditLike(npcData) and isBanditLike(targetData) then
        if leftFaction == "" or rightFaction == "" or leftFaction == rightFaction then
            return false
        end
    end

    if leftFaction ~= ""
        and rightFaction ~= ""
        and leftFaction ~= "Independent"
        and rightFaction ~= "Independent"
        and leftFaction ~= "Factionless"
        and rightFaction ~= "Factionless"
        and leftFaction == rightFaction then
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
Internal.IsExplicitHostilePlayerForNPC = isExplicitHostilePlayerForNPC
Internal.ResolveExplicitHostilePlayerIdentity = resolveExplicitHostilePlayerIdentity
Internal.GetDTNPCDataFromZombie = getDTNPCDataFromZombie
Internal.IsDTNPCHostileToNPC = isDTNPCHostileToNPC
Internal.isDTNPCHostileToNPC = isDTNPCHostileToNPC

DTNPCProtect.IsDTNPCHostileToNPC = isDTNPCHostileToNPC
