-- ==============================================================================
-- DTNPC_Health_Shared.lua
-- Shared helpers and internal utilities for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function isRemoteClient()
    return isClient() and not isServer()
end

internal.isRemoteClient = isRemoteClient

local function isDedicatedServer()
    return isServer() and not isClient()
end

internal.isDedicatedServer = isDedicatedServer

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

internal.isLocalPlayerAttacker = isLocalPlayerAttacker

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

internal.reportWeaponHitToServer = reportWeaponHitToServer

local function clearDeferredSpawnRestore(combatHealth)
    if not combatHealth then
        return
    end

    combatHealth.deferredSpawnBufferTarget = nil
    combatHealth.deferredSpawnBufferUntil = nil
    combatHealth.deferredSpawnReason = nil
end

internal.clearDeferredSpawnRestore = clearDeferredSpawnRestore

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
    combatHealth.deferredSpawnBufferUntil = internal.nowMillis() + DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS
    combatHealth.deferredSpawnReason = tostring(reason or "spawn")
end

internal.scheduleDeferredSpawnRestore = scheduleDeferredSpawnRestore

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

internal.resolveSpawnHealthPlan = resolveSpawnHealthPlan

local function getBaseHPMultiplier()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.NPCBaseHealthMultiplier) or nil
    if configured and configured > 0 then
        return configured
    end

    return 1.0
end

internal.getBaseHPMultiplier = getBaseHPMultiplier

local function nowMillis()
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

internal.nowMillis = nowMillis

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

internal.clamp = clamp

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

internal.isPlayerOwnedNPC = isPlayerOwnedNPC

local function getLinkedWorkerCompanionBridge()
    local colony = rawget(_G, "DC_Colony")
    local companion = colony and colony.Companion or nil
    if type(companion) ~= "table" then
        return nil
    end
    return companion
end

internal.getLinkedWorkerCompanionBridge = getLinkedWorkerCompanionBridge

