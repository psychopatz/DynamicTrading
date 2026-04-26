DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}

local Scheduler = DynamicTrading_TradeScheduler
local ROSTER_KEY = "DynamicTrading_Roster"
local HASH_MOD = 2147483647
local TRADING_DAY_START_HOUR = 5

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function hashString(value)
    local text = tostring(value or "")
    local hash = 5381
    for index = 1, #text do
        hash = ((hash * 33) + string.byte(text, index)) % HASH_MOD
    end
    return hash
end

local function buildSeed(...)
    local parts = { ... }
    for index = 1, #parts do
        parts[index] = tostring(parts[index] or "")
    end
    return hashString(table.concat(parts, "|"))
end

local function getRosterData(rosterData)
    local data = rosterData or ModData.get(ROSTER_KEY)
    if type(data) ~= "table" then
        data = {}
    end
    data.Souls = type(data.Souls) == "table" and data.Souls or {}
    data.FactionMembers = type(data.FactionMembers) == "table" and data.FactionMembers or {}
    return data
end

local function getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

local function getCountFromPercent(totalCount, percent)
    local safePercent = clamp(math.floor(tonumber(percent) or 0), 0, 100)
    if totalCount <= 0 or safePercent <= 0 then
        return 0
    end

    local count = math.floor((totalCount * safePercent) / 100)
    if count <= 0 then
        count = 1
    end

    return clamp(count, 0, totalCount)
end

local function getFaction(factionID, factionOverride)
    if factionOverride then
        return factionOverride
    end
    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        return DynamicTrading_Factions.GetFaction(factionID)
    end
    return nil
end

local function isActiveStatus(status)
    return status == "Away" or status == "Trading"
end

local function isCandidateAlive(registry)
    return type(registry) == "table" and registry.status ~= "Dead"
end

