-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_Companion.lua
-- Companion notice helpers for DTNPC guarded combat.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

function DTNPCProtect.PushCompanionModeNotice(zombie, npcData, dialogueStatus, dialogueState, mode)
    if not npcData then
        return false
    end
    if mode and npcData.companionAmbientMode == mode then
        return false
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionAmbientCue then
        if DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState) then
            npcData.companionAmbientMode = mode or npcData.companionAmbientMode
            return true
        end
    end

    return false
end

function DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, mode)
    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if npcData.companionCombatActive == true and npcData.companionLastCombatTargetID == targetID then
        return
    end

    npcData.companionCombatActive = true
    npcData.companionLastCombatTargetID = targetID
    npcData.companionLastRangedTargetID = nil
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "Attack", mode or "combat")
end

function DTNPCProtect.AnnounceCompanionRangedAttack(zombie, npcData, mode)
    if not npcData then
        return
    end

    local targetID = npcData.combatTargetID
    if not targetID or npcData.companionLastRangedTargetID == targetID then
        return
    end

    npcData.companionLastRangedTargetID = targetID
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "AttackRange", mode or "ranged")
end

function DTNPCProtect.AnnounceCompanionCombatReturn(zombie, npcData, mode)
    if not npcData or npcData.companionCombatActive ~= true then
        return
    end

    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil
    DTNPCProtect.PushCompanionModeNotice(zombie, npcData, "Companion", "Return", mode or "return")
end
