require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTradingInfoUI" 
require "Utils/DT_StringUtils" -- [NEW] Utils for text wrapping

DynamicTradingTraderListUI = ISCollapsableWindow:derive("DynamicTradingTraderListUI")
DynamicTradingTraderListUI.instance = nil

function DynamicTradingTraderListUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Trader Network & Logs")
    self:setResizable(false)
    self.clearStencil = false 
    self.radioObj = nil
    self.isHam = false
    
    -- State Trackers (for auto-refresh optimization)
    self.lastLogCount = -1
    self.lastTopLogID = "" 
    self.lastTraderCount = -1 
end

function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local width = self.width
    
    -- 1. SCAN BUTTON
    self.btnScan = ISButton:new(10, th + 10, width - 20, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)

    -- 2. TRADER LIST (Top Section)
    self.lblTraders = ISLabel:new(10, th + 45, 16, "Active Signals:", 0.8, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTraders)

    local list1Height = 180
    local list1Y = th + 65
    
    self.listbox = ISScrollingListBox:new(10, list1Y, width - 20, list1Height)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 30
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9}
    self.listbox.doDrawItem = self.drawItem 
    self.listbox.onMouseDown = self.onListMouseDown
    self:addChild(self.listbox)

    -- 3. LOG LIST (Bottom Section - Static/Non-Scrollable history)
    local logLabelY = list1Y + list1Height + 15
    local logListY = logLabelY + 20
    local list2Height = (12 * 20) + 2 -- Exact height for 12 lines
    
    self.lblLogs = ISLabel:new(10, logLabelY, 16, "System Logs (Last 12):", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblLogs)
    
    self.logList = ISScrollingListBox:new(10, logListY, width - 20, list2Height)
    self.logList:initialise()
    self.logList:setAnchorRight(true)
    self.logList.font = UIFont.NewSmall
    self.logList.itemheight = 20
    self.logList.drawBorder = true
    self.logList.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.logList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9}
    self.logList.doDrawItem = self.drawLogItem
    
    -- Disable Scroll Wheel on logs (it's a fixed display)
    self.logList.onMouseWheel = function(self, del) return true end
    
    self:addChild(self.logList)

    -- 4. MARKET INFO BUTTON
    local btnInfoY = logListY + list2Height + 10
    self.btnInfo = ISButton:new(10, btnInfoY, width - 20, 25, "VIEW MARKET INFO", self, self.onInfoClick)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = {r=1, g=1, b=1, a=0.5}
    self.btnInfo.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0} -- Slight Blue tint
    self:addChild(self.btnInfo)
end

-- ==========================================================
-- UPDATE LOGIC
-- ==========================================================
function DynamicTradingTraderListUI:render()
    ISCollapsableWindow.render(self)
    
    -- 1. Auto-Close check (Distance/Power)
    if not self:CheckConnectionValidity() then
        self:close()
        if DynamicTradingUI and DynamicTradingUI.instance then 
            DynamicTradingUI.instance:close() 
        end
        return
    end

    -- 2. Cooldown Button State
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

    -- 3. LOG AUTO-REFRESH
    local currentLogCount = data.NetworkLogs and #data.NetworkLogs or 0
    local currentTopLog = ""
    
    if data.NetworkLogs and data.NetworkLogs[1] then
        currentTopLog = data.NetworkLogs[1].time .. data.NetworkLogs[1].text
    end
    
    if currentLogCount ~= self.lastLogCount or currentTopLog ~= self.lastTopLogID then
        self:populateLogs()
        self.lastLogCount = currentLogCount
        self.lastTopLogID = currentTopLog
    end

    -- 4. TRADER AUTO-REFRESH
    local currentTraderCount = 0
    if data.Traders then
        for _ in pairs(data.Traders) do currentTraderCount = currentTraderCount + 1 end
    end

    if currentTraderCount ~= self.lastTraderCount then
        self:populateList()
        self.lastTraderCount = currentTraderCount
    end
end

