-- ==============================================================================
-- Behavior_AttackRange_Shared.lua
-- Shared constants and helper functions for hostile ranged combat.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange
local modules = BehaviorAttackRange.Modules or {}
local Constants = BehaviorAttackRange.Constants or {}

BehaviorAttackRange.Modules = modules
BehaviorAttackRange.Constants = Constants

if modules.Shared then
    return
end

modules.Shared = true

Constants.KITE_DIST_MIN = 3.5
Constants.KITE_DIST_MAX = 8.0
Constants.MAX_RANGE = 14.0
Constants.SPEED_FWD = 0.055
Constants.SPEED_BCK = 0.035
Constants.SPEED_RETREAT_RUN = 0.07
Constants.REACTION_DELAY = 30

function BehaviorAttackRange.PerformRangedShot(zombie, npcData, target, stats, shotSpecs)
    if not zombie or not npcData or not target then return end

    if DTNPC and DTNPC.TriggerRangedCombatAnim then
        DTNPC.TriggerRangedCombatAnim(zombie, npcData)
    end

    if DTNPCProtect and DTNPCProtect.ConsumeRangedShot then
        DTNPCProtect.ConsumeRangedShot(npcData, 1)
    elseif DTNPCProtect and DTNPCProtect.ConsumeAmmo then
        DTNPCProtect.ConsumeAmmo(npcData, 1)
    end

    if DTNPCProtect and DTNPCProtect.ConsumeWeaponCondition then
        DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
    end

    local emitter = zombie:getEmitter()
    if shotSpecs.shotSound then
        emitter:playSound(shotSpecs.shotSound)
    end
    if shotSpecs.shellSound then
        emitter:playSound(shotSpecs.shellSound)
    end

    if DT_FirearmSystem and DT_FirearmSystem.FireShot then
        DT_FirearmSystem.FireShot(zombie, target:getX(), target:getY(), target:getZ(), {
            weaponItem = shotSpecs.weaponItem,
        })
    end

    local isMoving = zombie:isMoving()
    local hitChance = isMoving and stats.hitMove or stats.hitStill
    if ZombRand(100) < hitChance then
        DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        })
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
    end
end

function BehaviorAttackRange.IsPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end
