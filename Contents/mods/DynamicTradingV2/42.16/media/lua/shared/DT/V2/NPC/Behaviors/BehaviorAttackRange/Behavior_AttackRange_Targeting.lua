-- ==============================================================================
-- Behavior_AttackRange_Targeting.lua
-- Target resolution and temporary busy-state handlers for ranged combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange
local modules = BehaviorAttackRange.Modules or {}
local Constants = BehaviorAttackRange.Constants or {}

BehaviorAttackRange.Modules = modules
BehaviorAttackRange.Constants = Constants

if modules.Targeting then
    return
end

modules.Targeting = true

function BehaviorAttackRange.ResolveCombatTarget(zombie, npcData, target, dist)
    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            zombie:setTarget(nil)
        end
    end

    if not target or target:isDead() then
        if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.HandleMissingHostileTarget then
            local replacementTarget, replacementDist, handled = DTNPCLogic.BehaviorAttack.HandleMissingHostileTarget(zombie, npcData)
            if handled then
                return nil, nil, nil, true
            end
            if replacementTarget then
                target = replacementTarget
                dist = replacementDist
            end
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        BehaviorAttackRange.StopMoveAnim(zombie)
        zombie:setTarget(nil)
        return nil, nil, nil, true
    end

    if DTNPCLogic.BehaviorAttack and DTNPCLogic.BehaviorAttack.ClearHostileNoTargetState then
        DTNPCLogic.BehaviorAttack.ClearHostileNoTargetState(npcData)
    end

    if DTNPCLogic.HandleHostileLostSight
        and DTNPCLogic.HandleHostileLostSight(zombie, npcData, target, dist, { speed = Constants.SPEED_FWD }) then
        return nil, nil, nil, true
    end
    if DTNPCLogic.HandleHostileChaseGiveUp
        and DTNPCLogic.HandleHostileChaseGiveUp(zombie, npcData, target, dist) then
        return nil, nil, nil, true
    end

    if DTNPCProtect and DTNPCProtect.IsCombatCapable then
        local capable, reason = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, reason)
            end
            return nil, nil, nil, true
        end
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "AttackRange", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist)

    return target, dist, resolvedState, false
end

function BehaviorAttackRange.HandleCombatBusy(zombie, npcData, target, tx, ty)
    if DTNPCProtect and DTNPCProtect.UpdateRangedReloadAction then
        local busy, busyReason = DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
        if busy then
            BehaviorAttackRange.StopMoveAnim(zombie)
            if DTNPC and DTNPC.SetRangedCombatIdleState then
                DTNPC.SetRangedCombatIdleState(zombie, npcData)
            end
            return true
        end
        if busyReason == "reloaded" and DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if DTNPCMobility and DTNPCMobility.IsSpecialActionActive then
        local specialActive = DTNPCMobility.IsSpecialActionActive(npcData)
        if specialActive and npcData._dtSpecialAction == "fence" then
            if DTNPCMobility.UpdateSpecialAction then
                DTNPCMobility.UpdateSpecialAction(zombie, npcData)
            end
            zombie:faceLocation(tx, ty)
            return true
        end
    end

    return false
end
