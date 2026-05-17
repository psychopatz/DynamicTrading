-- ==============================================================================
-- DTNPC_Health_Spawn.lua
-- Spawn initialization and engine-buffer restoration for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

function DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    if not zombie or not npcData or internal.isRemoteClient() then
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
    internal.clearDeferredSpawnRestore(combatHealth)
    return true
end

function DTNPCHealth.ProcessDeferredSpawnRestore(zombie, npcData)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false
    end

    local targetHealth = tonumber(combatHealth.deferredSpawnBufferTarget) or 0
    local restoreAt = tonumber(combatHealth.deferredSpawnBufferUntil) or 0
    if targetHealth <= 0 or internal.nowMillis() < restoreAt then
        return false
    end

    zombie:setHealth(targetHealth)
    combatHealth.lastEngineHealth = targetHealth
    npcData.health = targetHealth
    npcData.lastHealth = targetHealth

    local restoreReason = combatHealth.deferredSpawnReason
    internal.clearDeferredSpawnRestore(combatHealth)

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
    npcData.bodyRecoveryRetryAt = nil
    combatHealth.lastDamageAt = 0
    combatHealth.lastDamageAmount = 0
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.spawnInitializedAt = internal.nowMillis()
    combatHealth.spawnReason = spawnReason
    combatHealth.eventDrivenOnly = false

    local initialEngineHealth, desiredEngineHealth, deferRestore = internal.resolveSpawnHealthPlan(npcData, combatHealth, options)

    if npcData.incapState == "Active" then
        local currentTime = internal.nowMillis()
        local existingCurrent = tonumber(combatHealth.current)
        local existingGraceUntil = tonumber(combatHealth.incapGraceUntil) or 0
        local preserveGrace = existingGraceUntil > currentTime

        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = internal.clamp(
            existingCurrent
                or math.max(
                    tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1,
                    tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01
                ),
            tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01,
            tonumber(combatHealth.max) or existingCurrent or (tonumber(DTNPCHealth.INCAP_CUSTOM_HP) or 1)
        )
        combatHealth.incapGraceUntil = preserveGrace and existingGraceUntil or 0
        combatHealth.lastEngineHealth = initialEngineHealth
        if deferRestore and preserveGrace then
            internal.scheduleDeferredSpawnRestore(combatHealth, desiredEngineHealth, spawnReason .. "_incap")
        else
            internal.clearDeferredSpawnRestore(combatHealth)
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
                .. " preservedGrace=" .. tostring(preserveGrace)
                .. " customCurrent=" .. tostring(combatHealth.current)
                .. " incapState=" .. tostring(npcData.incapState)
        )
        return combatHealth
    end

    combatHealth.enabled = true
    combatHealth.engineProtected = true
    if resetCurrent then
        combatHealth.current = combatHealth.max
    else
        combatHealth.current = internal.clamp(combatHealth.current, 0, combatHealth.max)
    end

    if zombie and deferRestore then
        zombie:setHealth(initialEngineHealth)
        combatHealth.lastEngineHealth = initialEngineHealth
        npcData.health = initialEngineHealth
        npcData.lastHealth = initialEngineHealth
        internal.scheduleDeferredSpawnRestore(combatHealth, desiredEngineHealth, spawnReason)
    elseif zombie then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        npcData.lastHealth = zombie:getHealth()
    else
        combatHealth.lastEngineHealth = combatHealth.engineBuffer
        npcData.health = combatHealth.engineBuffer
        npcData.lastHealth = combatHealth.engineBuffer
        internal.clearDeferredSpawnRestore(combatHealth)
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
