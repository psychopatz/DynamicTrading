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

    BehaviorAttack.EnsureManualControl(zombie)
    if BehaviorAttack.IsPlayerTarget(target) then
        zombie:setTarget(nil)
    else
        zombie:setTarget(target)
    end

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
