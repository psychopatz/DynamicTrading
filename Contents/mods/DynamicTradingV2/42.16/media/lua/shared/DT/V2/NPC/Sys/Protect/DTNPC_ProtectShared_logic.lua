-- ==============================================================================
-- DTNPC_ProtectShared_logic.lua
-- Shared constants and internal helper functions for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

DTNPCProtect.CONFIG = DTNPCProtect.CONFIG or {
    ScanRadius = 12,
    FloorTolerance = 1,
    StickyRadiusBonus = 1.75,
    StickyTargetScoreBias = 0.45,
    NoticeCooldownMs = 12000,
    DiagnosticCooldownMs = 15000,
    DebugCooldownMs = 15000,
    DebugLogging = false,
    ConsoleLogging = false,
    CombatIssueLogging = false,
    AggressivePlayerRepThreshold = -10,
    HostilePlayerRepThreshold = -40,
    StationaryPostResetDistance = 4,
    StationaryCombatLeashRadius = 10,
    CombatUnreachableTimeoutMs = 6000,
    CombatProgressDistance = 0.35,
    MeleeCrowdRadius = 1.8,
    MeleeCrowdPenalty = 0.8,
    MeleeCrowdClosestPenalty = 0.7,
    MeleeCrowdDangerRadius = 2.4,
    MeleeCrowdDangerThreshold = 3,
    MeleeCrowdSevereThreshold = 4,
    MeleeRecentZombieDamageWindowMs = 4500,
    MeleeLowHealthRetreatRatio = 0.58,
    MeleeImmediateThreatRadius = 2.2,
    MeleeImmediateThreatStickyBreak = 0.65,
    HostileLostSightSearchMinMs = 60000,
    HostileLostSightSearchMaxMs = 90000,
    HostileLastSeenChaseMs = 4500,
    HostileOffscreenDespawnRadius = 70,
    PlayerHitReactionCooldownMs = 1600,
    HostileChaseGiveUpMinMs = 30000,
    HostileChaseGiveUpMaxMs = 55000,
    HostileChaseGiveUpMinDistance = 8,
    BanditChasePauseMs = 120000,
}

DTNPCProtect.CONFIG.DiagnosticCooldownMs = tonumber(DTNPCProtect.CONFIG.DiagnosticCooldownMs) or 15000
DTNPCProtect.CONFIG.DebugCooldownMs = tonumber(DTNPCProtect.CONFIG.DebugCooldownMs) or 15000
DTNPCProtect.CONFIG.DebugLogging = DTNPCProtect.CONFIG.DebugLogging == true
DTNPCProtect.CONFIG.ConsoleLogging = DTNPCProtect.CONFIG.ConsoleLogging == true
DTNPCProtect.CONFIG.CombatIssueLogging = DTNPCProtect.CONFIG.CombatIssueLogging == true
DTNPCProtect.CONFIG.HostileChaseGiveUpMinMs = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMinMs) or 30000
DTNPCProtect.CONFIG.HostileChaseGiveUpMaxMs = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMaxMs) or 55000
DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance) or 8
DTNPCProtect.CONFIG.BanditChasePauseMs = tonumber(DTNPCProtect.CONFIG.BanditChasePauseMs) or 120000

DTNPCProtect.LOADOUT_WEIGHTS = DTNPCProtect.LOADOUT_WEIGHTS or {
    melee = 45,
    ranged = 45,
    hybrid = 10,
}

DTNPCProtect.LOADOUT_PRESETS = DTNPCProtect.LOADOUT_PRESETS or {
    melee = {
        rangedWeapon = nil,
        rangedAmmoType = nil,
        ammoCount = 0,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
    ranged = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = nil,
        bag = nil,
    },
    hybrid = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
}

DTNPCProtect.SKILL_XP_PER_LEVEL = DTNPCProtect.SKILL_XP_PER_LEVEL or {
    Melee = 80,
    Shooting = 100,
}

DTNPCProtect.COMBAT_SKILL_XP = DTNPCProtect.COMBAT_SKILL_XP or {
    MeleeHit = 4,
    MeleeKillBonus = 18,
    ShootingHit = 4,
    ShootingKillBonus = 16,
}

local function nowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return 0
end

