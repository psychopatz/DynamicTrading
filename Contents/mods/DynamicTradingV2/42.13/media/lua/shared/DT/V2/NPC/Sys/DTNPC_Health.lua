-- ==============================================================================
-- DTNPC_Health.lua
-- Authoritative custom health handling for DT NPCs.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}

DTNPCHealth.BASE_HP_BY_ARCHETYPE = DTNPCHealth.BASE_HP_BY_ARCHETYPE or {
    General = 120,
    Teacher = 110,
    Librarian = 110,
    Tailor = 115,
    Bartender = 120,
    Chef = 125,
    Doctor = 125,
    Angler = 130,
    Burglar = 130,
    Welder = 130,
    Mechanic = 135,
    Hiker = 135,
    Foreman = 140,
    Athlete = 145,
    Sheriff = 160,
    Survivalist = 170,
}

DTNPCHealth.DEFAULT_ENGINE_BUFFER = DTNPCHealth.DEFAULT_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_ENGINE_HEALTH = DTNPCHealth.INCAP_ENGINE_HEALTH or 2
DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_GRACE_WINDOW_MS = DTNPCHealth.INCAP_GRACE_WINDOW_MS or 1200
DTNPCHealth.MIN_DAMAGE = DTNPCHealth.MIN_DAMAGE or 0.01
DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS = DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS or 250
DTNPCHealth.NETWORK_SAFE_SPAWN_ENGINE_HEALTH = DTNPCHealth.NETWORK_SAFE_SPAWN_ENGINE_HEALTH or 2
DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS = DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS or 250
DTNPCHealth.SPAWN_FALLBACK_GUARD_MS = DTNPCHealth.SPAWN_FALLBACK_GUARD_MS or 12000
DTNPCHealth.PLAYER_REP_DAMAGE_THRESHOLD_RATIO = DTNPCHealth.PLAYER_REP_DAMAGE_THRESHOLD_RATIO or 0.25
DTNPCHealth.PLAYER_REP_DAMAGE_PENALTY = DTNPCHealth.PLAYER_REP_DAMAGE_PENALTY or -10
DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO = DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO or 0.66
DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS or 4000
DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES = DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES or 2
DTNPCHealth.SELF_BANDAGE_RETRY_DELAY_MS = DTNPCHealth.SELF_BANDAGE_RETRY_DELAY_MS or 15000
DTNPCHealth.SELF_BANDAGE_VISIBLE_RADIUS = DTNPCHealth.SELF_BANDAGE_VISIBLE_RADIUS or 18
DTNPCHealth.BANDAGE_IDLE_STATE = DTNPCHealth.BANDAGE_IDLE_STATE or "11"
DTNPCHealth.BANDAGE_SOUND = DTNPCHealth.BANDAGE_SOUND or "FirstAidApplyBandage"
DTNPCHealth.BANDAGE_ANIM_VARIANTS = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {
    { id = "UpperBody", weight = 3 },
    { id = "LeftArm", weight = 2 },
    { id = "RightArm", weight = 2 },
    { id = "LowerBody", weight = 1 },
    { id = "LeftLeg", weight = 1 },
    { id = "RightLeg", weight = 1 },
    { id = "Head", weight = 1 },
}
DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS = DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS or 2000
DTNPCHealth.DEFAULT_BANDAGE_TIER = DTNPCHealth.DEFAULT_BANDAGE_TIER or "clean_rag"
DTNPCHealth.BANDAGE_TIERS = DTNPCHealth.BANDAGE_TIERS or {
    clean_rag = {
        label = "Clean Rag",
        totalHeal = 20,
        applyHeal = 2,
        regenPerTick = 1,
        regenIntervalMs = 2000,
    },
    sterilized_rag = {
        label = "Sterilized Rag",
        totalHeal = 28,
        applyHeal = 3,
        regenPerTick = 1.5,
        regenIntervalMs = 2000,
    },
    bandage = {
        label = "Bandage",
        totalHeal = 36,
        applyHeal = 4,
        regenPerTick = 2,
        regenIntervalMs = 2000,
    },
}
DTNPCHealth.SELF_BANDAGE_TUNING_VERSION = DTNPCHealth.SELF_BANDAGE_TUNING_VERSION or 3

local nowMillis

local function isRemoteClient()
    return isClient() and not isServer()
end

local function isDedicatedServer()
    return isServer() and not isClient()
end

local function isLocalPlayerAttacker(attacker)
    if not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return false
    end

    if attacker.isLocalPlayer then
        local ok, result = pcall(attacker.isLocalPlayer, attacker)
        if ok and result == true then
            return true
        end
    end

    if attacker.getPlayerNum and getSpecificPlayer then
        local ok, playerNum = pcall(attacker.getPlayerNum, attacker)
        if ok and playerNum ~= nil and playerNum >= 0 then
            local localPlayer = getSpecificPlayer(playerNum)
            if localPlayer == attacker then
                return true
            end
        end
    end

    return false
end

local function reportWeaponHitToServer(attacker, target, weapon, damage)
    if not isRemoteClient() or not sendClientCommand then
        return false
    end
    if not isLocalPlayerAttacker(attacker) then
        return false
    end

    local modData = target and target.getModData and target:getModData() or nil
    local uuid = modData and modData.DTNPC_UUID or nil
    if not uuid then
        return false
    end

    sendClientCommand("DTNPC", "ReportWeaponHit", {
        uuid = uuid,
        bodyInstanceID = target.getPersistentOutfitID and target:getPersistentOutfitID() or nil,
        damage = tonumber(damage) or 0,
        attackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        weaponFullType = weapon and weapon.getFullType and weapon:getFullType() or nil,
        targetHealthAfterHit = target.getHealth and target:getHealth() or nil,
    })

    return true
end

local function clearDeferredSpawnRestore(combatHealth)
    if not combatHealth then
        return
    end

    combatHealth.deferredSpawnBufferTarget = nil
    combatHealth.deferredSpawnBufferUntil = nil
    combatHealth.deferredSpawnReason = nil
