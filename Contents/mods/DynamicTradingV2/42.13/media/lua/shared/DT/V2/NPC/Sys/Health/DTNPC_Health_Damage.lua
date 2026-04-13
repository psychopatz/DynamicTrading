-- ==============================================================================
-- DTNPC_Health_Damage.lua
-- Damage application, incapacitation, and fallback damage handling.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function restoreAfterIgnoredFriendlyFire(zombie, npcData, combatHealth)
    if not zombie or not npcData then
        return
    end

    if npcData.incapState == "Active" then
        combatHealth.engineProtected = true
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        return
    end

    if DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end
end

local function shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    if not internal.isFriendlyFollowerOrProtectorHit
        or not internal.isFriendlyFollowerOrProtectorHit(npcData, attacker) then
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
            "Health",
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

local function shouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, source)
    if not isServer or not isServer() then
        return false
    end

    local now = internal.nowMillis()
    local lastLogAt = tonumber(combatHealth and combatHealth.lastMultiplayerEngineDeltaIgnoredAt) or 0
    if combatHealth and now - lastLogAt > 1500 then
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
                .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
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
    elseif zombie and DTNPCHealth.RestoreEngineBuffer then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    end

    return true
end

function DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.zeroHpMode ~= "Incapacitated" then
        return false
    end

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "HandleZeroHP name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
    )

    internal.capturePlayerAttacker(npcData, attacker)
    internal.setIncapacitatedState(zombie, npcData)
    internal.syncHealth(zombie, npcData, true)
    return true
end

function DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false, false
    end

    local currentTime = internal.nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    if shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    internal.capturePlayerAttacker(npcData, attacker)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "HandleIncapacitatedDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " amount=" .. tostring(amount)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " currentTime=" .. tostring(currentTime)
            .. " graceUntil=" .. tostring(graceUntil)
    )

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
        combatHealth.lastAttackerType = internal.getAttackerType(attacker)
        combatHealth.lastAttackerID = internal.getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        internal.syncAndPersistHealth(zombie, npcData, false, true)
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.incapGraceUntil = 0
    combatHealth.incapFinalKillRequestedAt = currentTime
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = 0
    npcData.lastHealth = 0
    combatHealth.lastEngineHealth = 0
    zombie:setHealth(0)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
        if DTNPCManager and DTNPCManager.FinalizeIncapacitatedDeath then
            DTNPCManager.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
        end
        return true, true
    end

    return false, false
end

function DTNPCHealth.ApplyDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false, false
    end

    if npcData.incapState == "Active" then
        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false, false
    end

    context = type(context) == "table" and context or {}
    if shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local damage = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    local now = internal.nowMillis()

    internal.capturePlayerAttacker(npcData, attacker)

    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if context.queueFallbackIgnore ~= false then
        internal.queueFallbackIgnore(combatHealth, damage)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ApplyDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " damage=" .. tostring(damage)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " customBefore=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " engineHealth=" .. tostring(zombie:getHealth())
    )

    local currentBefore = internal.clamp(tonumber(combatHealth.current) or combatHealth.max, 0, combatHealth.max)
    local appliedDamage = math.min(damage, currentBefore)
    combatHealth.current = internal.clamp(currentBefore - damage, 0, combatHealth.max)

    internal.applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    if combatHealth.current <= 0 then
        local handled = DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
        return handled, handled
    end

    DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    internal.syncAndPersistHealth(zombie, npcData, false, true)
    return true, false
end

function DTNPCHealth.ApplyDamageToDataOnly(npcData, amount, attacker, context)
    if not npcData or internal.isRemoteClient() then
        return false, false
    end

    context = type(context) == "table" and context or {}
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false, false
    end

    if shouldIgnoreFriendlyFire(nil, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local damage = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    local now = internal.nowMillis()

    internal.capturePlayerAttacker(npcData, attacker)
    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if npcData.incapState == "Active" then
        local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0
        if now < graceUntil then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Health",
                "ApplyDamageToDataOnly ignored incapacitated grace hit for "
                    .. tostring(npcData.name or npcData.uuid or "Unknown")
                    .. " uuid=" .. tostring(npcData.uuid)
                    .. " source=" .. tostring(context.source or "unknown")
                    .. " damage=" .. tostring(damage)
                    .. " graceUntil=" .. tostring(graceUntil)
            )
            return true, false
        end

        combatHealth.engineProtected = false
        combatHealth.incapGraceUntil = 0
        combatHealth.incapFinalKillRequestedAt = now
        npcData.health = 0
        npcData.lastHealth = 0
        combatHealth.lastEngineHealth = 0
        return true, true
    end

    if combatHealth.enabled ~= true then
        return false, false
    end

    local currentBefore = internal.clamp(tonumber(combatHealth.current) or combatHealth.max, 0, combatHealth.max)
    local appliedDamage = math.min(damage, currentBefore)
    combatHealth.current = internal.clamp(currentBefore - damage, 0, combatHealth.max)
    internal.applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ApplyDamageToDataOnly name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context.source or "unknown")
            .. " damage=" .. tostring(damage)
            .. " customBefore=" .. tostring(currentBefore)
            .. " customAfter=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
    )

    return true, combatHealth.current <= 0
end

function DTNPCHealth.ProcessFallbackDamage(zombie, npcData)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false, false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
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

        if internal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker) then
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

        if shouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "incap_engine_fallback") then
            return false, false
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Health",
            "ProcessFallbackDamage incap name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " delta=" .. tostring(healthDelta)
                .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
                .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
        )

        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, healthDelta, attacker, {
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

    if internal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, attacker) then
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

    if shouldIgnoreMultiplayerEngineDelta(zombie, npcData, combatHealth, currentHealth, previousHealth, attacker, "engine_fallback") then
        return false, false
    end

    healthDelta = internal.consumeFallbackIgnore(combatHealth, healthDelta)
    if healthDelta <= DTNPCHealth.MIN_DAMAGE then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ProcessFallbackDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
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
