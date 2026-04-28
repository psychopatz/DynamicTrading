require "ISUI/ISCollapsableWindow"

DT_RadioScannerScanStatsModal = ISCollapsableWindow:derive("DT_RadioScannerScanStatsModal")
DT_RadioScannerScanStatsModal.instance = nil

local function formatPercent(value)
    return string.format("%.0f%%", tonumber(value) or 0)
end

function DT_RadioScannerScanStatsModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
    self:setTitle("Radar Scan Modifiers")
end

function DT_RadioScannerScanStatsModal:prerender()
    ISCollapsableWindow.prerender(self)
    self:drawRect(0, self:titleBarHeight(), self.width, self.height - self:titleBarHeight(), 0.94, 0.03, 0.03, 0.03)
end

function DT_RadioScannerScanStatsModal:render()
    ISCollapsableWindow.render(self)

    local stats = self.stats or {}
    local startY = self:titleBarHeight() + 12
    local lineGap = 16
    local detailGap = 48
    local titleColor = { 0.88, 0.88, 0.88, 1 }
    local detailColor = { 0.72, 0.72, 0.72, 1 }

    local sections = {
        {
            title = "Base Chance: " .. formatPercent(stats.baseChance),
            lines = {
                "This is the starting scan chance before any radio, world,",
                "or skill-based protection is applied.",
            },
        },
        {
            title = "Power Bonus: " .. formatPercent((tonumber(stats.powerBonus) or 1.0) * 100),
            lines = {
                "Better radios push the roll upward.",
                "Stronger devices improve the scan chance above the base value.",
            },
        },
        {
            title = "Electricity Floor: " .. formatPercent(stats.electricityFloorChance),
            lines = {
                "Your Electricity skill sets the minimum lock chance.",
                "At level 10, the floor becomes 100% for eligible signals.",
            },
        },
        {
            title = "World Modifier: " .. formatPercent((tonumber(stats.globalChanceMult) or 1.0) * 100),
            lines = {
                "World and event conditions can strengthen or weaken signal discovery.",
                "Good signal weather raises the roll, bad conditions reduce it.",
            },
        },
    }

    for index, section in ipairs(sections) do
        local blockY = startY + ((index - 1) * detailGap)
        self:drawText(section.title, 14, blockY, titleColor[1], titleColor[2], titleColor[3], titleColor[4], UIFont.Medium)
        for lineIndex, line in ipairs(section.lines or {}) do
            self:drawText(line, 14, blockY + lineGap + ((lineIndex - 1) * 14), detailColor[1], detailColor[2], detailColor[3], detailColor[4], UIFont.Small)
        end
    end

    self:drawText("Click the X or press Escape to close.", 14, self.height - 30, 0.55, 0.55, 0.55, 1, UIFont.Small)
end

function DT_RadioScannerScanStatsModal:onKeyPress(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
        return true
    end
end

function DT_RadioScannerScanStatsModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if DT_RadioScannerScanStatsModal.instance == self then
        DT_RadioScannerScanStatsModal.instance = nil
    end
end

function DT_RadioScannerScanStatsModal:new(x, y, w, h)
    local o = ISCollapsableWindow:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.resizable = false
    o.stats = {}
    return o
end

function DT_RadioScannerScanStatsModal.Open(stats)
    if DT_RadioScannerScanStatsModal.instance then
        DT_RadioScannerScanStatsModal.instance:close()
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = 620
    local height = 280
    local x = math.floor((screenW - width) / 2)
    local y = math.floor((screenH - height) / 2)

    local modal = DT_RadioScannerScanStatsModal:new(x, y, width, height)
    modal.stats = type(stats) == "table" and stats or {}
    modal:initialise()
    modal:addToUIManager()
    modal:setVisible(true)

    DT_RadioScannerScanStatsModal.instance = modal
    return modal
end
