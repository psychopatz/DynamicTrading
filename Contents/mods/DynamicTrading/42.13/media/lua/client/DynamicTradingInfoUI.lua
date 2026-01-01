require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTrading_Events"
require "DynamicTradingUI" -- Needed to open the trading window

DynamicTradingInfoUI = ISCollapsableWindow:derive("DynamicTradingInfoUI")
DynamicTradingInfoUI.instance = nil

function DynamicTradingInfoUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Global Economy Status")
    self:setResizable(true)
    self.clearStencil = false 
end

function DynamicTradingInfoUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 20
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    -- [NEW] Enable Mouse Interaction
    self.listbox.onMouseDown = DynamicTradingInfoUI.onListMouseDown
    
    self:addChild(self.listbox)
    
    self:populateList()
end

function DynamicTradingInfoUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Manager.GetData()
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    -- ==========================================================
    -- SECTION 1: DIFFICULTY PROFILE
    -- ==========================================================
    local header = self.listbox:addItem("=== DIFFICULTY PROFILE ===", nil)
    header.textColor = {r=1, g=0.9, b=0.5, a=1}
    
    self.listbox:addItem("  Setting: " .. (diff.name or "Unknown"), nil)
    self.listbox:addItem("  Buying Price: x" .. diff.buyMult, nil)
    self.listbox:addItem("  Stock Size: x" .. diff.stockMult, nil)
    self.listbox:addItem(" ", nil)

    -- ==========================================================
    -- SECTION 2: ACTIVE WORLD EVENTS
    -- ==========================================================
    header = self.listbox:addItem("=== ACTIVE EVENTS ===", nil)
    header.textColor = {r=0.5, g=1, b=0.5, a=1}
    
    local anyEvent = false
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
            anyEvent = true
            local item = self.listbox:addItem(" [!] " .. (event.name or "Unknown Event"), nil)
            item.textColor = {r=0.2, g=1.0, b=0.2, a=1}
            
            if event.inject then
                for tag, count in pairs(event.inject) do
                    self.listbox:addItem("    + Injecting " .. count .. "x " .. tag, nil)
                end
            end
            
            if event.effects then
                for tag, mod in pairs(event.effects) do
                    local txt = "    - " .. tag .. ": "
                    if mod.price then txt = txt .. "Price x" .. mod.price .. " " end
                    if mod.vol then txt = txt .. "Vol x" .. mod.vol end
                    self.listbox:addItem(txt, nil)
                end
            end
        end
    end
    
    if not anyEvent then 
        self.listbox:addItem("  (No active events)", nil)
    end
    self.listbox:addItem(" ", nil)

    -- ==========================================================
    -- SECTION 3: MARKET INFLATION
    -- ==========================================================
    header = self.listbox:addItem("=== CATEGORY INFLATION ===", nil)
    header.textColor = {r=1, g=0.5, b=0.5, a=1}
    
    local anyHeat = false
    if data.globalHeat then
        for cat, val in pairs(data.globalHeat) do
            if math.abs(val) > 0.01 then
                anyHeat = true
                local percent = math.floor(val * 100)
                local sign = (val > 0) and "+" or ""
                local text = string.format("  %s: %s%d%% Price", cat, sign, percent)
                
                local item = self.listbox:addItem(text, nil)
                if val > 0 then
                    item.textColor = {r=1, g=0.6, b=0.6, a=1}
                else
                    item.textColor = {r=0.6, g=0.6, b=1, a=1}
                end
            end
        end
    end
    
    if not anyHeat then
        self.listbox:addItem("  (Market is stable)", nil)
    end
    self.listbox:addItem(" ", nil)
    
    -- ==========================================================
    -- SECTION 4: TRADER NETWORK (CLICKABLE)
    -- ==========================================================
    header = self.listbox:addItem("=== KNOWN TRADERS ===", nil)
    header.textColor = {r=0.8, g=0.8, b=1, a=1}
    
    local count = 0
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            count = count + 1
            local name = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or trader.archetype
            
            -- Prepare the display text
            local txt = "  - " .. name .. " (" .. id .. ")"
            
            -- Pass the ID and Archetype as item data
            local itemData = { traderID = id, archetype = trader.archetype, isDebug = false }
            
            -- Check if it's a Debug Trader
            if string.find(id, "Debug_Trader") then
                txt = txt .. " [OPEN]"
                itemData.isDebug = true
            end
            
            local listItem = self.listbox:addItem(txt, itemData)
            
            -- Highlight clickable debug traders in Cyan
            if itemData.isDebug then
                listItem.textColor = {r=0.0, g=1.0, b=1.0, a=1}
            end
        end
    end
    
    if count == 0 then
        self.listbox:addItem("  (No traders discovered yet)", nil)
    end
end

-- =================================================
-- CLICK HANDLER
-- =================================================
function DynamicTradingInfoUI.onListMouseDown(target, x, y)
    -- Standard listbox selection logic
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    -- Get the item data we attached in populateList
    local item = target.items[row]
    if item and item.item and item.item.isDebug then
        local data = item.item
        
        -- Open the Trading UI for this specific trader
        if DynamicTradingUI and DynamicTradingUI.ToggleWindow then
            DynamicTradingUI.ToggleWindow(data.traderID, data.archetype)
        end
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

    local ui = DynamicTradingInfoUI:new(100, 100, 350, 500)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingInfoUI.instance = ui
end