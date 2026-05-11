-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_Control.lua
-- Manual combat control and reset helpers for DTNPC guarded combat.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

function DTNPCProtect.EnsureManualCombatControl(zombie)
    if not zombie then
        return
    end
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

function DTNPCProtect.ResetGuardedCombatState(zombie, npcData, options)
    options = type(options) == "table" and options or {}

    if npcData then
        npcData.attackTimer = 0
        npcData.reactionTimer = 0
        npcData.guardReturningToPost = nil
        if options.clearAutoProtectState ~= false then
            npcData.autoProtectActiveState = nil
        end

        if options.resetMoveState then
            options.resetMoveState(npcData)
        else
            npcData.isMovingState = false
        end

        if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
            DTNPCProtect.ClearCombatTarget(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end

        if options.clearCompanion == true then
            npcData.companionCombatActive = false
            npcData.companionLastCombatTargetID = nil
            npcData.companionLastRangedTargetID = nil
        end
    end

    if zombie then
        zombie:setTarget(nil)
    end
end