end

local function scheduleDeferredSpawnRestore(combatHealth, targetHealth, reason)
    if not combatHealth then
        return
    end

    local resolvedTarget = math.max(1, tonumber(targetHealth) or 0)
    if resolvedTarget <= 0 then
        clearDeferredSpawnRestore(combatHealth)
        return
    end

    combatHealth.deferredSpawnBufferTarget = resolvedTarget
    combatHealth.deferredSpawnBufferUntil = nowMillis() + DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS
    combatHealth.deferredSpawnReason = tostring(reason or "spawn")
end

local function resolveSpawnHealthPlan(npcData, combatHealth, options)
    options = type(options) == "table" and options or {}

    local desiredHealth
    local isIncapacitatedSpawn = npcData and npcData.incapState == "Active"
    if npcData and npcData.incapState == "Active" then
        desiredHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    else
        desiredHealth = math.max(1, tonumber(combatHealth and combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
    end

    local initialHealth = desiredHealth
    local deferRestore = false
    if options.deferNetworkSafeBuffer == true and not isIncapacitatedSpawn then
        initialHealth = math.min(
            desiredHealth,
            math.max(1, tonumber(options.networkSafeSpawnHealth) or DTNPCHealth.NETWORK_SAFE_SPAWN_ENGINE_HEALTH)
        )
        deferRestore = initialHealth < desiredHealth
    end

    return initialHealth, desiredHealth, deferRestore
end

local function getBaseHPMultiplier()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.NPCBaseHealthMultiplier) or nil
    if configured and configured > 0 then
        return configured
    end

    return 1.0
end

nowMillis = function()
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

local function isPlayerOwnedNPC(npcData)
    if not npcData then
        return false
    end

    if DTNPCProtect and DTNPCProtect.IsPlayerOwnedTrader then
        local ok, result = pcall(DTNPCProtect.IsPlayerOwnedTrader, npcData)
        if ok and result == true then
            return true
        end
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

local function isCombatState(state)
    return state == "Attack"
        or state == "AttackRange"
        or state == "Flee"
        or state == "TradingDefenseRanged"
        or state == "TradingDefenseMelee"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
        or state == "Incapacitated"
end

local function getBandageTierDef(tierID)
    local tiers = DTNPCHealth.BANDAGE_TIERS or {}
    local resolvedID = tostring(tierID or DTNPCHealth.DEFAULT_BANDAGE_TIER or "clean_rag")
    local tier = tiers[resolvedID]
    if tier then
        return resolvedID, tier
    end

    local fallbackID = tostring(DTNPCHealth.DEFAULT_BANDAGE_TIER or "clean_rag")
    tier = tiers[fallbackID]
    if tier then
        return fallbackID, tier
    end

    return "clean_rag", {
        label = "Clean Rag",
        totalHeal = 20,
        applyHeal = 2,
        regenPerTick = 1,
        regenIntervalMs = 2000,
    }
end

local function playEmitterSound(character, soundName)
    if not character or not soundName or soundName == "" then
        return false
    end

    local emitter = character.getEmitter and character:getEmitter() or nil
    if emitter and emitter.playSound then
        emitter:playSound(soundName)
        return true
    end

    return false
end

local function getDefaultBandageAnimVariantID()
    local variants = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {}
    return variants[1] and tostring(variants[1].id or "UpperBody") or "UpperBody"
end

local function getResolvedBandageAnimVariantID(variantID)
    local safeVariantID = tostring(variantID or "")
    local variants = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {}
    for i = 1, #variants do
        if safeVariantID == tostring(variants[i].id or "") then
            return safeVariantID
        end
    end

    return getDefaultBandageAnimVariantID()
end

local function rollBandageAnimVariantID()
    local variants = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {}
    local totalWeight = 0

    for i = 1, #variants do
        totalWeight = totalWeight + math.max(1, tonumber(variants[i].weight) or 1)
    end

    if totalWeight <= 0 then
        return getDefaultBandageAnimVariantID()
    end

    local roll = ZombRand(totalWeight)
    local cursor = 0
    for i = 1, #variants do
        local entry = variants[i]
        cursor = cursor + math.max(1, tonumber(entry.weight) or 1)
        if roll < cursor then
            return tostring(entry.id or getDefaultBandageAnimVariantID())
        end
    end

    return getDefaultBandageAnimVariantID()
end

local function applyBandageAnimVariables(zombie, combatHealth)
    if not zombie or not combatHealth then
        return nil
    end

    local variantID = getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    combatHealth.bandageAnimVariant = variantID
    zombie:setVariable("DTBandageVariant", variantID)
    return variantID
end

local function clearBandageAnimVariables(zombie)
    if not zombie then
        return
    end

    zombie:setVariable("DTBandageVariant", "")
end

local function pushBandageAmbientCue(zombie, npcData)
    if not npcData or not DTNPCProtect or not DTNPCProtect.PushCompanionAmbientCue then
        return false
    end

    return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, "Default", "Bandage") == true
end

local function getActivePlayersForBandage()
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

local function isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker)
    if attacker then
        return false
    end

    local spawnedAt = tonumber(combatHealth and combatHealth.spawnInitializedAt) or 0
    if spawnedAt <= 0 then
        return false
    end

    local ageMs = nowMillis() - spawnedAt
    if ageMs < 0 or ageMs > DTNPCHealth.SPAWN_FALLBACK_GUARD_MS then
        return false
    end

    local prev = tonumber(previousHealth) or 0
    local curr = tonumber(currentHealth) or 0
    if prev < 50 then
        return false
    end

    return curr <= DTNPCHealth.INCAP_ENGINE_HEALTH
end

local function getResolvedSkillLevelForHealth(npcData, skillID)
    if not npcData or not skillID then
        return 0
    end

    local internal = DTNPCProtect and DTNPCProtect.Internal or nil
    if internal and internal.getResolvedSkillLevel then
        local ok, value = pcall(internal.getResolvedSkillLevel, npcData, skillID)
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

