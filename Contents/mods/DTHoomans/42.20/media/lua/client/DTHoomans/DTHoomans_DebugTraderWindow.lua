require "ISUI/ISPanel"
require "ISUI/ISButton"

DTHoomans = DTHoomans or {}
DTHoomans.DebugTraderWindow = DTHoomans.DebugTraderWindow or {}

local Window = ISPanel:derive("DTHoomansDebugTraderWindow")
local Manager = DTHoomans.DebugTraderWindow
Manager.instance = Manager.instance or nil

local function player()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function request(command, payload)
    local current = player()
    if not current or type(sendClientCommand) ~= "function" then
        return false
    end
    sendClientCommand(
        current,
        DTHoomans.MOD_ID,
        command,
        payload or {}
    )
    return true
end

local function addButton(panel, id, title, x, y, width)
    local button = ISButton:new(
        x, y, width, 25, title, panel, Window.onButton)
    button.internal = id
    button:initialise()
    button:instantiate()
    panel:addChild(button)
    return button
end

function Window:initialise()
    ISPanel.initialise(self)
end

function Window:createChildren()
    ISPanel.createChildren(self)
    self.refreshButton = addButton(
        self, "REFRESH", "Refresh", 10, 10, 85)
    self.closeButton = addButton(
        self, "CLOSE", "Close", self.width - 90, 10, 80)
    self.rows = {}
    self.traders = {}
    self.pending = {}
    self.notice = "Requesting trader state..."
end

function Window:onButton(button)
    local id = button and button.internal or ""
    if id == "REFRESH" then
        self.notice = "Refreshing..."
        request("DebugListTraders")
        return true
    end
    if id == "CLOSE" then
        self:close()
        return true
    end
    if id == "TP" then
        self.notice = "Teleport request sent for " .. tostring(button.traderID)
        request("DebugTeleportTrader", {
            traderID = button.traderID,
        })
        return true
    end
    if id == "TRADE" then
        if DTCommon and DTCommon.Client then
            DTCommon.Client.OpenTrader(button.traderID, {
                mode = "trade",
                npcID = button.npcID,
            })
        end
        return true
    end
    return false
end

function Window:setData(traders, pending, notice)
    self.traders = type(traders) == "table" and traders or {}
    self.pending = type(pending) == "table" and pending or {}
    self.notice = tostring(notice or "refreshed")
    self:rebuildRowButtons()
end

