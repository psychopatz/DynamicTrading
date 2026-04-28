require "ISUI/ISPanel"
pcall(require, "DT/Common/UI/RadioScanner/DT_RadioScannerScanStatsModal")

DT_RadioScannerScanStatsPanel = ISPanel:derive("DT_RadioScannerScanStatsPanel")

local function hasStatsData(stats)
    if type(stats) ~= "table" then
        return false
    end

    for _, _ in pairs(stats) do
        return true
    end

    return false
end

local function pickMetricColor(kind, value, fallbackGood)
    local numeric = tonumber(value)
    if kind == "multiplier" then
        if numeric == nil then
            return 0.65, 0.65, 0.65
        end
        if numeric >= 1.2 then
            return 0.35, 0.9, 1.0
        end
        if numeric >= 1.0 then
            return 0.35, 0.95, 0.4
        end
        if numeric >= 0.85 then
            return 1.0, 0.82, 0.25
        end
        return 1.0, 0.4, 0.4
    end

    if kind == "chance" then
        if numeric == nil then
            return 0.65, 0.65, 0.65
        end
        if numeric >= 100 then
            return 0.35, 0.9, 1.0
        end
        if numeric >= 75 then
            return 0.35, 0.95, 0.4
        end
        if numeric >= 40 then
            return 1.0, 0.82, 0.25
        end
        return 1.0, 0.4, 0.4
    end

    if kind == "level" then
        if numeric == nil then
            return 0.65, 0.65, 0.65
        end
        if numeric >= 10 then
            return 0.35, 0.9, 1.0
        end
        if numeric >= 7 then
            return 0.35, 0.95, 0.4
        end
        if numeric >= 4 then
            return 1.0, 0.82, 0.25
        end
        return 1.0, 0.4, 0.4
    end

    if kind == "count" then
        if numeric and numeric > 0 then
            return 0.35, 0.95, 0.4
        end
        return 1.0, 0.4, 0.4
    end

    if fallbackGood == true then
        return 0.35, 0.95, 0.4
    end
    return 0.75, 0.75, 0.75
end

function DT_RadioScannerScanStatsPanel:initialise()
    ISPanel.initialise(self)
    self.stats = self.stats or {}
end

function DT_RadioScannerScanStatsPanel:setStats(stats)
    self.stats = type(stats) == "table" and stats or {}
end

function DT_RadioScannerScanStatsPanel:onMouseDown(x, y)
    return true
end

function DT_RadioScannerScanStatsPanel:onMouseUp(x, y)
    if hasStatsData(self.stats)
        and type(DT_RadioScannerScanStatsModal) == "table"
        and type(DT_RadioScannerScanStatsModal.Open) == "function" then
        local ok, err = pcall(DT_RadioScannerScanStatsModal.Open, self.stats)
        if not ok and DynamicTrading and DynamicTrading.Log then
            DynamicTrading.Log("DTCommons", "Radio", "Error", "Failed to open scan stats modal: " .. tostring(err))
        end
        return ok == true
    end
    return false
end

function DT_RadioScannerScanStatsPanel:prerender()
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, 0.45, 0.03, 0.03, 0.03)
    self:drawRectBorder(0, 0, self.width, self.height, 0.7, 0.24, 0.24, 0.24)
end

function DT_RadioScannerScanStatsPanel:render()
    ISPanel.render(self)

    local stats = self.stats or {}
    local cards = {
        {
            label = "Base Chance",
            value = string.format("%.0f%%", tonumber(stats.baseChance) or 0),
            color = { pickMetricColor("chance", stats.baseChance, true) },
        },
        {
            label = "Power Bonus",
            value = string.format("%.0f%%", (tonumber(stats.powerBonus) or 1.0) * 100),
            color = { pickMetricColor("multiplier", stats.powerBonus, true) },
        },
        {
            label = "Electricity Floor",
            value = string.format("%.0f%%", tonumber(stats.electricityFloorChance) or 0),
            color = { pickMetricColor("chance", stats.electricityFloorChance, true) },
        },
        {
            label = "World Modifier",
            value = string.format("%.0f%%", (tonumber(stats.globalChanceMult) or 1.0) * 100),
            color = { pickMetricColor("multiplier", stats.globalChanceMult, true) },
        },
    }

    local outerPadding = 8
    local gap = 8
    local cardCount = #cards
    local availableWidth = math.max(120, self.width - (outerPadding * 2) - (gap * math.max(0, cardCount - 1)))
    local cardWidth = math.floor(availableWidth / math.max(1, cardCount))
    local cardHeight = math.max(26, self.height - 12)
    local cardY = math.floor((self.height - cardHeight) / 2)

    for index, card in ipairs(cards) do
        local cardX = outerPadding + ((index - 1) * (cardWidth + gap))
        local currentCardWidth = cardWidth
        if index == cardCount then
            currentCardWidth = math.max(cardWidth, self.width - outerPadding - cardX)
        end

        local r, g, b = card.color[1], card.color[2], card.color[3]
        self:drawRect(cardX, cardY, currentCardWidth, cardHeight, 0.16, r, g, b)
        self:drawRectBorder(cardX, cardY, currentCardWidth, cardHeight, 0.45, r, g, b)
        self:drawTextCentre(tostring(card.label), cardX + (currentCardWidth / 2), cardY + 3, 0.86, 0.86, 0.86, 0.95, UIFont.Small)
        self:drawTextCentre(tostring(card.value), cardX + (currentCardWidth / 2), cardY + 17, r, g, b, 1, UIFont.Medium)
    end
end

function DT_RadioScannerScanStatsPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.stats = {}
    return o
end
