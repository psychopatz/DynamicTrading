require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "DT/Common/Faction/TradingSys/RosterLogic/TradeScheduler/DT_RosterLogic_TradeScheduler"

DT_FactionInfoTab_Calendar = ISPanel:derive("DT_FactionInfoTab_Calendar")

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function getScaleTags(tab)
    local scale = "Medium"
    if tab.parent and tab.parent.parent and tab.parent.parent.fontScale then
        scale = tab.parent.parent.fontScale
    end

    if scale == "Large" then
        return "Large", "Medium"
    end
    if scale == "Small" then
        return "Small", "Small"
    end
    return "Medium", "Small"
end

local function formatHourLabel(hours)
    local totalMinutes = math.floor(((hours or 0) % 24) * 60 + 0.5)
    if totalMinutes < 0 then
        totalMinutes = totalMinutes + (24 * 60)
    end
    local hour = math.floor(totalMinutes / 60) % 24
    local minute = totalMinutes % 60
    return string.format("%02d:%02d", hour, minute)
end

local function formatWindowLabel(window, currentTradingDay)
    if not window then
        return T("DTCommon_UI_Faction_NoScheduledRun", nil, "No scheduled run")
    end

    local dayDelta = (window.tradingDay or 0) - (currentTradingDay or 0)
    local dayLabel = T("DTCommon_UI_Faction_TradingDayOffset", { offset = tostring(dayDelta) }, "Trading Day +" .. tostring(dayDelta))
    if dayDelta == 0 then
        dayLabel = T("DTCommon_UI_Faction_Today", nil, "Today")
    elseif dayDelta == 1 then
        dayLabel = T("DTCommon_UI_Faction_Tomorrow", nil, "Tomorrow")
    elseif dayDelta < 0 then
        dayLabel = T("DTCommon_UI_Faction_Earlier", nil, "Earlier")
    end

    return string.format(
        "%s  %s-%s",
        dayLabel,
        formatHourLabel(window.startsAt),
        formatHourLabel(window.endsAt)
    )
end

function DT_FactionInfoTab_Calendar:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end

function DT_FactionInfoTab_Calendar:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Calendar:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.richText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Calendar:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:paginate()
    end
end