-- ==========================================================
-- POPULATION & DRAWING
-- ==========================================================
function DynamicTradingTraderListUI:populateLogs()
    self.logList:clear()
    local data = DynamicTrading.Manager.GetData()
    
    -- [REFACTOR] Use Utils for Text Wrapping
    local listWidth = self.logList:getWidth() - 25 -- Scrollbar allowance
    local tm = getTextManager()
    local font = self.logList.font
    
    if data.NetworkLogs then
        local limit = math.min(#data.NetworkLogs, 12)
        for i=1, limit do
            local log = data.NetworkLogs[i]
            
            -- 1. Measure the timestamp width to indent text properly
            local timeWid = tm:MeasureStringX(font, log.time)
            
            -- 2. Calculate remaining space for the message
            local textSpace = listWidth - timeWid - 15 -- Padding
            if textSpace < 50 then textSpace = 50 end
            
            -- 3. Wrap the text
            local lines = DynamicTrading.Utils.WrapText(log.text, textSpace, font)
            
            -- 4. Calculate Height
            local lineHeight = self.logList.itemheight
            local totalHeight = #lines * lineHeight
            if totalHeight < lineHeight then totalHeight = lineHeight end
            
            -- 5. Add to List with metadata
            local addedItem = self.logList:addItem(log.time, {
                log = log,
                lines = lines,
                timeWidth = timeWid,
                height = totalHeight
            })
            addedItem.height = totalHeight
        end
    end
end

function DynamicTradingTraderListUI:populateList()
    self.listbox:clear()
    local data = DynamicTrading.Manager.GetData()
    
    if not data.Traders then 
        self.listbox:addItem("No signals. Try scanning.", {})
        return 
    end

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

-- ==========================================================
-- HELPERS & EVENTS
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

function DynamicTradingTraderListUI:onScanClick()
    local player = getSpecificPlayer(0)
    if not self:CheckConnectionValidity() then self:close() return end
    
    -- Force Sync to ensure limits are accurate
    sendClientCommand(player, "DynamicTrading", "RequestFullState", {})

    if DT_RadioInteraction and DT_RadioInteraction.PerformScan then
        DT_RadioInteraction.PerformScan(player, self.radioObj, self.isHam)
    end
end

function DynamicTradingTraderListUI:onInfoClick()
    if DynamicTradingInfoUI then
        if DynamicTradingInfoUI.instance and DynamicTradingInfoUI.instance:isVisible() then
            DynamicTradingInfoUI.instance:addToUIManager()
        else
            DynamicTradingInfoUI.ToggleWindow()
        end
    end
end

function DynamicTradingTraderListUI.drawItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    
    if this.selected == item.index then
        this:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) 
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
    local data = item.item -- Contains: { log, lines, timeWidth, height }
    local log = data.log
    local height = data.height
    local width = this:getWidth()
    local lineHeight = this.itemheight
    
    if alt then 
        this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) 
    end
    
    local r, g, b = 0.8, 0.8, 0.8
    if log.cat == "good" then r, g, b = 0.4, 1.0, 0.4 
    elseif log.cat == "bad" then r, g, b = 1.0, 0.4, 0.4
    elseif log.cat == "event" then r, g, b = 1.0, 1.0, 0.4 end
    
    -- 1. Draw Timestamp (Gray)
    this:drawText(log.time, 5, y + 2, 0.5, 0.5, 0.5, 1, this.font)
    
    -- 2. Draw Wrapped Text (Colored & Indented)
    local textX = 5 + data.timeWidth + 8 -- Start after timestamp
    local currentY = y
    
    if data.lines and #data.lines > 0 then
        for _, line in ipairs(data.lines) do
            this:drawText(line, textX, currentY + 2, r, g, b, 1, this.font)
            currentY = currentY + lineHeight
        end
    else
        -- Fallback safety
        this:drawText(log.text, textX, y + 2, r, g, b, 1, this.font)
    end
    
    return y + height
end

function DynamicTradingTraderListUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    if item.item and item.item.traderID and DynamicTradingUI then
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
        return
    end

    local ui = DynamicTradingTraderListUI:new(200, 100, 380, 600)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    
    ui:populateList()
    ui:populateLogs()
    
    -- Initialize State Logic
    local data = DynamicTrading.Manager.GetData()
    if data.NetworkLogs then 
        ui.lastLogCount = #data.NetworkLogs 
        if data.NetworkLogs[1] then
            ui.lastTopLogID = data.NetworkLogs[1].time .. data.NetworkLogs[1].text
        end
    end
    local count = 0
    if data.Traders then for _ in pairs(data.Traders) do count = count + 1 end end
    ui.lastTraderCount = count
    
    DynamicTradingTraderListUI.instance = ui
end