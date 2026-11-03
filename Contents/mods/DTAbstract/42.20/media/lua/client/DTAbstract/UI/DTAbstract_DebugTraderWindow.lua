require "ISUI/ISPanel"
require "ISUI/ISButton"

DTAbstract = DTAbstract or {}
DTAbstract.DebugTraderWindow = DTAbstract.DebugTraderWindow or {}

local Manager = DTAbstract.DebugTraderWindow
local Window = ISPanel:derive("DTAbstractDebugTraderWindow")

Manager.instance = Manager.instance or nil

local function service()
    return DTAbstract.DebugHub
end

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function addButton(panel, id, title, x, y, width)
    local button = ISButton:new(
        x, y, width, 25, title, panel, Window.onButton)
    button.internal = id
    if button.initialise then button:initialise() end
    if button.instantiate then button:instantiate() end
    panel:addChild(button)
    return button
end

function Window:initialise()
    ISPanel.initialise(self)
end

function Window:createChildren()
    ISPanel.createChildren(self)

    self.refreshButton = addButton(self, "REFRESH", "Refresh", 10, 10, 80)
    self.spawnNearButton =
        addButton(self, "SPAWN_NEAR", "Spawn Near", 98, 10, 100)
    self.spawnAtButton =
        addButton(self, "SPAWN_AT", "Spawn At Player", 206, 10, 125)
    self.tickButton =
        addButton(self, "TICK", "Force Tick", 339, 10, 90)
    self.closeButton =
        addButton(self, "CLOSE", "Close", self.width - 90, 10, 80)

    self.rows = {}
    self.traders = {}
    self.notice = "Loading synchronized abstract trader state..."
    self:refreshData()
end

function Window:refreshData()
    local api = service()
    self.traders = api and api.ListTraders and api.ListTraders() or {}
    if api and api.RefreshProjection then api.RefreshProjection() end
    self:rebuildRowButtons()
end

function Window:onButton(button)
    local id = button and button.internal or ""
    local api = service()
    if not api then return false end

    if id == "REFRESH" then
        self.notice = "Refreshing synchronized projection..."
        self:refreshData()
        return true
    elseif id == "SPAWN_NEAR" then
        self.notice = "Spawn-near request sent..."
        return api.SpawnNear()
    elseif id == "SPAWN_AT" then
        local current = player()
        if not current then
            self.notice = "No local player."
            return false
        end
        self.notice = "Explicit-position spawn request sent..."
        return api.SpawnAt(
            current:getX(), current:getY(), current.getZ and current:getZ() or 0)
    elseif id == "TICK" then
        self.notice = "Force-tick request sent..."
        return api.ForceTick()
    elseif id == "CLOSE" then
        self:close()
        return true
    end

    local traderID = button and button.traderID
    if not traderID then return false end

    if id == "TP" then
        self.notice = "Teleport request: " .. traderID
        return api.TeleportToTrader(traderID)
    elseif id == "ARRIVE" then
        self.notice = "Force-arrival request: " .. traderID
        return api.ForceArrival(traderID)
    elseif id == "LOCATE" then
        local ok, pos = api.LocateOnMap(traderID)
        if ok and pos then
            self.notice = "Map location: "
                .. math.floor(pos.x) .. "," .. math.floor(pos.y)
        else
            self.notice = "Unable to locate " .. traderID
        end
        return ok
    elseif id == "RESET_DISCOVERY" then
        local ok = api.ResetDiscovery(traderID)
        self.notice = ok and ("Discovery reset: " .. traderID)
            or ("Discovery reset failed: " .. traderID)
        return ok
    elseif id == "MARK_DISCOVERY" then
        local ok = api.MarkDiscovery(traderID)
        self.notice = ok and ("Marked seen: " .. traderID)
            or ("Mark seen failed: " .. traderID)
        return ok
    elseif id == "REMOVE" then
        self.notice = "Remove request: " .. traderID
        return api.RemoveTrader(traderID)
    elseif id == "MATERIALIZE" then
        self.notice = "Materialize request: " .. traderID
        return api.Materialize(traderID)
    elseif id == "DEMATERIALIZE" then
        self.notice = "Dematerialize request: " .. traderID
        return api.Dematerialize(traderID)
    end
    return false
end

