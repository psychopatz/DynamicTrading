-- ==============================================================================
-- DTNPC_Lifecycle_DamageAuthority.lua
-- Friendly-fire protection, MP damage authority, and engine-delta processing.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal
local MULTIPLAYER_ENGINE_DELTA_LOG_COOLDOWN_MS = 15000

local function hasRecentTrustedExplicitHit(combatHealth, now, windowMs)
    local recentSource = tostring(combatHealth and combatHealth.lastDamageSource or "")
    local recentDamageAt = tonumber(combatHealth and combatHealth.lastDamageAt) or 0
    local recentWindowMs = math.max(250, tonumber(windowMs) or 2000)

    now = tonumber(now) or internal.nowMillis()
    return recentDamageAt > 0
        and (now - recentDamageAt) <= recentWindowMs
        and DTNPCHealth
        and DTNPCHealth.Internal
        and DTNPCHealth.Internal.isTrustedExplicitDamageSource
        and DTNPCHealth.Internal.isTrustedExplicitDamageSource(recentSource)
end

local function restoreAfterIgnoredFriendlyFire(zombie, npcData, combatHealth)
    if not npcData then
        return
    end

    if npcData.incapState == "Active" then
        if combatHealth then
            combatHealth.engineProtected = true
            combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        end
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        if zombie and zombie.setHealth then
            zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        end
        return
    end

    if zombie and DTNPCHealth and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end
end

function DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if not healthInternal
        or not healthInternal.isFriendlyFollowerOrProtectorHit
        or not healthInternal.isFriendlyFollowerOrProtectorHit(npcData, attacker) then
        return false
    end

    context = type(context) == "table" and context or {}
    local now = internal.nowMillis()
    local lastLogAt = tonumber(combatHealth and combatHealth.lastFriendlyFireIgnoredAt) or 0

    restoreAfterIgnoredFriendlyFire(zombie, npcData, combatHealth)

    if combatHealth and now - lastLogAt > 1500 then
        combatHealth.lastFriendlyFireIgnoredAt = now
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "Ignored friendly fire for "
                .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " source=" .. tostring(context.source or "unknown")
                .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
                .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
        )
    end

    return true
end

function DTNPCLifecycle.ShouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, source)
    if not isServer or not isServer() then
        return false
    end

    local now = internal.nowMillis()
    local attackerType = internal.getAttackerType and internal.getAttackerType(attacker) or nil

    local lastLogAt = tonumber(combatHealth and combatHealth.lastMultiplayerEngineDeltaIgnoredAt) or 0
    if combatHealth and now - lastLogAt > MULTIPLAYER_ENGINE_DELTA_LOG_COOLDOWN_MS then
        combatHealth.lastMultiplayerEngineDeltaIgnoredAt = now
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Ignored multiplayer engine health delta for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
                .. " source=" .. tostring(source or "engine_fallback")
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " attackerType=" .. tostring(attackerType)
                .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
        )
    end

    if npcData and npcData.incapState == "Active" then
        if zombie and zombie.setHealth then
            zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        end
        if combatHealth then
            combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        end
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    elseif zombie and DTNPCHealth and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end

    return true
end

local function shouldIgnorePostReviveEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, source)
    if not zombie or not npcData or type(combatHealth) ~= "table" then
        return false
    end

    local now = internal.nowMillis()
    local graceUntil = tonumber(combatHealth.postReviveGraceUntil) or 0
    if graceUntil <= 0 or now >= graceUntil then
        return false
    end

    if attacker ~= nil or hasRecentTrustedExplicitHit(combatHealth, now) then
        return false
    end

    local lastLogAt = tonumber(combatHealth.lastPostReviveEngineDeltaIgnoredAt) or 0
    if now - lastLogAt > MULTIPLAYER_ENGINE_DELTA_LOG_COOLDOWN_MS then
        combatHealth.lastPostReviveEngineDeltaIgnoredAt = now
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Ignored attacker-less post-revive engine health delta for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
                .. " source=" .. tostring(source or "engine_fallback")
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " graceUntil=" .. tostring(graceUntil)
        )
    end

    if DTNPCHealth and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end
    return true
