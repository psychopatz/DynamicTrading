-- ==============================================================================
-- Behavior_Attack_Movement.lua
-- Live movement-state helpers for hostile attack behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}
local Constants = BehaviorAttack.Constants or {}

BehaviorAttack.Modules = modules
BehaviorAttack.Constants = Constants

if modules.Movement then
    return
end

modules.Movement = true

function BehaviorAttack.ResetAttackMoveState(npcData)
    if not npcData then
        return
    end

    npcData.isMovingState = false
    npcData.attackMovePrimed = nil
    npcData.attackMoveReason = nil
end

function BehaviorAttack.StopMoveAnim(zombie, npcData)
    BehaviorAttack.ResetAttackMoveState(npcData)
    DTNPCMobility.Stop(zombie)
end

function BehaviorAttack.EnsureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

function BehaviorAttack.ForceMoveAnim(zombie, isRunning)
    if not zombie then
        return
    end

    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            moving = true,
            animSpeed = isRunning and 1.15 or 1.0,
            isRunning = isRunning == true,
            dtWalkType = isRunning and "Run" or "Walk",
        })
        return
    end

    zombie:setVariable("DTIdleState", "0")
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("WalkType", "1")
    zombie:setVariable("Speed", isRunning and 1.15 or 1.0)
    zombie:setRunning(isRunning == true)
end

function BehaviorAttack.PrimeMovement(zombie, npcData, dirX, dirY, isRunning, reason)
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
    npcData.attackMoveReason = reason or "hostile-move"
    BehaviorAttack.ForceMoveAnim(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + moveDirX, zombie:getY() + moveDirY)
    return false
end

function BehaviorAttack.GetTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end
