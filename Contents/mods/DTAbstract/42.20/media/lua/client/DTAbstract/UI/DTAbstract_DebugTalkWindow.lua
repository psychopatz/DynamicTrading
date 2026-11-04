require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISTextEntryBox"

DTAbstract = DTAbstract or {}
DTAbstract.DebugTalkWindow = DTAbstract.DebugTalkWindow or {}

local Manager = DTAbstract.DebugTalkWindow
local Window = ISPanel:derive("DTAbstractDebugTalkWindow")

Manager.instance = Manager.instance or nil

local MAX_HISTORY = 12
local MAX_LINE = 105

local function client()
    return DTCommon and DTCommon.Client or nil
end

local function compact(value)
    value = tostring(value or "")
    value = string.gsub(value, "[\r\n]+", " ")
    if #value > MAX_LINE then
        return string.sub(value, 1, MAX_LINE - 3) .. "..."
    end
    return value
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

    self.input = ISTextEntryBox:new(
        "", 12, self.height - 44, self.width - 190, 25)
    if self.input.initialise then self.input:initialise() end
    if self.input.instantiate then self.input:instantiate() end
    self:addChild(self.input)

    self.sendButton = addButton(
        self, "SEND", "Send", self.width - 168, self.height - 44, 70)
    self.closeButton = addButton(
        self, "CLOSE", "Close", self.width - 90, self.height - 44, 78)
end

function Window:addHistory(prefix, text)
    self.history = self.history or {}
    self.history[#self.history + 1] =
        tostring(prefix or "") .. compact(text)
    while #self.history > MAX_HISTORY do
        table.remove(self.history, 1)
    end
end

function Window:applyTalkResult(args)
    args = type(args) == "table" and args or {}
    if tostring(args.traderID or "") ~= tostring(self.traderID or "") then
        return false
    end
    if args.accepted ~= true then
        self.status = "Talk failed: " .. tostring(args.reason or "talk_rejected")
        return false
    end

    self.sessionID = tostring(args.sessionID or self.sessionID or "")
    self.mode = tostring(args.mode or self.mode or "radio")
    self.debugAccess = args.debugAccess == true
    self.status = self.debugAccess
        and "Debug remote talk active (access simulated)."
        or "Talk session active."

    local result = type(args.result) == "table" and args.result or nil
    local turnCount = args.state and tonumber(args.state.turnCount) or nil
    if result and turnCount ~= self.lastTurnCount then
        local responses = type(result.responses) == "table"
            and result.responses or {}
        local added = false
        for index = 1, #responses do
            local row = responses[index]
            local text = type(row) == "table"
                and (row.text or row.fallback) or row
            if text and tostring(text) ~= "" then
                self:addHistory("Trader: ", text)
                added = true
            end
        end
        if not added and result.text then
            self:addHistory("Trader: ", result.text)
        end
        self.lastTurnCount = turnCount
    end
    return true
end

function Window:onButton(button)
    local id = button and button.internal or ""
    if id == "CLOSE" then
        self:close()
        return true
    end
    if id ~= "SEND" then return false end

    local api = client()
    if not api or type(api.SubmitTalk) ~= "function" then
        self.status = "DTCommon talk client unavailable."
        return false
    end
    if not self.sessionID or self.sessionID == "" then
        self.status = "Waiting for debug talk session..."
        return false
    end

    local text = self.input and self.input.getText
        and tostring(self.input:getText() or "") or ""
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then
        self.status = "Enter something to say."
        return false
    end

    self:addHistory("You: ", text)
    local ok, reason = api.SubmitTalk(
        self.traderID,
        self.sessionID,
        text,
        self.mode or "radio"
    )
    if not ok then
        self.status = "Send failed: " .. tostring(reason or "unknown")
        return false
    end
    if self.input and self.input.setText then
        self.input:setText("")
    end
    self.status = "Waiting for trader response..."
    return true
end

function Window:prerender()
    ISPanel.prerender(self)
    self:drawRect(
        0, 0, self.width, self.height, 0.97, 0.025, 0.025, 0.03)
    self:drawRectBorder(
        0, 0, self.width, self.height, 0.95, 0.3, 0.65, 0.9)

    self:drawText(
        "Abstract Trader Debug Talk",
        12, 10, 0.95, 0.95, 0.95, 1, UIFont.Medium)
    self:drawText(
        tostring(self.displayName or self.traderID or "Trader")
            .. " | " .. tostring(self.traderID or ""),
        12, 36, 0.72, 0.8, 0.9, 1, UIFont.Small)
    self:drawText(
        tostring(self.status or "Opening debug talk session..."),
        12, 54, 0.65, 0.75, 0.82, 1, UIFont.Small)

    local y = 82
    for index = 1, #(self.history or {}) do
        self:drawText(
            self.history[index],
            12, y, 0.9, 0.9, 0.9, 1, UIFont.Small)
        y = y + 20
    end
end

function Window:close()
    local api = client()
    if api and type(api.CloseTalk) == "function"
        and self.sessionID and self.sessionID ~= ""
    then
        api.CloseTalk(
            self.traderID,
            self.sessionID,
            self.mode or "radio"
        )
    end
    self:setVisible(false)
    self:removeFromUIManager()
    if Manager.instance == self then Manager.instance = nil end
end

function Window:new(x, y, width, height, traderID, displayName)
    local object = ISPanel:new(x, y, width, height)
    setmetatable(object, self)
    self.__index = self
    object.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    object.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    object.moveWithMouse = true
    object.traderID = tostring(traderID or "")
    object.displayName = displayName
    object.history = {}
    object.status = "Opening debug talk session..."
    object.mode = "radio"
    object.sessionID = nil
    object.lastTurnCount = nil
    return object
end

function Manager.Open(traderID, displayName)
    traderID = tostring(traderID or "")
    if traderID == "" then return nil, "trader_required" end
    if Manager.instance then
        Manager.instance:close()
    end

    local width, height = 720, 360
    local screenWidth = getCore and getCore():getScreenWidth() or 1280
    local screenHeight = getCore and getCore():getScreenHeight() or 720
    local window = Window:new(
        math.floor((screenWidth - width) / 2),
        math.floor((screenHeight - height) / 2),
        width,
        height,
        traderID,
        displayName
    )
    window:initialise()
    window:instantiate()
    window:addToUIManager()
    window:bringToTop()
    Manager.instance = window
    return window
end

local function onServerCommand(module, command, args)
    if module ~= (DTCommon and DTCommon.MOD_ID or "DynamicTrading")
        or command ~= "TalkResult"
    then
        return
    end
    if Manager.instance then
        Manager.instance:applyTalkResult(args)
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not Manager._serverHook
then
    Manager._serverHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

return Manager
