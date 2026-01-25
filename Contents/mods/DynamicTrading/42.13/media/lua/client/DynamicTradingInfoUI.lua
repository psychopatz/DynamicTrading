require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTabPanel"
require "ISUI/ISPanel"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTrading_Events"

-- ==============================================================================
-- DynamicTradingInfoUI - Tabbed Economy Stats Window
-- ==============================================================================
DynamicTradingInfoUI = ISCollapsableWindow:derive("DynamicTradingInfoUI")
DynamicTradingInfoUI.instance = nil

-- Color Constants for consistent theming
DynamicTradingInfoUI.Colors = {
    -- Headers
    HeaderMarket = {r=1.0, g=0.85, b=0.3, a=1},      -- Golden Yellow
    HeaderMeta = {r=0.4, g=0.8, b=1.0, a=1},         -- Cyan
    HeaderFlash = {r=0.3, g=1.0, b=0.3, a=1},        -- Green
    HeaderInflation = {r=1.0, g=0.5, b=0.5, a=1},    -- Red
    
    -- Status Colors
    StatusGood = {r=0.4, g=1.0, b=0.5, a=1},         -- Green (Available/Positive)
    StatusBad = {r=1.0, g=0.4, b=0.4, a=1},          -- Red (Full/Negative)
    StatusNeutral = {r=0.8, g=0.8, b=0.8, a=1},      -- Grey
    StatusMixed = {r=1.0, g=0.9, b=0.4, a=1},        -- Yellow (Mixed)
    
    -- Effect Colors
    EffectGood = {r=0.4, g=1.0, b=1.0, a=1},         -- Cyan (Positive System)
    EffectBad = {r=1.0, g=0.4, b=1.0, a=1},          -- Magenta (Negative System)
    EffectCheap = {r=0.4, g=1.0, b=0.4, a=1},        -- Green (Cheap/Abundant)
    EffectExpensive = {r=1.0, g=0.4, b=0.4, a=1},    -- Red (Expensive/Scarce)
    
    -- Inflation Colors
    InflationHigh = {r=1.0, g=0.6, b=0.6, a=1},      -- Light Red
    InflationLow = {r=0.6, g=0.6, b=1.0, a=1},       -- Light Blue
    
    -- Text
    Description = {r=0.7, g=0.7, b=0.7, a=1},
    Normal = {r=0.9, g=0.9, b=0.9, a=1},
    Muted = {r=0.6, g=0.6, b=0.6, a=1},
}

-- ==============================================================================
-- INITIALIZATION
-- ==============================================================================
function DynamicTradingInfoUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Global Economy Monitor")
    self:setResizable(true)
    self.clearStencil = false 
    self.refreshTimer = 0
    self.activeTab = 1
end

function DynamicTradingInfoUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local titleBarHeight = 24
    local tabHeight = 28
    local padding = 10
    
    -- Tab Panel
    self.tabPanel = ISTabPanel:new(0, titleBarHeight, self.width, self.height - titleBarHeight)
    self.tabPanel:initialise()
    self.tabPanel.target = self
    self.tabPanel.onActivateView = self.onTabChanged
    self.tabPanel:setAnchorRight(true)
    self.tabPanel:setAnchorBottom(true)
    self.tabPanel.tabHeight = tabHeight
    self:addChild(self.tabPanel)
    
    -- Create tabs
    self:createMarketProfileTab()
    self:createMetaEventsTab()
    self:createFlashEventsTab()
    self:createInflationTab()
    
    -- Initial population
    self:populateAllTabs()
end

-- ==============================================================================
-- TAB CREATION
-- ==============================================================================
function DynamicTradingInfoUI:createListPanel()
    local panel = ISPanel:new(0, 0, self.width, self.height - 52)
    panel:initialise()
    panel:setAnchorRight(true)
    panel:setAnchorBottom(true)
    
    local listbox = ISScrollingListBox:new(10, 10, panel.width - 20, panel.height - 20)
    listbox:initialise()
    listbox:setAnchorRight(true)
    listbox:setAnchorBottom(true)
    listbox.font = UIFont.Small
    listbox.itemheight = 24
    listbox.drawBorder = true
    listbox.borderColor = {r=0.3, g=0.3, b=0.3, a=0.8}
    listbox.backgroundColor = {r=0.1, g=0.1, b=0.12, a=0.95}
    panel:addChild(listbox)
    
    panel.listbox = listbox
    return panel
end

function DynamicTradingInfoUI:createMarketProfileTab()
    self.marketPanel = self:createListPanel()
    self.tabPanel:addView("Market", self.marketPanel)
    self.marketPanel.listbox.backgroundColor = {r=0.12, g=0.1, b=0.05, a=0.95}
end