end

local function shouldIgnoreSpawnEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, source)
    if not zombie or not npcData or type(combatHealth) ~= "table" then
        return false
    end
    if not isServer or isServer() ~= true then
        return false
    end
    if attacker ~= nil then
        return false
    end

    local now = internal.nowMillis()
    if hasRecentTrustedExplicitHit(combatHealth, now) then
        return false
    end

    local spawnedAt = tonumber(combatHealth.spawnInitializedAt) or 0
    if spawnedAt <= 0 then
        return false
    end

    local ageMs = now - spawnedAt
    local guardWindowMs = math.max(1000, tonumber(DTNPCHealth and DTNPCHealth.SPAWN_FALLBACK_GUARD_MS) or 12000)
    if ageMs < 0 or ageMs > guardWindowMs then
        return false
    end

    local delta = math.max(0, (tonumber(previousHealth) or 0) - (tonumber(currentHealth) or 0))
    if delta <= (tonumber(DTNPCHealth and DTNPCHealth.MIN_DAMAGE) or 0.01) then
        return false
    end

    local lastDamageAt = tonumber(combatHealth.lastDamageAt) or 0
    local recentDamageWindowMs = 1200
    if lastDamageAt > 0 and (now - lastDamageAt) <= recentDamageWindowMs then
        return false
    end

    local lastSource = tostring(combatHealth.lastDamageSource or "")
    local currentCustom = tonumber(combatHealth.current) or 0
    local maxCustom = tonumber(combatHealth.max) or 0

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Ignored suspicious spawn-time engine health delta for "
            .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
            .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
            .. " source=" .. tostring(source or "engine_fallback")
            .. " previousHealth=" .. tostring(previousHealth)
            .. " currentHealth=" .. tostring(currentHealth)
            .. " delta=" .. tostring(delta)
            .. " spawnAgeMs=" .. tostring(ageMs)
            .. " customCurrent=" .. tostring(currentCustom)
            .. " customMax=" .. tostring(maxCustom)
            .. " lastDamageSource=" .. tostring(lastSource)
    )

    if DTNPCHealth and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end
    return true
end

local function shouldIgnoreAmbientIdleEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, source)
    if not zombie or not npcData or type(combatHealth) ~= "table" then
        return false
    end
    if attacker ~= nil then
        return false
    end

    local now = internal.nowMillis()
    if hasRecentTrustedExplicitHit(combatHealth, now) then
        return false
    end

    local delta = math.max(0, (tonumber(previousHealth) or 0) - (tonumber(currentHealth) or 0))
    if delta <= (tonumber(DTNPCHealth and DTNPCHealth.MIN_DAMAGE) or 0.01) or delta > 0.51 then
        return false
    end

    if npcData.incapState == "Active" or npcData.combatTargetID ~= nil or npcData.combatTargetType ~= nil or npcData.isHostile == true then
        return false
    end

    local state = tostring(npcData.state or "")
    local status = tostring(npcData.status or "")
    local idleTask = type(npcData.dtIdleTask) == "table" and npcData.dtIdleTask or nil
    local taskBehaviorId = tostring(idleTask and idleTask.behaviorId or "")
    local isIdleLike = status == "Resting"
        or state == "Idle"
        or state == "Guard"
        or state == "Home"
        or state == "Resting"
        or state == "Stationary"
        or state == "Stay"
    local isAIFactionTask = taskBehaviorId ~= "" and string.sub(taskBehaviorId, 1, 8) == "faction_"
    if not isIdleLike and not isAIFactionTask then
        return false
    end

    local lastLogAt = tonumber(combatHealth.lastAmbientEngineDeltaIgnoredAt) or 0
    if now - lastLogAt > MULTIPLAYER_ENGINE_DELTA_LOG_COOLDOWN_MS then
        combatHealth.lastAmbientEngineDeltaIgnoredAt = now
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Ignored ambient idle engine health delta for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
                .. " source=" .. tostring(source or "engine_fallback")
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " delta=" .. tostring(delta)
                .. " state=" .. tostring(state)
                .. " status=" .. tostring(status)
                .. " task=" .. tostring(taskBehaviorId)
        )
    end

    if DTNPCHealth and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end
    return true
