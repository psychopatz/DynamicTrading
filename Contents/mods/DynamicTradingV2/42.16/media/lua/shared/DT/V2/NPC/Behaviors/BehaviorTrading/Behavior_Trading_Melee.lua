-- ==============================================================================
-- Behavior_Trading_Melee.lua
-- Melee defense behavior used while trading.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

DTNPCLogic.Behaviors["TradingDefenseMelee"] = function(zombie, npcData)
    local target = nil
    local targetDist = 9999
    target, targetDist = Trading.SelectStationaryThreat(zombie, npcData)
    if not DTNPCProtect.HasUsableMeleeLoadout(npcData) then
        if DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end
    if not target then
        if DTNPCProtect.ResetMeleeCombat then
            DTNPCProtect.ResetMeleeCombat(npcData)
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end

    Trading.EnsureManualControl(zombie)

    local anchorTarget = Trading.GetCombatAnchorTarget(zombie, npcData)
    local anchorX = anchorTarget and anchorTarget:getX() or nil
    local anchorY = anchorTarget and anchorTarget:getY() or nil
    local anchorZ = anchorTarget and anchorTarget:getZ() or zombie:getZ()
    local leashRadius = Trading.GetCombatLeashRadius(npcData)
    local outsideLeash, leashDist, leashLimit = Trading.IsOutsideCombatLeash(zombie, npcData)
    if outsideLeash then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseMeleeLeash",
                "Too far from post. Returning.",
                "warning",
                "dist=" .. tostring(string.format("%.2f", leashDist or 0)) .. " leash=" .. tostring(string.format("%.2f", leashLimit or leashRadius))
            )
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end

    local result = DTNPCProtect.ExecuteMeleeCombat and DTNPCProtect.ExecuteMeleeCombat(zombie, npcData, target, {
        mode = "trading",
        blockCounterKey = "tradingBlockedTicks",
        fallbackReach = Trading.TRADING_DEFENSE_MELEE_REACH,
        defaultSpeed = Trading.TRADING_DEFENSE_DEFAULT_SPEED,
        enterBuffer = Trading.MELEE_APPROACH_START_BUFFER or 0.25,
        holdBuffer = 0.45,
        stopBuffer = Trading.MELEE_APPROACH_STOP_BUFFER,
        anchorX = anchorX,
        anchorY = anchorY,
        anchorZ = anchorZ,
        leashRadius = leashRadius,
    }) or {
        status = "blocked",
        distance = targetDist,
        attacked = false,
    }

    local currentDist = tonumber(result.distance) or Trading.GetTargetDistance(zombie, target)
    Trading.MarkCombatPursuit(npcData, target, currentDist, result.attacked == true)

    if result.status == "leash" then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseMeleeLeashAdvance",
                "Won't chase that far. Returning.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", currentDist))
            )
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
        return
    end

    if result.status == "recovering" then
        return
    end

    if result.status == "blocked" and Trading.ShouldAbortCombatPursuit(npcData) then
        if DTNPCProtect and DTNPCProtect.ReportCombatIssue then
            DTNPCProtect.ReportCombatIssue(
                zombie,
                npcData,
                "TradingDefenseMeleeTimeout",
                "Can't reach that threat. Returning.",
                "warning",
                "targetDist=" .. tostring(string.format("%.2f", currentDist))
            )
        end
        Trading.ReturnToPostOrResume(zombie, npcData)
    end
end
