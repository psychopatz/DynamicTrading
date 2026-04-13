-- ==============================================================================
-- Behavior_Trading_Trading.lua
-- Core trading behavior and defense state handoff.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

local Trading = DTNPCLogic.BehaviorTrading

DTNPCLogic.Behaviors["Trading"] = function(zombie, npcData)
    local target = nil
    local targetDist = 9999
    DTNPCProtect.RememberStationaryPost(zombie, npcData, "Trading")
    if DTNPCProtect and DTNPCProtect.SelectNearestThreat then
        target, targetDist = Trading.SelectStationaryThreat(zombie, npcData)
    end
    if target then
        local nextState = DTNPCProtect and DTNPCProtect.GetTradingDefenseState and DTNPCProtect.GetTradingDefenseState(npcData, targetDist or 9999) or nil
        if nextState then
            Trading.EnterDefense(zombie, npcData, nextState)
            local behavior = DTNPCLogic.Behaviors[nextState]
            if behavior then
                behavior(zombie, npcData, target, targetDist)
            end
            return
        end
        if DTNPCProtect and DTNPCProtect.ClearCombatTarget then
            DTNPCProtect.ClearCombatTarget(npcData)
        end
    else
        npcData.combatResumeState = nil
    end

    DTNPCLogic.Stationary.Run(zombie, npcData)
end
