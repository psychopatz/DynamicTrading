require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
-- We don't require DynamicTradingUI here to avoid circular dependency issues during load,
-- we check for it globally when needed.

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

-- ==========================================================
-- SETUP UI
-- ==========================================================
function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local width = self.width
    local height = self.height

    -- 1. SCAN BUTTON
    self.btnScan = ISButton:new(10, th + 10, width - 20, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)

    -- 2. TRADER LIST
    self.lblTraders = ISLabel:new(10, th + 45, 16, "Active Signals:", 0.8, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTraders)

    local list1Height = 180
    local list1Y = th + 65
    
    self.listbox = ISScrollingListBox:new(10, list1Y, width - 20, list1Height)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(false)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 30
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9} -- Opaque Background
    self.listbox.doDrawItem = self.drawItem 
    self.listbox.onMouseDown = self.onListMouseDown
    
    self:ApplyClipping(self.listbox) -- Force Clipping
    self:addChild(self.listbox)

    -- 3. LOG LIST
    local logLabelY = list1Y + list1Height + 15
    local logListY = logLabelY + 20
    local list2Height = height - logListY - 15
    
    self.lblLogs = ISLabel:new(10, logLabelY, 16, "System Logs (Last 12):", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblLogs)
    
    self.logList = ISScrollingListBox:new(10, logListY, width - 20, list2Height)
    self.logList:initialise()
    self.logList:setAnchorRight(true)
    self.logList:setAnchorBottom(true)
    self.logList.font = UIFont.NewSmall
    self.logList.itemheight = 20
    self.logList.drawBorder = true
    self.logList.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.logList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9} -- Opaque Background
    self.logList.doDrawItem = self.drawLogItem
    
    self:ApplyClipping(self.logList) -- Force Clipping
    self:addChild(self.logList)
end

-- Helper: Forces text to cut off at the edge of the listbox
function DynamicTradingTraderListUI:ApplyClipping(uiElement)
    if not uiElement then return end
    
    uiElement.prerender = function(self)
        self:setStencilRect(0, 0, self.width, self.height)
        ISScrollingListBox.prerender(self)
    end
    
    uiElement.render = function(self)
        ISScrollingListBox.render(self)
        self:clearStencilRect()
    end
end

-- ==========================================================
-- LOGIC & VALIDATION
-- ==========================================================
function DynamicTradingTraderListUI:CheckConnectionValidity()
    local player = getSpecificPlayer(0)
    if not player or not self.radioObj then return false end
    
    local data = self.radioObj:getDeviceData()
    if not data then return false end

    -- 1. Must be Turned ON
    if not data:getIsTurnedOn() then return false end

    -- 2. Device Specific Checks
    if self.isHam then
        local sq = self.radioObj:getSquare()
        if not sq then return false end 
        -- Distance check (2.5 tiles)
        if IsoUtils.DistanceTo(player:getX(), player:getY(), self.radioObj:getX(), self.radioObj:getY()) > 2.5 then return false end 
        
        -- Power Check (Battery OR Grid)
        local hasPower = false
        if data:getIsBatteryPowered() then
            if data:getPower() > 0 then hasPower = true end
        elseif sq:haveElectricity() then 
            hasPower = true 
        end
        if not hasPower then return false end
    else
        -- Walkie Check
        if self.radioObj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end

    return true
end

function DynamicTradingTraderListUI:render()
    ISCollapsableWindow.render(self)
    
    -- 1. Auto-Close if signal lost
    if not self:CheckConnectionValidity() then
        self:close()
        -- Close child window too
        if DynamicTradingUI and DynamicTradingUI.instance then 
            DynamicTradingUI.instance:close() 
        end
        return
    end

    -- 2. Button Cooldown State
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
    
    -- 3. Auto-Refresh Lists
    local data = DynamicTrading.Manager.GetData()

    -- Check Logs
    local currentLogCount = data.NetworkLogs and #data.NetworkLogs or 0
    if currentLogCount ~= self.lastLogCount then
        self:populateLogs()
        self.lastLogCount = currentLogCount
    end

    -- Check Traders
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
    
    -- Trigger Scan
    if DT_RadioInteraction and DT_RadioInteraction.PerformScan then
        DT_RadioInteraction.PerformScan(player, self.radioObj, self.isHam)
    end
end

-- ==========================================================
-- POPULATE LISTS
-- ==========================================================
function DynamicTradingTraderListUI:populateList()
    self.listbox:clear()
    local data = DynamicTrading.Manager.GetData()
    
    if not data.Traders then 
        self.listbox:addItem("No signals. Try scanning.", {})
        return 
    end

    -- Sort: Newest First (Using ID which contains timestamp)
    local sortedList = {}
    for id, trader in pairs(data.Traders) do
        table.insert(sortedList, { id = id, data = trader })
    end
    table.sort(sortedList, function(a, b) return a.id > b.id end)

    for _, entry in ipairs(sortedList) do
        local trader = entry.data
        local occupation = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or trader.archetype
        local txt = (trader.name or "Unknown") .. " - " .. occupation
        
        self.listbox:addItem(txt, { traderID = entry.id, archetype = trader.archetype })
    end
    
    if #sortedList == 0 then
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
    
    -- Selection Highlight
    if this.selected == item.index then
        this:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) 
    end
    this:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- Empty message check
    if not item.item.traderID then
        this:drawText(item.text, 10, y + 8, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    -- Icon
    local icon = getTexture("Item_WalkieTalkie1")
    if icon then this:drawTextureScaled(icon, 6, y + 5, 20, 20, 1, 1, 1, 1) end
    
    -- Text
    this:drawText(item.text, 35, y + 8, 0.9, 0.9, 0.9, 1, this.font)
    
    return y + height
end

function DynamicTradingTraderListUI.drawLogItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    local log = item.item
    
    if alt then 
        this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) 
    end
    
    -- Color Coding
    local r, g, b = 0.8, 0.8, 0.8
    if log.cat == "good" then r, g, b = 0.4, 1.0, 0.4 
    elseif log.cat == "bad" then r, g, b = 1.0, 0.4, 0.4
    elseif log.cat == "event" then r, g, b = 1.0, 1.0, 0.4 end
    
    -- Time
    this:drawText(log.time, 5, y + 2, 0.5, 0.5, 0.5, 1, this.font)
    
    -- Message
    local timeWid = TextManager.instance:MeasureStringX(this.font, log.time)
    this:drawText(log.text, 5 + timeWid + 8, y + 2, r, g, b, 1, this.font)
    
    return y + height
end

-- ==========================================================
-- INTERACTION
-- ==========================================================
function DynamicTradingTraderListUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    -- Open Trade Window on click
    if item.item and item.item.traderID and DynamicTradingUI then
        -- [CRITICAL] We must pass the radioObj from this window (parent) to the child
        local parentWin = target.parent
        if parentWin and parentWin.radioObj then
             DynamicTradingUI.ToggleWindow(item.item.traderID, item.item.archetype, parentWin.radioObj)
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
        -- Close resets the UI. To reopen with new radio, simply call Toggle again if desired logic requires it,
        -- but typically toggling off means close.
        return
    end

    local ui = DynamicTradingTraderListUI:new(200, 100, 380, 500)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    
    -- Initial Population
    ui:populateList()
    ui:populateLogs()
    
    -- Sync Trackers
    local data = DynamicTrading.Manager.GetData()
    if data.NetworkLogs then ui.lastLogCount = #data.NetworkLogs end
    local count = 0
    if data.Traders then for _ in pairs(data.Traders) do count = count + 1 end end
    ui.lastTraderCount = count
    
    DynamicTradingTraderListUI.instance = ui
end