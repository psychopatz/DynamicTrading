-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_Shared.lua
-- Shared helpers for DTNPC guarded combat modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

require "DT/V2/Systems/Firearm/DT_FirearmSystem"

local Internal = DTNPCProtect.Internal

Internal.GuardedCombatKiteMin = 3.25
Internal.GuardedCombatKiteMax = 8.5
Internal.GuardedCombatMaxRange = 13.5
Internal.GuardedCombatAdvanceSpeed = 0.05
Internal.GuardedCombatBackpedalSpeed = 0.03

local function performRangedShot(zombie, npcData, target, stats, shotSpecs, moved, options)
    if not zombie or not npcData or not target then
        return false
    end

    options = type(options) == "table" and options or {}

    if options.onRangedAttack then
        options.onRangedAttack(zombie, npcData, target)
    end
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

    local hitChance = moved and stats.hitMove or stats.hitStill
    local hit = false
    if ZombRand(100) < hitChance then
        hit = DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
            attackType = "ranged",
            damage = stats.damage,
        }) == true
    end
    if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
        DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
    end
    return hit
end

local function faceTarget(zombie, target)
    if zombie and target then
        zombie:faceLocation(target:getX(), target:getY())
    end
end

local function stopMoveAnim(zombie, npcData)
    if npcData then
        npcData.isMovingState = false
    end
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
end

Internal.PerformGuardedRangedShot = performRangedShot
Internal.FaceGuardedCombatTarget = faceTarget
Internal.StopGuardedCombatMove = stopMoveAnim
