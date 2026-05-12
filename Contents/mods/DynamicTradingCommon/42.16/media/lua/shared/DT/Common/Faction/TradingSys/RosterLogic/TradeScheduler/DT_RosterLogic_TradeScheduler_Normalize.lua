DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}
DynamicTrading_TradeScheduler.Internal = DynamicTrading_TradeScheduler.Internal or {}

local Scheduler = DynamicTrading_TradeScheduler
local Internal = Scheduler.Internal

function Scheduler.NormalizeSoulState(uuid, registry, currentHours)
    if isClient() and not isServer() then
        return false
    end

    if not Internal.IsActiveStatus(registry and registry.status) then
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
    local data = Internal.GetRosterData(rosterData)
    local changed = 0
    local uuids = {}

    for uuid in pairs(data.Souls) do
        uuids[#uuids + 1] = uuid
    end

    local index = 1
    while index <= #uuids do
        local uuid = uuids[index]
        if Scheduler.NormalizeSoulState(uuid, data.Souls[uuid], currentHours) then
            changed = changed + 1
        end
        index = index + 1
    end

    return changed
end

return Scheduler