local function protectLog(message)
    local line = "[DTNPC Protect] " .. tostring(message or "")
    if DTNPCProtect.CONFIG.ConsoleLogging == true then
        print(line)
    end

    if DynamicTrading and DynamicTrading.Log then
        pcall(function()
            DynamicTrading.Log("DTV2", "NPC", "Protect", tostring(message or ""))
        end)
    elseif DTNPCProtect.CONFIG.ConsoleLogging == true then
        print(line)
    end
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

local function getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end

    return nil
end

local function getConditionMax(fullType)
    local scriptItem = getScriptItem(fullType)
    if scriptItem and scriptItem.getConditionMax then
        local maxCondition = tonumber(scriptItem:getConditionMax()) or 0
        if maxCondition > 0 then
            return math.floor(maxCondition)
        end
    end
    return nil
end

local function createConditionProbeItem(fullType)
    if not fullType or fullType == "" then
        return nil
    end

    if instanceItem then
        return instanceItem(fullType)
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        return InventoryItemFactory.CreateItem(fullType)
    end

    return nil
end

local function normalizeWeaponCondition(loadout, weaponKey, conditionKey, trackCondition)
    local weapon = loadout[weaponKey]
    if not weapon or weapon == "" then
        loadout[conditionKey] = nil
        return
    end

    if not trackCondition then
        loadout[conditionKey] = nil
        return
    end

    local maxCondition = getConditionMax(weapon)
    if not maxCondition then
        loadout[conditionKey] = nil
        return
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition == nil then
        currentCondition = maxCondition
    end

    currentCondition = math.max(0, math.min(maxCondition, math.floor(currentCondition)))
    loadout[conditionKey] = currentCondition
end

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

local function syncProtectNotice(zombie, npcData)
    if not zombie or not npcData or not npcData.uuid then
        return false
    end
    if not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return false
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return false
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
    return true
end

local function buildProtectDebugSummary(npcData)
    npcData = type(npcData) == "table" and npcData or {}
    local loadout = type(npcData.loadout) == "table" and npcData.loadout or {}

    return table.concat({
        "uuid=" .. tostring(npcData.uuid or "?"),
        "state=" .. tostring(npcData.state or "nil"),
        "order=" .. tostring(npcData.combatOrder or "nil"),
        "melee=" .. tostring(loadout.meleeWeapon or "nil"),
        "ranged=" .. tostring(loadout.rangedWeapon or "nil"),
        "ammo=" .. tostring(loadout.ammoCount or 0),
    }, " | ")
end

local function isPlayerOwnedTraderRaw(npcData)
    if not npcData then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    if npcData.isPlayerFactionTrader == true then
        return true
    end

    if npcData.masterID ~= nil then
        return true
    end
    if npcData.master and tostring(npcData.master) ~= "" then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        if faction and faction.playerOwned == true then
            return true
        end
    end

    return npcData.linkedWorkerID ~= nil
end

local function isFriendlyAuthorityPlayer(npcData, player)
    if not npcData or not player or not instanceof or not instanceof(player, "IsoPlayer") then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
        return true
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return false
    end

    if npcData.master and tostring(npcData.master) == username then
        return true
    end

    if npcData.ownerUsername and tostring(npcData.ownerUsername) == username then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        local leaderUsername = faction and (faction.leaderUsername or faction.ownerUsername) or nil
        if leaderUsername and tostring(leaderUsername) == username then
            return true
        end
    end

    return false
end

local function isWeaponDurabilitySandboxEnabled()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and sandbox.NPCWeaponDurability ~= nil then
        return sandbox.NPCWeaponDurability ~= false
    end
    return true
end

local function shouldConsumeWeaponDurabilityRaw(npcData)
    return isPlayerOwnedTraderRaw(npcData) and isWeaponDurabilitySandboxEnabled()
end

local function getVariableBooleanSafe(zombie, name)
    if not zombie or not name then
        return false
    end

    if zombie.getVariableBoolean then
        local ok, result = pcall(zombie.getVariableBoolean, zombie, name)
        if ok then
            return result == true
        end
    end

    local value = zombie.getVariableString and zombie:getVariableString(name) or ""
    value = string.lower(tostring(value or ""))
    return value == "true" or value == "1"
end

local function getActionStateNameSafe(zombie)
    if not zombie or not zombie.getActionStateName then
        return ""
    end

    local ok, result = pcall(zombie.getActionStateName, zombie)
    if ok then
        return string.lower(tostring(result or ""))
    end

    return ""
end