local function syncHealth(zombie, npcData, fullSync)
    if not zombie or not npcData or not npcData.uuid then
        return
    end
    if not DTNPCServerCore then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return
    end

    if fullSync == true and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData, true)
    end
end

local function persistHealthSnapshot(npcData, forceManagerSave)
    if not npcData or isRemoteClient() then
        return
    end

    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end

    if not DTNPCManager or not DTNPCManager.Save then
        return
    end

    local now = nowMillis()
    local lastPersistedAt = tonumber(combatHealth and combatHealth.lastPersistedAt) or 0
    if forceManagerSave == true or (now - lastPersistedAt) >= DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS then
        if combatHealth then
            combatHealth.lastPersistedAt = now
        end
        DTNPCManager.Save()
    end
end

local function syncAndPersistHealth(zombie, npcData, fullSync, forceManagerSave)
    syncHealth(zombie, npcData, fullSync)
    persistHealthSnapshot(npcData, forceManagerSave)
end

local function isBandageVisibleOpportunity(zombie)
    if not zombie or zombie:isDead() then
        return false
    end

    if zombie.isOnScreen then
        local ok, visible = pcall(zombie.isOnScreen, zombie)
        if ok and visible == true then
            return true
        end
    end

    local players = getActivePlayersForBandage()
    if #players <= 0 then
        return not isDedicatedServer()
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ() or 0
    local visibleRadius = tonumber(DTNPCHealth.SELF_BANDAGE_VISIBLE_RADIUS) or 18
    local visibleRadiusSq = visibleRadius * visibleRadius

    for i = 1, #players do
        local player = players[i]
        if player and not player:isDead() and math.abs((player:getZ() or 0) - zz) <= 1 then
            local dx = player:getX() - zx
            local dy = player:getY() - zy
            local distSq = (dx * dx) + (dy * dy)
            if distSq <= visibleRadiusSq then
                return true
            end
        end
    end

    return false
end

local function startSelfBandage(zombie, npcData, resumeState, options)
    if not zombie or not npcData then
        return false
    end

    options = type(options) == "table" and options or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" or npcData.state == "Departure" then
        return false
    end

    local now = nowMillis()
    if options.ignoreRetry ~= true and (tonumber(combatHealth.bandageRetryAt) or 0) > now then
        return false
    end

    local resolvedResumeState = resumeState
    if resolvedResumeState == "Bandage" or resolvedResumeState == nil or resolvedResumeState == "" then
        resolvedResumeState = combatHealth.bandageResumeState or "Idle"
    end

    combatHealth.bandageResumeState = resolvedResumeState
    combatHealth.bandageActionUntil = options.immediate == true
        and 0
        or (now + math.max(0, tonumber(combatHealth.selfBandageApplyDurationMs) or 0))
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageAnimVariant = rollBandageAnimVariantID()
    combatHealth.bandageDirty = false
    combatHealth.bandageStatus = combatHealth.bandageActionUntil > now and "Applying" or "Ready"
    applyBandageAnimVariables(zombie, combatHealth)
    playEmitterSound(zombie, DTNPCHealth.BANDAGE_SOUND)
    npcData.state = "Bandage"
    pushBandageAmbientCue(zombie, npcData)
    syncAndPersistHealth(zombie, npcData, false, false)
    return true
end

local function clearActiveBandage(combatHealth, keepDirtyFlag)
    if not combatHealth then
        return
    end

    combatHealth.activeBandage = false
    combatHealth.bandageHealPool = 0
    combatHealth.bandageHealRemaining = 0
    combatHealth.lastBandageRegenAt = 0
    combatHealth.bandageAnimVariant = nil
    combatHealth.bandageStatus = keepDirtyFlag and "Dirty" or "None"
    if keepDirtyFlag ~= true then
        combatHealth.bandageDirty = false
    end
end

local function queueFallbackIgnore(combatHealth, amount)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return
    end

    combatHealth.pendingFallbackIgnoreAmount = math.max(0, tonumber(combatHealth.pendingFallbackIgnoreAmount) or 0) + amount
    combatHealth.pendingFallbackIgnoreUntil = nowMillis() + DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS
end

local function consumeFallbackIgnore(combatHealth, delta)
    local now = nowMillis()
    local ignoreAmount = math.max(0, tonumber(combatHealth.pendingFallbackIgnoreAmount) or 0)
    local ignoreUntil = tonumber(combatHealth.pendingFallbackIgnoreUntil) or 0
    if ignoreAmount <= 0 or now > ignoreUntil then
        combatHealth.pendingFallbackIgnoreAmount = 0
        combatHealth.pendingFallbackIgnoreUntil = 0
        return delta
    end

    local consumed = math.min(ignoreAmount, math.max(0, tonumber(delta) or 0))
    combatHealth.pendingFallbackIgnoreAmount = ignoreAmount - consumed
    if combatHealth.pendingFallbackIgnoreAmount <= DTNPCHealth.MIN_DAMAGE then
        combatHealth.pendingFallbackIgnoreAmount = 0
        combatHealth.pendingFallbackIgnoreUntil = 0
    end

    return math.max(0, delta - consumed)
end

