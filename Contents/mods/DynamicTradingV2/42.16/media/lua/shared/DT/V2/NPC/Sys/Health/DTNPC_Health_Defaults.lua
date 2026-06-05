-- ==============================================================================
-- DTNPC_Health_Defaults.lua
-- Defaults, derived stats, and public health state accessors.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function syncDerivedHealthState(npcData, combatHealth)
    if type(npcData) ~= "table" then
        return nil
    end

    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        npcData.healthState = nil
        return nil
    end

    if npcData.incapState == "Active" or tostring(npcData.state or "") == "Incapacitated" then
        npcData.healthState = nil
        return "Incapacitated"
    end

    combatHealth = type(combatHealth) == "table" and combatHealth or npcData.combatHealth
    local current = tonumber(combatHealth and combatHealth.current) or nil
    local maxHealth = tonumber(combatHealth and combatHealth.max) or nil
    if current ~= nil and maxHealth ~= nil and maxHealth > 0 then
        local ratio = current / maxHealth
        if ratio <= (tonumber(DTNPCHealth.WEAKENED_THRESHOLD_RATIO) or 0.30) then
            npcData.healthState = "Weakened"
            return "Weakened"
        end
    end

    npcData.healthState = "Healthy"
    return "Healthy"
end

internal.syncDerivedHealthState = syncDerivedHealthState

function DTNPCHealth.ComputeMaxHP(npcData)
    local archetypeID = tostring(npcData and npcData.archetypeID or "General")
    local baseTemplate = tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE[archetypeID]) or tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE.General) or 120
    local baseMax = math.max(1, math.floor((baseTemplate * internal.getBaseHPMultiplier()) + 0.5))
    local melee = internal.getResolvedSkillLevelForHealth(npcData, "Melee")
    local shooting = internal.getResolvedSkillLevelForHealth(npcData, "Shooting")
    local maintenance = internal.getResolvedSkillLevelForHealth(npcData, "Maintenance")
    local skillBonus = math.min(50, math.floor((melee * 2) + (shooting * 2) + maintenance))
    local maxHealth = math.max(1, math.floor(baseMax + skillBonus))
    return baseMax, skillBonus, maxHealth
end

