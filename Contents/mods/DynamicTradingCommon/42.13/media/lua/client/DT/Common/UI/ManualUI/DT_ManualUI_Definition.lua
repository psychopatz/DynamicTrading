require "ISUI/ISCollapsableWindow"
require "Utils/DT_ConfigManager"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {}

DT_ManualUI = DT_ManualUI or ISCollapsableWindow:derive("DT_ManualUI")
DT_ManualUI.instance = DT_ManualUI.instance or nil

function DT_ManualUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Dynamic Trading Manuals")
    self:setResizable(true)

    self.currentManualId = nil
    self.currentPageId = nil
    self.highlightSectionId = nil
    self.results = {}
    self.navRows = {}
    self.manuals = {}
    self.pageByManual = {}
    self.pageLookup = {}
    self.blockSectionIndex = {}
    self.resultsVisible = false
end

function DT_ManualUI:close()
    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("ManualUI", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end
    if DT_ConfigManager and DT_ConfigManager.setLastManualLocation then
        DT_ConfigManager.setLastManualLocation(self.currentManualId, self.currentPageId, self.highlightSectionId)
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DT_ManualUI.instance = nil
end

function DT_ManualUI.Open(args)
    if DT_ManualUI.instance then
        DT_ManualUI.instance:close()
    end

    local width = 940
    local height = 640
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("ManualUI")
        if state then
            x = state.x or x
            y = state.y or y
            width = state.w or width
            height = state.h or height
        end
    end

    local ui = DT_ManualUI:new(x, y, width, height)
    ui:initialise()
    ui:addToUIManager()
    ui:loadManualData()
    ui:openLocation(args)

    DT_ManualUI.instance = ui
    return ui
end

function DT_ManualUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.resizable = true
    o.title = "Dynamic Trading Manuals"
    return o
end

DynamicTrading.Manuals.Open = function(args)
    return DT_ManualUI.Open(args or {})
end