local function capturePlayerAttacker(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return
    end

    npcData.lastPlayerAttackerUsername = attacker.getUsername and attacker:getUsername() or nil
    npcData.lastPlayerAttackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil
    npcData.lastPlayerAttackedAt = nowMillis()
end

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
        if DynamicTrading_Factions.ModifyReputation(factionID, username, delta) then
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

local function setIncapacitatedState(zombie, npcData)
    local incapacitatedAt = nowMillis()

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.state = "Incapacitated"
    npcData.incapState = "Active"
    npcData.preIncapStatus = npcData.status or "Resting"
    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = nil
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.combatOrder = nil
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.combatResumeState = nil
    npcData.autoProtectActiveState = nil
    npcData.combatPursuitTargetID = nil
    npcData.combatPursuitStartedAt = 0
    npcData.combatPursuitLastProgressAt = 0
    npcData.combatPursuitLastAttackAt = 0
    npcData.combatPursuitLastDistance = nil
    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    combatHealth.enabled = false
    combatHealth.engineProtected = true
    combatHealth.current = 0
    combatHealth.lastDamageAt = incapacitatedAt
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.incapGraceUntil = incapacitatedAt + DTNPCHealth.INCAP_GRACE_WINDOW_MS
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    clearActiveBandage(combatHealth, false)
    combatHealth.bandageActionUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil
    npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastCustomDamageHandledAt = combatHealth.lastDamageAt

    zombie:setTarget(nil)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setRunning(false)
    zombie:setVariable("bBecomeCrawler", true)
    zombie:setVariable("bCrawling", true)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("WalkType", "2")
    zombie:setVariable("DTWalkType", "Crawl")
    clearBandageAnimVariables(zombie)
    zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "NPC entered incapacitated state on existing body: " .. tostring(npcData.name or npcData.uuid or "Unknown")
    )
end

function DTNPCHealth.ComputeMaxHP(npcData)
    local archetypeID = tostring(npcData and npcData.archetypeID or "General")
    local baseTemplate = tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE[archetypeID]) or tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE.General) or 120
    local baseMax = math.max(1, math.floor((baseTemplate * getBaseHPMultiplier()) + 0.5))
    local melee = getResolvedSkillLevelForHealth(npcData, "Melee")
    local shooting = getResolvedSkillLevelForHealth(npcData, "Shooting")
    local maintenance = getResolvedSkillLevelForHealth(npcData, "Maintenance")
    local skillBonus = math.min(50, math.floor((melee * 2) + (shooting * 2) + maintenance))
    local maxHealth = math.max(1, math.floor(baseMax + skillBonus))
    return baseMax, skillBonus, maxHealth
end

function DTNPCHealth.EnsureDefaults(npcData)
    if not npcData then
        return nil
    end

    if type(npcData.combatHealth) ~= "table" then
        npcData.combatHealth = {}
    end
    if npcData._dtHealthDefaultsActive then
        return npcData.combatHealth
    end
    npcData._dtHealthDefaultsActive = true

    local combatHealth = npcData.combatHealth
    local baseMax, skillBonus, maxHealth = DTNPCHealth.ComputeMaxHP(npcData)

    if combatHealth.enabled == nil then combatHealth.enabled = npcData.incapState ~= "Active" end
    if combatHealth.engineProtected == nil then combatHealth.engineProtected = combatHealth.enabled == true end
    if combatHealth.baseMax == nil then combatHealth.baseMax = baseMax end
    if combatHealth.skillBonus == nil then combatHealth.skillBonus = skillBonus end
    if combatHealth.max == nil then combatHealth.max = maxHealth end
    if combatHealth.current == nil then
        combatHealth.current = npcData.incapState == "Active" and 0 or combatHealth.max
    end
    if combatHealth.eventDrivenOnly == nil then combatHealth.eventDrivenOnly = true end
    if combatHealth.invulnerableBody == nil then combatHealth.invulnerableBody = true end
    if combatHealth.engineBuffer == nil then combatHealth.engineBuffer = DTNPCHealth.DEFAULT_ENGINE_BUFFER end
    if combatHealth.zeroHpMode == nil then combatHealth.zeroHpMode = "Incapacitated" end
    if combatHealth.lastEngineHealth == nil then
        combatHealth.lastEngineHealth = combatHealth.enabled and combatHealth.engineBuffer or DTNPCHealth.INCAP_ENGINE_HEALTH
    end
    if combatHealth.lastDamageAt == nil then combatHealth.lastDamageAt = 0 end
    if combatHealth.lastDamageAmount == nil then combatHealth.lastDamageAmount = 0 end
    if combatHealth.lastAttackerType == nil then combatHealth.lastAttackerType = nil end
    if combatHealth.lastAttackerID == nil then combatHealth.lastAttackerID = nil end
    if type(combatHealth.playerReputationDamage) ~= "table" then combatHealth.playerReputationDamage = {} end
    if combatHealth.pendingFallbackIgnoreAmount == nil then combatHealth.pendingFallbackIgnoreAmount = 0 end
    if combatHealth.pendingFallbackIgnoreUntil == nil then combatHealth.pendingFallbackIgnoreUntil = 0 end
    if combatHealth.incapGraceUntil == nil then combatHealth.incapGraceUntil = 0 end
    if combatHealth.selfBandageThreshold == nil then combatHealth.selfBandageThreshold = DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO end
    if combatHealth.selfBandageApplyDurationMs == nil then combatHealth.selfBandageApplyDurationMs = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS end
    if combatHealth.bandageUnlimited == nil then combatHealth.bandageUnlimited = not isPlayerOwnedNPC(npcData) end
    if combatHealth.bandageCharges == nil and combatHealth.bandageUnlimited ~= true then
        combatHealth.bandageCharges = DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES
    end
    local tierID, tierDef = getBandageTierDef(combatHealth.bandageTier)
    if combatHealth.bandageTier == nil then combatHealth.bandageTier = tierID end
    if combatHealth.bandageActionUntil == nil then combatHealth.bandageActionUntil = 0 end
    if combatHealth.bandageRetryAt == nil then combatHealth.bandageRetryAt = 0 end
    if combatHealth.bandageHealPool == nil then combatHealth.bandageHealPool = 0 end
    if combatHealth.bandageHealRemaining == nil then combatHealth.bandageHealRemaining = 0 end
    if combatHealth.lastBandageRegenAt == nil then combatHealth.lastBandageRegenAt = 0 end
    if combatHealth.bandageDirty == nil then combatHealth.bandageDirty = false end
    if combatHealth.activeBandage == nil then combatHealth.activeBandage = false end
    if combatHealth.bandageStatus == nil then combatHealth.bandageStatus = "None" end
    if combatHealth.bandageResumeState == nil then combatHealth.bandageResumeState = nil end
    if combatHealth.bandageAnimVariant ~= nil then
        combatHealth.bandageAnimVariant = getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    end
    if combatHealth.lastPersistedAt == nil then combatHealth.lastPersistedAt = 0 end
    if combatHealth.bandageTuningVersion == nil then combatHealth.bandageTuningVersion = 0 end

    if tonumber(combatHealth.bandageTuningVersion) < DTNPCHealth.SELF_BANDAGE_TUNING_VERSION then
        combatHealth.selfBandageApplyDurationMs = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS
        combatHealth.bandageTier = tierID
        combatHealth.bandageHealPool = combatHealth.activeBandage == true and math.max(0, tonumber(tierDef.totalHeal) or 0) or 0
        combatHealth.bandageHealRemaining = combatHealth.activeBandage == true and math.max(0, tonumber(tierDef.totalHeal) or 0) or 0
        combatHealth.lastBandageRegenAt = 0
        combatHealth.bandageTuningVersion = DTNPCHealth.SELF_BANDAGE_TUNING_VERSION
    end

    tierID, tierDef = getBandageTierDef(combatHealth.bandageTier)
    combatHealth.bandageTier = tierID
    if combatHealth.activeBandage ~= true then
        combatHealth.bandageHealPool = 0
        combatHealth.bandageHealRemaining = 0
    elseif (tonumber(combatHealth.bandageHealPool) or 0) <= 0 then
        combatHealth.bandageHealPool = math.max(0, tonumber(tierDef.totalHeal) or 0)
        combatHealth.bandageHealRemaining = math.max(0, tonumber(combatHealth.bandageHealPool) or 0)
    else
        combatHealth.bandageHealRemaining = clamp(
            tonumber(combatHealth.bandageHealRemaining) or combatHealth.bandageHealPool,
            0,
            math.max(0, tonumber(combatHealth.bandageHealPool) or 0)
        )
    end

    combatHealth.baseMax = baseMax
    combatHealth.skillBonus = skillBonus
    combatHealth.max = maxHealth
    if npcData.incapState == "Active" then
        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = 0
        clearActiveBandage(combatHealth, false)
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageRetryAt = 0
        combatHealth.bandageResumeState = nil
        combatHealth.bandageAnimVariant = nil
    else
        combatHealth.current = clamp(combatHealth.current, 0, combatHealth.max)
        combatHealth.incapGraceUntil = 0
    end

    npcData._dtHealthDefaultsActive = nil
    return combatHealth
