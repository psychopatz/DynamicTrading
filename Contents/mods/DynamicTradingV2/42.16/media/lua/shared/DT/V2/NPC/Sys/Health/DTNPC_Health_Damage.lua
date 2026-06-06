-- ==============================================================================
-- DTNPC_Health_Damage.lua
-- Damage application, incapacitation, and fallback damage handling.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function resolveIncomingDamage(amount, context)
    local baseAmount = math.max(0, tonumber(amount) or 0)
    if baseAmount <= 0 then
        return 0, 1.0
    end

    context = type(context) == "table" and context or nil
    if context and context.damageScaled == true then
        return math.max(DTNPCHealth.MIN_DAMAGE, baseAmount), tonumber(context.damageTakenMultiplier) or 1.0
    end

    local multiplier = internal.getNPCDamageTakenMultiplier and internal.getNPCDamageTakenMultiplier() or 1.0
    multiplier = math.max(0, tonumber(multiplier) or 1.0)
    local resolvedDamage = baseAmount * multiplier

    if context then
        context.damageScaled = true
        context.damageTakenMultiplier = multiplier
        context.rawDamage = baseAmount
    end

    return math.max(DTNPCHealth.MIN_DAMAGE, resolvedDamage), multiplier
end

local function shouldQueueFallbackIgnore(context)
    context = type(context) == "table" and context or {}
    if context.queueFallbackIgnore == false then
        return false
    end

    return internal.isTrustedExplicitDamageSource
        and internal.isTrustedExplicitDamageSource(context.source)
        or false
end

local function shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    if DTNPCLifecycle and DTNPCLifecycle.ShouldIgnoreFriendlyFire then
        return DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context)
    end

    return false
end

local function shouldPlayHurtVocal(combatHealth, attacker, context)
    if not combatHealth or combatHealth.current <= 0 then
        return false
    end

    context = type(context) == "table" and context or {}
    if context.suppressHurtVocal == true then
        return false
    end

    local source = tostring(context.source or "")
    local attackerType = internal.getAttackerType(attacker)

    -- Engine fallback damage may inherit stale attackedBy attribution and create false vocal hits.
    if source == "engine_fallback" then
        return false
    end

    if attackerType == "zombie" then
        if source == "zombie_lease" then
            return true
        end
        return context.confirmedZombieHit == true
    end

    return attackerType ~= nil
end

local function raiseLinkedWorkerAlert(zombie, npcData, attacker, context)
    if not npcData or npcData.linkedWorkerID == nil or not DC_Colony or not DC_Colony.Defense or not DC_Colony.Defense.RaiseAlert then
        return
    end

    local point = nil
    if attacker and attacker.getX and attacker.getY then
        point = {
            x = math.floor(attacker:getX()),
            y = math.floor(attacker:getY()),
            z = math.floor(attacker.getZ and attacker:getZ() or 0),
        }
    elseif zombie and zombie.getX and zombie.getY then
        point = {
            x = math.floor(zombie:getX()),
            y = math.floor(zombie:getY()),
            z = math.floor(zombie.getZ and zombie:getZ() or 0),
        }
    end

    DC_Colony.Defense.RaiseAlert(npcData.ownerUsername, {
        source = "DTNPCHealth",
        reason = tostring(context and context.source or "damage"),
        target = attacker,
        point = point,
    })
end

function DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    local incapped = DTNPCLifecycle
        and DTNPCLifecycle.EnterIncapacitated
        and DTNPCLifecycle.EnterIncapacitated(zombie, npcData, attacker, context)
        or false

    if not incapped and DTNPCHealth and DTNPCHealth.EnsureDefaults then
        local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
        if combatHealth and combatHealth.current <= (tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01) then
            if DTNPCHealth.Internal and DTNPCHealth.Internal.setIncapacitatedState then
                DTNPCHealth.Internal.setIncapacitatedState(zombie, npcData)
                if DTNPCHealth.Internal.syncHealth then
                    DTNPCHealth.Internal.syncHealth(zombie, npcData, true)
                end
                incapped = true
            end
        end
    end
    
    if not incapped and DTNPCHostility and DTNPCHostility.PlayDeathSound then
        DTNPCHostility.PlayDeathSound(zombie, npcData)
    end
    if not incapped and DTNPC_ZombieAggro and DTNPC_ZombieAggro.EmitVocalNoise then
        DTNPC_ZombieAggro.EmitVocalNoise(zombie, npcData, "Death", {
            radius = 22,
            volume = 1.2,
            cooldownMs = 0,
        })
    end
    
    return incapped