function DT_FactionInfoTab_Calendar:updateData(f, rosterData)
    self.currentFaction = f
    if not self.richText then
        return
    end

    if not f then
        self.richText:setText(" <RGB:0.6,0.6,0.6> " .. T("DTCommon_UI_Faction_NoFactionSelected", nil, "No faction selected."))
        return
    end

    local titleTag, bodyTag = getScaleTags(self)
    local currentHours = DynamicTrading_TradeScheduler.GetCurrentHours()
    local currentTradingDay = DynamicTrading_TradeScheduler.GetTradingDay(currentHours)
    local hasSouls = false

    if rosterData and type(rosterData.Souls) == "table" then
        for _ in pairs(rosterData.Souls) do
            hasSouls = true
            break
        end
    end

    if f.isV1 and (not rosterData or type(rosterData.Souls) ~= "table" or not hasSouls) then
        local legacyText = " <RGB:1,0.8,0> <SIZE:" .. titleTag .. "> " .. T("DTCommon_UI_Faction_TradingCalendar", nil, "Trading Calendar") .. " <SIZE:" .. bodyTag .. "> <LINE> "
        legacyText = legacyText .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_CurrentTradingDay", { day = tostring(currentTradingDay) }, "Current Trading Day: " .. tostring(currentTradingDay)) .. " <LINE> <LINE> "
        legacyText = legacyText .. " <RGB:0.6,0.6,0.6> " .. T("DTCommon_UI_Faction_V1CalendarFallback", nil, "Legacy V1 radio data does not expose a roster-backed faction schedule on this client yet. The deterministic scheduler is active on the server runtime, but this fallback view can only show the shared trading-day anchor until roster sync is available.")
        self.richText:setText(legacyText)
        self.richText:paginate()
        return
    end

    local plan = DynamicTrading_TradeScheduler.BuildFactionPlan(f.id, rosterData, currentHours, f)
    local windows = DynamicTrading_TradeScheduler.GetUpcomingWindows(f.id, 5, currentHours)

    local text = " <RGB:1,0.8,0> <SIZE:" .. titleTag .. "> " .. T("DTCommon_UI_Faction_TradingCalendar", nil, "Trading Calendar") .. " <SIZE:" .. bodyTag .. "> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_NameRow", { name = tostring(f.name or f.id or T("DTCommon_UI_Faction_DefaultLeader", nil, "Unknown")) }, "Faction: " .. tostring(f.name or f.id or "Unknown")) .. " <LINE> "
    text = text .. " " .. T("DTCommon_UI_Faction_CurrentTradingDay", { day = tostring(plan.tradingDay or currentTradingDay) }, "Current Trading Day: " .. tostring(plan.tradingDay or currentTradingDay)) .. " <LINE> <LINE> "

    text = text .. " <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_CurrentWindow", nil, "CURRENT WINDOW:") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. formatWindowLabel(plan.window, currentTradingDay) .. " <LINE> "
    if plan.isWindowActive then
        text = text .. " <RGB:0.2,1,0.2> " .. T("DTCommon_UI_Faction_StatusActiveDispatch", nil, "Status: Active dispatch window") .. " <LINE> "
    else
        text = text .. " <RGB:0.75,0.75,0.75> " .. T("DTCommon_UI_Faction_StatusWaitingDispatch", nil, "Status: Waiting for next dispatch window") .. " <LINE> "
    end
    if not plan.autoEnabled then
        text = text .. " <RGB:1,0.65,0.25> " .. T("DTCommon_UI_Faction_AutoSchedulingPaused", nil, "Automatic scheduling is paused until this player faction enters Regency.") .. " <LINE> "
    end

    text = text .. " <LINE> <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_RotationSummary", nil, "ROTATION SUMMARY:") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_CandidateRoster", { count = tostring(plan.totalCount or 0) }, "Candidate Roster: " .. tostring(plan.totalCount or 0)) .. " <LINE> "
    text = text .. " " .. T("DTCommon_UI_Faction_EligiblePool", { count = tostring(plan.eligibleCount or 0) }, "Eligible Pool: " .. tostring(plan.eligibleCount or 0)) .. " <LINE> "
    text = text .. " " .. T("DTCommon_UI_Faction_ActiveTraders", {
        active = tostring(plan.activeCount or 0),
        max = tostring(plan.maxConcurrentCount or 0)
    }, "Active Traders: " .. tostring(plan.activeCount or 0) .. " / " .. tostring(plan.maxConcurrentCount or 0)) .. " <LINE> "
    text = text .. " " .. T("DTCommon_UI_Faction_WindowTarget", { count = tostring(plan.targetCount or 0) }, "Window Target: " .. tostring(plan.targetCount or 0)) .. " <LINE> "
    text = text .. " " .. T("DTCommon_UI_Faction_SeededIntensity", { percent = tostring(plan.intensityPercent or 0) }, "Seeded Intensity: " .. tostring(plan.intensityPercent or 0) .. "%") .. " <LINE> "

    text = text .. " <LINE> <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_UpcomingWindows", nil, "UPCOMING WINDOWS:") .. " <LINE> "
    for index, window in ipairs(windows) do
        local prefix = (index == 1 and plan.isWindowActive)
            and T("DTCommon_UI_Faction_Now", nil, "Now")
            or T("DTCommon_UI_Faction_RunIndex", { index = tostring(index) }, "Run " .. tostring(index))
        text = text .. " <RGB:0.8,0.8,0.8> " .. prefix .. ": " .. formatWindowLabel(window, currentTradingDay) .. " <LINE> "
    end

    text = text .. " <LINE> <RGB:0.55,0.55,0.55> " .. T("DTCommon_UI_Faction_CalendarFooter", nil, "Automatic faction windows are seeded from trading day and faction identity. Restarting the world will not reshuffle the schedule; only the live state of already-active traders is resumed.")

    self.richText:setText(text)
    self.richText:paginate()
end
