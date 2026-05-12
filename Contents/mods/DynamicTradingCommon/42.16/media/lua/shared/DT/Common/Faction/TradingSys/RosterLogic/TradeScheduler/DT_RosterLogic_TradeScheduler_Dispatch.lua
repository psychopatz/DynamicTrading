DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}
DynamicTrading_TradeScheduler.Internal = DynamicTrading_TradeScheduler.Internal or {}

local Scheduler = DynamicTrading_TradeScheduler
local Internal = Scheduler.Internal

function Scheduler.GetDispatchCandidates(factionID, rosterData, currentHours, factionOverride)
    local data = Internal.GetRosterData(rosterData)
    local plan = Scheduler.BuildFactionPlan(factionID, data, currentHours, factionOverride)
    local dispatchable = {}

    if not plan.isWindowActive or plan.targetCount <= 0 or plan.activeCount >= plan.targetCount then
        return dispatchable, plan
    end

    local projectedActive = plan.activeCount
    local index = 1
    while index <= #plan.selectedOrder do
        if projectedActive >= plan.targetCount then
            break
        end

        local uuid = plan.selectedOrder[index]
        local registry = data.Souls[uuid]
        local liveSoul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
        local isDeparting = liveSoul and liveSoul.state == "Departure"
        if registry and registry.status == "Resting" and not isDeparting then
            dispatchable[#dispatchable + 1] = uuid
            projectedActive = projectedActive + 1
        end
        index = index + 1
    end

    return dispatchable, plan
end

function Scheduler.IsSoulScheduledToDispatch(uuid, factionID, rosterData, currentHours, factionOverride)
    if not uuid or not factionID then
        return false, nil
    end

    local plan = Scheduler.BuildFactionPlan(factionID, rosterData, currentHours, factionOverride)
    return plan.isWindowActive == true and plan.selectedSet[uuid] == true, plan
end

function Scheduler.BuildAllFactionPlans(rosterData, currentHours)
    local data = Internal.GetRosterData(rosterData)
    local plans = {}
    local factionSeen = {}

    for factionID in pairs(data.FactionMembers) do
        factionSeen[factionID] = true
    end
    for _, registry in pairs(data.Souls) do
        if registry and registry.factionID then
            factionSeen[registry.factionID] = true
        end
    end

    for factionID in pairs(factionSeen) do
        plans[factionID] = Scheduler.BuildFactionPlan(factionID, data, currentHours)
    end

    return plans
end

return Scheduler
