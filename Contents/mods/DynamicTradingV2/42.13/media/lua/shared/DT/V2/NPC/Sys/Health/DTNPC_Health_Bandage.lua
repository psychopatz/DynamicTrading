-- ==============================================================================
-- DTNPC_Health_Bandage.lua
-- Self-bandage flow, visuals, and passive healing behavior.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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

    local now = internal.nowMillis()
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
    combatHealth.bandageAnimVariant = internal.rollBandageAnimVariantID()
    combatHealth.bandageDirty = false
    combatHealth.bandageStatus = combatHealth.bandageActionUntil > now and "Applying" or "Ready"
    internal.applyBandageAnimVariables(zombie, combatHealth)
    internal.playEmitterSound(zombie, DTNPCHealth.BANDAGE_SOUND)
    npcData.state = "Bandage"
    internal.pushBandageAmbientCue(zombie, npcData)
    internal.syncAndPersistHealth(zombie, npcData, false, false)
    return true
end

function DTNPCHealth.ApplyBandageVisualState(zombie, npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return nil
    end

    if combatHealth.bandageAnimVariant == nil or combatHealth.bandageAnimVariant == "" then
        combatHealth.bandageAnimVariant = internal.rollBandageAnimVariantID()
    else
        combatHealth.bandageAnimVariant = internal.getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    end

    if zombie then
        zombie:setVariable("DTIdleState", tostring(DTNPCHealth.BANDAGE_IDLE_STATE or "11"))
        internal.applyBandageAnimVariables(zombie, combatHealth)
    end

    return combatHealth.bandageAnimVariant
end

function DTNPCHealth.IsBandageVisibleOpportunity(zombie)
    return internal.isBandageVisibleOpportunity(zombie)
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
        bandageTierLabel = select(2, internal.getBandageTierDef(combatHealth.bandageTier)).label,
        bandageHealPool = tonumber(combatHealth.bandageHealPool) or 0,
        bandageHealRemaining = tonumber(combatHealth.bandageHealRemaining) or 0,
        current = tonumber(combatHealth.current) or 0,
        max = tonumber(combatHealth.max) or 0,
        ratio = DTNPCHealth.GetHealthRatio(npcData),
        threshold = tonumber(combatHealth.selfBandageThreshold) or DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO,
        visible = internal.isBandageVisibleOpportunity(zombie),
        hasSupply = DTNPCHealth.HasUsableBandageSupply(npcData),
        bandageUnlimited = combatHealth.bandageUnlimited == true,
        bandageCharges = tonumber(combatHealth.bandageCharges) or 0,
        retryAt = tonumber(combatHealth.bandageRetryAt) or 0,
        actionUntil = tonumber(combatHealth.bandageActionUntil) or 0,
        animVariant = combatHealth.bandageAnimVariant or internal.getDefaultBandageAnimVariantID(),
    }
end

function DTNPCHealth.ForceEnterSelfBandage(zombie, npcData, resumeState)
    return startSelfBandage(zombie, npcData, resumeState, {
        ignoreRetry = true,
        immediate = false,
    })
end

function DTNPCHealth.ProcessPassiveBandageRegen(zombie, npcData)
    if not npcData or internal.isRemoteClient() then
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
        internal.clearActiveBandage(combatHealth, true)
        internal.syncAndPersistHealth(zombie, npcData, false, false)
        return false
    end

    local now = internal.nowMillis()
    if combatHealth.bandageDirty == true then
        combatHealth.lastBandageRegenAt = now
        return false
    end

    if combatHealth.current >= combatHealth.max then
        combatHealth.lastBandageRegenAt = now
        return false
    end

    local _, tierDef = internal.getBandageTierDef(combatHealth.bandageTier)
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
    combatHealth.current = internal.clamp(currentBefore + healAmount, 0, combatHealth.max)
    combatHealth.bandageHealRemaining = math.max(0, healRemaining - healAmount)
    combatHealth.lastBandageRegenAt = lastRegenAt + (elapsedSteps * intervalMs)
    if combatHealth.bandageHealRemaining <= DTNPCHealth.MIN_DAMAGE then
        internal.clearActiveBandage(combatHealth, true)
    end
    if healAmount <= DTNPCHealth.MIN_DAMAGE and combatHealth.bandageDirty ~= true then
        return false
    end

    internal.syncAndPersistHealth(zombie, npcData, false, false)
    return true
end

function DTNPCHealth.ProcessPassiveRestRegen(zombie, npcData, options)
    if not npcData or internal.isRemoteClient() then
        return false
    end

    options = type(options) == "table" and options or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    local now = internal.nowMillis()
    if not internal.canUseRestingRegen(npcData, combatHealth) then
        combatHealth.lastRestingRegenAt = now
        return false
    end

    local lastRegenAt = tonumber(combatHealth.lastRestingRegenAt) or 0
    if lastRegenAt <= 0 then
        combatHealth.lastRestingRegenAt = now
        return false
    end

    local intervalMs = math.max(1000, tonumber(DTNPCHealth.RESTING_REGEN_INTERVAL_MS) or 20000)
    local elapsedMs = math.max(0, now - lastRegenAt)
    local elapsedSteps = math.floor(elapsedMs / intervalMs)
    if elapsedSteps <= 0 then
        return false
    end

    local currentBefore = tonumber(combatHealth.current) or 0
    local missingHealth = math.max(0, (tonumber(combatHealth.max) or 0) - currentBefore)
    local healBudget = elapsedSteps
        * math.max(0, tonumber(DTNPCHealth.RESTING_REGEN_PER_TICK) or 0.5)
        * internal.getRestingRegenMultiplier(npcData, combatHealth)
    local healAmount = math.min(healBudget, missingHealth)
    combatHealth.lastRestingRegenAt = lastRegenAt + (elapsedSteps * intervalMs)

    if healAmount <= DTNPCHealth.MIN_DAMAGE then
        return false
    end

    combatHealth.current = internal.clamp(currentBefore + healAmount, 0, combatHealth.max)
    internal.syncAndPersistHealth(zombie, npcData, false, options.forceManagerSave == true)
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

    if (tonumber(combatHealth.bandageActionUntil) or 0) > internal.nowMillis() then
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

    return startSelfBandage(zombie, npcData, state)
end

function DTNPCHealth.ProcessSelfBandageAction(zombie, npcData)
    if not zombie or not npcData or internal.isRemoteClient() then
        return "blocked"
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return "blocked"
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return "applied"
    end

    local now = internal.nowMillis()
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

    local linkedSupply = internal.consumeLinkedWorkerBandageSupply and internal.consumeLinkedWorkerBandageSupply(npcData) or nil
    if linkedSupply and linkedSupply.tierID then
        combatHealth.bandageTier = linkedSupply.tierID
    elseif combatHealth.bandageUnlimited ~= true then
        combatHealth.bandageCharges = math.max(0, (tonumber(combatHealth.bandageCharges) or 0) - 1)
    end

    local _, tierDef = internal.getBandageTierDef(combatHealth.bandageTier)
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
    combatHealth.current = internal.clamp(currentHealth + immediateHeal, 0, combatHealth.max)
    if combatHealth.bandageHealRemaining <= DTNPCHealth.MIN_DAMAGE then
        internal.clearActiveBandage(combatHealth, true)
    end
    internal.syncAndPersistHealth(zombie, npcData, false, true)
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
    internal.clearBandageAnimVariables(zombie)
    if npcData.state == "Bandage" then
        npcData.state = nextState
        internal.syncAndPersistHealth(zombie, npcData, false, false)
    end
end
