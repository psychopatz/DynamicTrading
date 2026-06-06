-- ==============================================================================
-- Behavior_Attack_Behavior.lua
-- Main hostile melee behavior entry.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}
local Constants = BehaviorAttack.Constants or {}

BehaviorAttack.Modules = modules
BehaviorAttack.Constants = Constants

if modules.Behavior then
    return
end

modules.Behavior = true

DTNPCLogic.Behaviors["Attack"] = function(zombie, npcData, target, dist)
    if not npcData then
        BehaviorAttack.RunLegacyWakeup(zombie, target, dist)
        return
    end

    if npcData.state ~= "Attack" then
        BehaviorAttack.RunLegacyWakeup(zombie, target, dist)
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            zombie:setTarget(nil)
        end
    end

    if not target or target:isDead() then
        if BehaviorAttack.HandleMissingHostileTarget then
            local replacementTarget, replacementDist, handled = BehaviorAttack.HandleMissingHostileTarget(zombie, npcData)
            if handled then
                return
            end
            if replacementTarget then
                target = replacementTarget
                dist = replacementDist
            end
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        BehaviorAttack.StopMoveAnim(zombie, npcData)
        zombie:setTarget(nil)
        return
    end

    if BehaviorAttack.ClearHostileNoTargetState then
        BehaviorAttack.ClearHostileNoTargetState(npcData)
    end

    if DTNPCLogic.HandleHostileLostSight
        and DTNPCLogic.HandleHostileLostSight(zombie, npcData, target, dist, { speed = Constants.MELEE_DEFAULT_SPEED }) then
        return
    end
    if DTNPCLogic.HandleHostileChaseGiveUp
        and DTNPCLogic.HandleHostileChaseGiveUp(zombie, npcData, target, dist) then
        return
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist) or BehaviorAttack.GetTargetDistance(zombie, target)

    if resolvedState ~= "Attack" then
        if resolvedState == "AttackRange" and DTNPCLogic.Behaviors["AttackRange"] then
            npcData.state = "AttackRange"
            DTNPCLogic.Behaviors["AttackRange"](zombie, npcData, target, dist)
            return
        end
        BehaviorAttack.RunLegacyWakeup(zombie, target, dist)
        return
    end

    local actualDist = tonumber(dist) or BehaviorAttack.GetTargetDistance(zombie, target)
    local moveThreshold = Constants.MELEE_DEFAULT_REACH + Constants.MELEE_APPROACH_STOP_BUFFER + 0.35
    if actualDist > moveThreshold then
        local dx = target:getX() - zombie:getX()
        local dy = target:getY() - zombie:getY()
        local chaseSpeed = Constants.MELEE_DEFAULT_SPEED
        if BehaviorAttack.PrimeMovement
            and not BehaviorAttack.PrimeMovement(zombie, npcData, dx, dy, chaseSpeed > 0.06, "hostile-melee-approach") then
            return
        end
    else
        npcData.attackMovePrimed = nil
        npcData.attackMoveReason = nil
    end

    BehaviorAttack.EnsureManualControl(zombie)
    zombie:setTarget(nil)

    if DTNPCProtect and DTNPCProtect.ExecuteMeleeCombat then
        DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
            mode = "hostile",
            blockCounterKey = "attackBlockedTicks",
            fallbackReach = Constants.MELEE_DEFAULT_REACH,
            defaultSpeed = Constants.MELEE_DEFAULT_SPEED,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = Constants.MELEE_APPROACH_STOP_BUFFER,
        })
    end
end
