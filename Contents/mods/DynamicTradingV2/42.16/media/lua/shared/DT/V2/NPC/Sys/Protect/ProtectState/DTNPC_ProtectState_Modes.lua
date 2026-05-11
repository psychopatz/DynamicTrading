-- ==============================================================================
-- DTNPC_ProtectState_Modes.lua
-- Protect, guard, and hostile mode resolution for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local function normalizeGuardModeToken(value)
    local token = tostring(value or "")
    if token == "" then
        return nil
    end

    if token == "GuardRanged" or token == "ProtectRanged" or token == "ranged" then
        return "GuardRanged"
    end
    if token == "GuardMelee" or token == "ProtectMelee" or token == "melee" then
        return "GuardMelee"
    end
    if token == "GuardAuto" or token == "ProtectAuto" or token == "auto" then
        return "GuardAuto"
    end

    return nil
end

function DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if preferredState == "ProtectRanged" or preferredState == "ProtectMelee" or preferredState == "ProtectAuto" then
        return preferredState
    end
    if npcData.combatOrder == "ProtectRanged" or npcData.combatOrder == "ProtectMelee" or npcData.combatOrder == "ProtectAuto" then
        return npcData.combatOrder
    end
    if npcData.state == "ProtectRanged" or npcData.state == "ProtectMelee" or npcData.state == "ProtectAuto" then
        return npcData.state
    end
    return nil
end

function DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    if not hasRanged and not hasMelee then
        return nil
    end

    local distance = tonumber(targetDist) or 9999
    if hasMelee and distance <= 1.85 then
        return "ProtectMelee"
    end
    if hasRanged then
        return "ProtectRanged"
    end
    if hasMelee then
        return "ProtectMelee"
    end

    return nil
end

function DTNPCProtect.GetRequestedGuardState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requested = normalizeGuardModeToken(preferredState)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.guardCombatOrder)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.guardAttackMode)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.combatOrder)
    if requested then
        return requested
    end

    return "GuardAuto"
end

function DTNPCProtect.GetAutoGuardState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    if not hasRanged and not hasMelee then
        return nil
    end

    local distance = tonumber(targetDist) or 9999
    if hasMelee and distance <= 1.85 then
        return "GuardMelee"
    end
    if hasRanged then
        return "GuardRanged"
    end
    if hasMelee then
        return "GuardMelee"
    end

    return nil
end

function DTNPCProtect.ResolveGuardCombatState(npcData, targetDist, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requested = DTNPCProtect.GetRequestedGuardState(npcData, preferredState)
    if requested ~= "GuardRanged" and requested ~= "GuardMelee" and requested ~= "GuardAuto" then
        return nil
    end

    if requested == "GuardAuto" then
        return DTNPCProtect.GetAutoGuardState(npcData, targetDist)
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local resolvedState = nil

    if requested == "GuardRanged" then
        if hasRanged then
            resolvedState = "GuardRanged"
        elseif hasMelee then
            resolvedState = "GuardMelee"
        end
    elseif requested == "GuardMelee" then
        if hasMelee then
            resolvedState = "GuardMelee"
        elseif hasRanged then
            resolvedState = "GuardRanged"
        end
    end

    if resolvedState ~= requested then
        local fallbackRequested = requested == "GuardRanged" and "ProtectRanged"
            or requested == "GuardMelee" and "ProtectMelee"
            or "ProtectAuto"
        local fallbackResolved = resolvedState == "GuardRanged" and "ProtectRanged"
            or resolvedState == "GuardMelee" and "ProtectMelee"
            or nil
        local text, sentiment = DTNPCProtect.BuildFallbackNotice(fallbackRequested, fallbackResolved)
        DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    end

    return resolvedState
end

function DTNPCProtect.GetHostileCombatState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local distance = tonumber(targetDist) or 9999

    if hasMelee and distance <= 1.85 then
        return "Attack"
    end
    if hasRanged then
        return "AttackRange"
    end
    if hasMelee then
        return "Attack"
    end

    return "Attack"
end

function DTNPCProtect.ResolveHostileCombatState(npcData, preferredState, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local requestedState = preferredState
    local distance = tonumber(targetDist) or 9999

    if requestedState ~= "Attack" and requestedState ~= "AttackRange" then
        requestedState = npcData and npcData.state or nil
    end

    if requestedState == "AttackRange" then
        if hasMelee and distance <= 1.85 then
            return "Attack"
        end
        if hasRanged then
            return "AttackRange"
        end
        if hasMelee then
            return "Attack"
        end
        return "Attack"
    end

    if requestedState == "Attack" then
        if hasRanged and not hasMelee then
            return "AttackRange"
        end
        if hasMelee and distance <= 1.85 then
            return "Attack"
        end
        if hasRanged then
            return "AttackRange"
        end
        if hasMelee then
            return "Attack"
        end
        return "Attack"
    end

    return DTNPCProtect.GetHostileCombatState(npcData, targetDist)
end

function DTNPCProtect.ResolveProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requestedState = DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    if requestedState ~= "ProtectRanged" and requestedState ~= "ProtectMelee" and requestedState ~= "ProtectAuto" then
        return nil
    end

    if requestedState == "ProtectAuto" then
        return DTNPCProtect.GetAutoProtectState(npcData)
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local resolvedState = nil

    if requestedState == "ProtectRanged" then
        if hasRanged then
            resolvedState = "ProtectRanged"
        elseif hasMelee then
            resolvedState = "ProtectMelee"
        end
    elseif requestedState == "ProtectMelee" then
        if hasMelee then
            resolvedState = "ProtectMelee"
        elseif hasRanged then
            resolvedState = "ProtectRanged"
        end
    end

    if resolvedState ~= requestedState then
        local text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    end

    return resolvedState
end
