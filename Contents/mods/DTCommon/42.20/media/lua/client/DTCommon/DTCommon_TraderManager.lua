-- Shared Dynamic Trading trader manager.
-- The model and window are provider-neutral; providers register only bounded
-- authorization/transport actions.

DTCommon = DTCommon or {}
DTCommon.TraderManager = DTCommon.TraderManager or {}

local Manager = DTCommon.TraderManager
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

Manager.Providers = Manager.Providers or {}
Manager.MAX_ROWS = tonumber(Manager.MAX_ROWS) or 18
Manager.instance = Manager.instance or nil
Manager.notice = Manager.notice or "Ready"

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

function Manager.CanUse()
    local current = player()
    if not current then return true end
    local debugSettings = PsychopatzCore and PsychopatzCore.Debug
    if debugSettings and type(debugSettings.CanUse) == "function" then
        return debugSettings.CanUse(current) == true
    end
    return false
end

function Manager.RegisterProvider(providerID, definition)
    providerID = tostring(providerID or "")
    if providerID == "" or type(definition) ~= "table"
        or type(definition.action) ~= "function"
    then
        return false, "invalid_trader_manager_provider"
    end
    Manager.Providers[providerID] = {
        authorize = definition.authorize,
        action = definition.action,
        diagnostics = definition.diagnostics,
    }
    return true
end

local function normalizedRow(row)
    row = type(row) == "table" and row or {}
    if row.displayName == nil then row.displayName = row.name end
    if row.name == nil then row.name = row.displayName end
    return row
end

