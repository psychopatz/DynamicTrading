-- ==============================================================================
-- DTNPC_ProtectGuardedCombat_Melee.lua
-- Guarded melee combat execution for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

function DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, options)
    options = type(options) == "table" and options or {}
    local issuePrefix = tostring(options.issuePrefix or "GuardMelee")

    if DTNPCProtect and not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        if DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        if DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                issuePrefix .. "Unavailable",
                options.unavailableText or "Can't swing. No usable melee weapon.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", tonumber(targetDist) or 0))
            )
        end
        return {
            status = "unavailable",
            moved = false,
            attacked = false,
        }
    end

    local result = DTNPCProtect.ExecuteMeleeCombat and DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
        mode = tostring(options.mode or "guard"),
        blockCounterKey = options.blockCounterKey or "guardBlockedTicks",
        fallbackReach = tonumber(options.fallbackReach) or 1.25,
        defaultSpeed = tonumber(options.defaultSpeed) or 0.05,
        enterBuffer = tonumber(options.enterBuffer) or 0.25,
        holdBuffer = tonumber(options.holdBuffer) or 0.45,
        stopBuffer = tonumber(options.stopBuffer) or 0.16,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
    }) or nil

    if result and result.status == "blocked" and DTNPCProtect and DTNPCProtect.ReportCombatIssue then
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            issuePrefix .. "Blocked",
            options.blockedText or "Can't reach that target.",
            "warning",
            "currentDist=" .. tostring(string.format("%.2f", tonumber(result.distance) or tonumber(targetDist) or 0))
        )
    end

    if result and result.attacked and options.debugLabel and DTNPCProtect and DTNPCProtect.LogProtectDebug and isDebugEnabled and isDebugEnabled() then
        DTNPCProtect.LogProtectDebug(
            npcData,
            tostring(options.debugLabel),
            "dist=" .. tostring(string.format("%.2f", tonumber(result.distance) or 0))
        )
    end

    return result or {
        status = "no_result",
        moved = false,
        attacked = false,
    }
end
