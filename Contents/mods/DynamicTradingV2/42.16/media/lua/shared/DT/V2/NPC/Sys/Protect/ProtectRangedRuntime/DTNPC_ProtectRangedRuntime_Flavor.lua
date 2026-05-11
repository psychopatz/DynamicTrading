-- ==============================================================================
-- DTNPC_ProtectRangedRuntime_Flavor.lua
-- Shared combat flavor helpers for DTNPC ranged runtime.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local function getFlavorLine(kind)
    return DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        or nil
end

function DTNPCProtect.GetCombatFlavorLine(kind, fallbackKind)
    return getFlavorLine(kind or fallbackKind)
end

function DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, kind, sentiment, dialogueStatus, dialogueState)
    if not npcData then
        return false
    end

    local line = getFlavorLine(kind)
    if line and line ~= "" and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "warning")
    end

    if DTNPCProtect.PushCompanionAmbientCue and dialogueStatus and dialogueState then
        return DTNPCProtect.PushCompanionAmbientCue(zombie, npcData, dialogueStatus, dialogueState)
    end

    return false
end
