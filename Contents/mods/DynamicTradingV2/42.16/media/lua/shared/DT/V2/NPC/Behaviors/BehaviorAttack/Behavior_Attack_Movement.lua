-- ==============================================================================
-- Behavior_Attack_Movement.lua
-- Live movement-state helpers for hostile attack behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}

BehaviorAttack.Modules = modules

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

function BehaviorAttack.GetTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end
