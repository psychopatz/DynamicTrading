-- ==============================================================================
-- DTNPC_Lifecycle_DamageAuthority.lua
-- Friendly-fire protection, MP damage authority, and engine-delta processing.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal
local MULTIPLAYER_ENGINE_DELTA_LOG_COOLDOWN_MS = 15000

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
    if not internal.isDedicatedServer or internal.isDedicatedServer() ~= true then
        return false
    end

    local attackerType = internal.getAttackerType and internal.getAttackerType(attacker) or nil
    local recentSource = tostring(combatHealth and combatHealth.lastDamageSource or "")
    local recentDamageAt = tonumber(combatHealth and combatHealth.lastDamageAt) or 0
    local now = internal.nowMillis()
    local recentWindowMs = 2000
    local hasRecentClientWeaponReport = recentDamageAt > 0
        and (now - recentDamageAt) <= recentWindowMs
        and (
            recentSource == "client_weapon_hit_report"
            or recentSource == "client_weapon_hit_report_dead_body"
        )

    if attackerType ~= "player" and hasRecentClientWeaponReport ~= true then
        return false
    end

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
