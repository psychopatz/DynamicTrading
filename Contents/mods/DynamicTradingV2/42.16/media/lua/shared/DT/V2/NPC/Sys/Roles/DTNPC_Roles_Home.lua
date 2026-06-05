-- ==============================================================================
-- DTNPC_Roles_Home.lua
-- Home-anchor and maintenance-home policy for DT NPC roles.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}
DTNPCRoles.Internal = DTNPCRoles.Internal or {}

local Internal = DTNPCRoles.Internal

function DTNPCRoles.ResolveHomeTarget(npcData)
    local context = DTNPCRoles.ResolveContext(npcData)
    if context.hasHomeAnchor ~= true then
        return nil
    end

    return {
        x = context.homeX,
        y = context.homeY,
        z = context.homeZ or 0,
        radius = context.homeVicinityRadius,
    }
end

function DTNPCRoles.ShouldAutoReturnHome(npcData)
    local context = DTNPCRoles.ResolveContext(npcData)
    if context.hasHomeAnchor ~= true then
        return false
    end
    if context.hasDirectPlayerAuthority == true then
        return false
    end
    if context.isBanditLike == true or context.isHostileFaction == true then
        return false
    end
    if type(npcData) ~= "table" then
        return false
    end
    if Internal.toText(npcData.contactVisitMode) ~= "" then
        return false
    end
    if Internal.toText(npcData.doObjectiveHookId) ~= "" or npcData.doObjectiveEscortActive == true then
        return false
    end

    return true
end