function DTNPCHealth.EnsureDefaults(npcData)
    if not npcData then
        return nil
    end

    local isDeadState = tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) ~= nil

    if type(npcData.combatHealth) ~= "table" then
        npcData.combatHealth = {}
    end
    if isDeadState then
        npcData.healthState = nil
        npcData.reviveData = nil
        npcData.incapState = nil
    end
    if not isDeadState and type(npcData.reviveData) ~= "table" then
        npcData.reviveData = npcData.reviveData ~= nil and {} or npcData.reviveData
    end
    if not isDeadState and type(npcData.reviveData) == "table" then
        local requiredCount = tonumber(npcData.reviveData.requiredItemCount) or 0
        if requiredCount > 0 then
            npcData.reviveData.requiredItemCount = math.max(1, math.floor(requiredCount))
        else
            npcData.reviveData.requiredItemCount = nil
        end
    end
    if npcData._dtHealthDefaultsActive then
        return npcData.combatHealth
    end
    npcData._dtHealthDefaultsActive = true

    local combatHealth = npcData.combatHealth
    local baseMax, skillBonus, maxHealth = DTNPCHealth.ComputeMaxHP(npcData)
    local linkedWorkerHealth = internal.getLinkedWorkerHealthSnapshot and internal.getLinkedWorkerHealthSnapshot(npcData) or nil
    if linkedWorkerHealth and tonumber(linkedWorkerHealth.maxHp) and tonumber(linkedWorkerHealth.maxHp) > 0 then
        baseMax = math.max(1, math.floor(tonumber(linkedWorkerHealth.maxHp) + 0.5))
        skillBonus = 0
        maxHealth = baseMax
    end

    if combatHealth.enabled == nil then combatHealth.enabled = npcData.incapState ~= "Active" end
    if combatHealth.engineProtected == nil then combatHealth.engineProtected = combatHealth.enabled == true end
    if combatHealth.baseMax == nil then combatHealth.baseMax = baseMax end
    if combatHealth.skillBonus == nil then combatHealth.skillBonus = skillBonus end
    if combatHealth.max == nil then combatHealth.max = maxHealth end
    if combatHealth.current == nil then
        combatHealth.current = npcData.incapState == "Active" and (tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1)
            or math.max(0, tonumber(linkedWorkerHealth and linkedWorkerHealth.hp) or combatHealth.max)
    end
    if combatHealth.eventDrivenOnly == nil or combatHealth.eventDrivenOnly == true then combatHealth.eventDrivenOnly = false end
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
    if combatHealth.postReviveGraceUntil == nil then combatHealth.postReviveGraceUntil = 0 end
    if combatHealth.lastRevivedAt == nil then combatHealth.lastRevivedAt = 0 end
    if combatHealth.selfBandageThreshold == nil then combatHealth.selfBandageThreshold = DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO end
    if combatHealth.selfBandageApplyDurationMs == nil then combatHealth.selfBandageApplyDurationMs = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS end
    if combatHealth.bandageUnlimited == nil then
        if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
            combatHealth.bandageUnlimited = DTNPCRoles.ShouldRequireItems(npcData, "bandage") ~= true
        else
            combatHealth.bandageUnlimited = not internal.isPlayerOwnedNPC(npcData)
        end
    end
    if combatHealth.bandageCharges == nil and combatHealth.bandageUnlimited ~= true then
        combatHealth.bandageCharges = DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES
    end
    local tierID, tierDef = internal.getBandageTierDef(combatHealth.bandageTier)
    if combatHealth.bandageTier == nil then combatHealth.bandageTier = tierID end
    if combatHealth.bandageActionUntil == nil then combatHealth.bandageActionUntil = 0 end
    if combatHealth.bandageAnimFallbackUntil == nil then combatHealth.bandageAnimFallbackUntil = 0 end
    if combatHealth.bandageRetryAt == nil then combatHealth.bandageRetryAt = 0 end
    if combatHealth.bandageHealPool == nil then combatHealth.bandageHealPool = 0 end
    if combatHealth.bandageHealRemaining == nil then combatHealth.bandageHealRemaining = 0 end
    if combatHealth.lastBandageRegenAt == nil then combatHealth.lastBandageRegenAt = 0 end
    if combatHealth.bandageDirty == nil then combatHealth.bandageDirty = false end
    if combatHealth.activeBandage == nil then combatHealth.activeBandage = false end
    if combatHealth.bandageStatus == nil then combatHealth.bandageStatus = "None" end
    if combatHealth.bandageItemFullType == nil then
        combatHealth.bandageItemFullType = tostring(tierDef.iconFullType or "Base.Bandage")
    end
    if combatHealth.bandageResumeState == nil then combatHealth.bandageResumeState = nil end
    if combatHealth.bandageAnimVariant ~= nil then
        combatHealth.bandageAnimVariant = internal.getResolvedBandageAnimVariantID(combatHealth.bandageAnimVariant)
    end
    if combatHealth.lastPersistedAt == nil then combatHealth.lastPersistedAt = 0 end
    if combatHealth.bandageTuningVersion == nil then combatHealth.bandageTuningVersion = 0 end
    if combatHealth.lastRestingRegenAt == nil then combatHealth.lastRestingRegenAt = 0 end
    if combatHealth.restingRegenMultiplier == nil then
        combatHealth.restingRegenMultiplier = tonumber(npcData.restingRegenMultiplier)
            or tonumber(npcData.restingHealMultiplier)
            or DTNPCHealth.DEFAULT_RESTING_REGEN_MULTIPLIER
    end

    if tonumber(combatHealth.bandageTuningVersion) < DTNPCHealth.SELF_BANDAGE_TUNING_VERSION then
        combatHealth.selfBandageApplyDurationMs = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS
        combatHealth.bandageTier = tierID
        combatHealth.bandageHealPool = combatHealth.activeBandage == true and math.max(0, tonumber(tierDef.totalHeal) or 0) or 0
        combatHealth.bandageHealRemaining = combatHealth.activeBandage == true and math.max(0, tonumber(tierDef.totalHeal) or 0) or 0
        combatHealth.lastBandageRegenAt = 0
        combatHealth.bandageTuningVersion = DTNPCHealth.SELF_BANDAGE_TUNING_VERSION
    end

    tierID, tierDef = internal.getBandageTierDef(combatHealth.bandageTier)
    combatHealth.bandageTier = tierID
    if combatHealth.bandageItemFullType == nil or combatHealth.bandageItemFullType == "" then
        combatHealth.bandageItemFullType = tostring(tierDef.iconFullType or "Base.Bandage")
    end
    if combatHealth.activeBandage ~= true then
        combatHealth.bandageHealPool = 0
        combatHealth.bandageHealRemaining = 0
    elseif (tonumber(combatHealth.bandageHealPool) or 0) <= 0 then
        combatHealth.bandageHealPool = math.max(0, tonumber(tierDef.totalHeal) or 0)
        combatHealth.bandageHealRemaining = math.max(0, tonumber(combatHealth.bandageHealPool) or 0)
    else
        combatHealth.bandageHealRemaining = internal.clamp(
            tonumber(combatHealth.bandageHealRemaining) or combatHealth.bandageHealPool,
            0,
            math.max(0, tonumber(combatHealth.bandageHealPool) or 0)
        )
    end

    combatHealth.baseMax = baseMax
    combatHealth.skillBonus = skillBonus
    combatHealth.max = maxHealth
    if isDeadState then
        combatHealth.enabled = false
        combatHealth.engineProtected = false
        combatHealth.current = 0
        combatHealth.incapGraceUntil = 0
        combatHealth.postReviveGraceUntil = 0
        combatHealth.lastRevivedAt = 0
        combatHealth.lastEngineHealth = 0
        internal.clearActiveBandage(combatHealth, false)
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageAnimFallbackUntil = 0
        combatHealth.bandageRetryAt = 0
        combatHealth.bandageResumeState = nil
        combatHealth.bandageAnimVariant = nil
    elseif npcData.incapState == "Active" then
        npcData.healthState = nil
        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = math.max(
            tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1,
            tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01
        )
        combatHealth.postReviveGraceUntil = 0
        internal.clearActiveBandage(combatHealth, false)
        combatHealth.bandageActionUntil = 0
        combatHealth.bandageAnimFallbackUntil = 0
        combatHealth.bandageRetryAt = 0
        combatHealth.bandageResumeState = nil
        combatHealth.bandageAnimVariant = nil
    else
        combatHealth.current = internal.clamp(combatHealth.current, 0, combatHealth.max)
        combatHealth.incapGraceUntil = 0
        syncDerivedHealthState(npcData, combatHealth)
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

    return internal.clamp(current / maxHealth, 0, 1)
end

function DTNPCHealth.IsCombatState(state)
    return internal.isCombatState(state)
end

function DTNPCHealth.HasUsableBandageSupply(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
        local ok, shouldRequire = pcall(DTNPCRoles.ShouldRequireItems, npcData, "bandage")
        if ok and shouldRequire ~= true then
            return true
        end
    end

    if combatHealth.bandageUnlimited == true then
        return true
    end

    if internal.hasLinkedWorkerBandageSupply and internal.hasLinkedWorkerBandageSupply(npcData) then
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
