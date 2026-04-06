-- ==============================================================================
-- DTNPC_Health_Damage.lua
-- Damage application, incapacitation, and fallback damage handling.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = DTNPCHealth.INCAP_ENGINE_HEALTH
    npcData.lastHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    zombie:setHealth(DTNPCHealth.INCAP_ENGINE_HEALTH)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
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

        if healthDelta <= 0 then
            if combatHealth then
                combatHealth.lastEngineHealth = currentHealth
            end
            npcData.health = currentHealth
            return false, false
        end

        if internal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, zombie:getAttackedBy()) then
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

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Health",
            "ProcessFallbackDamage incap name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
                .. " uuid=" .. tostring(npcData.uuid)
                .. " previousHealth=" .. tostring(previousHealth)
                .. " currentHealth=" .. tostring(currentHealth)
                .. " delta=" .. tostring(healthDelta)
                .. " attackerType=" .. tostring(internal.getAttackerType(zombie:getAttackedBy()))
                .. " attackerID=" .. tostring(internal.getAttackerID(zombie:getAttackedBy()))
        )

        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
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
    if healthDelta <= 0 then
        combatHealth.lastEngineHealth = currentHealth
        npcData.health = currentHealth
        return false, false
    end

    if internal.isLikelySpawnFallbackCollapse(npcData, combatHealth, currentHealth, previousHealth, zombie:getAttackedBy()) then
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
            .. " attackerType=" .. tostring(internal.getAttackerType(zombie:getAttackedBy()))
            .. " attackerID=" .. tostring(internal.getAttackerID(zombie:getAttackedBy()))
    )

    return DTNPCHealth.ApplyDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
        source = "engine_fallback",
        queueFallbackIgnore = false,
    })
end