function DynamicTradingInfoUI:createMetaEventsTab()
    self.metaPanel = self:createListPanel()
    self.tabPanel:addView("World", self.metaPanel)
    self.metaPanel.listbox.backgroundColor = {r=0.05, g=0.1, b=0.15, a=0.95}
end

function DynamicTradingInfoUI:createFlashEventsTab()
    self.flashPanel = self:createListPanel()
    self.tabPanel:addView("News", self.flashPanel)
    self.flashPanel.listbox.backgroundColor = {r=0.05, g=0.12, b=0.05, a=0.95}
end

function DynamicTradingInfoUI:createInflationTab()
    self.inflationPanel = self:createListPanel()
    self.tabPanel:addView("Inflation", self.inflationPanel)
    self.inflationPanel.listbox.backgroundColor = {r=0.15, g=0.08, b=0.08, a=0.95}
end

-- ==============================================================================
-- AUTO-UPDATE LOGIC
-- ==============================================================================
function DynamicTradingInfoUI:update()
    ISCollapsableWindow.update(self)
    
    -- Refresh every 60 ticks (approx 1 second)
    self.refreshTimer = self.refreshTimer + 1
    if self.refreshTimer >= 60 then
        self:populateAllTabs()
        self.refreshTimer = 0
    end
end

function DynamicTradingInfoUI:onTabChanged()
    -- Optional: Could be used to trigger specific refresh on tab switch
end

-- ==============================================================================
-- POPULATE ALL TABS
-- ==============================================================================
function DynamicTradingInfoUI:populateAllTabs()
    self:populateMarketProfile()
    self:populateMetaEvents()
    self:populateFlashEvents()
    self:populateInflation()
end

-- ==============================================================================
-- MARKET PROFILE TAB
-- ==============================================================================
function DynamicTradingInfoUI:populateMarketProfile()
    local listbox = self.marketPanel.listbox
    local yScroll = listbox:getYScroll()
    listbox:clear()
    
    local data = DynamicTrading.Manager.GetData()
    local diff = DynamicTrading.Config.GetDifficultyData()
    local colors = DynamicTradingInfoUI.Colors
    
    -- Header
    local header = listbox:addItem("═══ MARKET PROFILE ═══", nil)
    header.textColor = colors.HeaderMarket
    
    listbox:addItem(" ", nil)
    
    -- Daily Network Status
    if data.DailyCycle then
        local found = data.DailyCycle.currentTradersFound or 0
        local limit = data.DailyCycle.dailyTraderLimit or 5
        
        -- Adjust Limit if modified by an event
        local eventMult = 1.0
        if DynamicTrading.Events.GetSystemModifier then
            eventMult = DynamicTrading.Events.GetSystemModifier("traderLimit")
        end
        local displayLimit = math.floor(limit * eventMult)
        if displayLimit < 1 then displayLimit = 1 end
        
        -- Status indicator
        local statusIcon = "●"
        local statusColor = colors.StatusGood
        local statusText = "ACTIVE"
        if found >= displayLimit then 
            statusColor = colors.StatusBad
            statusText = "LIMIT REACHED"
        end
        
        local networkItem = listbox:addItem(string.format("  %s Network Status: %s", statusIcon, statusText), nil)
        networkItem.textColor = statusColor
        
        local countItem = listbox:addItem(string.format("    Traders Found: %d / %d", found, displayLimit), nil)
        countItem.textColor = colors.Normal
    end
    
    listbox:addItem(" ", nil)
    
    -- Difficulty Multipliers Section
    local diffHeader = listbox:addItem("─── DIFFICULTY SETTINGS ───", nil)
    diffHeader.textColor = colors.Muted
    
    -- Format multipliers
    local buyMult = diff.buyMult or 1.0
    local sellMult = diff.sellMult or 0.5
    local stockMult = diff.stockMult or 1.0
    local rarityBonus = diff.rarityBonus or 0
    
    -- Buy Price (Higher = Worse for player)
    local buyStr = string.format("%d%%", math.floor(buyMult * 100))
    local buyItem = listbox:addItem("  BUY PRICE MODIFIER: " .. buyStr, nil)
    if buyMult > 1.0 then buyItem.textColor = colors.EffectExpensive
    elseif buyMult < 1.0 then buyItem.textColor = colors.EffectCheap
    else buyItem.textColor = colors.Normal end
    
    -- Sell Return (Higher = Better for player)
    local sellStr = string.format("%d%%", math.floor(sellMult * 100))
    local sellItem = listbox:addItem("  SELL RETURN RATE: " .. sellStr, nil)
    if sellMult > 0.5 then sellItem.textColor = colors.EffectCheap
    elseif sellMult < 0.5 then sellItem.textColor = colors.EffectExpensive
    else sellItem.textColor = colors.Normal end
    
    -- Stock Volume (Higher = Better)
    local stockStr = string.format("%d%%", math.floor(stockMult * 100))
    local stockItem = listbox:addItem("  STOCK VOLUME: " .. stockStr, nil)
    if stockMult > 1.0 then stockItem.textColor = colors.EffectCheap
    elseif stockMult < 1.0 then stockItem.textColor = colors.EffectExpensive
    else stockItem.textColor = colors.Normal end
    
    -- Rarity Bonus
    local rarityStr = tostring(rarityBonus)
    if rarityBonus > 0 then rarityStr = "+" .. rarityStr end
    local rarityItem = listbox:addItem("  RARITY TIER BONUS: " .. rarityStr, nil)
    if rarityBonus > 0 then rarityItem.textColor = colors.EffectCheap
    elseif rarityBonus < 0 then rarityItem.textColor = colors.EffectExpensive
    else rarityItem.textColor = colors.Normal end
    
    listbox:setYScroll(yScroll)
