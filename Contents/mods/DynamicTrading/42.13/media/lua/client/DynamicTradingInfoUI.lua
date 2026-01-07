require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTrading_Events"

DynamicTradingInfoUI = ISCollapsableWindow:derive("DynamicTradingInfoUI")
DynamicTradingInfoUI.instance = nil

function DynamicTradingInfoUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Global Economy Stats")
    self:setResizable(true)
    self.clearStencil = false 
    self.refreshTimer = 0 -- Timer for auto-update
end

function DynamicTradingInfoUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 22
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    -- Use default drawing
    self:addChild(self.listbox)
    
    self:populateList()
end

-- ==========================================================
-- AUTO-UPDATE LOGIC
-- ==========================================================
function DynamicTradingInfoUI:update()
    ISCollapsableWindow.update(self)
    
    -- Refresh every 60 ticks (approx 1 second) to keep data live without killing performance
    self.refreshTimer = self.refreshTimer + 1
    if self.refreshTimer >= 60 then
        self:populateList()
        self.refreshTimer = 0
    end
end

-- ==========================================================
-- POPULATE LIST
-- ==========================================================
function DynamicTradingInfoUI:populateList()
    -- Remember scroll position to prevent jumping during auto-refresh
    local yScroll = self.listbox:getYScroll()
    
    self.listbox:clear()
    
    local data = DynamicTrading.Manager.GetData()
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    -- 1. MARKET PROFILE
    local header = self.listbox:addItem("=== MARKET PROFILE ===", nil)
    header.textColor = {r=1, g=0.9, b=0.5, a=1}
    
    -- DAILY NETWORK STATUS
    if data.DailyCycle then
        local found = data.DailyCycle.currentTradersFound or 0
        local limit = data.DailyCycle.dailyTraderLimit or 5
        
        -- [NEW] Adjust Limit display if modified by an event
        local eventMult = 1.0
        if DynamicTrading.Events.GetSystemModifier then
            eventMult = DynamicTrading.Events.GetSystemModifier("traderLimit")
        end
        local displayLimit = math.floor(limit * eventMult)
        if displayLimit < 1 then displayLimit = 1 end

        -- Color logic: Green = Available, Red = Full/Limit Reached
        local statusColor = {r=0.5, g=1, b=0.5, a=1}
        if found >= displayLimit then 
            statusColor = {r=1, g=0.5, b=0.5, a=1} 
        end
        
        local statItem = self.listbox:addItem(string.format("  Daily Network: %d / %d Found", found, displayLimit), nil)
        statItem.textColor = statusColor
    end

    -- Format multipliers to percentage strings
    local buyStr = string.format("%d%%", math.floor((diff.buyMult or 1.0) * 100))
    local sellStr = string.format("%d%%", math.floor((diff.sellMult or 0.5) * 100))
    local stockStr = string.format("%d%%", math.floor((diff.stockMult or 1.0) * 100))
    local rarityStr = tostring(diff.rarityBonus or 0)
    if (diff.rarityBonus or 0) > 0 then rarityStr = "+" .. rarityStr end

    self.listbox:addItem("  Buy Price: " .. buyStr, nil)
    self.listbox:addItem("  Sell Return: " .. sellStr, nil)
    self.listbox:addItem("  Stock Vol: " .. stockStr, nil)
    self.listbox:addItem("  Rarity Bonus: " .. rarityStr, nil)
    self.listbox:addItem(" ", nil)

    -- 2. ACTIVE EVENTS (STACKABLE)
    header = self.listbox:addItem("=== ACTIVE EVENTS ===", nil)
    header.textColor = {r=0.5, g=1, b=0.5, a=1}
    
    local anyEvent = false
    
    -- Iterate through the ActiveEvents list rebuilt by the Manager
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
            anyEvent = true
            
            -- Event Name & Type Coloring
            local nameColor = {r=0.2, g=1.0, b=0.2, a=1} -- Green (Default/Flash)
            local typeLabel = "[NEWS] "
            
            if event.type == "meta" then
                nameColor = {r=0.4, g=0.8, b=1.0, a=1} -- Cyan for Meta/World State
                typeLabel = "[WORLD] "
            end
            
            local item = self.listbox:addItem(" " .. typeLabel .. (event.name or "Unknown"), nil)
            item.textColor = nameColor
            
            -- Event Description
            if event.description then
                local descItem = self.listbox:addItem("     \"" .. event.description .. "\"", nil)
                descItem.textColor = {r=0.7, g=0.7, b=0.7, a=1} 
            end

            -- [A] SYSTEM MODIFIERS (Global Effects)
            if event.system then
                for sysKey, val in pairs(event.system) do
                    local txt = "      > GLOBAL: "
                    local isGood = false
                    
                    if sysKey == "traderLimit" then
                        txt = txt .. "Trader Network Cap (x" .. val .. ")"
                        if val > 1 then isGood = true end
                    elseif sysKey == "globalStock" then
                        txt = txt .. "All Stock Levels (x" .. val .. ")"
                        if val > 1 then isGood = true end
                    elseif sysKey == "scanChance" then
                        txt = txt .. "Signal Reception (x" .. val .. ")"
                        if val > 1 then isGood = true end
                    else
                        txt = txt .. sysKey .. " (x" .. val .. ")"
                        if val > 1 then isGood = true end
                    end
                    
                    local sysItem = self.listbox:addItem(txt, nil)
                    -- Cyan for Good, Purple for Bad (Distinct from standard Price/Stock colors)
                    if isGood then sysItem.textColor = {r=0.4, g=1.0, b=1.0, a=1} 
                    else sysItem.textColor = {r=1.0, g=0.4, b=1.0, a=1} 
                    end
                end
            end

            -- [B] ITEM CATEGORY EFFECTS (Price/Stock)
            if event.effects then
                for tag, mod in pairs(event.effects) do
                    local effectStr = "      - " .. tag
                    local isBad = false  -- High Price / Low Stock
                    local isGood = false -- Low Price / High Stock

                    if mod.price then 
                        effectStr = effectStr .. " (Price x" .. mod.price .. ")"
                        if mod.price > 1.01 then isBad = true end
                        if mod.price < 0.99 then isGood = true end
                    end
                    
                    if mod.vol then 
                        effectStr = effectStr .. " (Stock x" .. mod.vol .. ")" 
                        if mod.vol < 0.99 then isBad = true end
                        if mod.vol > 1.01 then isGood = true end
                    end
                    
                    local lineItem = self.listbox:addItem(effectStr, nil)
                    
                    -- Color Logic based on "Consumer" perspective (Buying)
                    if isBad and not isGood then
                         -- Red (Expensive/Scarce)
                         lineItem.textColor = {r=1.0, g=0.4, b=0.4, a=1} 
                    elseif isGood and not isBad then
                         -- Green (Cheap/Abundant)
                         lineItem.textColor = {r=0.4, g=1.0, b=0.4, a=1} 
                    elseif isGood and isBad then
                         -- Yellow (Mixed Bag)
                         lineItem.textColor = {r=1.0, g=0.9, b=0.4, a=1} 
                    else
                         -- Grey (Neutral)
                         lineItem.textColor = {r=0.8, g=0.8, b=0.8, a=1} 
                    end
                end
            end
            self.listbox:addItem(" ", nil) -- Spacing between events
        end
    end
    
    if not anyEvent then 
        self.listbox:addItem("  (No active events)", nil) 
        self.listbox:addItem(" ", nil)
    end
    
    -- 3. INFLATION / HEAT
    header = self.listbox:addItem("=== CATEGORY INFLATION ===", nil)
    header.textColor = {r=1, g=0.5, b=0.5, a=1}
    local anyHeat = false
    if data.globalHeat then
        for cat, val in pairs(data.globalHeat) do
            if math.abs(val) > 0.01 then
                anyHeat = true
                local percent = math.floor(val * 100)
                local sign = (val > 0) and "+" or ""
                local item = self.listbox:addItem(string.format("  %s: %s%d%%", cat, sign, percent), nil)
                -- Redish if expensive, Blueish if cheap
                item.textColor = (val > 0) and {r=1, g=0.6, b=0.6, a=1} or {r=0.6, g=0.6, b=1, a=1}
            end
        end
    end
    if not anyHeat then self.listbox:addItem("  (Market is stable)", nil) end
    
    -- Restore scroll position
    self.listbox:setYScroll(yScroll)
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
    local ui = DynamicTradingInfoUI:new(500, 100, 380, 500)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingInfoUI.instance = ui
end

