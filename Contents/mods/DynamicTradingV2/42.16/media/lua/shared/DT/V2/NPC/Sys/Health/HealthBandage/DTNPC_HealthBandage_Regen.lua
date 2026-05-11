-- ==============================================================================
-- DTNPC_HealthBandage_Regen.lua
-- Passive bandage and resting regeneration behavior.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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
