DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}
DynamicTrading_TradeScheduler.Internal = DynamicTrading_TradeScheduler.Internal or {}

local Scheduler = DynamicTrading_TradeScheduler
local Internal = Scheduler.Internal

function Scheduler.BuildFactionPlan(factionID, rosterData, currentHours, factionOverride)
    local data = Internal.GetRosterData(rosterData)
    local faction = Internal.GetFaction(factionID, factionOverride)
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end

    local settings = Scheduler.GetSettings()
    local tradingDay = Scheduler.GetTradingDay(hours)
    local window = Scheduler.GetFactionWindow(factionID, tradingDay)
    local autoEnabled = Internal.CanAutoDispatchFaction(faction)
    local allEntries = {}
    local activeCount = 0

    local factionUUIDs = Internal.CollectFactionUUIDs(factionID, data, faction)
    local index = 1
    while index <= #factionUUIDs do
        local uuid = factionUUIDs[index]
        local registry = data.Souls[uuid]
        if Internal.IsCandidateAlive(registry) and Internal.IsManuallyEligibleWorker(registry, faction) then
            local entry = Internal.BuildCandidateEntry(uuid, registry)
            allEntries[#allEntries + 1] = entry
            if Internal.IsActiveStatus(registry.status) then
                activeCount = activeCount + 1
            end
        end
        index = index + 1
    end

    Internal.SortBySeed(allEntries, factionID, tradingDay, "eligible")

    local eligibleLimit = Internal.GetCountFromPercent(#allEntries, settings.eligiblePercent)
    local eligibleEntries = {}
    local eligibleSet = {}
    index = 1
    while index <= eligibleLimit do
        local entry = allEntries[index]
        eligibleEntries[#eligibleEntries + 1] = entry
        eligibleSet[entry.uuid] = true
        index = index + 1
    end

    local limitMultiplier = 1.0
    if DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        limitMultiplier = DynamicTrading.Events.GetFactionSystemModifier(faction, "traderLimit") or 1.0
    end

    local effectiveConcurrentPercent = settings.concurrentPercent * limitMultiplier
    local maxConcurrentCount = Internal.GetCountFromPercent(#allEntries, effectiveConcurrentPercent)
    maxConcurrentCount = math.min(maxConcurrentCount, #eligibleEntries)

    local intensityPercent = 60 + (Internal.BuildSeed(factionID, tradingDay, "intensity") % 41)
    local targetCount = 0
    if maxConcurrentCount > 0 and autoEnabled then
        targetCount = math.max(1, math.floor((maxConcurrentCount * intensityPercent) / 100 + 0.5))
        targetCount = math.min(targetCount, maxConcurrentCount)
    end

    Internal.SortBySeed(eligibleEntries, factionID, tradingDay, "dispatch")

    local selectedOrder = {}
    local selectedSet = {}
    index = 1
    while index <= targetCount do
        local entry = eligibleEntries[index]
        if entry then
            selectedOrder[#selectedOrder + 1] = entry.uuid
            selectedSet[entry.uuid] = true
        end
        index = index + 1
    end

    local isWindowActive = autoEnabled and Scheduler.IsWindowActive(window, hours)
    if faction and faction.hostileToPlayers == true and tostring(faction.factionType or "") == "bandit" then
        isWindowActive = autoEnabled
        targetCount = math.max(1, math.min(tonumber(faction.trickleActiveCount) or 1, math.max(1, maxConcurrentCount)))
    end
    local nextWindow = Scheduler.GetUpcomingWindows(factionID, 1, hours)[1]

    return {
        factionID = factionID,
        faction = faction,
        tradingDay = tradingDay,
        currentHours = hours,
        settings = settings,
        window = window,
        nextWindow = nextWindow,
        isWindowActive = isWindowActive,
        autoEnabled = autoEnabled,
        totalCount = #allEntries,
        eligibleCount = #eligibleEntries,
        activeCount = activeCount,
        limitMultiplier = limitMultiplier,
        effectiveConcurrentPercent = effectiveConcurrentPercent,
        maxConcurrentCount = maxConcurrentCount,
        targetCount = targetCount,
        selectedOrder = selectedOrder,
        selectedSet = selectedSet,
        eligibleSet = eligibleSet,
        intensityPercent = intensityPercent,
    }
end

return Scheduler
