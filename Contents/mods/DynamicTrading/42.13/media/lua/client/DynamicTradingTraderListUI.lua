require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTradingUI" 

DynamicTradingTraderListUI = ISCollapsableWindow:derive("DynamicTradingTraderListUI")
DynamicTradingTraderListUI.instance = nil

function DynamicTradingTraderListUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Trader Network")
    self:setResizable(false)
    self.clearStencil = false 
    self.radioObj = nil
    self.isHam = false
end

function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. SCAN BUTTON
    self.btnScan = ISButton:new(10, 25, self.width - 20, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)

    -- 2. LISTBOX
    self.listbox = ISScrollingListBox:new(10, 60, self.width - 20, self.height - 70)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 30
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingTraderListUI.drawItem 
    self.listbox.onMouseDown = DynamicTradingTraderListUI.onListMouseDown
    self:addChild(self.listbox)
end

-- ==========================================================
-- VALIDATION LOOP (Auto-Close Logic)
-- ==========================================================
function DynamicTradingTraderListUI:CheckConnectionValidity()
    local player = getSpecificPlayer(0)
    if not player or not self.radioObj then return false end
    
    local data = self.radioObj:getDeviceData()
    if not data then return false end

    -- 1. CHECK IF TURNED ON
    if not data:getIsTurnedOn() then return false end

    -- 2. CHECK SPECIFIC TYPE LOGIC
    if self.isHam then
        -- A. Object Existence
        local sq = self.radioObj:getSquare()
        if not sq then return false end -- Object destroyed or removed
        
        -- B. Distance (Must be close to base station)
        -- Using getX() check to avoid complex math if not needed
        local dist = IsoUtils.DistanceTo(player:getX(), player:getY(), self.radioObj:getX(), self.radioObj:getY())
        if dist > 2.5 then return false end -- Close if moved away ~2-3 tiles
        
        -- C. Power
        local hasPower = false
        if data:getIsBatteryPowered() then
            if data:getPower() > 0 then hasPower = true end
        elseif sq:haveElectricity() then
            hasPower = true
        end
        if not hasPower then return false end

    else
        -- Walkie Talkie Logic
        
        -- A. Inventory Check (Must be in main inventory or equipped)
        if self.radioObj:getContainer() ~= player:getInventory() then return false end
        
        -- B. Power
        if data:getPower() <= 0.001 then return false end
    end

    return true
end

function DynamicTradingTraderListUI:render()
    ISCollapsableWindow.render(self)
    
    -- 1. Auto-Close if connection lost
    if not self:CheckConnectionValidity() then
        self:close()
        -- Close the trading window too if it's open
        if DynamicTradingUI and DynamicTradingUI.instance then
             DynamicTradingUI.instance:close()
        end
        return
    end

    -- 2. Update Button State (Cooldown)
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
end

function DynamicTradingTraderListUI:onScanClick()
    local player = getSpecificPlayer(0)
    
    -- Verify Radio again just in case
    if not self:CheckConnectionValidity() then
        self:close()
        player:Say("Signal lost!")
        return
    end
    
    -- Perform Scan
    local found = DT_RadioInteraction.PerformScan(player, self.radioObj, self.isHam)
    
    if found then
        self:populateList()
    end
end

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

function DynamicTradingTraderListUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    if item.item.traderID then
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
        -- If user clicked the SAME radio to toggle it off, we stop here.
        -- But if they clicked a DIFFERENT radio, ideally we would reopen, 
        -- but simpler behavior is just close first.
        return
    end

    local ui = DynamicTradingTraderListUI:new(200, 200, 350, 450)
    ui:initialise()
    ui.radioObj = radioObj
    ui.isHam = isHam
    ui:addToUIManager()
    ui:populateList()
    DynamicTradingTraderListUI.instance = ui
end