-- ==============================================================================
-- DTNPC_HealthBandage_Action.lua
-- Self-bandage execution, cancellation, and exit behavior.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

function DTNPCHealth.ProcessSelfBandageAction(zombie, npcData)
    if not zombie or not npcData then
        return "blocked"
    end

    if internal.isRemoteClient() then
        return "applying"
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
    if internal.isBandageAnimFinished
        and not internal.isBandageAnimFinished(zombie)
        and now < (tonumber(combatHealth.bandageAnimFallbackUntil) or 0) then
        combatHealth.bandageStatus = "Applying"
        return "applying"
    end

    if not DTNPCHealth.HasUsableBandageSupply(npcData) then
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageAnimFallbackUntil = 0
        combatHealth.bandageStatus = "None"
        combatHealth.bandageDirty = false
        combatHealth.bandageRetryAt = now + math.max(0, tonumber(DTNPCHealth.SELF_BANDAGE_RETRY_DELAY_MS) or 0)
        return "blocked"
    end

    local shouldConsume = true
    if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
        local ok, result = pcall(DTNPCRoles.ShouldRequireItems, npcData, "bandage")
        if ok then
            shouldConsume = result == true
        end
    end

    local linkedSupply = nil
    if shouldConsume then
        linkedSupply = internal.consumeLinkedWorkerBandageSupply and internal.consumeLinkedWorkerBandageSupply(npcData) or nil
        if linkedSupply and linkedSupply.tierID then
            combatHealth.bandageTier = linkedSupply.tierID
        elseif combatHealth.bandageUnlimited ~= true then
            combatHealth.bandageCharges = math.max(0, (tonumber(combatHealth.bandageCharges) or 0) - 1)
        end
    end

    local _, tierDef = internal.getBandageTierDef(combatHealth.bandageTier)
    local bandageHealPool = math.max(0, tonumber(tierDef.totalHeal) or 0)
    local applyHeal = math.min(bandageHealPool, math.max(0, tonumber(tierDef.applyHeal) or 0))
    local currentHealth = tonumber(combatHealth.current) or 0
    local missingHealth = math.max(0, (tonumber(combatHealth.max) or 0) - currentHealth)
    local immediateHeal = math.min(applyHeal, missingHealth)

    combatHealth.bandageActionUntil = 0
    combatHealth.bandageAnimFallbackUntil = 0
    combatHealth.bandageRetryAt = 0
    combatHealth.activeBandage = true
    combatHealth.bandageDirty = false
    combatHealth.bandageStatus = "Clean"
    combatHealth.bandageItemFullType = linkedSupply and linkedSupply.fullType or tostring(tierDef.iconFullType or "Base.Bandage")
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

function DTNPCHealth.CancelPendingSelfBandage(zombie, npcData, resumeOverride, options)
    if not npcData then
        return false
    end

    options = type(options) == "table" and options or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    local now = internal.nowMillis()
    local nextState = resumeOverride or combatHealth.bandageResumeState or "Idle"
    if nextState == "Bandage" then
        nextState = "Idle"
    end

    local changed = false
    if (tonumber(combatHealth.bandageActionUntil) or 0) > 0 then
        combatHealth.bandageActionUntil = 0
        changed = true
    end
    if (tonumber(combatHealth.bandageAnimFallbackUntil) or 0) > 0 then
        combatHealth.bandageAnimFallbackUntil = 0
        changed = true
    end
    if combatHealth.bandageResumeState ~= nil then
        combatHealth.bandageResumeState = nil
        changed = true
    end
    if combatHealth.bandageAnimVariant ~= nil then
        combatHealth.bandageAnimVariant = nil
        changed = true
    end

    if options.manualInterrupt == true and combatHealth.activeBandage ~= true then
        local retryDelay = math.max(
            0,
            tonumber(options.retryDelayMs)
                or tonumber(DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS)
                or 0
        )
        local retryAt = now + retryDelay
        if retryAt > (tonumber(combatHealth.bandageRetryAt) or 0) then
            combatHealth.bandageRetryAt = retryAt
            changed = true
        end
    end

    if combatHealth.activeBandage == true then
        combatHealth.bandageStatus = combatHealth.bandageDirty == true and "Dirty" or "Clean"
    else
        combatHealth.bandageStatus = "None"
        combatHealth.bandageDirty = false
    end

    internal.clearBandageAnimVariables(zombie)
    if npcData.state == "Bandage" then
        npcData.state = nextState
        changed = true
    end

    if changed and options.sync ~= false then
        internal.syncAndPersistHealth(zombie, npcData, false, false)
    end

    return changed
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
    combatHealth.bandageAnimFallbackUntil = 0
    combatHealth.bandageResumeState = nil
    combatHealth.bandageAnimVariant = nil
    internal.clearBandageAnimVariables(zombie)
    if npcData.state == "Bandage" then
        npcData.state = nextState
        internal.syncAndPersistHealth(zombie, npcData, false, false)
    end
end
