-- ==============================================================================
-- DTNPC_HealthBandage_Visuals.lua
-- Visual state, visibility, and bandage debug helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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
    return internal.startSelfBandage(zombie, npcData, resumeState, {
        ignoreRetry = true,
        immediate = false,
    })
end
