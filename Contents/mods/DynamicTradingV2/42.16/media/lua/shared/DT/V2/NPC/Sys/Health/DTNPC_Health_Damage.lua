-- ==============================================================================
-- DTNPC_Health_Damage.lua
-- Damage application, incapacitation, and fallback damage handling.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    if DTNPCLifecycle and DTNPCLifecycle.ShouldIgnoreFriendlyFire then
        return DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    end

    return false
end

function DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    local incapped = DTNPCLifecycle
        and DTNPCLifecycle.EnterIncapacitated
        and DTNPCLifecycle.EnterIncapacitated(zombie, npcData, attacker, context)
        or false
    
    if not incapped and DTNPCHostility and DTNPCHostility.PlayDeathSound then
        DTNPCHostility.PlayDeathSound(zombie, npcData)
    end
    
    return incapped
end

function DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if DTNPCLifecycle and DTNPCLifecycle.HandleIncapacitatedDamage then
        return DTNPCLifecycle.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
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

    -- Play unique hurt sound based on character identity
    if combatHealth.current > 0 and DTNPCHostility and DTNPCHostility.PlayHurtSound then
        DTNPCHostility.PlayHurtSound(zombie, npcData, "Hurt")
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
    if DTNPCLifecycle and DTNPCLifecycle.ProcessEngineHealthDelta then
        return DTNPCLifecycle.ProcessEngineHealthDelta(zombie, npcData)
    end
    return false, false
end
