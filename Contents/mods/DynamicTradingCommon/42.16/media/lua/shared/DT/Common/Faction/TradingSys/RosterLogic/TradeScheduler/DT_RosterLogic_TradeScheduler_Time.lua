DynamicTrading_TradeScheduler = DynamicTrading_TradeScheduler or {}
DynamicTrading_TradeScheduler.Internal = DynamicTrading_TradeScheduler.Internal or {}

local Scheduler = DynamicTrading_TradeScheduler
local Internal = Scheduler.Internal

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
    return math.floor((hours - Internal.TRADING_DAY_START_HOUR) / 24)
end

function Scheduler.GetTradingDayStartHours(tradingDay)
    return (tonumber(tradingDay) or 0) * 24 + Internal.TRADING_DAY_START_HOUR
end

function Scheduler.GetSettings()
    local sandbox = Internal.GetSandbox()
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
    local seed = Internal.BuildSeed(factionID, day, "window")
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

return Scheduler
