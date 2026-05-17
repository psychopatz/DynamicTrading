-- ==============================================================================
-- DTNPC_HealthBandage_Flow.lua
-- Self-bandage entry conditions and state transition flow.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function hasNearbyThreat(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false
    end

    local radius = 10
    local threat = DTNPCProtect.SelectNearestThreat(zombie, npcData, radius, zombie, radius, true)
    return threat ~= nil
end

function internal.startSelfBandage(zombie, npcData, resumeState, options)
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

    local now = internal.nowMillis()
    if options.ignoreRetry ~= true and (tonumber(combatHealth.bandageRetryAt) or 0) > now then
        return false
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return false
    end

    if (tonumber(combatHealth.bandageActionUntil) or 0) > now then
        npcData.state = "Bandage"
        combatHealth.bandageStatus = "Applying"
        if combatHealth.bandageAnimVariant == nil or combatHealth.bandageAnimVariant == "" then
            combatHealth.bandageAnimVariant = internal.rollBandageAnimVariantID()
        end
        internal.applyBandageAnimVariables(zombie, combatHealth)
        internal.syncAndPersistHealth(zombie, npcData, false, false)
        return true
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty == true then
        internal.clearActiveBandage(combatHealth, false)
    end

    local resolvedResumeState = resumeState
    if resolvedResumeState == "Bandage" or resolvedResumeState == nil or resolvedResumeState == "" then
        resolvedResumeState = combatHealth.bandageResumeState or "Idle"
    end

    combatHealth.bandageResumeState = resolvedResumeState
    combatHealth.bandageActionUntil = options.immediate == true
        and 0
        or (now + math.max(0, tonumber(combatHealth.selfBandageApplyDurationMs) or 0))
    combatHealth.bandageAnimFallbackUntil = combatHealth.bandageActionUntil
        + math.max(0, tonumber(DTNPCHealth.SELF_BANDAGE_ANIM_FALLBACK_GRACE_MS) or 0)
    combatHealth.bandageRetryAt = 0
    combatHealth.bandageAnimVariant = internal.rollBandageAnimVariantID()
    combatHealth.bandageDirty = false
    combatHealth.bandageStatus = combatHealth.bandageActionUntil > now and "Applying" or "Ready"
    internal.resetBandageAnimFinished(zombie)
    internal.applyBandageAnimVariables(zombie, combatHealth)
    internal.playEmitterSound(zombie, DTNPCHealth.BANDAGE_SOUND)
    if DTNPCHostility and DTNPCHostility.PlayHurtSound then
        DTNPCHostility.PlayHurtSound(zombie, npcData, "Bandage")
    end
    npcData.state = "Bandage"
    internal.pushBandageAmbientCue(zombie, npcData)
    internal.syncAndPersistHealth(zombie, npcData, false, false)
    return true
end

function DTNPCHealth.ShouldSelfBandage(npcData)
    if not npcData or npcData.incapState == "Active" then
        return false
    end

    if npcData.raidHostileFaction == true
        or (npcData.banditGroupID ~= nil and npcData.banditLeaving ~= true) then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false
    end

    if combatHealth.current <= 0 or combatHealth.current >= combatHealth.max then
        return false
    end

    local now = internal.nowMillis()
    if npcData.isHostile == true
        or npcData.combatTargetID ~= nil
        or npcData.combatTargetType ~= nil
        or ((tonumber(combatHealth.lastDamageAt) or 0) > 0
            and (now - (tonumber(combatHealth.lastDamageAt) or 0)) < (tonumber(DTNPCHealth.SELF_BANDAGE_COMBAT_COOLDOWN_MS) or 12000)) then
        return false
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return false
    end

    if (tonumber(combatHealth.bandageActionUntil) or 0) > now then
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
    if internal.isCombatState(state) or state == "Departure" then
        return false
    end

    if not DTNPCHealth.ShouldSelfBandage(npcData) then
        return false
    end

    if not internal.isBandageVisibleOpportunity(zombie) then
        return false
    end
    if hasNearbyThreat(zombie, npcData) then
        return false
    end

    return internal.startSelfBandage(zombie, npcData, state)
end
