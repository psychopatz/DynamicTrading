require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTradingUI" 

DynamicTradingTraderListUI = ISCollapsableWindow:derive("DynamicTradingTraderListUI")
DynamicTradingTraderListUI.instance = nil

function DynamicTradingTraderListUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Trader Network & Logs")
    self:setResizable(false)
    self.clearStencil = false 
    self.radioObj = nil
    self.isHam = false
    
    -- State Trackers for Auto-Refresh
    self.lastLogCount = -1
    self.lastTraderCount = -1 
end

function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local width = self.width
    local height = self.height

    -- ============================
    -- 1. TOP SECTION: CONTROLS
    -- ============================
    self.btnScan = ISButton:new(10, th + 10, width - 20, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)

    -- ============================
    -- 2. MIDDLE SECTION: TRADERS
    -- ============================
    self.lblTraders = ISLabel:new(10, th + 45, 16, "Active Signals:", 0.8, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTraders)

    local list1Height = 180
    
    self.listbox = ISScrollingListBox:new(10, th + 65, width - 20, list1Height)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(false)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 30
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingTraderListUI.drawItem 
    self.listbox.onMouseDown = DynamicTradingTraderListUI.onListMouseDown
    self:addChild(self.listbox)

    -- ============================
    -- 3. BOTTOM SECTION: LOGS
    -- ============================
    local logY = th + 65 + list1Height + 15
    
    self.lblLogs = ISLabel:new(10, logY, 16, "System Logs:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblLogs)
    
    local list2Height = height - logY - 25
    
    self.logList = ISScrollingListBox:new(10, logY + 20, width - 20, list2Height)
    self.logList:initialise()
    self.logList:setAnchorRight(true)
    self.logList:setAnchorBottom(true)
    self.logList.font = UIFont.NewSmall
    self.logList.itemheight = 20
    self.logList.drawBorder = true
    self.logList.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.logList.doDrawItem = DynamicTradingTraderListUI.drawLogItem
    self:addChild(self.logList)
end

-- ==========================================================
-- VALIDATION LOOP
-- ==========================================================
function DynamicTradingTraderListUI:CheckConnectionValidity()
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
        elseif sq:haveElectricity() then hasPower = true end
        if not hasPower then return false end
    else
        if self.radioObj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
end

function DynamicTradingTraderListUI:render()
    ISCollapsableWindow.render(self)
    
    -- 1. Check Connection
    if not self:CheckConnectionValidity() then
        self:close()
        if DynamicTradingUI and DynamicTradingUI.instance then DynamicTradingUI.instance:close() end
        return
    end

    -- 2. Update Button Cooldown
    local player = getSpecificPlayer(0)
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if canScan then
        self.btnScan:setEnable(true)
        self.btnScan:setTitle("SCAN FREQUENCIES")
        self.btnScan.textColor = {r=1, g=1, b=1, a=1}
    else
        self.btnScan:setEnable(false)
        self.btnScan:setTitle("COOLDOWN (" .. math.ceil(timeRem) .. "m)")
        self.btnScan.textColor = {r=1, g=0.5, b=0.5, a=1}
    end
    
    local data = DynamicTrading.Manager.GetData()

    -- 3. Auto-Refresh LOGS
    if data.NetworkLogs and #data.NetworkLogs ~= self.lastLogCount then
        self:populateLogs()
        self.lastLogCount = #data.NetworkLogs
    end

    -- 4. Auto-Refresh TRADERS (New Feature)
    local currentTraderCount = 0
    if data.Traders then
        for _ in pairs(data.Traders) do currentTraderCount = currentTraderCount + 1 end
    end

    if currentTraderCount ~= self.lastTraderCount then
        self:populateList()
        self.lastTraderCount = currentTraderCount
    end
end

function DynamicTradingTraderListUI:onScanClick()
    local player = getSpecificPlayer(0)
    if not self:CheckConnectionValidity() then self:close() return end
    
    -- The render loop will handle list updates, but we force log update here to be snappy
    DT_RadioInteraction.PerformScan(player, self.radioObj, self.isHam)
end

-- ==========================================================
-- LIST POPULATION
-- ==========================================================
function DynamicTradingTraderListUI:populateList()
    self.listbox:clear()
    local data = DynamicTrading.Manager.GetData()
    local count = 0
    
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            count = count + 1
            local occupation = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or trader.archetype
            local txt = (trader.name or "Unknown") .. " - " .. occupation
            self.listbox:addItem(txt, { traderID = id, archetype = trader.archetype })
        end
    end
    
    if count == 0 then
        self.listbox:addItem("No signals. Try scanning.", {})
    end
end

function DynamicTradingTraderListUI:populateLogs()
    self.logList:clear()
    local data = DynamicTrading.Manager.GetData()
    
    if data.NetworkLogs then
        for _, log in ipairs(data.NetworkLogs) do
            self.logList:addItem(log.time .. ": " .. log.text, log)
        end
    end
end

-- ==========================================================
-- DRAWING
-- ==========================================================
function DynamicTradingTraderListUI.drawItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    
    if this.selected == item.index then
        this:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        this:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    this:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    if not item.item.traderID then
        this:drawText(item.text, 10, y + 8, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    local icon = getTexture("Item_WalkieTalkie1")
    if icon then this:drawTextureScaled(icon, 6, y + 5, 20, 20, 1, 1, 1, 1) end
    this:drawText(item.text, 35, y + 8, 0.9, 0.9, 0.9, 1, this.font)
    return y + height
end

function DynamicTradingTraderListUI.drawLogItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    local log = item.item
    
    if alt then this:drawRect(0, y, width, height, 0.1, 0.1, 0.1, 0.2) end
    
    local r, g, b = 0.8, 0.8, 0.8
    if log.cat == "good" then r, g, b = 0.4, 1.0, 0.4 
    elseif log.cat == "bad" then r, g, b = 1.0, 0.4, 0.4
    elseif log.cat == "event" then r, g, b = 1.0, 1.0, 0.4 end
    
    this:drawText(log.time, 5, y + 2, 0.5, 0.5, 0.5, 1, this.font)
    local timeWid = TextManager.instance:MeasureStringX(this.font, log.time)
    this:drawText(log.text, 5 + timeWid + 8, y + 2, r, g, b, 1, this.font)
    
    return y + height
end

function DynamicTradingTraderListUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    if item.item and item.item.traderID then
        local data = item.item
        if DynamicTradingUI and DynamicTradingUI.ToggleWindow then
            DynamicTradingUI.ToggleWindow(data.traderID, data.archetype)
        end
    end
end

function DynamicTradingTraderListUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingTraderListUI.instance = nil
end

function DynamicTradingTraderListUI.ToggleWindow(radioObj, isHam)
    if DynamicTradingTraderListUI.instance then
        DynamicTradingTraderListUI.instance:close()
        return
    end

    local ui = DynamicTradingTraderListUI:new(200, 100, 380, 500)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    -- Initial population
    ui:populateList()
    ui:populateLogs()
    -- Set trackers to avoid double refresh on first frame
    local data = DynamicTrading.Manager.GetData()
    if data.NetworkLogs then ui.lastLogCount = #data.NetworkLogs end
    local count = 0
    if data.Traders then for _ in pairs(data.Traders) do count = count + 1 end end
    ui.lastTraderCount = count
    
    DynamicTradingTraderListUI.instance = ui
end