function Window:rebuildRowButtons()
    local maxRows = 12
    local rowHeight = 42

    for rowIndex = 1, #(self.rows or {}) do
        local row = self.rows[rowIndex]
        for _, button in pairs(row) do
            if type(button) == "table" and button.setVisible then
                button:setVisible(false)
            end
        end
    end
    self.rows = self.rows or {}

    for rowIndex = 1, math.min(#self.traders, maxRows) do
        local item = self.traders[rowIndex]
        local y = 76 + (rowIndex - 1) * rowHeight
        local row = self.rows[rowIndex] or {}

        if not row.teleport then
            local x = self.width - 455
            row.locate = addButton(self, "LOCATE", "Map", x, y, 55)
            row.teleport = addButton(self, "TP", "TP", x + 60, y, 45)
            row.arrive = addButton(self, "ARRIVE", "Arrive", x + 110, y, 60)
            row.reset = addButton(
                self, "RESET_DISCOVERY", "Reset Seen", x + 175, y, 80)
            row.provider = addButton(
                self, "MATERIALIZE", "Materialize", x + 260, y, 90)
            row.remove = addButton(self, "REMOVE", "Remove", x + 355, y, 75)
        end

        local buttons = {
            row.locate, row.teleport, row.arrive,
            row.reset, row.provider, row.remove,
        }
        for _, button in ipairs(buttons) do
            button.traderID = item.traderID
            button:setY(y)
            button:setVisible(true)
        end

        if item.discovered then
            row.reset.internal = "RESET_DISCOVERY"
            row.reset:setTitle("Reset Seen")
        else
            row.reset.internal = "MARK_DISCOVERY"
            row.reset:setTitle("Mark Seen")
        end

        if item.providerState == "materialized" then
            row.provider.internal = "DEMATERIALIZE"
            row.provider:setTitle("Dematerialize")
        else
            row.provider.internal = "MATERIALIZE"
            row.provider:setTitle("Materialize")
        end

        self.rows[rowIndex] = row
    end
end

function Window:setResult(message)
    self.notice = tostring(message or "")
    self:refreshData()
end

function Window:prerender()
    ISPanel.prerender(self)
    self:drawRect(
        0, 0, self.width, self.height, 0.96, 0.025, 0.025, 0.03)
    self:drawRectBorder(
        0, 0, self.width, self.height, 0.95, 0.3, 0.65, 0.9)

    self:drawText(
        "Dynamic Trading - Abstract Trader Manager",
        10, 42, 0.95, 0.95, 0.95, 1, UIFont.Medium)
    self:drawText(
        tostring(self.notice or ""),
        445, 17, 0.65, 0.72, 0.8, 1, UIFont.Small)

    local maxRows = 12
    for index = 1, math.min(#self.traders, maxRows) do
        local item = self.traders[index]
        local y = 80 + (index - 1) * 42
        local pos = item.position
        local posText = pos and (
            math.floor(pos.x) .. "," .. math.floor(pos.y)
                .. "," .. math.floor(pos.z or 0)
        ) or "sync pending"
        local distance = item.distance
            and tostring(math.floor(item.distance)) or "?"

        self:drawText(
            tostring(item.displayName) .. " | " .. tostring(item.traderID),
            10, y, 0.92, 0.92, 0.92, 1, UIFont.Small)
        self:drawText(
            "actor=" .. tostring(item.actorID)
                .. " provider=" .. tostring(item.provider)
                .. "/" .. tostring(item.providerState)
                .. " pos=" .. posText
                .. " dist=" .. distance,
            10, y + 14, 0.65, 0.7, 0.78, 1, UIFont.Small)
        self:drawText(
            "route=" .. tostring(item.currentSettlementID or "-")
                .. " -> " .. tostring(item.destinationSettlementID or "-")
                .. " journey=" .. tostring(item.journeyState)
                .. " " .. tostring(math.floor(
                    (tonumber(item.journeyProgress) or 0) * 100)) .. "%",
            10, y + 27, 0.6, 0.68, 0.78, 1, UIFont.Small)
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

function Manager.SetResult(message)
    if Manager.instance then Manager.instance:setResult(message) end
end

function Manager.Open()
    if Manager.instance then
        Manager.instance:setVisible(true)
        Manager.instance:bringToTop()
        Manager.instance:refreshData()
        return Manager.instance
    end

    local width, height = 1120, 610
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
    return window
end

return Manager