function Manager.ListTraders(force, now)
    local rows = Presentation.ListTraderViews
        and Presentation.ListTraderViews(force == true, now) or {}
    local output = {}
    for _, row in ipairs(rows or {}) do
        output[#output + 1] = normalizedRow(row)
    end
    table.sort(output, function(left, right)
        return tostring(left.traderID or "")
            < tostring(right.traderID or "")
    end)
    return output
end

function Manager.FindTrader(traderID, force, actorID)
    traderID = tostring(traderID or "")
    actorID = tostring(actorID or "")
    for _, row in ipairs(Manager.ListTraders(force == true)) do
        if tostring(row.traderID or "") == traderID
            and (actorID == "" or tostring(row.actorID or "") == actorID)
        then
            return row
        end
    end
    return nil, "trader_not_found"
end

local function providerFor(row)
    return Manager.Providers[tostring(row and row.provider or "")]
end

-- Ordinary player-facing actions use the same shared model and provider
-- transport as the debug manager, but do not inherit its debug authorization
-- gate. Provider adapters remain responsible only for the transport/action.
function Manager.Request(action, traderID, args)
    action = tostring(action or "")
    args = type(args) == "table" and args or {}
    if action ~= "talk" and action ~= "trade" then
        return false, "trader_request_invalid"
    end
    local row, reason = Manager.FindTrader(
        traderID,
        true,
        args.actorID or args.npcID
    )
    if not row then return false, reason end
    if action == "talk" and row.talkAvailable == false then
        return false, "talk_unavailable"
    end
    if action == "trade" and row.tradeAvailable == false then
        return false, "trade_unavailable"
    end
    local provider = providerFor(row)
    if not provider or type(provider.action) ~= "function" then
        return false, "provider_adapter_unavailable"
    end
    local ok, result = provider.action(action, row, args)
    if ok == true then
        Manager.notice = tostring(action) .. " requested for "
            .. tostring(row.name or row.traderID) .. "."
    elseif result ~= nil then
        Manager.SetNotice(
            tostring(action) .. " unavailable: " .. tostring(result)
        )
    end
    return ok, result
end

function Manager.Action(action, traderID, args)
    action = tostring(action or "")
    args = type(args) == "table" and args or {}
    if action == "refresh" then
        if Presentation.InvalidateRecordCache then
            Presentation.InvalidateRecordCache()
        end
        local ok = false
        for _, provider in pairs(Manager.Providers) do
            if type(provider.action) == "function" then
                local providerOK = provider.action("refresh", nil, args)
                ok = providerOK == true or ok
            end
        end
        local client = args.client
        if client and type(client.RequestActors) == "function" then
            ok = client.RequestActors() == true or ok
        end
        Manager.notice = "Projection refresh requested."
        return ok or true
    end

    if action == "spawn_near"
        or action == "spawn_at"
        or action == "force_tick"
    then
        for _, provider in pairs(Manager.Providers) do
            if type(provider.action) == "function" then
                local ok, result = provider.action(action, nil, args)
                if ok ~= nil then return ok, result end
            end
        end
        return false, "provider_adapter_unavailable"
    end

    local row, reason = Manager.FindTrader(traderID, true)
    if not row then return false, reason end
    local provider = providerFor(row)
    if not provider then return false, "provider_adapter_unavailable" end
    if type(provider.authorize) == "function"
        and provider.authorize(action, row, args) ~= true
    then
        return false, "not_authorized"
    end
    local ok, result = provider.action(action, row, args)
    if ok == true then
        Manager.notice = tostring(action) .. " requested for "
            .. tostring(row.name or row.traderID) .. "."
    elseif result ~= nil then
        Manager.SetNotice(
            tostring(action) .. " unavailable: " .. tostring(result)
        )
    end
    return ok, result
end

function Manager.SetNotice(message)
    Manager.notice = tostring(message or "")
    if Manager.instance then
        Manager.instance.notice = Manager.notice
    end
end

function Manager.SetResult(message, args)
    Manager.SetNotice(message)
    if Manager.instance and Manager.instance.refreshData then
        Manager.instance:refreshData()
    end
    Manager.LastResult = args
end

local function ensureWindowType()
    if Manager.Window then return Manager.Window end
    if type(ISPanel) ~= "table" and type(ISPanel) ~= "function" then
        pcall(require, "ISUI/ISPanel")
    end
    if type(ISButton) ~= "table" and type(ISButton) ~= "function" then
        pcall(require, "ISUI/ISButton")
    end
    if not ISPanel or not ISButton or type(ISPanel.derive) ~= "function" then
        return nil
    end

    local Window = ISPanel:derive("DTCommonTraderManagerWindow")

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
        self.spawnNearButton = addButton(
            self, "SPAWN_NEAR", "Spawn Near", 98, 10, 100)
        self.spawnAtButton = addButton(
            self, "SPAWN_AT", "Spawn At", 206, 10, 90)
        self.tickButton = addButton(
            self, "FORCE_TICK", "Force Tick", 304, 10, 90)
        self.closeButton = addButton(
            self, "CLOSE", "Close", self.width - 90, 10, 80)
        self.rows = {}
        self.traders = {}
        self.notice = Manager.notice
        self:refreshData()
    end

    function Window:refreshData()
        self.traders = Manager.ListTraders(true)
        self.notice = Manager.notice
        self:rebuildRowButtons()
    end

    function Window:onButton(button)
        local id = button and button.internal or ""
        if id == "CLOSE" then
            self:close()
            return true
        end
        if id == "REFRESH" then
            Manager.Action("refresh")
            self:refreshData()
            return true
        end
        if id == "SPAWN_NEAR" or id == "SPAWN_AT"
            or id == "FORCE_TICK"
        then
            local action = id == "SPAWN_NEAR" and "spawn_near"
                or id == "SPAWN_AT" and "spawn_at" or "force_tick"
            local ok, reason = Manager.Action(action, nil, {
                player = player(),
            })
            if not ok then Manager.SetNotice(reason) end
            return ok
        end
        local ok, reason = Manager.Action(
            id:lower(),
            button and button.traderID,
            {
                player = player(),
                actorID = button and button.actorID,
            }
        )
        if not ok then Manager.SetNotice(reason) end
        return ok
    end

    function Window:rebuildRowButtons()
        for _, row in ipairs(self.rows or {}) do
            for _, button in pairs(row) do
                if type(button) == "table" and button.setVisible then
                    button:setVisible(false)
                end
            end
        end
        self.rows = self.rows or {}
        for index = 1, math.min(#self.traders, Manager.MAX_ROWS) do
            local item = self.traders[index]
            local y = 76 + (index - 1) * 40
            local row = self.rows[index] or {}
            local x = self.width - 420
            if not row.locate then
                row.locate = addButton(self, "LOCATE", "Map", x, y, 52)
                row.talk = addButton(self, "TALK", "Talk", x + 56, y, 52)
                row.trade = addButton(self, "TRADE", "Trade", x + 112, y, 58)
                row.arrive = addButton(
                    self, "FORCE_ARRIVAL", "Arrive", x + 174, y, 60)
                row.remove = addButton(
                    self, "REMOVE", "Remove", x + 238, y, 62)
                row.seen = addButton(
                    self, "MARK_SEEN", "Seen", x + 304, y, 55)
            end
            for _, button in pairs(row) do
                button.traderID = item.traderID
                button.actorID = item.actorID
                button:setY(y)
                button:setVisible(true)
            end
            if row.talk and type(row.talk.setEnable) == "function" then
                row.talk:setEnable(item.talkAvailable ~= false)
            end
            if row.trade and type(row.trade.setEnable) == "function" then
                row.trade:setEnable(item.tradeAvailable ~= false)
            end
            self.rows[index] = row
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
            10, 42, 0.95, 0.95, 0.95, 1, UIFont.Medium)
        self:drawText(
            tostring(self.notice or Manager.notice),
            410, 17, 0.65, 0.72, 0.8, 1, UIFont.Small)
        for index = 1, math.min(#self.traders, Manager.MAX_ROWS) do
            local item = self.traders[index]
            local y = 80 + (index - 1) * 40
            local position = item.position
            local posText = position and (
                math.floor(tonumber(position.x) or 0) .. ","
                .. math.floor(tonumber(position.y) or 0)
            ) or "sync pending"
            self:drawText(
                tostring(item.name or item.displayName or item.traderID)
                    .. " | " .. tostring(item.traderID),
                10, y, 0.92, 0.92, 0.92, 1, UIFont.Small)
            self:drawText(
                "actor=" .. tostring(item.actorID)
                    .. " provider=" .. tostring(item.provider)
                    .. "/" .. tostring(item.providerState)
                    .. " pos=" .. posText
                    .. " faction=" .. tostring(item.factionID or "-"),
                10, y + 14, 0.65, 0.7, 0.78, 1, UIFont.Small)
            self:drawText(
                "journey=" .. tostring(item.journey and item.journey.state
                    or item.journeyState or "idle")
                    .. " progress=" .. tostring(math.floor(
                        (tonumber(item.journey
                            and item.journey.progress
                            or item.journeyProgress) or 0) * 100)) .. "%",
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

    Manager.Window = Window
    return Window
end

function Manager.Open()
    if Manager.instance then
        Manager.instance:setVisible(true)
        Manager.instance:bringToTop()
        Manager.instance:refreshData()
        return Manager.instance
    end
    local Window = ensureWindowType()
    if not Window then return nil, "ui_unavailable" end
    local width, height = 1120, 650
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

local CoreDebugHub = PsychopatzCore and PsychopatzCore.DebugHub
if CoreDebugHub
    and type(CoreDebugHub.RegisterTool) == "function"
    and not Manager._hubToolRegistered
then
    Manager._hubToolRegistered = true
    CoreDebugHub.RegisterTool({
        id = "dtcommon.traderManager",
        source = "Dynamic Trading",
        order = 220,
        category = "dynamictrading",
        title = "Trader Manager",
        description = "Inspect and operate Dynamic Trading traders.",
        available = Manager.CanUse,
        action = Manager.Open,
    })
end

return Manager
