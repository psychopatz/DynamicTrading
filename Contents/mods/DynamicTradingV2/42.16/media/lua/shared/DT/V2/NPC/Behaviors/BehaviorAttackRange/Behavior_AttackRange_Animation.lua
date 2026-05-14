-- ==============================================================================
-- Behavior_AttackRange_Animation.lua
-- Movement and locomotion helpers for hostile ranged combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange
local modules = BehaviorAttackRange.Modules or {}

BehaviorAttackRange.Modules = modules

if modules.Animation then
    return
end

modules.Animation = true

function BehaviorAttackRange.StopMoveAnim(zombie)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

function BehaviorAttackRange.EnsureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

function BehaviorAttackRange.ForceCombatAnim(zombie, isMoving)
    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            moving = isMoving == true,
            isRunning = false,
            dtWalkType = "Walk",
            animSpeed = isMoving and 1.0 or 0.0,
        })
        return
    end

    if isMoving then
        zombie:setVariable("bMoving", true)
        zombie:setVariable("isMoving", true)
        zombie:setVariable("WalkType", "1")
        zombie:setVariable("Speed", 1.0)
        zombie:setRunning(false)
    else
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("Speed", 0.0)
        zombie:setRunning(false)
    end
end
