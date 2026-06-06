-- ==============================================================================
-- DTNPC_LifecycleFinalDeath_IncapacitatedDamage.lua
-- Incapacitated damage handling for lifecycle final-death flow.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal

function DTNPCLifecycle.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false, false
    end

    local resolvedDamage = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    local takenMultiplier = tonumber(context.damageTakenMultiplier) or nil
    if context.damageScaled ~= true then
        if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.getNPCDamageTakenMultiplier then
            takenMultiplier = math.max(0, tonumber(DTNPCHealth.Internal.getNPCDamageTakenMultiplier()) or 1.0)
        else
            takenMultiplier = 1.0
        end
        resolvedDamage = math.max(DTNPCHealth.MIN_DAMAGE, resolvedDamage * takenMultiplier)
        context.damageScaled = true
        context.damageTakenMultiplier = takenMultiplier
        context.rawDamage = tonumber(amount) or 0
    else
        takenMultiplier = tonumber(takenMultiplier) or 1.0
    end

    local currentTime = internal.nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    if DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.capturePlayerAttacker then
        healthInternal.capturePlayerAttacker(npcData, attacker)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "HandleIncapacitatedDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " amount=" .. tostring(resolvedDamage)
            .. " rawAmount=" .. tostring(context.rawDamage or amount)
            .. " takenMultiplier=" .. tostring(takenMultiplier)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " currentTime=" .. tostring(currentTime)
            .. " graceUntil=" .. tostring(graceUntil)
    )

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = resolvedDamage
        combatHealth.lastAttackerType = internal.getAttackerType(attacker)
        combatHealth.lastAttackerID = internal.getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        if healthInternal and healthInternal.syncAndPersistHealth then
            healthInternal.syncAndPersistHealth(zombie, npcData, false, true)
        end
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.current = 0
    combatHealth.incapGraceUntil = 0
    combatHealth.incapFinalKillRequestedAt = currentTime
    npcData.healthState = nil
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = resolvedDamage
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
        DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
        return true, true
    end

    return false, false
end
