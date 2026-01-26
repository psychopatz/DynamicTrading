require "ISUI/ISCollapsableWindow"
require "client/Radio/DT_SignalPanel"
require "client/Radio/DT_TraderListPanel"
require "client/Radio/DT_LogPanel"

DT_RadioWindow = ISCollapsableWindow:derive("DT_RadioWindow")
DT_RadioWindow.instance = nil

function DT_RadioWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Trader Network & Logs")
    self:setResizable(false)
    self.clearStencil = false 
    self.radioObj = nil
    self.isHam = false
end

function DT_RadioWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local th = self:titleBarHeight()
    local w = self.width
    
    -- 1. Signal & Control Panel (Top)
    -- Height ~170 (accommodate bigger anim)
    self.signalPanel = DT_SignalPanel:new(0, th, w, 170)
    self.signalPanel:initialise()
    self:addChild(self.signalPanel)
    
    -- 2. Trader List Panel (Middle)
    -- Height ~220
    self.traderListPanel = DT_TraderListPanel:new(0, th + 170, w, 220)
    self.traderListPanel:initialise()
    self:addChild(self.traderListPanel)
    
    -- 3. Logs Panel (Bottom)
    -- Remaining Height
    local startY = th + 170 + 220
    local remInh = self.height - startY
    self.logPanel = DT_LogPanel:new(0, startY, w, remInh)
    self.logPanel:initialise()
    self:addChild(self.logPanel)
    
    -- Expose helper for refresh logic (referenced by other scripts)
    self.refreshList = function() 
        if self.traderListPanel then self.traderListPanel:populateList() end 
        -- Also update internal state to prevent double refresh
        if self.traderListPanel then 
            local p = getSpecificPlayer(0)
            self.traderListPanel.lastDiscoveredCount = DynamicTrading.Manager.GetDiscoveredCount(p)
        end
    end
end

function DT_RadioWindow:render()
    ISCollapsableWindow.render(self)
    
    -- Auto-Close Validation
    if not self:CheckConnectionValidity() then
        self:close()
        if DynamicTradingUI and DynamicTradingUI.instance then 
            DynamicTradingUI.instance:close() 
        end
        return
    end
end

function DT_RadioWindow:CheckConnectionValidity()
    local player = getSpecificPlayer(0)
    if not player or not self.radioObj then return false end
    
    local data = self.radioObj:getDeviceData()
    if not data then return false end

    if not data:getIsTurnedOn() then return false end

    if self.isHam then
        local sq = self.radioObj:getSquare()
        if not sq then return false end 
        if IsoUtils.DistanceTo(player:getX(), player:getY(), self.radioObj:getX(), self.radioObj:getY()) > 2.5 then return false end 
        
        local hasPower = false
        if data:getIsBatteryPowered() then
            if data:getPower() > 0 then hasPower = true end
        elseif sq:haveElectricity() then 
            hasPower = true 
        end
        if not hasPower then return false end
    else
        if self.radioObj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end

    return true
end

function DT_RadioWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_RadioWindow.instance = nil
end

function DT_RadioWindow.ToggleWindow(radioObj, isHam)
    if DT_RadioWindow.instance then
        DT_RadioWindow.instance:close()
        return
    end

    local ui = DT_RadioWindow:new(200, 100, 380, 660)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    
    -- Initial Data Load
    if ui.traderListPanel then ui.traderListPanel:populateList() end
    if ui.logPanel then ui.logPanel:populateLogs() end
    
    -- Initial State Sync
    local data = DynamicTrading.Manager.GetData()
    local player = getSpecificPlayer(0)
    
    if ui.traderListPanel then
         ui.traderListPanel.lastDiscoveredCount = DynamicTrading.Manager.GetDiscoveredCount(player)
    end
    
    if data.NetworkLogs and ui.logPanel then 
        ui.logPanel.lastLogCount = #data.NetworkLogs 
        if data.NetworkLogs[1] then
            ui.logPanel.lastTopLogID = data.NetworkLogs[1].time .. data.NetworkLogs[1].text
        end
    end
    
    DT_RadioWindow.instance = ui
end
