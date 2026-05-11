-- ==============================================================================
-- DTNPC_HealthShared_SpawnSafety.lua
-- Spawn buffering and fallback-damage safety helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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
