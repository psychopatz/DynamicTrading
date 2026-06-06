-- ==============================================================================
-- Behavior_AttackRange_Behavior.lua
-- Main hostile ranged behavior entry.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange
local modules = BehaviorAttackRange.Modules or {}
local Constants = BehaviorAttackRange.Constants or {}

BehaviorAttackRange.Modules = modules
BehaviorAttackRange.Constants = Constants

if modules.Behavior then
    return
end

modules.Behavior = true

DTNPCLogic.Behaviors["AttackRange"] = function(zombie, npcData, target, dist)
    if not npcData or npcData.state ~= "AttackRange" then
        return
    end

    local resolvedTarget, resolvedDist, resolvedState, handled = BehaviorAttackRange.ResolveCombatTarget(
        zombie,
        npcData,
        target,
        dist
    )
    if handled then
        return
    end

    target = resolvedTarget
    dist = resolvedDist

    if resolvedState ~= "AttackRange" then
        if DTNPCLogic.Behaviors["Attack"] then
            npcData.state = "Attack"
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
        end
        return
    end

    BehaviorAttackRange.EnsureManualControl(zombie)
    zombie:setTarget(nil)

    local tx = target:getX()
    local ty = target:getY()

    if BehaviorAttackRange.HandleCombatBusy(zombie, npcData, target, tx, ty) then
        return
    end

    local movement = BehaviorAttackRange.BuildMovementContext(zombie, npcData, target, tx, ty)
    local isMoving = BehaviorAttackRange.ApplyMovement(zombie, npcData, target, tx, ty, movement)

    if not isMoving and movement.distance > 0.001 then
        zombie:faceLocation(tx, ty)
    end

    if movement.distance > Constants.MAX_RANGE then
        return
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if BehaviorAttackRange.IsPlayerTarget(target) then
        stats.fireRate = math.max(72, tonumber(stats.fireRate) or 72)
        stats.hitStill = math.min(tonumber(stats.hitStill) or 0, 58)
        stats.hitMove = math.min(tonumber(stats.hitMove) or 0, 28)
    end
    if movement.recovering then
        npcData.attackTimer = 0
        return
    end

    if npcData.burstRemaining and npcData.burstRemaining > 0 then
        npcData.burstTimer = (npcData.burstTimer or 0) + 1
        local burstShotSpecs = npcData.shotSpecs
        if burstShotSpecs and npcData.burstTimer >= (burstShotSpecs.recoilDelay or 10) then
            npcData.burstTimer = 0
            npcData.burstRemaining = npcData.burstRemaining - 1
            BehaviorAttackRange.PerformRangedShot(zombie, npcData, target, stats, burstShotSpecs)
        end
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer >= stats.fireRate then
        npcData.attackTimer = 0

        local shotSpecs = DTNPCProtect.GetRangedShotSpecs(npcData)
        BehaviorAttackRange.PerformRangedShot(zombie, npcData, target, stats, shotSpecs)

        if shotSpecs.isAuto and ZombRand(100) < 60 then
            npcData.burstRemaining = ZombRand(2, 5)
            npcData.burstTimer = 0
            npcData.shotSpecs = shotSpecs
        end
    end
end