local function collectFactionUUIDs(factionID, rosterData, faction)
    local uuids = {}
    local members = rosterData.FactionMembers[factionID]

    if type(members) == "table" and #members > 0 then
        for _, uuid in ipairs(members) do
            uuids[#uuids + 1] = uuid
        end
        return uuids
    end

    for uuid, registry in pairs(rosterData.Souls) do
        if faction and faction.isV1 then
            uuids[#uuids + 1] = uuid
        elseif registry and registry.factionID == factionID then
            uuids[#uuids + 1] = uuid
        end
    end

    return uuids
end

local function isManuallyEligibleWorker(registry, faction)
    if not faction or not faction.playerOwned then
        return true
    end

    local workerID = registry and registry.linkedWorkerID or nil
    return workerID ~= nil
        and type(faction.tradeEligibleWorkerIDs) == "table"
        and faction.tradeEligibleWorkerIDs[workerID] == true
end

local function canAutoDispatchFaction(faction)
    if not faction or not faction.playerOwned then
        return true
    end
    return tostring(faction.leadershipState or "") == "Regency"
end

local function buildCandidateEntry(uuid, registry)
    return {
        uuid = uuid,
        registry = registry,
    }
end

local function sortBySeed(entries, factionID, tradingDay, channel)
    table.sort(entries, function(left, right)
        local leftRank = buildSeed(factionID, tradingDay, channel, left.uuid)
        local rightRank = buildSeed(factionID, tradingDay, channel, right.uuid)
        if leftRank == rightRank then
            return tostring(left.uuid or "") < tostring(right.uuid or "")
        end
        return leftRank < rightRank
    end)
end

function Scheduler.GetCurrentHours()
    if getGameTime then
        return getGameTime():getWorldAgeHours()
    end
    return 0
end

function Scheduler.GetTradingDay(currentHours)
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end
    return math.floor((hours - TRADING_DAY_START_HOUR) / 24)
end

function Scheduler.GetTradingDayStartHours(tradingDay)
    return (tonumber(tradingDay) or 0) * 24 + TRADING_DAY_START_HOUR
end

function Scheduler.GetSettings()
    local sandbox = getSandbox()
    return {
        walkHours = tonumber(sandbox.NPCTradingWalkHours) or 1.0,
        stayHours = tonumber(sandbox.NPCTradingStayHours) or 24.0,
        concurrentPercent = tonumber(sandbox.NPCTradePopPercent) or 40,
        eligiblePercent = tonumber(sandbox.NPCTradeEligiblePercent) or 100,
    }
end

function Scheduler.GetFactionWindow(factionID, tradingDay)
    local day = tonumber(tradingDay) or 0
    local dayStart = Scheduler.GetTradingDayStartHours(day)
    local seed = buildSeed(factionID, day, "window")
    local quarterHour = (seed % 4) * 0.25
    local startOffset = 1 + (seed % 13) + quarterHour
    local durationHours = 2 + (math.floor(seed / 17) % 4)
    local startsAt = dayStart + startOffset
    local endsAt = math.min(dayStart + 23.75, startsAt + durationHours)

    return {
        factionID = factionID,
        tradingDay = day,
        startsAt = startsAt,
        endsAt = endsAt,
        durationHours = endsAt - startsAt,
    }
end

function Scheduler.IsWindowActive(window, currentHours)
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end
    return type(window) == "table"
        and hours >= (window.startsAt or 0)
        and hours < (window.endsAt or 0)
end

function Scheduler.GetUpcomingWindows(factionID, count, currentHours)
    local windows = {}
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end

    local tradingDay = Scheduler.GetTradingDay(hours)
    local wanted = math.max(1, tonumber(count) or 1)
    local day = tradingDay

    while #windows < wanted do
        local window = Scheduler.GetFactionWindow(factionID, day)
        if day > tradingDay or window.endsAt >= hours then
            windows[#windows + 1] = window
        end
        day = day + 1
    end

    return windows
end

function Scheduler.NormalizeSoulState(uuid, registry, currentHours)
    if isClient() and not isServer() then
        return false
    end

    if not isActiveStatus(registry and registry.status) then
        return false
    end

    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end

    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
    local returnTime = registry.returnTime
    local returnStatus = registry.returnStatus

    if returnTime == nil and soul then
        returnTime = soul.returnTime
    end
    if returnStatus == nil and soul then
        returnStatus = soul.returnStatus
    end

    if type(returnTime) ~= "number" or returnTime <= 0 then
        if soul and soul.homeCoords then
            soul.lastX = soul.homeCoords.x
            soul.lastY = soul.homeCoords.y
            soul.lastZ = soul.homeCoords.z or 0
            soul.travelTarget = nil
            DynamicTrading_Roster.SaveSoul(uuid, soul)
        end
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Resting", 0, nil)
        DynamicTrading.Log(
            "DTCommons",
            "TradeSchedule",
            "Normalize",
            "Reset invalid trader state to Resting for " .. tostring(uuid) .. " at " .. tostring(hours)
        )
        return true
    end

    if tostring(returnStatus or "") == "" then
        local inferredStatus = "Resting"
        if registry.status == "Trading" then
            inferredStatus = "Away"
        elseif soul and soul.departureTargetX ~= nil then
            inferredStatus = "Trading"
        end

        DynamicTrading_Roster.UpdateSoulStatus(uuid, registry.status, returnTime, inferredStatus)
        DynamicTrading.Log(
            "DTCommons",
            "TradeSchedule",
            "Normalize",
            "Inferred missing returnStatus=" .. tostring(inferredStatus) .. " for " .. tostring(uuid)
        )
        return true
    end

    return false
end

function Scheduler.NormalizeRosterState(rosterData, currentHours)
    local data = getRosterData(rosterData)
    local changed = 0
    local uuids = {}

    for uuid in pairs(data.Souls) do
        uuids[#uuids + 1] = uuid
    end

    for _, uuid in ipairs(uuids) do
        if Scheduler.NormalizeSoulState(uuid, data.Souls[uuid], currentHours) then
            changed = changed + 1
        end
    end

    return changed
end

function Scheduler.BuildFactionPlan(factionID, rosterData, currentHours, factionOverride)
    local data = getRosterData(rosterData)
    local faction = getFaction(factionID, factionOverride)
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = Scheduler.GetCurrentHours()
    end

    local settings = Scheduler.GetSettings()
    local tradingDay = Scheduler.GetTradingDay(hours)
    local window = Scheduler.GetFactionWindow(factionID, tradingDay)
    local autoEnabled = canAutoDispatchFaction(faction)
    local allEntries = {}
    local activeCount = 0

    for _, uuid in ipairs(collectFactionUUIDs(factionID, data, faction)) do
        local registry = data.Souls[uuid]
        if isCandidateAlive(registry) and isManuallyEligibleWorker(registry, faction) then
            local entry = buildCandidateEntry(uuid, registry)
            allEntries[#allEntries + 1] = entry
            if isActiveStatus(registry.status) then
                activeCount = activeCount + 1
            end
        end
    end

    sortBySeed(allEntries, factionID, tradingDay, "eligible")

    local eligibleLimit = getCountFromPercent(#allEntries, settings.eligiblePercent)
    local eligibleEntries = {}
    local eligibleSet = {}
    for index = 1, eligibleLimit do
        local entry = allEntries[index]
        eligibleEntries[#eligibleEntries + 1] = entry
        eligibleSet[entry.uuid] = true
    end

    local limitMultiplier = 1.0
    if DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        limitMultiplier = DynamicTrading.Events.GetFactionSystemModifier(faction, "traderLimit") or 1.0
    end

    local effectiveConcurrentPercent = settings.concurrentPercent * limitMultiplier
    local maxConcurrentCount = getCountFromPercent(#allEntries, effectiveConcurrentPercent)
    maxConcurrentCount = math.min(maxConcurrentCount, #eligibleEntries)

    local intensityPercent = 60 + (buildSeed(factionID, tradingDay, "intensity") % 41)
    local targetCount = 0
    if maxConcurrentCount > 0 and autoEnabled then
        targetCount = math.max(1, math.floor((maxConcurrentCount * intensityPercent) / 100 + 0.5))
        targetCount = math.min(targetCount, maxConcurrentCount)
    end

    sortBySeed(eligibleEntries, factionID, tradingDay, "dispatch")

    local selectedOrder = {}
    local selectedSet = {}
    for index = 1, targetCount do
        local entry = eligibleEntries[index]
        if entry then
            selectedOrder[#selectedOrder + 1] = entry.uuid
            selectedSet[entry.uuid] = true
        end
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

function Scheduler.GetDispatchCandidates(factionID, rosterData, currentHours, factionOverride)
    local data = getRosterData(rosterData)
    local plan = Scheduler.BuildFactionPlan(factionID, data, currentHours, factionOverride)
    local dispatchable = {}

    if not plan.isWindowActive or plan.targetCount <= 0 or plan.activeCount >= plan.targetCount then
        return dispatchable, plan
    end

    local projectedActive = plan.activeCount
    for _, uuid in ipairs(plan.selectedOrder) do
        if projectedActive >= plan.targetCount then
            break
        end

        local registry = data.Souls[uuid]
        local liveSoul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
        local isDeparting = liveSoul and liveSoul.state == "Departure"
        if registry and registry.status == "Resting" and not isDeparting then
            dispatchable[#dispatchable + 1] = uuid
            projectedActive = projectedActive + 1
        end
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
    local data = getRosterData(rosterData)
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
