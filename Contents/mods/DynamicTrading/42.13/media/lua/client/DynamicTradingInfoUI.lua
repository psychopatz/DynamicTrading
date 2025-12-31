require "ISUI/ISCollapsableWindow"

-- ==========================================================
-- DYNAMIC TRADING INFO UI
-- Visualizes the Economy numbers
-- ==========================================================

DynamicTradingInfoUI = ISCollapsableWindow:derive("DynamicTradingInfoUI")
DynamicTradingInfoUI.instance = nil

function DynamicTradingInfoUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Economy UI")
    self:setResizable(true)
    self.clearStencil = false 
end

function DynamicTradingInfoUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- Create the scrolling list box
    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 20
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.listbox)
    
    self:populateList()
end

function DynamicTradingInfoUI:populateList()
    self.listbox:clear()
    
    if not DynamicTrading or not DynamicTrading.Shared then 
        self.listbox:addItem("Error: DynamicTrading ModData not loaded.", nil)
        return 
    end

    local data = DynamicTrading.Shared.GetData()
    local merchantName = data.currentMerchant or "Unknown"

    -- ==========================================================
    -- SECTION 1: ACTIVE META EVENTS
    -- ==========================================================
    local header = self.listbox:addItem("=== ACTIVE META EVENTS ===", nil)
    header.textColor = {r=1, g=1, b=0.8, a=1}
    
    local anyEvent = false
    if DynamicTrading.Events and DynamicTrading.Events.Registry then
        for id, event in pairs(DynamicTrading.Events.Registry) do
            if event.condition and event.condition() then
                anyEvent = true
                local item = self.listbox:addItem(" [!] " .. (event.name or id), nil)
                item.textColor = {r=0.2, g=1.0, b=0.2, a=1} -- Bright Green for active events
                
                if event.effects then
                    for tag, eff in pairs(event.effects) do
                        local txt = "    - " .. tag .. " :: "
                        local parts = {}
                        if eff.price then table.insert(parts, "Price x" .. eff.price) end
                        if eff.volume then table.insert(parts, "Vol x" .. eff.volume) end
                        
                        self.listbox:addItem(txt .. table.concat(parts, ", "), nil)
                    end
                end
            end
        end
    end
    
    if not anyEvent then 
        local item = self.listbox:addItem("  (No active events)", nil)
        item.textColor = {r=0.6, g=0.6, b=0.6, a=1}
    end
    
    self.listbox:addItem(" ", nil) -- Spacer

    -- ==========================================================
    -- SECTION 2: MERCHANT STATE
    -- ==========================================================
    header = self.listbox:addItem("=== MERCHANT STATE ===", nil)
    header.textColor = {r=1, g=1, b=0.8, a=1}
    
    self.listbox:addItem("  Archetype: " .. merchantName, nil)
    
    local gt = GameTime:getInstance()
    local lastDay = data.lastResetDay or 0
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    local nextReset = lastDay + interval
    local daysLeft = nextReset - math.floor(gt:getDaysSurvived())
    
    self.listbox:addItem("  Next Restock: " .. daysLeft .. " day(s)", nil)
    
    self.listbox:addItem(" ", nil) -- Spacer

    -- ==========================================================
    -- SECTION 3: CATEGORY INFLATION (Buying Heat)
    -- ==========================================================
    header = self.listbox:addItem("=== CATEGORY HEAT (Inflation) ===", nil)
    header.textColor = {r=1, g=1, b=0.8, a=1}
    
    local anyHeat = false
    if data.categoryHeat then
        for cat, val in pairs(data.categoryHeat) do
            if val > 0.01 then
                anyHeat = true
                local percent = math.floor(val * 100)
                local text = string.format("  %s: +%d%% Price", cat, percent)
                local item = self.listbox:addItem(text, nil)
                item.textColor = {r=1, g=0.6, b=0.6, a=1} -- Reddish
            end
        end
    end
    if not anyHeat then
        self.listbox:addItem("  (Market Stable)", nil)
    end
    
    self.listbox:addItem(" ", nil) -- Spacer

    -- ==========================================================
    -- SECTION 4: PLAYER SELLING HISTORY (Quotas)
    -- ==========================================================
    header = self.listbox:addItem("=== YOUR SALES TODAY (Quotas) ===", nil)
    header.textColor = {r=1, g=1, b=0.8, a=1}

    local anySales = false
    if data.buyHistory then
        for key, soldAmount in pairs(data.buyHistory) do
            anySales = true
            local limit = 0
            
            -- We need to calculate limit dynamically to show it here
            if DynamicTrading.Economy and DynamicTrading.Economy.GetDemandLimit then
                limit = DynamicTrading.Economy.GetDemandLimit(key, merchantName)
            end
            
            local itemName = key
            local config = DynamicTrading.Config.MasterList[key]
            if config then
                 -- Try to get simple name
                 itemName = config.item:match(".*%.(.*)") or config.item
            end

            local txt = string.format("  %s: %d / %d", itemName, soldAmount, limit)
            local item = self.listbox:addItem(txt, nil)
            
            if soldAmount >= limit then
                item.textColor = {r=1, g=0.3, b=0.3, a=1} -- Red: Limit Reached (Junk Price)
                item.text = item.text .. " (OVERSTOCK)"
            else
                item.textColor = {r=0.6, g=1, b=0.6, a=1} -- Green: Demand Remaining
            end
        end
    end
    
    if not anySales then
        self.listbox:addItem("  (You haven't sold anything yet)", nil)
    end
end

function DynamicTradingInfoUI:onResize()
    ISCollapsableWindow.onResize(self)
    self.listbox:setWidth(self.width - 20)
    self.listbox:setHeight(self.height - 40)
end

function DynamicTradingInfoUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingInfoUI.instance = nil
end

function DynamicTradingInfoUI.ToggleWindow()
    if DynamicTradingInfoUI.instance then
        if DynamicTradingInfoUI.instance:isVisible() then
            DynamicTradingInfoUI.instance:close()
        else
            DynamicTradingInfoUI.instance:setVisible(true)
            DynamicTradingInfoUI.instance:addToUIManager()
            DynamicTradingInfoUI.instance:populateList()
        end
        return
    end

    -- Default Position and Size
    local ui = DynamicTradingInfoUI:new(100, 100, 350, 500)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingInfoUI.instance = ui
end