end

function DTNPCHealth.IsCustomHealthEnabled(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and combatHealth.enabled == true
end

function DTNPCHealth.IsEventDrivenOnly(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and combatHealth.eventDrivenOnly == true
end

function DTNPCHealth.GetCurrentHP(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and tonumber(combatHealth.current) or nil
end

function DTNPCHealth.GetMaxHP(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and tonumber(combatHealth.max) or nil
end

function DTNPCHealth.GetHealthRatio(npcData)
    local current = DTNPCHealth.GetCurrentHP(npcData)
    local maxHealth = DTNPCHealth.GetMaxHP(npcData)
    if not current or not maxHealth or maxHealth <= 0 then
        return 1
    end

    return clamp(current / maxHealth, 0, 1)
end

function DTNPCHealth.IsCombatState(state)
    return isCombatState(state)
end

function DTNPCHealth.HasUsableBandageSupply(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    if combatHealth.bandageUnlimited == true then
        return true
    end

    return math.max(0, tonumber(combatHealth.bandageCharges) or 0) > 0
end

function DTNPCHealth.HasActiveBandage(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    return combatHealth.activeBandage == true
        and combatHealth.bandageDirty ~= true
        and (tonumber(combatHealth.bandageHealRemaining) or 0) > DTNPCHealth.MIN_DAMAGE
end

function DTNPCHealth.ApplyBandageVisualState(zombie, npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return nil
    end

    if combatHealth.bandageAnimVariant == nil or combatHealth.bandageAnimVariant == "" then
        combatHealth.bandageAnimVariant = rollBandageAnimVariantID()
    else
        combatHealth.bandageAnimVariant = getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    end

    if zombie then
        zombie:setVariable("DTIdleState", tostring(DTNPCHealth.BANDAGE_IDLE_STATE or "11"))
        applyBandageAnimVariables(zombie, combatHealth)
    end

    return combatHealth.bandageAnimVariant
end

function DTNPCHealth.IsBandageVisibleOpportunity(zombie)
    return isBandageVisibleOpportunity(zombie)
end

function DTNPCHealth.GetBandageDebugInfo(zombie, npcData)
    if not npcData then
        return nil
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return nil
    end

    return {
        state = npcData.state or "Idle",
        status = combatHealth.bandageStatus or "None",
        activeBandage = combatHealth.activeBandage == true,
        bandageDirty = combatHealth.bandageDirty == true,
        bandageTier = combatHealth.bandageTier or DTNPCHealth.DEFAULT_BANDAGE_TIER,
        bandageTierLabel = select(2, getBandageTierDef(combatHealth.bandageTier)).label,
        bandageHealPool = tonumber(combatHealth.bandageHealPool) or 0,
        bandageHealRemaining = tonumber(combatHealth.bandageHealRemaining) or 0,
        current = tonumber(combatHealth.current) or 0,
        max = tonumber(combatHealth.max) or 0,
        ratio = DTNPCHealth.GetHealthRatio(npcData),
        threshold = tonumber(combatHealth.selfBandageThreshold) or DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO,
        visible = isBandageVisibleOpportunity(zombie),
        hasSupply = DTNPCHealth.HasUsableBandageSupply(npcData),
        bandageUnlimited = combatHealth.bandageUnlimited == true,
        bandageCharges = tonumber(combatHealth.bandageCharges) or 0,
        retryAt = tonumber(combatHealth.bandageRetryAt) or 0,
        actionUntil = tonumber(combatHealth.bandageActionUntil) or 0,
        animVariant = combatHealth.bandageAnimVariant or getDefaultBandageAnimVariantID(),
    }
end

function DTNPCHealth.ForceEnterSelfBandage(zombie, npcData, resumeState)
    return startSelfBandage(zombie, npcData, resumeState, {
        ignoreRetry = true,
        immediate = false,
    })
end

function DTNPCHealth.RequestSync(zombie, npcData, fullSync)
    syncHealth(zombie, npcData, fullSync)
end

function DTNPCHealth.ProcessPassiveBandageRegen(zombie, npcData)
    if not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false
    end

    if combatHealth.activeBandage ~= true then
        return false
    end

    local healRemaining = math.max(0, tonumber(combatHealth.bandageHealRemaining) or 0)
    if healRemaining <= DTNPCHealth.MIN_DAMAGE then
        clearActiveBandage(combatHealth, true)
        syncAndPersistHealth(zombie, npcData, false, false)
        return false
    end

    local now = nowMillis()
    if combatHealth.bandageDirty == true then
        combatHealth.lastBandageRegenAt = now
        return false
    end

    if combatHealth.current >= combatHealth.max then
        combatHealth.lastBandageRegenAt = now
        return false
    end

    local _, tierDef = getBandageTierDef(combatHealth.bandageTier)
    local lastRegenAt = tonumber(combatHealth.lastBandageRegenAt) or 0
    if lastRegenAt <= 0 then
        combatHealth.lastBandageRegenAt = now
        return false
    end

    local intervalMs = math.max(250, tonumber(tierDef.regenIntervalMs) or 2000)
    local elapsedMs = math.max(0, now - lastRegenAt)
    local elapsedSteps = math.floor(elapsedMs / intervalMs)
    if elapsedSteps <= 0 then
        return false
    end

    local currentBefore = tonumber(combatHealth.current) or 0
    local missingHealth = math.max(0, (tonumber(combatHealth.max) or 0) - currentBefore)
    local healBudget = elapsedSteps * math.max(0, tonumber(tierDef.regenPerTick) or 0)
    local healAmount = math.min(healBudget, missingHealth, healRemaining)
    combatHealth.current = clamp(currentBefore + healAmount, 0, combatHealth.max)
    combatHealth.bandageHealRemaining = math.max(0, healRemaining - healAmount)
    combatHealth.lastBandageRegenAt = lastRegenAt + (elapsedSteps * intervalMs)
    if combatHealth.bandageHealRemaining <= DTNPCHealth.MIN_DAMAGE then
        clearActiveBandage(combatHealth, true)
    end
    if healAmount <= DTNPCHealth.MIN_DAMAGE and combatHealth.bandageDirty ~= true then
        return false
    end

    syncAndPersistHealth(zombie, npcData, false, false)
    return true
end

function DTNPCHealth.ShouldSelfBandage(npcData)
    if not npcData or npcData.incapState == "Active" then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false
    end

    if combatHealth.current <= 0 or combatHealth.current >= combatHealth.max then
        return false
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return false
    end

    if (tonumber(combatHealth.bandageActionUntil) or 0) > nowMillis() then
        return true
    end

    if not DTNPCHealth.HasUsableBandageSupply(npcData) then
        return false
    end

    return DTNPCHealth.GetHealthRatio(npcData) <= (tonumber(combatHealth.selfBandageThreshold) or DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO)
end

function DTNPCHealth.TryEnterSelfBandage(zombie, npcData, currentState)
    if not zombie or not npcData or npcData.state == "Bandage" then
        return false
    end

    local state = currentState or npcData.state or "Idle"
    if isCombatState(state) or state == "Departure" then
        return false
    end

    if not DTNPCHealth.ShouldSelfBandage(npcData) then
        return false
    end

    if not isBandageVisibleOpportunity(zombie) then
        return false
    end

    return startSelfBandage(zombie, npcData, state)
end

function DTNPCHealth.ProcessSelfBandageAction(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return "blocked"
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return "blocked"
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return "applied"
    end

    local now = nowMillis()
    if (tonumber(combatHealth.bandageActionUntil) or 0) > now then
        combatHealth.bandageStatus = "Applying"
        return "applying"
    end

    if not DTNPCHealth.HasUsableBandageSupply(npcData) then
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageStatus = "None"
        combatHealth.bandageDirty = false
        return "blocked"
    end

    if combatHealth.bandageUnlimited ~= true then
        combatHealth.bandageCharges = math.max(0, (tonumber(combatHealth.bandageCharges) or 0) - 1)
    end

    local _, tierDef = getBandageTierDef(combatHealth.bandageTier)
    local bandageHealPool = math.max(0, tonumber(tierDef.totalHeal) or 0)
    local applyHeal = math.min(bandageHealPool, math.max(0, tonumber(tierDef.applyHeal) or 0))
    local currentHealth = tonumber(combatHealth.current) or 0
    local missingHealth = math.max(0, (tonumber(combatHealth.max) or 0) - currentHealth)
    local immediateHeal = math.min(applyHeal, missingHealth)

    combatHealth.bandageActionUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.activeBandage = true
    combatHealth.bandageDirty = false
    combatHealth.bandageStatus = "Clean"
    combatHealth.bandageHealPool = bandageHealPool
    combatHealth.bandageHealRemaining = math.max(0, bandageHealPool - immediateHeal)
    combatHealth.lastBandageRegenAt = now
    combatHealth.current = clamp(
        currentHealth + immediateHeal,
        0,
        combatHealth.max
    )
    if combatHealth.bandageHealRemaining <= DTNPCHealth.MIN_DAMAGE then
        clearActiveBandage(combatHealth, true)
    end
    syncAndPersistHealth(zombie, npcData, false, true)
    return "applied"
end

function DTNPCHealth.ExitSelfBandage(zombie, npcData, resumeOverride)
    if not npcData then
        return
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return
    end

    local nextState = resumeOverride or combatHealth.bandageResumeState or "Idle"
    if nextState == "Bandage" then
        nextState = "Idle"
    end

    combatHealth.bandageActionUntil = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil
    clearBandageAnimVariables(zombie)
    if npcData.state == "Bandage" then
        npcData.state = nextState
        syncAndPersistHealth(zombie, npcData, false, false)
    end
end

function DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true or combatHealth.engineProtected ~= true then
        return false
    end

    local engineBuffer = math.max(1, tonumber(combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
    zombie:setHealth(engineBuffer)
    combatHealth.lastEngineHealth = engineBuffer
    npcData.health = engineBuffer
    npcData.lastHealth = engineBuffer
    clearDeferredSpawnRestore(combatHealth)
    return true
end

function DTNPCHealth.ProcessDeferredSpawnRestore(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    local targetHealth = tonumber(combatHealth.deferredSpawnBufferTarget) or 0
    local restoreAt = tonumber(combatHealth.deferredSpawnBufferUntil) or 0
    if targetHealth <= 0 or nowMillis() < restoreAt then
        return false
    end

    zombie:setHealth(targetHealth)
    combatHealth.lastEngineHealth = targetHealth
    npcData.health = targetHealth
    npcData.lastHealth = targetHealth

    local restoreReason = combatHealth.deferredSpawnReason
    clearDeferredSpawnRestore(combatHealth)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "Deferred engine-buffer restore applied for "
            .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " reason=" .. tostring(restoreReason or "spawn")
            .. " targetHealth=" .. tostring(targetHealth)
    )

    return true
end

function DTNPCHealth.InitializeForSpawn(zombie, npcData, options)
    if not npcData then
        return nil
    end

    options = type(options) == "table" and options or {}
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    local resetCurrent = options.resetCurrent == true
    local spawnReason = tostring(options.spawnReason or "spawn")
    combatHealth.lastDamageAt = 0
    combatHealth.lastDamageAmount = 0
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.spawnInitializedAt = nowMillis()
    combatHealth.spawnReason = spawnReason

    local initialEngineHealth, desiredEngineHealth, deferRestore = resolveSpawnHealthPlan(npcData, combatHealth, options)

    if npcData.incapState == "Active" then
        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = 0
        combatHealth.incapGraceUntil = nowMillis() + DTNPCHealth.INCAP_GRACE_WINDOW_MS
        combatHealth.lastEngineHealth = initialEngineHealth
        if deferRestore then
            scheduleDeferredSpawnRestore(combatHealth, desiredEngineHealth, spawnReason .. "_incap")
        else
            clearDeferredSpawnRestore(combatHealth)
        end
        if zombie then
            zombie:setHealth(initialEngineHealth)
        end
        npcData.health = initialEngineHealth
        npcData.lastHealth = initialEngineHealth
        npcData.lastCustomDamageHandledAt = 0
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "InitializeForSpawn incap name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " reason=" .. spawnReason
                .. " initialEngineHealth=" .. tostring(initialEngineHealth)
                .. " desiredEngineHealth=" .. tostring(desiredEngineHealth)
                .. " deferred=" .. tostring(deferRestore)
                .. " graceUntil=" .. tostring(combatHealth.incapGraceUntil)
                .. " incapState=" .. tostring(npcData.incapState)
        )
        return combatHealth
    end

    combatHealth.enabled = true
    combatHealth.engineProtected = true
    if resetCurrent then
        combatHealth.current = combatHealth.max
    else
        combatHealth.current = clamp(combatHealth.current, 0, combatHealth.max)
    end

    if zombie and deferRestore then
        zombie:setHealth(initialEngineHealth)
        combatHealth.lastEngineHealth = initialEngineHealth
        npcData.health = initialEngineHealth
        npcData.lastHealth = initialEngineHealth
        scheduleDeferredSpawnRestore(combatHealth, desiredEngineHealth, spawnReason)
    elseif zombie then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        npcData.lastHealth = zombie:getHealth()
    else
        combatHealth.lastEngineHealth = combatHealth.engineBuffer
        npcData.health = combatHealth.engineBuffer
        npcData.lastHealth = combatHealth.engineBuffer
        clearDeferredSpawnRestore(combatHealth)
    end
    npcData.lastCustomDamageHandledAt = 0

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "InitializeForSpawn name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " reason=" .. spawnReason
            .. " resetCurrent=" .. tostring(resetCurrent)
            .. " customCurrent=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " initialEngineHealth=" .. tostring(initialEngineHealth)
            .. " desiredEngineHealth=" .. tostring(desiredEngineHealth)
            .. " deferred=" .. tostring(deferRestore)
    )

    return combatHealth
end

function DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    if not zombie or not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.zeroHpMode ~= "Incapacitated" then
        return false
    end

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "HandleZeroHP name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " attackerType=" .. tostring(getAttackerType(attacker))
            .. " attackerID=" .. tostring(getAttackerID(attacker))
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
    )

    capturePlayerAttacker(npcData, attacker)
    setIncapacitatedState(zombie, npcData)
    syncHealth(zombie, npcData, true)
    return true
end

function DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false, false
    end

    local currentTime = nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    capturePlayerAttacker(npcData, attacker)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "HandleIncapacitatedDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " amount=" .. tostring(amount)
            .. " attackerType=" .. tostring(getAttackerType(attacker))
            .. " attackerID=" .. tostring(getAttackerID(attacker))
            .. " currentTime=" .. tostring(currentTime)
            .. " graceUntil=" .. tostring(graceUntil)
    )

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
        combatHealth.lastAttackerType = getAttackerType(attacker)
        combatHealth.lastAttackerID = getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        syncAndPersistHealth(zombie, npcData, false, true)
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.incapGraceUntil = 0
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = getAttackerType(attacker)
    combatHealth.lastAttackerID = getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = DTNPCHealth.INCAP_ENGINE_HEALTH
    npcData.lastHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    zombie:setHealth(DTNPCHealth.INCAP_ENGINE_HEALTH)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
        return true, true
    end

    return false, false
end

function DTNPCHealth.ApplyDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or isRemoteClient() then
        return false, false
    end

    if npcData.incapState == "Active" then
        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false, false
    end

    context = type(context) == "table" and context or {}
    local damage = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    local now = nowMillis()

    capturePlayerAttacker(npcData, attacker)

    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastAttackerType = getAttackerType(attacker)
    combatHealth.lastAttackerID = getAttackerID(attacker)

    if context.queueFallbackIgnore ~= false then
        queueFallbackIgnore(combatHealth, damage)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ApplyDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " damage=" .. tostring(damage)
            .. " attackerType=" .. tostring(getAttackerType(attacker))
            .. " attackerID=" .. tostring(getAttackerID(attacker))
            .. " customBefore=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " engineHealth=" .. tostring(zombie:getHealth())
    )

    local currentBefore = clamp(tonumber(combatHealth.current) or combatHealth.max, 0, combatHealth.max)
    local appliedDamage = math.min(damage, currentBefore)
    combatHealth.current = clamp(currentBefore - damage, 0, combatHealth.max)

    applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    if combatHealth.current <= 0 then
        local handled = DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
        return handled, handled
    end

    DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    syncAndPersistHealth(zombie, npcData, false, true)
    return true, false
end

function DTNPCHealth.ProcessFallbackDamage(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return false, false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if combatHealth and combatHealth.eventDrivenOnly == true then
        combatHealth.lastEngineHealth = zombie:getHealth()
        npcData.health = zombie:getHealth()
        return false, false
    end

    if npcData.incapState == "Active" then
        local currentHealth = tonumber(zombie:getHealth()) or 0
        local previousHealth = tonumber(combatHealth and combatHealth.lastEngineHealth) or currentHealth
        local healthDelta = math.max(0, previousHealth - currentHealth)

        if healthDelta <= 0 then
            if combatHealth then
                combatHealth.lastEngineHealth = currentHealth
            end
            npcData.health = currentHealth
            return false, false
        end

        if isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, zombie:getAttackedBy()) then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "Ignored suspicious incapacitated spawn fallback collapse for "
                    .. tostring(npcData.name or npcData.uuid or "Unknown")
                    .. " uuid=" .. tostring(npcData.uuid)
                    .. " previousHealth=" .. tostring(previousHealth)
                    .. " currentHealth=" .. tostring(currentHealth)
                    .. " spawnAgeMs=" .. tostring(nowMillis() - (tonumber(combatHealth.spawnInitializedAt) or 0))
            )
            zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
            combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            return false, false
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Health",
            "ProcessFallbackDamage incap name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " delta=" .. tostring(healthDelta)
                .. " attackerType=" .. tostring(getAttackerType(zombie:getAttackedBy()))
                .. " attackerID=" .. tostring(getAttackerID(zombie:getAttackedBy()))
        )

        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
            source = "incap_engine_fallback",
            queueFallbackIgnore = false,
        })
    end

    if not combatHealth or combatHealth.enabled ~= true or combatHealth.engineProtected ~= true then
        if combatHealth then
            combatHealth.lastEngineHealth = zombie:getHealth()
        end
        npcData.health = zombie:getHealth()
        return false, false
    end

    local currentHealth = tonumber(zombie:getHealth()) or 0
    local previousHealth = tonumber(combatHealth.lastEngineHealth) or currentHealth
    local healthDelta = math.max(0, previousHealth - currentHealth)
    if healthDelta <= 0 then
        combatHealth.lastEngineHealth = currentHealth
        npcData.health = currentHealth
        return false, false
    end

    if isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, zombie:getAttackedBy()) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Ignored suspicious spawn fallback collapse for "
                .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " spawnAgeMs=" .. tostring(nowMillis() - (tonumber(combatHealth.spawnInitializedAt) or 0))
        )
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    healthDelta = consumeFallbackIgnore(combatHealth, healthDelta)
    if healthDelta <= DTNPCHealth.MIN_DAMAGE then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ProcessFallbackDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " previousHealth=" .. tostring(previousHealth)
            .. " currentHealth=" .. tostring(currentHealth)
            .. " delta=" .. tostring(healthDelta)
            .. " attackerType=" .. tostring(getAttackerType(zombie:getAttackedBy()))
            .. " attackerID=" .. tostring(getAttackerID(zombie:getAttackedBy()))
    )

    return DTNPCHealth.ApplyDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
        source = "engine_fallback",
        queueFallbackIgnore = false,
    })
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not target then
        return
    end
    if not instanceof or not instanceof(target, "IsoZombie") then
        return
    end

    local modData = target:getModData()
    if not modData or not modData.IsDTNPC then
        return
    end

    local npcData = (DTNPC and DTNPC.GetData and DTNPC.GetData(target)) or modData.DTNPC_Data or modData.DTNPCBrain
    if not npcData then
        return
    end

    if isRemoteClient() then
        reportWeaponHitToServer(attacker, target, weapon, damage)
        return
    end

    -- Dedicated MP server should trust the hit-owning client report for player weapon hits,
    -- matching the Bandits pattern of client-side hit ownership plus server fan-out sync.
    if isDedicatedServer() and attacker and instanceof and instanceof(attacker, "IsoPlayer") then
        return
    end

    DTNPCHealth.ApplyDamage(target, npcData, damage, attacker, {
        source = "weapon_hit_event",
        weapon = weapon,
    })
end

if Events and Events.OnWeaponHitCharacter and not DTNPCHealth.WeaponHitHookRegistered then
    Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
    DTNPCHealth.WeaponHitHookRegistered = true
end
