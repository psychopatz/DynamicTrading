-- ==============================================================================
-- DTNPC_HealthShared_CombatAuthority.lua
-- Combat authority, attacker identity, and reputation helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal
local TRUSTED_EXPLICIT_DAMAGE_SOURCES = {
    weapon_hit_event = true,
    client_weapon_hit_report = true,
    client_weapon_hit_report_dead_body = true,
    zombie_lease = true,
    dt_npc_combat = true,
}

local function hasFriendlyPlayerAuthority(npcData, playerObj)
    if DTNPCRoles and DTNPCRoles.CanUsePlayerAuthority then
        local ok, result = pcall(DTNPCRoles.CanUsePlayerAuthority, npcData, playerObj)
        if ok then
            return result == true
        end
    end

    if DTNPCProtect and DTNPCProtect.Internal and DTNPCProtect.Internal.isFriendlyAuthorityPlayer then
        local ok, result = pcall(DTNPCProtect.Internal.isFriendlyAuthorityPlayer, npcData, playerObj)
        if ok then
            return result == true
        end
    end

    return false
end

local function getAttackerType(attacker)
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

internal.getAttackerType = getAttackerType

local function getAttackerID(attacker)
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

internal.getAttackerID = getAttackerID

local function isTrustedExplicitDamageSource(source)
    return TRUSTED_EXPLICIT_DAMAGE_SOURCES[tostring(source or "")] == true
end

internal.isTrustedExplicitDamageSource = isTrustedExplicitDamageSource

local function getResolvedSkillLevelForHealth(npcData, skillID)
    if not npcData or not skillID then
        return 0
    end

    local protectInternal = DTNPCProtect and DTNPCProtect.Internal or nil
    if protectInternal and protectInternal.getResolvedSkillLevel then
        local ok, value = pcall(protectInternal.getResolvedSkillLevel, npcData, skillID)
        if ok then
            return tonumber(value) or 0
        end
    end

    if DTNPCProtect and DTNPCProtect.GetSkillLevel then
        local ok, value = pcall(DTNPCProtect.GetSkillLevel, npcData, skillID)
        if ok then
            return tonumber(value) or 0
        end
    end

    return 0
end

internal.getResolvedSkillLevelForHealth = getResolvedSkillLevelForHealth

local function capturePlayerAttacker(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return
    end

    npcData.lastPlayerAttackerUsername = attacker.getUsername and attacker:getUsername() or nil
    npcData.lastPlayerAttackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil
    npcData.lastPlayerAttackedAt = internal.nowMillis()
end

internal.capturePlayerAttacker = capturePlayerAttacker

local function getPlayerUsername(attacker)
    if not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return nil
    end

    local username = attacker.getUsername and attacker:getUsername() or nil
    if not username or username == "" then
        return nil
    end

    return username
end

internal.getPlayerUsername = getPlayerUsername

local function isPlayerMatchedToCompanion(npcData, player, username)
    if not npcData or not player then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil then
        if npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end
        if npcData.preIncapMasterID ~= nil and tonumber(npcData.preIncapMasterID) == tonumber(playerID) then
            return true
        end
    end

    if not username or username == "" then
        return false
    end

    return (npcData.master and tostring(npcData.master) == username)
        or (npcData.preIncapMaster and tostring(npcData.preIncapMaster) == username)
end

internal.isPlayerMatchedToCompanion = isPlayerMatchedToCompanion

local function isFriendlyFollowerOrProtectorHit(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return false
    end

    if DTNPCRoles and DTNPCRoles.ResolveContext then
        local ok, context = pcall(DTNPCRoles.ResolveContext, npcData)
        if not (ok and type(context) == "table" and context.isColonyOwned == true) then
            return false
        end
    elseif not internal.isColonyOwnedCompanionNPC
        or not internal.isColonyOwnedCompanionNPC(npcData) then
        return false
    end

    local state = tostring(npcData.state or "")
    local combatOrder = tostring(npcData.combatOrder or "")
    local shouldProtect = internal.isFollowerOrProtectorState(state) or internal.isFollowerOrProtectorState(combatOrder)
    if not shouldProtect and DTNPCRoles and DTNPCRoles.ResolveContext then
        local ok, context = pcall(DTNPCRoles.ResolveContext, npcData)
        if ok and type(context) == "table" and context.isPlayerOwned == true then
            shouldProtect = true
        end
    end
    if npcData.incapState == "Active" and internal.isFollowerOrProtectorState(tostring(npcData.preIncapState or "")) then
        shouldProtect = true
    end
    if not shouldProtect then
        return false
    end

    local username = getPlayerUsername(attacker)
    if isPlayerMatchedToCompanion(npcData, attacker, username) then
        return true
    end

    if hasFriendlyPlayerAuthority(npcData, attacker) then
        return true
    end

    return false
end

internal.isFriendlyFollowerOrProtectorHit = isFriendlyFollowerOrProtectorHit

local function applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)
    if not npcData or not combatHealth then
        return
    end
    if not DynamicTrading_Factions or not DynamicTrading_Factions.ModifyReputation then
        return
    end
    if not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return
    end

    local factionID = npcData.factionID
    if not factionID or factionID == "" or factionID == "Independent" then
        return
    end

    local username = getPlayerUsername(attacker)
    if not username then
        return
    end

    if hasFriendlyPlayerAuthority(npcData, attacker) then
        return
    end

    local resolvedDamage = math.max(0, tonumber(appliedDamage) or 0)
    if resolvedDamage <= DTNPCHealth.MIN_DAMAGE then
        return
    end

    local maxHealth = math.max(1, tonumber(combatHealth.max) or 0)
    local threshold = math.max(1, maxHealth * math.max(0.01, tonumber(DTNPCHealth.PLAYER_REP_DAMAGE_THRESHOLD_RATIO) or 0.25))
    local tracker = combatHealth.playerReputationDamage or {}
    local entry = tracker[username] or {
        totalDamage = 0,
        penaltiesApplied = 0,
    }

    entry.totalDamage = math.min(maxHealth, math.max(0, tonumber(entry.totalDamage) or 0) + resolvedDamage)

    local totalPenalties = math.floor(entry.totalDamage / threshold)
    local appliedPenalties = math.max(0, math.floor(tonumber(entry.penaltiesApplied) or 0))
    local newPenalties = totalPenalties - appliedPenalties

    if newPenalties > 0 then
        local delta = (tonumber(DTNPCHealth.PLAYER_REP_DAMAGE_PENALTY) or -10) * newPenalties
        if internal.applyFactionBiasPenalty(attacker, factionID, delta, "npc_damage_penalty") then
            entry.penaltiesApplied = totalPenalties
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "Applied faction reputation damage penalty name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                    .. " uuid=" .. tostring(npcData.uuid)
                    .. " faction=" .. tostring(factionID)
                    .. " username=" .. tostring(username)
                    .. " delta=" .. tostring(delta)
                    .. " accumulatedDamage=" .. tostring(string.format("%.2f", entry.totalDamage))
                    .. " threshold=" .. tostring(string.format("%.2f", threshold))
            )
        end
    end

    tracker[username] = entry
    combatHealth.playerReputationDamage = tracker
end

internal.applyPlayerDamageReputationPenalty = applyPlayerDamageReputationPenalty
