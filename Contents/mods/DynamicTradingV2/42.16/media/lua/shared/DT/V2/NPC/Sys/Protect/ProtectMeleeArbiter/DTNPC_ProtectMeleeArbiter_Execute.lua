-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_Execute.lua
-- Main melee arbiter execution for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getTargetKey = Internal.GetMeleeArbiterTargetKey
local getTargetDistance = Internal.GetMeleeArbiterTargetDistance
local isPlayerTarget = Internal.IsMeleeArbiterPlayerTarget
local resetForTarget = Internal.ResetMeleeArbiterForTarget
local ensureManualControl = Internal.EnsureMeleeArbiterManualControl
local stopMoveAnim = Internal.StopMeleeArbiterMoveAnim
local setPhase = Internal.SetMeleeArbiterPhase
local moveTowardTarget = Internal.MoveMeleeArbiterTowardTarget
local moveAwayFromPoint = Internal.MoveMeleeArbiterAwayFromPoint
local isSevereDanger = Internal.IsSevereMeleeArbiterDanger
local preserveAttackWindup = Internal.PreserveMeleeArbiterAttackWindup
local maybeAnnounceCrowdRefusal = Internal.MaybeAnnounceMeleeArbiterCrowdRefusal
local commitAttack = Internal.CommitMeleeArbiterAttack
local nowMillis = Internal.nowMillis
local DEFAULT_SPEED = Internal.MeleeArbiterDefaultSpeed
local ENTER_BUFFER = Internal.MeleeArbiterEnterBuffer
local HOLD_BUFFER = Internal.MeleeArbiterHoldBuffer
local STOP_BUFFER = Internal.MeleeArbiterStopBuffer
local RETREAT_LOCK_MS = Internal.MeleeArbiterRetreatLockMs
local PASSAGE_LOCK_MS = Internal.MeleeArbiterPassageLockMs

function DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, options)
    options = type(options) == "table" and options or {}

    if not zombie or not npcData or not target or target:isDead() then
        if npcData then
            npcData.attackTimer = 0
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        return {
            status = "invalid",
            moved = false,
            attacked = false,
            distance = 9999,
        }
    end

    local capable = true
    local blockReason = nil
    if DTNPCProtect.IsCombatCapable then
        capable, blockReason = DTNPCProtect.IsCombatCapable(zombie, npcData)
    end
    if not capable then
        if DTNPCProtect.StopCombatActions then
            DTNPCProtect.StopCombatActions(zombie, npcData, blockReason)
        end
        DTNPCProtect.ResetMeleeCombat(npcData)
        return {
            status = "not_capable",
            moved = false,
            attacked = false,
            distance = getTargetDistance(zombie, target),
            reason = blockReason,
        }
    end

    local targetKey = getTargetKey(target)
    resetForTarget(npcData, targetKey)
    ensureManualControl(zombie, target, options)

    local stats = options.stats or DTNPCProtect.GetMeleeCombatStats(npcData)
    stats = type(stats) == "table" and stats or {}
    stats.attackRate = tonumber(stats.attackRate) or 28
    stats.hitChance = tonumber(stats.hitChance) or 65
    stats.damage = tonumber(stats.damage) or 0.45
    stats.chaseSpeed = tonumber(stats.chaseSpeed) or tonumber(options.defaultSpeed) or DEFAULT_SPEED
    if options.mode == "hostile" and isPlayerTarget(target) then
        stats.attackRate = math.max(stats.attackRate, 42)
        stats.hitChance = math.min(stats.hitChance, 72)
        stats.chaseSpeed = math.min(stats.chaseSpeed, 0.058)
    end
    local engageReach = math.max(
        tonumber(stats.reach) or tonumber(options.fallbackReach) or 1.25,
        tonumber(options.minimumReach) or 1.45
    )
    local enterRange = engageReach + (tonumber(options.enterBuffer) or ENTER_BUFFER)
    local holdRange = engageReach + (tonumber(options.holdBuffer) or HOLD_BUFFER)
    local stopDistance = math.max(0.9, engageReach - (tonumber(options.stopBuffer) or STOP_BUFFER))
    local currentDist = getTargetDistance(zombie, target)
    local currentPhase = npcData.meleeCombatPhase
    local currentTime = nowMillis()
    local phaseUntil = tonumber(npcData.meleeCombatPhaseUntil) or 0
    local dangerState = DTNPCProtect.GetMeleeDangerState
        and DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, {
            engageReach = engageReach,
            retreatDistance = engageReach + 0.7,
        })
        or nil
    local recovering = false
    local recovery = nil
    if DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if currentDist <= holdRange
        and not (options.mode == "hostile" and isPlayerTarget(target))
        and not (recovering and recovery and recovery.reason == "stamina") then
        recovering = false
    end

    if currentPhase == "passage" and phaseUntil > 0 and currentTime > 0 and currentTime < phaseUntil then
        preserveAttackWindup(npcData, stats)
        return {
            status = "passage",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = "passage_wait",
        }
    end

    if currentPhase == "retreat" and phaseUntil > 0 and currentTime > 0 and currentTime < phaseUntil then
        preserveAttackWindup(npcData, stats)
        local moved, moveState = moveAwayFromPoint(
            zombie,
            npcData,
            stats,
            target:getX(),
            target:getY(),
            holdRange + 0.45,
            options
        )
        return {
            status = moveState == "leash" and "leash" or "retreat",
            moved = moved == true,
            attacked = false,
            distance = currentDist,
            reason = "retreat_lock",
            moveState = moveState,
        }
    end

    local forcedRetreat = DTNPCMobility.GetForcedRetreat and DTNPCMobility.GetForcedRetreat(zombie, npcData, {
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
    }) or nil
    if forcedRetreat then
        preserveAttackWindup(npcData, stats)
        setPhase(npcData, "retreat", math.max(options.retreatLockMs or RETREAT_LOCK_MS, forcedRetreat.lockMs or 0))
        local moved, moveState = moveAwayFromPoint(
            zombie,
            npcData,
            stats,
            forcedRetreat.fromX or target:getX(),
            forcedRetreat.fromY or target:getY(),
            forcedRetreat.desiredDistance or (holdRange + 0.45),
            {
                blockCounterKey = options.blockCounterKey,
                retreatStuckTicks = options.retreatStuckTicks,
                anchorX = options.anchorX,
                anchorY = options.anchorY,
                anchorZ = options.anchorZ,
                leashRadius = options.leashRadius,
                allowDamageRetreat = false,
            }
        )
        return {
            status = moveState == "leash" and "leash" or "retreat",
            moved = moved == true,
            attacked = false,
            distance = currentDist,
            reason = "damage_retreat",
            moveState = moveState,
        }
    end

    local shouldRetreat = isSevereDanger(dangerState)
    if shouldRetreat then
        maybeAnnounceCrowdRefusal(zombie, npcData, dangerState)
        preserveAttackWindup(npcData, stats)
        setPhase(npcData, "retreat", options.retreatLockMs or RETREAT_LOCK_MS)
        local retreatRun = dangerState.selfPressure
            and (tonumber(dangerState.selfPressure.count) or 0) >= 3
            or dangerState.recentZombieDamage == true
            or dangerState.recentHostileDamage == true

        local retreatDistance = math.max(
            engageReach + 0.8,
            tonumber(dangerState.retreatDistance) or (engageReach + 1.2)
        )
        local moved, moveState = moveAwayFromPoint(
            zombie,
            npcData,
            stats,
            dangerState.fleeFromX or target:getX(),
            dangerState.fleeFromY or target:getY(),
            retreatDistance,
            {
                blockCounterKey = options.blockCounterKey,
                retreatStuckTicks = options.retreatStuckTicks,
                anchorX = options.anchorX,
                anchorY = options.anchorY,
                anchorZ = options.anchorZ,
                leashRadius = options.leashRadius,
                allowDamageRetreat = options.allowDamageRetreat,
                damageRetreatDistance = options.damageRetreatDistance,
                damageRetreatLockMs = options.damageRetreatLockMs,
                retreatRun = retreatRun,
            }
        )

        return {
            status = moveState == "leash" and "leash" or "retreat",
            moved = moved == true,
            attacked = false,
            distance = currentDist,
            reason = dangerState.reason or "danger",
            moveState = moveState,
        }
    end

    if recovering then
        preserveAttackWindup(npcData, stats)
        setPhase(npcData, "retreat", options.retreatLockMs or RETREAT_LOCK_MS)
        local retreatDistance = math.max(engageReach + 0.45, recovery and recovery.distance or (engageReach + 0.7))
        local moved, moveState = moveAwayFromPoint(
            zombie,
            npcData,
            stats,
            target:getX(),
            target:getY(),
            retreatDistance,
            options
        )
        return {
            status = moveState == "leash" and "leash" or "retreat",
            moved = moved == true,
            attacked = false,
            distance = currentDist,
            reason = recovery and recovery.reason or "recovery",
            moveState = moveState,
        }
    end

    local committed = currentPhase == "commit" and currentDist <= holdRange
    if currentDist <= enterRange or committed then
        return commitAttack(zombie, npcData, target, targetKey, stats, currentDist, options)
    end

    preserveAttackWindup(npcData, stats)
    setPhase(npcData, "approach", 0)
    npcData.meleeContactPrimed = false
    local moved, moveState = moveTowardTarget(zombie, npcData, target, stats, stopDistance, options)

    if moveState == "leash" then
        setPhase(npcData, "blocked", 0)
        return {
            status = "leash",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = "leash",
            moveState = moveState,
        }
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        setPhase(npcData, "passage", options.passageLockMs or PASSAGE_LOCK_MS)
        return {
            status = "passage",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = moveState,
            moveState = moveState,
        }
    end

    if moveState == "exhausted" then
        setPhase(npcData, "recovering", options.retreatLockMs or RETREAT_LOCK_MS)
        stopMoveAnim(zombie, npcData)
        return {
            status = "recovering",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = "stamina",
            moveState = moveState,
        }
    end

    if moved or moveState == "moving" or moveState == "unstuck" then
        return {
            status = "approach",
            moved = true,
            attacked = false,
            distance = currentDist,
            reason = moveState or "moving",
            moveState = moveState,
        }
    end

    if moveState == "arrived" or moveState == "close_enough" then
        currentDist = getTargetDistance(zombie, target)
        if currentDist <= holdRange then
            return commitAttack(zombie, npcData, target, targetKey, stats, currentDist, options)
        end
    end

    setPhase(npcData, "blocked", 0)
    stopMoveAnim(zombie, npcData)
    return {
        status = "blocked",
        moved = false,
        attacked = false,
        distance = currentDist,
        reason = moveState or "blocked",
        moveState = moveState,
    }
end
