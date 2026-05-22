-- ==============================================================================
-- Behavior_AttackRange_Movement.lua
-- Kiting and positioning helpers for hostile ranged combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange
local modules = BehaviorAttackRange.Modules or {}
local Constants = BehaviorAttackRange.Constants or {}

BehaviorAttackRange.Modules = modules
BehaviorAttackRange.Constants = Constants

if modules.Movement then
    return
end

modules.Movement = true

function BehaviorAttackRange.BuildMovementContext(zombie, npcData, target, tx, ty)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local dx = tx - zx
    local dy = ty - zy
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then
        dx = dx / distance
        dy = dy / distance
    end

    if not npcData.reactionTimer then npcData.reactionTimer = 0 end

    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "ranged", target)
    end

    local desiredMin = recovering
        and math.max(Constants.KITE_DIST_MIN, recovery and recovery.distance or Constants.KITE_DIST_MIN)
        or Constants.KITE_DIST_MIN
    local desiredMax = recovering
        and math.max(Constants.KITE_DIST_MAX, desiredMin + 0.75)
        or Constants.KITE_DIST_MAX
    local dangerState = DTNPCProtect and DTNPCProtect.GetMeleeDangerState
        and DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, {
            engageReach = desiredMin,
            retreatDistance = math.max(desiredMax + 1.25, desiredMin + 1.65),
            pressureRadius = 2.8,
            targetPressureRadius = 2.1,
        })
        or nil

    if dangerState and dangerState.shouldDisengage == true then
        desiredMin = math.max(desiredMin, tonumber(dangerState.retreatDistance) or (desiredMin + 1.65))
        desiredMax = math.max(desiredMax, desiredMin + 1.0)
    end

    local moveDir = 0
    local currentSpeed = 0
    local retreatFromX = tx
    local retreatFromY = ty
    local retreatRun = false

    if dangerState and dangerState.shouldDisengage == true then
        retreatFromX = tonumber(dangerState.fleeFromX) or tx
        retreatFromY = tonumber(dangerState.fleeFromY) or ty
        retreatRun = dangerState.selfPressure
            and (tonumber(dangerState.selfPressure.count) or 0) >= 3
            or dangerState.recentZombieDamage == true
            or dangerState.recentHostileDamage == true
        npcData.reactionTimer = Constants.REACTION_DELAY + 1
        moveDir = -1
        currentSpeed = retreatRun and Constants.SPEED_RETREAT_RUN or math.max(Constants.SPEED_BCK, Constants.SPEED_FWD)
    elseif distance < desiredMin then
        npcData.reactionTimer = npcData.reactionTimer + 1
        if npcData.reactionTimer > Constants.REACTION_DELAY then
            moveDir = -1
            currentSpeed = Constants.SPEED_BCK
        else
            moveDir = 0
        end
    elseif distance > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        currentSpeed = Constants.SPEED_FWD
    else
        npcData.reactionTimer = 0
        moveDir = 0
    end

    return {
        dx = dx,
        dy = dy,
        distance = distance,
        recovering = recovering,
        desiredMin = desiredMin,
        desiredMax = desiredMax,
        dangerState = dangerState,
        moveDir = moveDir,
        currentSpeed = currentSpeed,
        retreatFromX = retreatFromX,
        retreatFromY = retreatFromY,
        retreatRun = retreatRun,
    }
end

function BehaviorAttackRange.ApplyMovement(zombie, npcData, target, tx, ty, movement)
    local moveDir = movement.moveDir
    if moveDir == 0 then
        if DTNPCLogic.BehaviorAttack then
            npcData.attackMovePrimed = nil
            npcData.attackMoveReason = nil
        end
        BehaviorAttackRange.ForceCombatAnim(zombie, false)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
        return false
    end

    if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.PrimeMovement then
        local primeDir = moveDir > 0 and 1 or -1
        if not DTNPCLogic.BehaviorAttack.PrimeMovement(
            zombie,
            npcData,
            movement.dx * primeDir,
            movement.dy * primeDir,
            false,
            moveDir > 0 and "hostile-ranged-advance" or "hostile-ranged-retreat"
        ) then
            return false
        end
    end

    zombie:setVariable("DTIdleState", "0")
    local moved, moveState
    if moveDir > 0 then
        local navMode = (tonumber(npcData.attackRangeBlockedTicks) or 0) >= 2 and "planned" or "direct"
        moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
            target = target,
            speed = movement.currentSpeed,
            navigationMode = navMode,
            plannerProfile = "combat_short",
            staminaMode = "pursuit",
            desiredRun = false,
            stopDistance = movement.desiredMin + 0.1,
            allowObstacleInteract = true,
            allowDamageRetreat = true,
            blockCounterKey = "attackRangeBlockedTicks",
            stuckTicks = 12,
            faceX = tx,
            faceY = ty,
            closeDoorTarget = target,
            closeDoorSafeRadius = 3.0,
            anim = {
                animSpeed = 1.0,
                isRunning = false,
                dtWalkType = "Walk",
            },
        })
    else
        moved, moveState = DTNPCMobility.MoveAwayFromPoint(zombie, npcData, {
            fromX = movement.retreatFromX,
            fromY = movement.retreatFromY,
            speed = movement.currentSpeed,
            staminaMode = "retreat",
            desiredRun = movement.retreatRun == true,
            desiredDistance = movement.dangerState and movement.dangerState.shouldDisengage == true
                and math.max(movement.desiredMin + 0.75, tonumber(movement.dangerState.retreatDistance) or (movement.desiredMin + 1.5))
                or (movement.desiredMin + 0.75),
            allowObstacleInteract = true,
            allowDamageRetreat = true,
            blockCounterKey = "attackRangeBlockedTicks",
            stuckTicks = 12,
            faceX = tx,
            faceY = ty,
            faceTargetWhileMoving = true,
            closeDoorTarget = target,
            closeDoorSafeRadius = 3.0,
            anim = {
                animSpeed = movement.retreatRun and 1.15 or 1.0,
                isRunning = movement.retreatRun == true,
                dtWalkType = movement.retreatRun and "Run" or "Walk",
            },
        })
    end

    local isMoving = moved == true or moveState == "damage_retreat"
    if moveState == "exhausted" then
        isMoving = false
        BehaviorAttackRange.ForceCombatAnim(zombie, false)
    elseif moveState == "special_action" or moveState == "interacted_fence" then
        isMoving = false
    elseif isMoving then
        BehaviorAttackRange.ForceCombatAnim(zombie, true)
    elseif not (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
        BehaviorAttackRange.ForceCombatAnim(zombie, false)
    end

    return isMoving
end
