DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}
DynamicTrading_TradeScheduler.Internal = DynamicTrading_TradeScheduler.Internal or {}

local Scheduler = DynamicTrading_TradeScheduler
local Internal = Scheduler.Internal

Internal.ROSTER_KEY = "DynamicTrading_Roster"
Internal.HASH_MOD = 2147483647
Internal.TRADING_DAY_START_HOUR = 5

function Internal.Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function Internal.HashString(value)
    local text = tostring(value or "")
    local hash = 5381
    local index = 1
    while index <= #text do
        hash = ((hash * 33) + string.byte(text, index)) % Internal.HASH_MOD
        index = index + 1
    end
    return hash
end

function Internal.BuildSeed(...)
    local parts = { ... }
    local index = 1
    while index <= #parts do
        parts[index] = tostring(parts[index] or "")
        index = index + 1
    end
    return Internal.HashString(table.concat(parts, "|"))
end

function Internal.GetRosterData(rosterData)
    local data = rosterData or ModData.get(Internal.ROSTER_KEY)
    if type(data) ~= "table" then
        data = {}
    end
    data.Souls = type(data.Souls) == "table" and data.Souls or {}
    data.FactionMembers = type(data.FactionMembers) == "table" and data.FactionMembers or {}
    return data
end

function Internal.GetSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

function Internal.GetCountFromPercent(totalCount, percent)
    local safePercent = Internal.Clamp(math.floor(tonumber(percent) or 0), 0, 100)
    if totalCount <= 0 or safePercent <= 0 then
        return 0
    end

    local count = math.floor((totalCount * safePercent) / 100)
    if count <= 0 then
        count = 1
    end

    return Internal.Clamp(count, 0, totalCount)
end

function Internal.GetFaction(factionID, factionOverride)
    if factionOverride then
        return factionOverride
    end
    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        return DynamicTrading_Factions.GetFaction(factionID)
    end
    return nil
end

function Internal.IsActiveStatus(status)
    return status == "Away" or status == "Trading"
end

function Internal.IsCandidateAlive(registry)
    return type(registry) == "table" and registry.status ~= "Dead"
end

function Internal.CollectFactionUUIDs(factionID, rosterData, faction)
    local uuids = {}
    local members = rosterData.FactionMembers[factionID]

    if type(members) == "table" and #members > 0 then
        local index = 1
        while index <= #members do
            uuids[#uuids + 1] = members[index]
            index = index + 1
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

function Internal.IsManuallyEligibleWorker(registry, faction)
    if not faction or not faction.playerOwned then
        return true
    end

    local workerID = registry and registry.linkedWorkerID or nil
    return workerID ~= nil
        and type(faction.tradeEligibleWorkerIDs) == "table"
        and faction.tradeEligibleWorkerIDs[workerID] == true
end

function Internal.CanAutoDispatchFaction(faction)
    if not faction or not faction.playerOwned then
        return true
    end
    return tostring(faction.leadershipState or "") == "Regency"
end

function Internal.BuildCandidateEntry(uuid, registry)
    return {
        uuid = uuid,
        registry = registry,
    }
end

function Internal.SortBySeed(entries, factionID, tradingDay, channel)
    table.sort(entries, function(left, right)
        local leftRank = Internal.BuildSeed(factionID, tradingDay, channel, left.uuid)
        local rightRank = Internal.BuildSeed(factionID, tradingDay, channel, right.uuid)
        if leftRank == rightRank then
            return tostring(left.uuid or "") < tostring(right.uuid or "")
        end
        return leftRank < rightRank
    end)
end

return Scheduler