end

function DTNPCLifecycle.ProcessEngineHealthDelta(zombie, npcData)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false, false
    end

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if combatHealth and combatHealth.eventDrivenOnly == true then
        combatHealth.lastEngineHealth = zombie:getHealth()
        npcData.health = zombie:getHealth()
        return false, false
    end

    if npcData.incapState == "Active" then
        local currentHealth = tonumber(zombie:getHealth()) or 0
        local previousHealth = tonumber(combatHealth and combatHealth.lastEngineHealth) or currentHealth
        local healthDelta = math.max(0, previousHealth - currentHealth)
        local attacker = zombie:getAttackedBy()

        if healthDelta <= 0 then
            if combatHealth then
                combatHealth.lastEngineHealth = currentHealth
            end
            npcData.health = currentHealth
            return false, false
        end

        local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
        if healthInternal and healthInternal.isLikelySpawnFallbackCollapse
            and healthInternal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker) then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "Ignored suspicious incapacitated spawn fallback collapse for "
                    .. tostring(npcData.name or npcData.uuid or "Unknown")
                    .. " uuid=" .. tostring(npcData.uuid)
                    .. " previousHealth=" .. tostring(previousHealth)
                    .. " currentHealth=" .. tostring(currentHealth)
                    .. " spawnAgeMs=" .. tostring(internal.nowMillis() - (tonumber(combatHealth.spawnInitializedAt) or 0))
            )
            zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
            combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
            return false, false
        end

        if DTNPCLifecycle.ShouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "incap_engine_fallback") then
            return false, false
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "ProcessEngineHealthDelta incap name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " delta=" .. tostring(healthDelta)
                .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
                .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
        )

        return DTNPCLifecycle.HandleIncapacitatedDamage(zombie, npcData, healthDelta, attacker, {
            source = "incap_engine_fallback",
            queueFallbackIgnore = false,
        })
    end

    if not combatHealth or combatHealth.enabled ~= true or combatHealth.engineProtected ~= true then
        if combatHealth then
            combatHealth.lastEngineHealth = zombie:getHealth()
        end
        npcData.health = zombie:getHealth()
        return false, false
    end

    local currentHealth = tonumber(zombie:getHealth()) or 0
    local previousHealth = tonumber(combatHealth.lastEngineHealth) or currentHealth
    local healthDelta = math.max(0, previousHealth - currentHealth)
    local attacker = zombie:getAttackedBy()
    if healthDelta <= 0 then
        combatHealth.lastEngineHealth = currentHealth
        npcData.health = currentHealth
        return false, false
    end

    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.isLikelySpawnFallbackCollapse
        and healthInternal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Ignored suspicious spawn fallback collapse for "
                .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " spawnAgeMs=" .. tostring(internal.nowMillis() - (tonumber(combatHealth.spawnInitializedAt) or 0))
        )
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    if shouldIgnoreSpawnEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "engine_fallback") then
        return false, false
    end

    if shouldIgnorePostReviveEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "engine_fallback") then
        return false, false
    end

    if shouldIgnoreAmbientIdleEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "engine_fallback") then
        return false, false
    end

    if DTNPCLifecycle.ShouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "engine_fallback") then
        return false, false
    end

    healthDelta = healthInternal and healthInternal.consumeFallbackIgnore
        and healthInternal.consumeFallbackIgnore(combatHealth, healthDelta)
        or healthDelta
    if healthDelta <= DTNPCHealth.MIN_DAMAGE then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "ProcessEngineHealthDelta name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " previousHealth=" .. tostring(previousHealth)
            .. " currentHealth=" .. tostring(currentHealth)
            .. " delta=" .. tostring(healthDelta)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
    )

    return DTNPCHealth.ApplyDamage(zombie, npcData, healthDelta, attacker, {
        source = "engine_fallback",
        queueFallbackIgnore = false,
    })
end
