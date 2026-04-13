-- ==============================================================================
-- Behavior_Attack.lua
-- Hostile melee combat plus legacy wake-up behavior for movement states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/DTNPC_Mobility"

local MELEE_DEFAULT_REACH = 1.25
local MELEE_DEFAULT_SPEED = 0.05
local MELEE_APPROACH_START_BUFFER = 0.18
local MELEE_APPROACH_STOP_BUFFER = 0.16

local function runLegacyWakeup(zombie, target, dist)
    if zombie:isUseless() then
        zombie:setUseless(false)
        zombie:setSpeedMod(1.1)
        zombie:DoZombieStats()
        zombie:setSitAgainstWall(false)
    end

    if target then
        zombie:setTarget(target)

        local shouldRun = (tonumber(dist) or 9999) > 3.0 or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)

        if not zombie:isMoving() and (tonumber(dist) or 9999) > 1.5 then
            zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
    elseif not zombie:isMoving() then
        zombie:setRunning(true)
    end
end

local function resetAttackMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.attackMovePrimed = nil
    npcData.attackMoveReason = nil
end

local function stopMoveAnim(zombie, npcData)
    resetAttackMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

local function forceWalkAnim(zombie, isRunning)
    DTNPCMobility.SetLocomotionState(zombie, {
        moving = true,
        animSpeed = isRunning and 1.15 or 1.0,
        isRunning = isRunning == true,
        walkType = "1",
    })
end

local function primeAttackMovement(zombie, npcData, dirX, dirY, isRunning, reason)
    if not zombie or not npcData then
        return true
    end

    local moveDirX = tonumber(dirX) or 0
    local moveDirY = tonumber(dirY) or 0
    local len = math.sqrt((moveDirX * moveDirX) + (moveDirY * moveDirY))
    if len <= 0.001 then
        return true
    end

    moveDirX = moveDirX / len
    moveDirY = moveDirY / len
    npcData.isMovingState = true

    if npcData.attackMovePrimed == true and npcData.attackMoveReason == reason then
        return true
    end

    npcData.attackMovePrimed = true
    npcData.attackMoveReason = reason or "move"
    forceWalkAnim(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + moveDirX, zombie:getY() + moveDirY)
    return false
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function moveTowardTarget(zombie, npcData, speed, target, stopDistance)
    local moved, state = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        stopDistance = stopDistance,
        blockCounterKey = "attackBlockedTicks",
        stuckTicks = 10,
        anim = {
            animSpeed = speed > 0.06 and 1.15 or 1.0,
            isRunning = speed > 0.06,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetAttackMoveState(npcData)
    end

    return moved or state == "arrived" or state == "close_enough", state
end

local function moveAwayFromPoint(zombie, npcData, speed, sourceX, sourceY, desiredDistance, faceTarget)
    local moved, state = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
        fromX = sourceX,
        fromY = sourceY,
        speed = speed,
        desiredDistance = desiredDistance,
        blockCounterKey = "attackBlockedTicks",
        stuckTicks = 8,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            walkType = "1",
        },
    })

    if moved and (state == "moving" or state == "unstuck") and npcData then
        npcData.isMovingState = true
    elseif npcData then
        resetAttackMoveState(npcData)
    end

    return moved or state == "spaced", state
end

local function preserveAttackWindup(npcData, stats)
    if not npcData then
        return
    end

    local attackRate = tonumber(stats and stats.attackRate) or 0
    local cap = attackRate > 0 and math.floor(attackRate * 0.5) or 0
    npcData.attackTimer = math.min(tonumber(npcData.attackTimer) or 0, cap)
end