function Window:rebuildRowButtons()
    local rowIndex
    local row
    local item
    local y
    local maxRows = 15
    local rowHeight = 31
    local button
    local visibleCount = 0

    for rowIndex = 1, #(self.rows or {}) do
        for _, button in ipairs(self.rows[rowIndex]) do
            button:setVisible(false)
        end
    end
    self.rows = self.rows or {}

    for rowIndex = 1, math.min(#self.traders, maxRows) do
        item = self.traders[rowIndex]
        y = 52 + (rowIndex - 1) * rowHeight
        row = self.rows[rowIndex] or {}
        if not row.teleport then
            row.teleport = addButton(
                self, "TP", "TP", self.width - 150, y, 55)
            row.trade = addButton(
                self, "TRADE", "Trade", self.width - 90, y, 70)
        end
        row.teleport.traderID = item.traderID
        row.trade.traderID = item.traderID
        row.trade.npcID = item.leaderNPCID
        row.teleport:setY(y)
        row.trade:setY(y)
        row.teleport:setVisible(true)
        row.trade:setVisible(true)
        self.rows[rowIndex] = row
        visibleCount = visibleCount + 1
    end

    for rowIndex = 1, math.min(#self.pending, maxRows - visibleCount) do
        y = 52 + (visibleCount + rowIndex - 1) * rowHeight
        row = self.rows[visibleCount + rowIndex] or {}
        if not row.teleport then
            row.teleport = addButton(
                self, "TP", "TP", self.width - 150, y, 55)
            row.trade = addButton(
                self, "TRADE", "Trade", self.width - 90, y, 70)
        end
        row.teleport.traderID = nil
        row.trade.traderID = nil
        row.teleport:setVisible(false)
        row.trade:setVisible(false)
        self.rows[visibleCount + rowIndex] = row
    end
end

function Window:prerender()
    ISPanel.prerender(self)
    self:drawRect(
        0, 0, self.width, self.height, 0.96, 0.025, 0.025, 0.03)
    self:drawRectBorder(
        0, 0, self.width, self.height, 0.95, 0.3, 0.65, 0.9)
    self:drawText(
        "Dynamic Trading - Trader Manager",
        10, 39, 0.95, 0.95, 0.95, 1, UIFont.Medium)
    self:drawText(
        tostring(self.notice or ""),
        125, 18, 0.65, 0.72, 0.8, 1, UIFont.Small)
    self:drawText(
        "Trader / faction / leader location",
        10, 55, 0.65, 0.7, 0.78, 1, UIFont.Small)

    local rowIndex
    local item
    local y
    for rowIndex = 1, math.min(#self.traders, 15) do
        item = self.traders[rowIndex]
        y = 60 + (rowIndex - 1) * 31
        self:drawText(
            tostring(item.name) .. " | " .. tostring(item.traderID),
            10, y, 0.9, 0.9, 0.9, 1, UIFont.Small)
        self:drawText(
            "faction=" .. tostring(item.factionID)
                .. " members=" .. tostring(item.memberCount)
                .. " state=" .. tostring(item.status)
                .. " presence=" .. tostring(item.presence),
            10, y + 13, 0.62, 0.67, 0.74, 1, UIFont.Small)
        self:drawText(
            "pos=" .. tostring(math.floor(tonumber(item.x) or 0))
                .. "," .. tostring(math.floor(tonumber(item.y) or 0))
                .. "," .. tostring(math.floor(tonumber(item.z) or 0))
                .. " mobile=" .. tostring(item.pathMode)
                .. "/" .. tostring(item.controlMode),
            420, y + 13, 0.62, 0.67, 0.74, 1, UIFont.Small)
    end
    for rowIndex = 1, math.min(#self.pending, 15 - #self.traders) do
        item = self.pending[rowIndex]
        y = 60 + (#self.traders + rowIndex - 1) * 31
        self:drawText(
            "PENDING " .. tostring(item.requestID),
            10, y, 1, 0.75, 0.35, 1, UIFont.Small)
        self:drawText(
            "faction=" .. tostring(item.factionID)
                .. " pos=" .. tostring(math.floor(item.x or 0))
                .. "," .. tostring(math.floor(item.y or 0))
                .. "," .. tostring(math.floor(item.z or 0)),
            420, y + 5, 0.8, 0.65, 0.35, 1, UIFont.Small)
    end
end

function Window:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if Manager.instance == self then Manager.instance = nil end
end

function Window:new(x, y, width, height)
    local object = ISPanel:new(x, y, width, height)
    setmetatable(object, self)
    self.__index = self
    object.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    object.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    object.moveWithMouse = true
    return object
end

function Manager.SetData(traders, pending, notice)
    if Manager.instance then
        Manager.instance:setData(traders, pending, notice)
    end
end

function Manager.Open()
    if Manager.instance then
        Manager.instance:setVisible(true)
        Manager.instance:bringToTop()
        request("DebugListTraders")
        return Manager.instance
    end
    local width = 900
    local height = 560
    local screenWidth = getCore and getCore():getScreenWidth() or 1280
    local screenHeight = getCore and getCore():getScreenHeight() or 720
    local window = Window:new(
        math.floor((screenWidth - width) / 2),
        math.floor((screenHeight - height) / 2),
        width,
        height
    )
    window:initialise()
    window:instantiate()
    window:addToUIManager()
    window:bringToTop()
    Manager.instance = window
    request("DebugListTraders")
    return window
end

return Manager