local function getLinkedWorkerHealthSnapshot(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.GetHealthSeed or not npcData or not npcData.linkedWorkerID then
        return nil
    end

    local registry = rawget(_G, "DC_Colony") and DC_Colony.Registry or nil
    local worker = registry and registry.GetWorkerRaw and registry.GetWorkerRaw(npcData.linkedWorkerID) or nil
    if not worker then
        return nil
    end

    return bridge.GetHealthSeed(worker)
end

internal.getLinkedWorkerHealthSnapshot = getLinkedWorkerHealthSnapshot

local function hasLinkedWorkerBandageSupply(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.ResolveBandageSupply or not npcData or not npcData.linkedWorkerID then
        return false
    end

    local registry = rawget(_G, "DC_Colony") and DC_Colony.Registry or nil
    local worker = registry and registry.GetWorkerRaw and registry.GetWorkerRaw(npcData.linkedWorkerID) or nil
    if not worker then
        return false
    end

    return bridge.ResolveBandageSupply(worker) ~= nil
end

internal.hasLinkedWorkerBandageSupply = hasLinkedWorkerBandageSupply

local function consumeLinkedWorkerBandageSupply(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.ConsumeBandageSupply or not npcData or not npcData.linkedWorkerID then
        return nil
    end

    return bridge.ConsumeBandageSupply(npcData.linkedWorkerID)
end

internal.consumeLinkedWorkerBandageSupply = consumeLinkedWorkerBandageSupply

local function syncLinkedWorkerHealth(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.SyncWorkerHealthFromNPC or not npcData or not npcData.linkedWorkerID then
        return false
    end

    return bridge.SyncWorkerHealthFromNPC(npcData.linkedWorkerID, npcData) == true
end

internal.syncLinkedWorkerHealth = syncLinkedWorkerHealth

local function handleLinkedWorkerIncapacitated(npcData)
    local bridge = getLinkedWorkerCompanionBridge()
    if not bridge or not bridge.HandleIncapacitatedNPC or not npcData or not npcData.linkedWorkerID then
        return false
    end

    return bridge.HandleIncapacitatedNPC(npcData) == true
end

internal.handleLinkedWorkerIncapacitated = handleLinkedWorkerIncapacitated

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

internal.isCombatState = isCombatState

local function isFollowerOrProtectorState(state)
    return state == "Follow"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
end

internal.isFollowerOrProtectorState = isFollowerOrProtectorState

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
        iconFullType = "Base.RippedSheets",
        totalHeal = 20,
        applyHeal = 2,
        regenPerTick = 1,
        regenIntervalMs = 2000,
    }
end

internal.getBandageTierDef = getBandageTierDef

local function getBandageItemFullType(npcData)
    if not npcData then
        return nil
    end

    local combatHealth = npcData.combatHealth
    if type(combatHealth) ~= "table" then
        return nil
    end

    local explicitFullType = tostring(combatHealth.bandageItemFullType or "")
    if explicitFullType ~= "" then
        return explicitFullType
    end

    local _, tierDef = getBandageTierDef(combatHealth.bandageTier)
    local fallbackFullType = tostring(tierDef and tierDef.iconFullType or "")
    if fallbackFullType ~= "" then
        return fallbackFullType
    end

    return "Base.Bandage"
end

internal.getBandageItemFullType = getBandageItemFullType

local function getRestingRegenMultiplier(npcData, combatHealth)
    local multiplier = tonumber(combatHealth and combatHealth.restingRegenMultiplier)
        or tonumber(npcData and npcData.restingRegenMultiplier)
        or tonumber(npcData and npcData.restingHealMultiplier)
        or tonumber(DTNPCHealth.DEFAULT_RESTING_REGEN_MULTIPLIER)
        or 1.0
    return math.max(0, multiplier)
end

internal.getRestingRegenMultiplier = getRestingRegenMultiplier

local function canUseRestingRegen(npcData, combatHealth)
    if not npcData or not combatHealth or combatHealth.enabled ~= true then
        return false
    end
    if npcData.incapState == "Active" or npcData.status ~= "Resting" then
        return false
    end
    if npcData.state == "Bandage" or combatHealth.activeBandage == true then
        return false
    end
    if isCombatState(npcData.state) then
        return false
    end
    if (tonumber(combatHealth.current) or 0) <= DTNPCHealth.MIN_DAMAGE
        or (tonumber(combatHealth.current) or 0) >= (tonumber(combatHealth.max) or 0) then
        return false
    end
    if getRestingRegenMultiplier(npcData, combatHealth) <= DTNPCHealth.MIN_DAMAGE then
        return false
    end
    return true
end

internal.canUseRestingRegen = canUseRestingRegen

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

internal.playEmitterSound = playEmitterSound

local function getDefaultBandageAnimVariantID()
    local variants = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {}
    return variants[1] and tostring(variants[1].id or "UpperBody") or "UpperBody"
end

internal.getDefaultBandageAnimVariantID = getDefaultBandageAnimVariantID

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

internal.getResolvedBandageAnimVariantID = getResolvedBandageAnimVariantID

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

internal.rollBandageAnimVariantID = rollBandageAnimVariantID

local function applyBandageAnimVariables(zombie, combatHealth)
    if not zombie or not combatHealth then
        return nil
    end

    local variantID = getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    combatHealth.bandageAnimVariant = variantID
    zombie:setVariable("DTBandageVariant", variantID)
    return variantID
end

internal.applyBandageAnimVariables = applyBandageAnimVariables

local function resetBandageAnimFinished(zombie)
    if not zombie then
        return
    end

    zombie:setVariable("DTBandageAnimFinished", false)
end

internal.resetBandageAnimFinished = resetBandageAnimFinished

local function isBandageAnimFinished(zombie)
    if not zombie then
        return false
    end

    if zombie.getVariableBoolean then
        return zombie:getVariableBoolean("DTBandageAnimFinished") == true
    end

    local value = zombie.getVariableString and zombie:getVariableString("DTBandageAnimFinished") or ""
    value = string.lower(tostring(value or ""))
    return value == "true" or value == "1"
end

internal.isBandageAnimFinished = isBandageAnimFinished

local function clearBandageAnimVariables(zombie)
    if not zombie then
        return
    end

    zombie:setVariable("DTBandageVariant", "")
    resetBandageAnimFinished(zombie)
end

internal.clearBandageAnimVariables = clearBandageAnimVariables

local function pushBandageAmbientCue(zombie, npcData)
    if not npcData or not DTNPCProtect or not DTNPCProtect.PushCompanionAmbientCue then
        return false
    end

    return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, "Default", "Bandage") == true
end

internal.pushBandageAmbientCue = pushBandageAmbientCue

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

internal.getActivePlayersForBandage = getActivePlayersForBandage

local function isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker)
    if attacker then
        return false
    end

    local spawnedAt = tonumber(combatHealth and combatHealth.spawnInitializedAt) or 0
    if spawnedAt <= 0 then
        return false
    end

    local ageMs = internal.nowMillis() - spawnedAt
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

internal.isLikelySpawnFallbackCollapse = isLikelySpawnFallbackCollapse

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

internal.syncHealth = syncHealth

function DTNPCHealth.RequestSync(zombie, npcData, fullSync)
    syncHealth(zombie, npcData, fullSync)
end

local function persistHealthSnapshot(npcData, forceManagerSave)
    if not npcData or isRemoteClient() then
        return
    end

    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    syncLinkedWorkerHealth(npcData)

    if not DTNPCManager or not DTNPCManager.Save then
        return
    end

    local now = internal.nowMillis()
    local lastPersistedAt = tonumber(combatHealth and combatHealth.lastPersistedAt) or 0
    if forceManagerSave == true or (now - lastPersistedAt) >= DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS then
        if combatHealth then
            combatHealth.lastPersistedAt = now
        end
        DTNPCManager.Save()
    end
end

internal.persistHealthSnapshot = persistHealthSnapshot

local function syncAndPersistHealth(zombie, npcData, fullSync, forceManagerSave)
    syncHealth(zombie, npcData, fullSync)
    persistHealthSnapshot(npcData, forceManagerSave)
end

internal.syncAndPersistHealth = syncAndPersistHealth

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

internal.isBandageVisibleOpportunity = isBandageVisibleOpportunity

local function clearActiveBandage(combatHealth, keepDirtyFlag)
    if not combatHealth then
        return
    end

    combatHealth.activeBandage = false
    combatHealth.bandageHealPool = 0
    combatHealth.bandageHealRemaining = 0
    combatHealth.lastBandageRegenAt = 0
    combatHealth.bandageAnimFallbackUntil = 0
    combatHealth.bandageAnimVariant = nil
    combatHealth.bandageItemFullType = nil
    combatHealth.bandageStatus = keepDirtyFlag and "Dirty" or "None"
    if keepDirtyFlag ~= true then
        combatHealth.bandageDirty = false
    end
end

internal.clearActiveBandage = clearActiveBandage

local function queueFallbackIgnore(combatHealth, amount)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return
    end

    combatHealth.pendingFallbackIgnoreAmount = math.max(0, tonumber(combatHealth.pendingFallbackIgnoreAmount) or 0) + amount
    combatHealth.pendingFallbackIgnoreUntil = internal.nowMillis() + DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS
end

internal.queueFallbackIgnore = queueFallbackIgnore

local function consumeFallbackIgnore(combatHealth, delta)
    local now = internal.nowMillis()
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

internal.consumeFallbackIgnore = consumeFallbackIgnore

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

local function isFriendlyFollowerOrProtectorHit(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return false
    end

    local state = tostring(npcData.state or "")
    local combatOrder = tostring(npcData.combatOrder or "")
    local shouldProtect = isFollowerOrProtectorState(state) or isFollowerOrProtectorState(combatOrder)
    if npcData.incapState == "Active" and isFollowerOrProtectorState(tostring(npcData.preIncapState or "")) then
        shouldProtect = true
    end
    if not shouldProtect then
        return false
    end

    local username = getPlayerUsername(attacker)
    if isPlayerMatchedToCompanion(npcData, attacker, username) then
        return true
    end

    if DTNPCProtect and DTNPCProtect.Internal and DTNPCProtect.Internal.isFriendlyAuthorityPlayer then
        local ok, isFriendlyAuthority = pcall(DTNPCProtect.Internal.isFriendlyAuthorityPlayer, npcData, attacker)
        if ok and isFriendlyAuthority == true then
            return true
        end
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

    if DTNPCProtect and DTNPCProtect.Internal and DTNPCProtect.Internal.isFriendlyAuthorityPlayer then
        local ok, isFriendlyAuthority = pcall(DTNPCProtect.Internal.isFriendlyAuthorityPlayer, npcData, attacker)
        if ok and isFriendlyAuthority == true then
            return
        end
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

internal.applyPlayerDamageReputationPenalty = applyPlayerDamageReputationPenalty

local function setIncapacitatedState(zombie, npcData)
    local incapacitatedAt = internal.nowMillis()

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.preIncapState = npcData.state
    npcData.state = "Incapacitated"
    npcData.incapState = "Active"
    npcData.preIncapStatus = npcData.status or "Resting"
    npcData.preIncapMaster = npcData.master
    npcData.preIncapMasterID = npcData.masterID
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
    npcData.isMovingState = false
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
    combatHealth.current = math.max(
        tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1,
        tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01
    )
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
    zombie:setVariable("bBecomeCrawler", false)
    zombie:setVariable("bCrawling", false)
    zombie:setVariable("FallOnFront", false)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("DTNPCMoveAnim", "")
    zombie:setVariable("DTNPCAnimSpeed", 0.0)
    zombie:setVariable("MovementSpeed", 0.0)
    zombie:setVariable("WalkSpeed", 0.0)
    zombie:setVariable("RunSpeed", 0.0)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("WalkType", "")
    zombie:setVariable("DTWalkType", "Crawl")
    clearBandageAnimVariables(zombie)
    zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
    zombie:resetModelNextFrame()

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end

    handleLinkedWorkerIncapacitated(npcData)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "NPC entered incapacitated state on existing body: " .. tostring(npcData.name or npcData.uuid or "Unknown")
    )
end

internal.setIncapacitatedState = setIncapacitatedState
