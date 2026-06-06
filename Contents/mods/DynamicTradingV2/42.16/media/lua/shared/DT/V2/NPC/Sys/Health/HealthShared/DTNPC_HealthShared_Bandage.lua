-- ==============================================================================
-- DTNPC_HealthShared_Bandage.lua
-- Shared bandage, visibility, and resting regen helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
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
        label = T("DTNPC_UI_CleanRag", nil, "Clean Rag"),
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
        return not internal.isDedicatedServer()
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