end

-- ==============================================================================
-- META EVENTS TAB (World State Events)
-- ==============================================================================
function DynamicTradingInfoUI:populateMetaEvents()
    local listbox = self.metaPanel.listbox
    local yScroll = listbox:getYScroll()
    listbox:clear()
    
    local colors = DynamicTradingInfoUI.Colors
    
    -- Header
    local header = listbox:addItem("═══ WORLD STATE EVENTS ═══", nil)
    header.textColor = colors.HeaderMeta
    
    listbox:addItem(" ", nil)
    
    local anyMeta = false
    
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
            if event.type == "meta" then
                anyMeta = true
                self:renderEventDetails(listbox, event, colors.HeaderMeta)
            end
        end
    end
    
    if not anyMeta then
        local emptyItem = listbox:addItem("  [INFO] No world state events active", nil)
        emptyItem.textColor = colors.Muted
        listbox:addItem(" ", nil)
        local infoItem = listbox:addItem("  World events are long-term changes that", nil)
        infoItem.textColor = colors.Description
        local infoItem2 = listbox:addItem("  affect the global economy over time.", nil)
        infoItem2.textColor = colors.Description
    end
    
    listbox:setYScroll(yScroll)
end

-- ==============================================================================
-- FLASH EVENTS TAB (News/Short-term Events)
-- ==============================================================================
function DynamicTradingInfoUI:populateFlashEvents()
    local listbox = self.flashPanel.listbox
    local yScroll = listbox:getYScroll()
    listbox:clear()
    
    local colors = DynamicTradingInfoUI.Colors
    
    -- Header
    local header = listbox:addItem("═══ BREAKING NEWS ═══", nil)
    header.textColor = colors.HeaderFlash
    
    listbox:addItem(" ", nil)
    
    local anyFlash = false
    
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
            if event.type ~= "meta" then
                anyFlash = true
                self:renderEventDetails(listbox, event, colors.HeaderFlash)
            end
        end
    end
    
    if not anyFlash then
        local emptyItem = listbox:addItem("  [INFO] No breaking news events active", nil)
        emptyItem.textColor = colors.Muted
        listbox:addItem(" ", nil)
        local infoItem = listbox:addItem("  Flash events are short-term market disruptions", nil)
        infoItem.textColor = colors.Description
        local infoItem2 = listbox:addItem("  that affect specific item categories.", nil)
        infoItem2.textColor = colors.Description
    end
    
    listbox:setYScroll(yScroll)
end

-- ==============================================================================
-- SHARED: RENDER EVENT DETAILS
-- ==============================================================================
function DynamicTradingInfoUI:renderEventDetails(listbox, event, headerColor)
    local colors = DynamicTradingInfoUI.Colors
    
    -- Event Name with icon
    local typeIcon = event.type == "meta" and "[WORLD]" or "[NEWS]"
    local nameItem = listbox:addItem(string.format(" %s %s", typeIcon, event.name or "Unknown Event"), nil)
    nameItem.textColor = headerColor
    
    -- Event Description
    if event.description then
        local descItem = listbox:addItem(string.format("   \"%s\"", event.description), nil)
        descItem.textColor = colors.Description
    end
    
    -- System Modifiers (Global Effects)
    if event.system then
        for sysKey, val in pairs(event.system) do
            local txt = "   ► GLOBAL: "
            local isGood = val > 1
            
            if sysKey == "traderLimit" then
                txt = txt .. string.format("Trader Network Cap (x%.1f)", val)
            elseif sysKey == "globalStock" then
                txt = txt .. string.format("All Stock Levels (x%.1f)", val)
            elseif sysKey == "scanChance" then
                txt = txt .. string.format("Signal Reception (x%.1f)", val)
            else
                txt = txt .. string.format("%s (x%.1f)", sysKey, val)
            end
            
            local sysItem = listbox:addItem(txt, nil)
            sysItem.textColor = isGood and colors.EffectGood or colors.EffectBad
        end
    end
    
    -- Item Category Effects (Price/Stock)
    if event.effects then
        for tag, mod in pairs(event.effects) do
            local effectStr = "   • " .. tag
            local isBad = false
            local isGood = false
            
            if mod.price then 
                effectStr = effectStr .. string.format(" (Price x%.2f)", mod.price)
                if mod.price > 1.01 then isBad = true end
                if mod.price < 0.99 then isGood = true end
            end
            
            if mod.vol then 
                effectStr = effectStr .. string.format(" (Stock x%.2f)", mod.vol)
                if mod.vol < 0.99 then isBad = true end
                if mod.vol > 1.01 then isGood = true end
            end
            
            local lineItem = listbox:addItem(effectStr, nil)
            
            -- Color Logic based on consumer perspective
            if isBad and not isGood then
                lineItem.textColor = colors.EffectExpensive
            elseif isGood and not isBad then
                lineItem.textColor = colors.EffectCheap
            elseif isGood and isBad then
                lineItem.textColor = colors.StatusMixed
            else
                lineItem.textColor = colors.StatusNeutral
            end
        end
    end
    
    listbox:addItem(" ", nil)
