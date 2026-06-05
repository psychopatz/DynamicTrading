-- ==============================================================================
-- DTNPC_Roles_Requirements.lua
-- Requirement-gating policy for DT NPC roles.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}

function DTNPCRoles.ShouldRequireItems(npcData, requirementKey)
    local context = DTNPCRoles.ResolveContext(npcData)
    local key = string.lower(tostring(requirementKey or ""))

    if key == "bandage" or key == "revive" then
        return context.isPlayerOwned == true
    end

    if key == "ammo" or key == "durability" then
        return context.isPlayerOwned == true
    end

    return context.usesItemRequirements == true
end