end

function DTNPCHealth.ForceZeroHPTransition(zombie, npcData, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false
    end

    context = type(context) == "table" and context or {}
    combatHealth.current = 0
    combatHealth.lastDamageAt = internal.nowMillis()
    combatHealth.lastDamageSource = tostring(context.source or "forced_zero_hp_gate")
    npcData.health = 0
    npcData.lastHealth = 0

    if internal.syncDerivedHealthState then
        internal.syncDerivedHealthState(npcData, combatHealth)
    end

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    if zombie.setHealth then
        zombie:setHealth(0)
    end

    local handled = DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    if handled and npcData.incapState == "Active" and zombie.setHealth then
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
    end
    return handled
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

    if internal.resolveAuthoritativeNPCContext then
        zombie, npcData = internal.resolveAuthoritativeNPCContext(zombie, npcData)
    end

    context = type(context) == "table" and context or {}
    if npcData.incapState == "Active" then
        local incapDamage = resolveIncomingDamage(amount, context)
        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, incapDamage, attacker, context)
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false, false
    end

    if shouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local damage, takenMultiplier = resolveIncomingDamage(amount, context)
    local now = internal.nowMillis()
    local source = tostring(context.source or "")

    internal.capturePlayerAttacker(npcData, attacker)

    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastDamageSource = source ~= "" and source or nil
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if shouldQueueFallbackIgnore(context) then
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
            .. " rawDamage=" .. tostring(context.rawDamage or amount)
            .. " takenMultiplier=" .. tostring(takenMultiplier)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " customBefore=" .. tostring(combatHealth.current)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " engineHealth=" .. tostring(zombie:getHealth())
    )

    local currentBefore = internal.clamp(tonumber(combatHealth.current) or combatHealth.max, 0, combatHealth.max)
    local appliedDamage = math.min(damage, currentBefore)
    combatHealth.current = internal.clamp(currentBefore - damage, 0, combatHealth.max)
    if internal.syncDerivedHealthState then
        internal.syncDerivedHealthState(npcData, combatHealth)
    end

    internal.applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)
    raiseLinkedWorkerAlert(zombie, npcData, attacker, context)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    -- Play unique hurt sound based on character identity
    if shouldPlayHurtVocal(combatHealth, attacker, context)
        and DTNPCHostility
        and DTNPCHostility.PlayHurtSound then
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

    local zombie = nil
    if internal.resolveAuthoritativeNPCContext then
        zombie, npcData = internal.resolveAuthoritativeNPCContext(nil, npcData)
    end

    context = type(context) == "table" and context or {}
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false, false
    end

    if shouldIgnoreFriendlyFire(nil, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local damage, takenMultiplier = resolveIncomingDamage(amount, context)
    local now = internal.nowMillis()
    local source = tostring(context.source or "")

    internal.capturePlayerAttacker(npcData, attacker)
    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastDamageSource = source ~= "" and source or nil
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
            internal.syncAndPersistHealth(zombie, npcData, false, true)
            return true, false
        end

        combatHealth.engineProtected = false
        combatHealth.current = 0
        combatHealth.incapGraceUntil = 0
        combatHealth.incapFinalKillRequestedAt = now
        npcData.healthState = nil
        npcData.health = 0
        npcData.lastHealth = 0
        combatHealth.lastEngineHealth = 0
        internal.syncAndPersistHealth(zombie, npcData, true, true)
        return true, true
    end

    if combatHealth.enabled ~= true then
        return false, false
    end

    local currentBefore = internal.clamp(tonumber(combatHealth.current) or combatHealth.max, 0, combatHealth.max)
    local appliedDamage = math.min(damage, currentBefore)
    combatHealth.current = internal.clamp(currentBefore - damage, 0, combatHealth.max)
    if internal.syncDerivedHealthState then
        internal.syncDerivedHealthState(npcData, combatHealth)
    end
    internal.applyPlayerDamageReputationPenalty(npcData, combatHealth, attacker, appliedDamage)
    raiseLinkedWorkerAlert(nil, npcData, attacker, context)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "ApplyDamageToDataOnly name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context.source or "unknown")
            .. " damage=" .. tostring(damage)
            .. " rawDamage=" .. tostring(context.rawDamage or amount)
            .. " takenMultiplier=" .. tostring(takenMultiplier)
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
