-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_logic.lua
-- Shared melee combat controller for hostile, protect, and trading defense modes.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID
local nowMillis = Internal.nowMillis

local DEFAULT_SPEED = 0.05
local ENTER_BUFFER = 0.25
local HOLD_BUFFER = 0.45
local STOP_BUFFER = 0.16
local RETREAT_LOCK_MS = 450
local PASSAGE_LOCK_MS = 350

local function getTargetKey(target)
    if not target then
        return nil
    end
    if instanceof and instanceof(target, "IsoPlayer") then
        return getPlayerRuntimeID and getPlayerRuntimeID(target) or tostring(target)
    end
    return getZombieRuntimeID and getZombieRuntimeID(target) or tostring(target)
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

local function resetMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.attackMovePrimed = nil
    npcData.protectMovePrimed = nil
    npcData.tradingMovePrimed = nil
end

local function stopMoveAnim(zombie, npcData)
    resetMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

local function setPhase(npcData, phase, lockMs)
    if not npcData then
        return
    end

    npcData.meleeCombatPhase = phase
    npcData.meleeCombatPhaseUntil = (tonumber(lockMs) or 0) > 0 and (nowMillis() + lockMs) or 0
    npcData.meleeCombatLastDecisionAt = nowMillis()
end

local function resetForTarget(npcData, targetKey)
    if not npcData then
        return
    end

    if npcData.meleeCombatTargetKey == targetKey then
        return
    end

    npcData.meleeCombatTargetKey = targetKey
    npcData.meleeCombatPhase = nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.meleeCombatLastDecisionAt = 0
    npcData.attackTimer = 0
    npcData.meleeContactTargetKey = nil
    npcData.meleeContactPrimed = nil
end

function DTNPCProtect.ResetMeleeCombat(npcData)
    if not npcData then
        return
    end

    npcData.meleeCombatTargetKey = nil
    npcData.meleeCombatPhase = nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.meleeCombatLastDecisionAt = 0
    npcData.meleeContactTargetKey = nil
    npcData.meleeContactPrimed = nil
end

local function ensureManualControl(zombie, target, options)
    if options and options.ensureManualControl == false then
        return
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
    if target and not isPlayerTarget(target) then
        zombie:setTarget(target)
    end
end

local function moveTowardTarget(zombie, npcData, target, stats, stopDistance, options)
    local speed = stats.chaseSpeed or options.defaultSpeed or DEFAULT_SPEED
    local moved, state, distance = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        stopDistance = stopDistance,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks or 10,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        allowObstacleInteract = options.allowObstacleInteract ~= false,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        closeDoorSafeRadius = options.closeDoorSafeRadius or 3.0,
        anim = {
            animSpeed = speed > 0.06 and 1.15 or 1.0,
            isRunning = speed > 0.06,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") then
        npcData.isMovingState = true
    end

    return moved, state, distance
end

local function moveAwayFromPoint(zombie, npcData, stats, sourceX, sourceY, desiredDistance, options)
    local speed = math.max(0.034, (stats.chaseSpeed or options.defaultSpeed or DEFAULT_SPEED) * 0.9)
    local moved, state, distance = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
        fromX = sourceX,
        fromY = sourceY,
        speed = speed,
        desiredDistance = desiredDistance,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.retreatStuckTicks or 8,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        allowObstacleInteract = false,
        allowDamageRetreat = options.allowDamageRetreat ~= false,
        damageRetreatDistance = options.damageRetreatDistance,
        damageRetreatLockMs = options.damageRetreatLockMs,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") then
        npcData.isMovingState = true
    end

    return moved, state, distance
end

local function isSevereDanger(dangerState)
    if not dangerState or dangerState.shouldDisengage ~= true then
        return false
    end

    if dangerState.reason == "low_health" then
        return true
    end

    local selfPressure = dangerState.selfPressure or {}
    local targetPressure = dangerState.targetPressure or {}
    local severeThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdSevereThreshold) or 4
    return math.max(tonumber(selfPressure.count) or 0, tonumber(targetPressure.count) or 0) >= severeThreshold
end

local function preserveAttackWindup(npcData, stats)
    if not npcData then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    local cap = attackRate > 0 and math.floor(attackRate * 0.65) or 0
    npcData.attackTimer = math.min(tonumber(npcData.attackTimer) or 0, cap)
end

local function maybeAnnounceCrowdRefusal(zombie, npcData, dangerState)
    if not zombie or not npcData or not dangerState then
        return false
    end

    local reason = tostring(dangerState.reason or "")
    if reason ~= "crowd" and reason ~= "surrounded" and reason ~= "pressured" then
        return false
    end

    local currentTime = nowMillis()
    local lastTime = tonumber(npcData._dtCrowdRefuseNoticeAt) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < 4500 then
        return false
    end
    npcData._dtCrowdRefuseNoticeAt = currentTime

    if DTNPCProtect.PushCombatFlavorNotice then
        return DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, "CrowdRefuse", "warning", "Companion", "CrowdRefuse")
    end
    if DTNPCProtect.PushCompanionAmbientCue then
        return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, "Companion", "CrowdRefuse")
    end
    return false
end

local function primeContactSwing(npcData, targetKey, stats)
    if not npcData then
        return
    end

    if npcData.meleeContactTargetKey == targetKey and npcData.meleeContactPrimed == true then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    npcData.attackTimer = math.max(tonumber(npcData.attackTimer) or 0, math.max(0, attackRate - 6))
    npcData.meleeContactTargetKey = targetKey
    npcData.meleeContactPrimed = true
end

local function commitAttack(zombie, npcData, target, targetKey, stats, currentDist, options)
    local capable, reason = true, nil
    if DTNPCProtect.IsCombatCapable then
        capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
    end
    if not capable then
        if DTNPCProtect.StopCombatActions then
            DTNPCProtect.StopCombatActions(zombie, npcData, reason)
        end
        return {
            status = "not_capable",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = reason,
        }
    end

    setPhase(npcData, "commit", 0)
    stopMoveAnim(zombie, npcData)
    zombie:faceLocation(target:getX(), target:getY())
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    if not (options.mode == "hostile" and isPlayerTarget(target)) then
        primeContactSwing(npcData, targetKey, stats)
    end
    npcData.attackTimer = (tonumber(npcData.attackTimer) or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        return {
            status = "commit",
            moved = false,
            attacked = false,
            distance = currentDist,
            reason = "windup",
        }
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)

    local hit = false
    if ZombRand(100) < stats.hitChance then
        hit = DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        }) == true
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "melee", target)
    end

    return {
        status = "commit",
        moved = false,
        attacked = true,
        hit = hit,
        distance = currentDist,
        reason = "swing",
    }
end

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

    local capable, blockReason = true, nil
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
    local recovering, recovery = false, nil
    if DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if currentDist <= holdRange and not (options.mode == "hostile" and isPlayerTarget(target)) then
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
            options
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

    if recovering and currentDist > holdRange then
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
            reason = "recovery",
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
