require "ISUI/ISCollapsableWindow"
require "DT/V1/Radio/SignalPanel/SignalPanel"
require "DT/V1/Radio/DT_TraderListPanel"
require "DT/V1/Radio/DT_LogPanel"
require "Utils/DT_ConfigManager"


DT_RadioWindow = ISCollapsableWindow:derive("DT_RadioWindow")
DT_RadioWindow.instance = nil

function DT_RadioWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Trader Network & Logs")
    self:setResizable(true) 
    self.clearStencil = false 
    self.radioObj = nil
    self.isHam = false
    
    self.minimumWidth = 380
    self.minimumHeight = 500
end

function DT_RadioWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local th = self:titleBarHeight()
    local w = self.width
    
    -- 1. Signal & Control Panel (Top)
    -- Height is now dynamic in relayout(), initial placeholder
    self.signalPanel = DT_SignalPanel:new(0, th, w, 150)
    self.signalPanel:initialise()
    self:addChild(self.signalPanel)
    
    -- 2. Trader List Panel (Middle)
    self.traderListPanel = DT_TraderListPanel:new(0, th + 150, w, 200)
    self.traderListPanel:initialise()
    self:addChild(self.traderListPanel)
    
    -- 3. Logs Panel (Bottom)
    self.logPanel = DT_LogPanel:new(0, th + 350, w, 100, "DynamicTrading_Logs_v1.0")
    self.logPanel:initialise()
    self:addChild(self.logPanel)
    
    -- Resize Widget Logic
    if self.resizeWidget then
        self.resizeWidget:bringToTop()
        self.resizeWidget:setVisible(true)
    end
    
    self.refreshList = function() 
        if self.traderListPanel then self.traderListPanel:populateList() end 
        if self.traderListPanel then 
            local p = getSpecificPlayer(0)
            self.traderListPanel.lastDiscoveredCount = DynamicTrading.Manager.GetDiscoveredCount(p)
        end
    end
    
    self:relayout()
end

function DT_RadioWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()
end

-- [UPDATED] Dynamic Layout Engine
function DT_RadioWindow:relayout()
    local th = self:titleBarHeight()
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- 1. Signal Panel Height Logic
    -- We want the radio image to scale with width, so we make height proportional to width.
    -- Target: ~35% of width, clamped between 140px and 250px.
    local signalH = math.floor(w * 0.35)
    if signalH < 140 then signalH = 140 end
    if signalH > 250 then signalH = 250 end
    
    -- Ensure Signal Panel doesn't eat the whole window if user resizes height very small
    if signalH > (h * 0.4) then signalH = math.floor(h * 0.4) end

    -- 2. Calculate remaining space
    local availableH = h - th - signalH
    if availableH < 50 then availableH = 50 end 
    
    -- 3. Split remaining space (45% Trader List / 55% Logs)
    local listH = math.floor(availableH * 0.45)
    local logH = availableH - listH 
    
    -- Apply Signal Panel
    if self.signalPanel then
        self.signalPanel:setWidth(w)
        self.signalPanel:setHeight(signalH)
        if self.signalPanel.onResize then self.signalPanel:onResize() end
    end
    
    -- Apply Trader List Panel
    if self.traderListPanel then
        self.traderListPanel:setY(th + signalH)
        self.traderListPanel:setWidth(w)
        self.traderListPanel:setHeight(listH)
        if self.traderListPanel.onResize then self.traderListPanel:onResize() end
    end
    
    -- Apply Log Panel
    if self.logPanel then
        self.logPanel:setY(th + signalH + listH)
        self.logPanel:setWidth(w)
        self.logPanel:setHeight(logH)
        if self.logPanel.onResize then self.logPanel:onResize() end
    end
    
    if self.resizeWidget then self.resizeWidget:bringToTop() end
end

function DT_RadioWindow:render()
    ISCollapsableWindow.render(self)
    if not self:CheckConnectionValidity() then
        self:close()
        if DT_TradingWindow and DT_TradingWindow.instance then DT_TradingWindow.instance:close() end
        return
    end
end

function DT_RadioWindow:CheckConnectionValidity()
    local player = getSpecificPlayer(0)
    if not player or not self.radioObj then return false end

    return DynamicTrading.Utils.IsInteractionValid(self.radioObj, player, nil)
end

function DT_RadioWindow:close()
    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("RadioWindow", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end
    self:setVisible(false)
    self:removeFromUIManager()
    DT_RadioWindow.instance = nil
end

function DT_RadioWindow:updateButtonState()
    if self.signalPanel then
        self.signalPanel:updateButtonState()
    end
end

function DT_RadioWindow.ToggleWindow(radioObj, isHam)
    if DT_RadioWindow.instance then
        DT_RadioWindow.instance:close()
        return
    end

    -- Dynamic Sizing
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(550, math.floor(screenW * 0.35))
    local height = math.min(900, math.floor(screenH * 0.75))
    width = math.max(380, width)
    height = math.max(600, height)
    
    local x = 200
    local y = 100

    -- Attempt to load persisted state
    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("RadioWindow")
        if state then
            x = state.x
            y = state.y
            width = state.w
            height = state.h
            
            -- Basic bounds check to prevent lost windows
            if x < 0 then x = 0 end
            if y < 0 then y = 0 end
            if x > screenW - 50 then x = screenW - width end
            if y > screenH - 50 then y = screenH - height end
        end
    end
    
    local ui = DT_RadioWindow:new(x, y, width, height)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    
    if ui.traderListPanel then ui.traderListPanel:populateList() end
    if ui.logPanel then ui.logPanel:populateLogs() end
    
    local p = getSpecificPlayer(0)
    if ui.traderListPanel then
         ui.traderListPanel.lastDiscoveredCount = DynamicTrading.Manager.GetDiscoveredCount(p)
    end
    
    DT_RadioWindow.instance = ui
end