DTNPCLogic.Behaviors["Attack"] = function(zombie, npcData, target, dist)
    if not npcData then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if npcData.state ~= "Attack" then
        runLegacyWakeup(zombie, target, dist)
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            target = currentTarget
            dist = getTargetDistance(zombie, currentTarget)
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        stopMoveAnim(zombie, npcData)
        zombie:setTarget(nil)
        return
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist) or getTargetDistance(zombie, target)

    if resolvedState ~= "Attack" then
        if resolvedState == "AttackRange" and DTNPCLogic.Behaviors["AttackRange"] then
            npcData.state = "AttackRange"
            DTNPCLogic.Behaviors["AttackRange"](zombie, npcData, target, dist)
            return
        end
        runLegacyWakeup(zombie, target, dist)
        return
    end

    ensureManualControl(zombie)
    zombie:setTarget(target)

    local stats = DTNPCProtect.GetMeleeCombatStats(npcData)
    local engageReach = math.max(stats.reach or MELEE_DEFAULT_REACH, 1.45)
    local attackRange = engageReach + MELEE_APPROACH_START_BUFFER
    local stopDistance = math.max(0.9, engageReach - MELEE_APPROACH_STOP_BUFFER)
    local currentDist = getTargetDistance(zombie, target)
    local recovering, recovery = false, nil
    local dangerState = DTNPCProtect and DTNPCProtect.GetMeleeDangerState
        and DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, {
            engageReach = engageReach,
            retreatDistance = engageReach + 0.7,
        })
        or nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "melee", target)
    end

    if dangerState and dangerState.shouldDisengage then
        preserveAttackWindup(npcData, stats)
        local retreatDistance = math.max(engageReach + 0.8, tonumber(dangerState.retreatDistance) or (engageReach + 1.2))
        local retreatDirX = zombie:getX() - (dangerState.fleeFromX or target:getX())
        local retreatDirY = zombie:getY() - (dangerState.fleeFromY or target:getY())
        if not primeAttackMovement(zombie, npcData, retreatDirX, retreatDirY, false, "danger-retreat") then
            return
        end
        local movedAway = moveAwayFromPoint(
            zombie,
            npcData,
            math.max(0.034, (stats.chaseSpeed or MELEE_DEFAULT_SPEED) * 0.9),
            dangerState.fleeFromX or target:getX(),
            dangerState.fleeFromY or target:getY(),
            retreatDistance
        )
        if not movedAway then
            stopMoveAnim(zombie, npcData)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        return
    end

    if recovering then
        npcData.attackTimer = 0
        local retreatDistance = math.max(engageReach + 0.45, recovery and recovery.distance or (engageReach + 0.7))
        if currentDist < retreatDistance then
            local retreatDirX = zombie:getX() - target:getX()
            local retreatDirY = zombie:getY() - target:getY()
            if not primeAttackMovement(zombie, npcData, retreatDirX, retreatDirY, false, "recover") then
                return
            end
            moveAwayFromPoint(
                zombie,
                npcData,
                math.max(0.028, (stats.chaseSpeed or MELEE_DEFAULT_SPEED) * 0.75),
                target:getX(),
                target:getY(),
                retreatDistance
            )
        else
            stopMoveAnim(zombie, npcData)
            if DTNPC and DTNPC.SetMeleeCombatIdleState then
                DTNPC.SetMeleeCombatIdleState(zombie, npcData)
            end
        end
        return
    end

    if currentDist > attackRange then
        local chaseSpeed = stats.chaseSpeed or MELEE_DEFAULT_SPEED
        local advanceDirX = target:getX() - zombie:getX()
        local advanceDirY = target:getY() - zombie:getY()
        if not primeAttackMovement(zombie, npcData, advanceDirX, advanceDirY, chaseSpeed > 0.06, "advance") then
            return
        end
        local arrived, moveState = moveTowardTarget(
            zombie,
            npcData,
            chaseSpeed,
            target,
            stopDistance
        )
        if not arrived then
            return
        end

        currentDist = getTargetDistance(zombie, target)
        if currentDist > attackRange then
            if moveState == "arrived" or moveState == "close_enough" then
                stopMoveAnim(zombie, npcData)
            end
            return
        end
    end

    stopMoveAnim(zombie, npcData)
    zombie:faceLocation(target:getX(), target:getY())
    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer < stats.attackRate then
        return
    end

    npcData.attackTimer = 0
    if DTNPC and DTNPC.TriggerMeleeCombatAnim then
        DTNPC.TriggerMeleeCombatAnim(zombie, npcData)
    end
    DTNPCProtect.ConsumeWeaponCondition(npcData, "melee", 1)

    if ZombRand(100) < stats.hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "melee",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "melee", target)
    end
end
