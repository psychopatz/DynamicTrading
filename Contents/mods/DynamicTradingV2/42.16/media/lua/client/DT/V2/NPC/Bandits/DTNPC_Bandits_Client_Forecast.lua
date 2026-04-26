-- ==============================================================================
-- DTNPC_Bandits_Client_Forecast.lua
-- Raid forecast UI for bandit and hostile faction ambushes.
-- ==============================================================================

if isServer() and not isClient() then return end

local BanditClient = DTNPCBanditClient
BanditClient.Internal = BanditClient.Internal or {}
BanditClient.Internal.Helpers = BanditClient.Internal.Helpers or {}
local Helpers = BanditClient.Internal.Helpers

local ForecastWindow = ISCollapsableWindow:derive("DTNPCBanditRaidForecastWindow")

function ForecastWindow:new(lines)
    local width = 520
    local height = math.min(520, math.max(260, 110 + (#(lines or {}) * 18)))
    local screenW = getCore and getCore():getScreenWidth() or 1280
    local screenH = getCore and getCore():getScreenHeight() or 720
    local x = math.max(20, math.floor((screenW - width) / 2))
    local y = math.max(20, math.floor((screenH - height) / 2))
    local o = ISCollapsableWindow.new(self, x, y, width, height)
    o.lines = lines or {}
    o.title = Helpers.getForecastText("WindowTitle")
    o.resizable = false
    return o
end

function ForecastWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    self.closeButton = ISButton:new(self.width - 96, self.height - 36, 76, 24, "Close", self, function(target)
        target:close()
    end)
    self.closeButton:initialise()
    self:addChild(self.closeButton)
end

function ForecastWindow:render()
    ISCollapsableWindow.render(self)
    self:drawText(Helpers.getForecastText("WindowHeading"), 18, 34, 1, 1, 1, 1, UIFont.Medium)
    local y = 62
    for _, line in ipairs(self.lines or {}) do
        self:drawText(tostring(line), 20, y, 0.86, 0.86, 0.86, 1, UIFont.Small)
        y = y + 18
    end
end

function BanditClient.ShowRaidForecast(args)
    args = type(args) == "table" and args or {}
    if BanditClient.ForecastWindow then
        BanditClient.ForecastWindow:close()
        BanditClient.ForecastWindow = nil
    end

    local lines = {}
    if args.currencyExpanded ~= true then
        lines[#lines + 1] = Helpers.getForecastText("DisabledNoCurrency")
    else
        lines[#lines + 1] = args.enabled == false
            and Helpers.getForecastText("SystemDisabled")
            or Helpers.getForecastText("SystemEnabled")
        lines[#lines + 1] = Helpers.getForecastText("ChancePerCheck", tostring(args.chance or 0))
        lines[#lines + 1] = Helpers.getForecastText("CooldownHours", tostring(args.cooldownHours or 0))
        lines[#lines + 1] = Helpers.getForecastText(
            "DemandWindow",
            tostring(string.format("%.1f", tonumber(args.demandWindowMinutes) or 0))
        )
        lines[#lines + 1] = Helpers.getForecastText(
            "NextEligibleHours",
            tostring(string.format("%.1f", tonumber(args.cooldownRemainingHours) or 0))
        )
        lines[#lines + 1] = Helpers.getForecastText(
            "MaxPartySize",
            tostring(args.maxRaidSize or "?"),
            tostring(args.partyPercent or "?")
        )
        lines[#lines + 1] = ""
        lines[#lines + 1] = Helpers.getForecastText("HostileHeading")

        local any = false
        for _, entry in ipairs(args.hostileFactions or {}) do
            any = true
            lines[#lines + 1] = Helpers.getForecastText(
                "HostileEntry",
                tostring(entry.name or entry.factionID or "Faction"),
                tostring(entry.raidSize or 0),
                tostring(entry.resting or 0)
            )
        end
        if not any then
            lines[#lines + 1] = Helpers.getForecastText("HostileNone")
        end
    end

    local window = ForecastWindow:new(lines)
    window:initialise()
    window:addToUIManager()
    BanditClient.ForecastWindow = window
end
