require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTrading_PortraitConfig"
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
    
    -- [NEW] Signal Animation State
    self.signalState = "search"  -- "search", "found", "none"
    self.signalFrame = 1
    self.signalAnimTimer = 0
    self.signalFrameDuration = 200  -- milliseconds per frame
    self.signalFoundPersist = false -- True when user just found a trader this session
    
    -- [NEW] Frame counts per signal type
    self.signalFrameCounts = {
        search = 5,
        found = 3,
        none = 3
    }
    
    -- [NEW] Preload signal textures
    self.signalTextures = {
        search = {},
        found = {},
        none = {}
    }
    for i = 1, 5 do
        self.signalTextures.search[i] = getTexture("media/ui/Radio/Signal_search/" .. i .. ".png")
    end
    for i = 1, 3 do
        self.signalTextures.found[i] = getTexture("media/ui/Radio/Signal_found/" .. i .. ".png")
        self.signalTextures.none[i] = getTexture("media/ui/Radio/Signal_none/" .. i .. ".png")
    end
end

function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local width = self.width
    
    -- [CHANGED] Layout constants for signal sprite area - Resized to 140px for high visibility
    local spriteSize = 140
    local spritePadding = 10
    local topRowHeight = spriteSize
    
    -- 1. SCAN BUTTON (Top Left Stack)
    local btnWidth = width - spriteSize - (spritePadding * 3)
    local btnX = 10
    local btnY = th + 25
    
    self.btnScan = ISButton:new(btnX, btnY, btnWidth, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)
    
    -- 2. MARKET INFO BUTTON (Immediately below Scan button)
    self.btnInfo = ISButton:new(btnX, btnY + 35, btnWidth, 25, "VIEW MARKET INFO", self, self.onInfoClick)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = {r=1, g=1, b=1, a=0.5}
    self.btnInfo.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0} 
    self:addChild(self.btnInfo)
    
    -- Store sprite position for render
    self.signalSpriteSize = spriteSize
    self.signalSpriteX = width - spriteSize - spritePadding
    self.signalSpriteY = th + 5

    -- 3. TRADER LIST (Below the top row)
    local list1Y = th + topRowHeight + 15
    self.lblTraders = ISLabel:new(10, list1Y, 16, "Active Signals:", 0.8, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTraders)

    local list1Height = 180
    list1Y = list1Y + 20
    
    self.listbox = ISScrollingListBox:new(10, list1Y, width - 20, list1Height)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 38 -- [CHANGED] Slightly increased to fit larger portrait icons
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9}
    self.listbox.doDrawItem = self.drawItem 
    self.listbox.onMouseDown = self.onListMouseDown
    self:addChild(self.listbox)

    -- 4. LOG LIST (Bottom Section - Static/Non-Scrollable history)
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
        -- [NEW] Detect if a new trader was found during this session
        if currentTraderCount > self.lastTraderCount and self.lastTraderCount >= 0 then
            self.signalFoundPersist = true
        end
        self:populateList()
        self.lastTraderCount = currentTraderCount
    end
    
    -- ==========================================================
    -- 5. SIGNAL ANIMATION LOGIC
    -- ==========================================================
    local currentFound, dailyLimit = DynamicTrading.Manager.GetDailyStatus()
    
    -- Determine signal state
    if self.signalFoundPersist then
        -- Player just found a signal, persist this state until scan or close
        self.signalState = "found"
    elseif currentFound >= dailyLimit then
        -- Daily limit reached, no more signals available
        self.signalState = "none"
    else
        -- Still searching for signals
        self.signalState = "search"
    end
    
    -- Update animation timer
    local deltaTime = UIManager.getMillisSinceLastRender()
    self.signalAnimTimer = self.signalAnimTimer + deltaTime
    
    -- Advance frame when timer exceeds duration
    local frameCount = self.signalFrameCounts[self.signalState] or 3
    if self.signalAnimTimer >= self.signalFrameDuration then
        self.signalAnimTimer = self.signalAnimTimer - self.signalFrameDuration
        self.signalFrame = self.signalFrame + 1
        if self.signalFrame > frameCount then
            self.signalFrame = 1
        end
    end
    
    -- Clamp frame to valid range
    if self.signalFrame > frameCount then self.signalFrame = 1 end
    
    -- Draw animated signal sprite (using stored position from createChildren)
    local tex = self.signalTextures[self.signalState] and self.signalTextures[self.signalState][self.signalFrame]
    if tex then
        local size = self.signalSpriteSize or 80
        local sx = self.signalSpriteX or (self.width - size - 10)
        local sy = self.signalSpriteY or (self:titleBarHeight() + 10)
        
        self:drawTextureScaled(tex, sx, sy, size, size, 1, 1, 1, 1)
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
    local player = getSpecificPlayer(0)
    
    if not data.Traders then 
        self.listbox:addItem("No signals. Try scanning.", {})
        return 
    end

    local sortedList = {}
    for id, trader in pairs(data.Traders) do
        -- [PUBLIC NETWORK] Only show traders this player has discovered
        if DynamicTrading.Manager.HasDiscovered(id, player) then
            table.insert(sortedList, { id = id, data = trader })
        end
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
    
    -- [NEW] Reset signal found state when clicking scan
    self.signalFoundPersist = false
    
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
        this:drawText(item.text, 10, y + 12, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    -- [NEW] Load and display portrait icon
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders and data.Traders[item.item.traderID]
    local tex = nil
    
    if trader and DynamicTrading.Portraits then
        local archetype = trader.archetype or "General"
        local gender = trader.gender or "Male"
        local portraitID = trader.portraitID or 1
        
        local pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
        local fullPath = pathFolder .. tostring(portraitID) .. ".png"
        tex = getTexture(fullPath)
    end
    
    -- Fallback to walkie-talkie icon if portrait not found
    if not tex then
        tex = getTexture("Item_WalkieTalkie1")
    end
    
    if tex then 
        this:drawTextureScaled(tex, 5, y + 5, 28, 28, 1, 1, 1, 1) 
    end
    
    this:drawText(item.text, 38, y + 12, 1, 1, 1, 1, this.font)
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

    local ui = DynamicTradingTraderListUI:new(200, 100, 380, 660)
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