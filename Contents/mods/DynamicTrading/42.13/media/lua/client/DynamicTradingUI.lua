require "ISUI/ISCollapsableWindow"

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Market Prices")
    self:setResizable(false)
end

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- Listbox setup
    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 25
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    -- Register Custom Draw
    self.listbox.doDrawItem = self.drawListItem
    
    self:addChild(self.listbox)
    self:populateList()
end

-- =================================================
-- CUSTOM DRAW FUNCTION
-- =================================================
function DynamicTradingUI:drawListItem(y, item, alt)
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.3, 0.3, 0.05)
    end
    
    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local r, g, b = 1, 1, 1 
    if item.customColor then
        r = item.customColor.r
        g = item.customColor.g
        b = item.customColor.b
    end

    self:drawText(item.text, 15, y + (item.height - self.fontHgt) / 2, r, g, b, 0.9, self.font)
    return y + item.height
end

function DynamicTradingUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Shared.GetData()
    local config = DynamicTrading.Config
    local gt = GameTime:getInstance()

    -- ==========================================================
    -- 1. CALCULATE DATE & RESTOCK TIME
    -- ==========================================================
    local interval = 1
    if SandboxVars.DynamicTrading then
        interval = SandboxVars.DynamicTrading.RestockInterval or 1
    end
    
    local currentDay = math.floor(gt:getDaysSurvived())
    local lastReset = data.lastResetDay or 0
    local nextRestockDayIndex = math.floor(lastReset) + interval
    local daysRemaining = nextRestockDayIndex - currentDay
    
    if daysRemaining < 1 then daysRemaining = 1 end

    local function getFutureDateString(daysToAdd)
        local d = gt:getDay()   -- Internal 0-29
        local m = gt:getMonth() -- Internal 0-11
        local y = gt:getYear()
        
        d = d + daysToAdd
        
        while true do
            local daysInMonth = gt:daysInMonth(y, m) 
            if d < daysInMonth then
                break 
            else
                d = d - daysInMonth
                m = m + 1
                if m > 11 then
                    m = 0
                    y = y + 1
                end
            end
        end
        return string.format("%02d/%02d/%d", m + 1, d + 1, y)
    end

    local dateString = getFutureDateString(daysRemaining)
    local restockMsg = ""
    
    if daysRemaining == 1 then
        restockMsg = "Restock is Tomorrow! (" .. dateString .. ")"
    else
        restockMsg = "Next Restock: " .. dateString .. " (" .. daysRemaining .. " days)"
    end

    -- ==========================================================
    -- 2. RENDER ITEMS
    -- ==========================================================
    local hasAnyStock = false
    
    -- Helper
    local function getItemName(fullType)
        local item = ScriptManager.instance:getItem(fullType)
        if item then return item:getDisplayName() end
        return fullType
    end

    -- Loop through config to find stocks
    for key, cfg in pairs(config) do
        local stock = data.stocks[key] or 0
        local price = data.prices[key] or cfg.basePrice
        local name = getItemName(cfg.item)
        
        if stock > 0 then
            hasAnyStock = true
            local text = string.format("%s   |   Qty: %d   |   $%d", name, stock, price)
            local entry = self.listbox:addItem(text, nil)
            entry.customColor = {r=1, g=1, b=1, a=1} 
        end
    end

    -- ==========================================================
    -- 3. RENDER FOOTER (Empty Message or Restock Info)
    -- ==========================================================
    
    -- Spacer Line
    self.listbox:addItem(" ", nil)

    if not hasAnyStock then
        local msg1 = self.listbox:addItem("There is nothing left to sell.", nil)
        msg1.customColor = {r=0.9, g=0.3, b=0.3, a=1} -- Red
    end

    -- Always show the restock time at the bottom
    local msgFooter = self.listbox:addItem(restockMsg, nil)
    msgFooter.customColor = {r=0.7, g=0.7, b=0.7, a=1} -- Grey
end

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end

function DynamicTradingUI.ToggleWindow()
    if DynamicTradingUI.instance then
        if DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:close()
        else
            DynamicTradingUI.instance:setVisible(true)
            DynamicTradingUI.instance:addToUIManager()
            DynamicTradingUI.instance:populateList()
        end
        return
    end

    local ui = DynamicTradingUI:new(100, 100, 320, 300)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingUI.instance = ui
end

local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    context:addOption("Check Market Prices", nil, DynamicTradingUI.ToggleWindow)
    if isDebugEnabled() then
        context:addOption("[DEBUG] Market Sales History", nil, DynamicTradingDebugUI.ToggleWindow)
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)