end

-- ==============================================================================
-- INFLATION TAB
-- ==============================================================================
function DynamicTradingInfoUI:populateInflation()
    local listbox = self.inflationPanel.listbox
    local yScroll = listbox:getYScroll()
    listbox:clear()
    
    local data = DynamicTrading.Manager.GetData()
    local colors = DynamicTradingInfoUI.Colors
    
    -- Header
    local header = listbox:addItem("═══ CATEGORY INFLATION ═══", nil)
    header.textColor = colors.HeaderInflation
    
    listbox:addItem(" ", nil)
    
    -- Info section
    local infoItem = listbox:addItem("  Price changes based on trading activity:", nil)
    infoItem.textColor = colors.Muted
    listbox:addItem(" ", nil)
    
    local anyHeat = false
    local sortedHeat = {}
    
    if data.globalHeat then
        for cat, val in pairs(data.globalHeat) do
            if math.abs(val) > 0.01 then
                table.insert(sortedHeat, {category = cat, value = val})
            end
        end
        -- Sort by absolute value (highest impact first)
        table.sort(sortedHeat, function(a, b) return math.abs(a.value) > math.abs(b.value) end)
    end
    
    if #sortedHeat > 0 then
        anyHeat = true
        
        -- Inflated categories (positive heat)
        local hasInflated = false
        for _, heat in ipairs(sortedHeat) do
            if heat.value > 0.01 then
                if not hasInflated then
                    local subHeader = listbox:addItem("  ─── INFLATED (Higher Prices) ───", nil)
                    subHeader.textColor = colors.InflationHigh
                    hasInflated = true
                end
                local percent = math.floor(heat.value * 100)
                local icon = "[+]"
                local item = listbox:addItem(string.format("   %s %s: +%d%%", icon, heat.category, percent), nil)
                item.textColor = colors.InflationHigh
            end
        end
        
        if hasInflated then listbox:addItem(" ", nil) end
        
        -- Deflated categories (negative heat)
        local hasDeflated = false
        for _, heat in ipairs(sortedHeat) do
            if heat.value < -0.01 then
                if not hasDeflated then
                    local subHeader = listbox:addItem("  ─── DEFLATED (Lower Prices) ───", nil)
                    subHeader.textColor = colors.InflationLow
                    hasDeflated = true
                end
                local percent = math.floor(heat.value * 100)
                local icon = "[-]"
                local item = listbox:addItem(string.format("   %s %s: %d%%", icon, heat.category, percent), nil)
                item.textColor = colors.InflationLow
            end
        end
    end
    
    if not anyHeat then
        local stableIcon = "[STABLE]"
        local stableItem = listbox:addItem(string.format("  %s Market is currently stable", stableIcon), nil)
        stableItem.textColor = colors.StatusGood
        listbox:addItem(" ", nil)
        local tipItem = listbox:addItem("  Inflation occurs when items are traded", nil)
        tipItem.textColor = colors.Description
        local tipItem2 = listbox:addItem("  frequently in a short period.", nil)
        tipItem2.textColor = colors.Description
    end
    
    listbox:setYScroll(yScroll)
end

-- ==============================================================================
-- WINDOW MANAGEMENT
-- ==============================================================================
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
            DynamicTradingInfoUI.instance:populateAllTabs()
        end
        return
    end
    
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local w = 420
    local h = 520
    local x = (screenW - w) / 2
    local y = (screenH - h) / 2
    
    local ui = DynamicTradingInfoUI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingInfoUI.instance = ui
end