local function isInvalidCombatActionState(actionState)
    if actionState == "" then
        return false
    end

    return string.find(actionState, "fall", 1, true) ~= nil
        or string.find(actionState, "stagger", 1, true) ~= nil
        or string.find(actionState, "stumble", 1, true) ~= nil
        or string.find(actionState, "bumped", 1, true) ~= nil
        or string.find(actionState, "knock", 1, true) ~= nil
        or string.find(actionState, "hitreaction", 1, true) ~= nil
        or string.find(actionState, "hit reaction", 1, true) ~= nil
end

local function resetCombatActionVariables(zombie)
    if not zombie then
        return
    end

    -- Do not write bAttack/bAttacking/Attack/Lunge here. In B42 these animation
    -- variables are callback/read-only slots and setting them floods the console.
    if zombie.setBumpDone then
        pcall(zombie.setBumpDone, zombie, true)
    end
end

function DTNPCProtect.IsCombatCapable(zombie, npcData, options)
    options = type(options) == "table" and options or {}

    if not zombie or not npcData or zombie:isDead() then
        return false, "invalid"
    end
    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return false, "incapacitated"
    end

    if getVariableBooleanSafe(zombie, "bCrawling")
        or getVariableBooleanSafe(zombie, "bBecomeCrawler")
        or getVariableBooleanSafe(zombie, "FallOnFront")
        or getVariableBooleanSafe(zombie, "bKnockedDown") then
        return false, "downed"
    end

    local actionState = getActionStateNameSafe(zombie)
    if isInvalidCombatActionState(actionState) then
        return false, "recovering_action"
    end

    if options.requireStanding ~= false then
        local methods = { "isOnFloor", "isFallOnFront", "isCrawling", "isKnockedDown" }
        for i = 1, #methods do
            local method = zombie[methods[i]]
            if type(method) == "function" then
                local ok, result = pcall(method, zombie)
                if ok and result == true then
                    return false, "downed"
                end
            end
        end
    end

    return true, nil
end

function DTNPCProtect.StopCombatActions(zombie, npcData, reason)
    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.isMovingState = false
        npcData.combatBlockedReason = reason
    end

    resetCombatActionVariables(zombie)
    if zombie then
        if zombie.setTarget then
            zombie:setTarget(nil)
        end
        if zombie.setAttackedBy then
            zombie:setAttackedBy(nil)
        end
    end
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
end

function DTNPCProtect.CanApplyPlayerHitReaction(npcData, target)
    if not npcData or not target or not instanceof or not instanceof(target, "IsoPlayer") then
        return true
    end

    local currentTime = nowMillis()
    local cooldownMs = tonumber(DTNPCProtect.CONFIG.PlayerHitReactionCooldownMs) or 1600
    local lastAt = tonumber(npcData.lastPlayerHitReactionAt) or 0
    if currentTime > 0 and lastAt > 0 and (currentTime - lastAt) < cooldownMs then
        return false
    end

    npcData.lastPlayerHitReactionAt = currentTime
    return true
end

function DTNPCProtect.IsHostileChasePaused(npcData)
    if not npcData then
        return false
    end

    local pauseUntil = tonumber(npcData.hostileChaseCooldownUntil) or 0
    if pauseUntil <= 0 then
        return false
    end

    local currentTime = nowMillis()
    return currentTime > 0 and currentTime < pauseUntil
end

Internal.nowMillis = nowMillis
Internal.protectLog = protectLog
Internal.lower = lower
Internal.clamp = clamp
Internal.getScriptItem = getScriptItem
Internal.getConditionMax = getConditionMax
Internal.createConditionProbeItem = createConditionProbeItem
Internal.normalizeWeaponCondition = normalizeWeaponCondition
Internal.getZombieRuntimeID = getZombieRuntimeID
Internal.getPlayerRuntimeID = getPlayerRuntimeID
Internal.syncProtectNotice = syncProtectNotice
Internal.buildProtectDebugSummary = buildProtectDebugSummary
Internal.isPlayerOwnedTraderRaw = isPlayerOwnedTraderRaw
Internal.isFriendlyAuthorityPlayer = isFriendlyAuthorityPlayer
Internal.isWeaponDurabilitySandboxEnabled = isWeaponDurabilitySandboxEnabled
Internal.shouldConsumeWeaponDurabilityRaw = shouldConsumeWeaponDurabilityRaw

DTNPCProtect.GetPlayerRuntimeID = getPlayerRuntimeID
