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
    -- Use default drawing, no fancy buttons needed here
    self:addChild(self.listbox)
    
    self:populateList()
end

function DynamicTradingInfoUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Manager.GetData()
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    -- 1. DIFFICULTY
    local header = self.listbox:addItem("=== DIFFICULTY PROFILE ===", nil)
    header.textColor = {r=1, g=0.9, b=0.5, a=1}
    self.listbox:addItem("  Setting: " .. (diff.name or "Unknown"), nil)
    self.listbox:addItem("  Buying Price: x" .. diff.buyMult, nil)
    self.listbox:addItem("  Selling Price: x" .. diff.sellMult, nil)
    self.listbox:addItem(" ", nil)

    -- 2. EVENTS
    header = self.listbox:addItem("=== ACTIVE EVENTS ===", nil)
    header.textColor = {r=0.5, g=1, b=0.5, a=1}
    
    local anyEvent = false
    if DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
            anyEvent = true
            local item = self.listbox:addItem(" [!] " .. (event.name or "Unknown"), nil)
            item.textColor = {r=0.2, g=1.0, b=0.2, a=1}
            
            if event.effects then
                for tag, mod in pairs(event.effects) do
                    local txt = "    - " .. tag .. ": " .. (mod.price and ("Price x"..mod.price) or "")
                    self.listbox:addItem(txt, nil)
                end
            end
        end
    end
    if not anyEvent then self.listbox:addItem("  (No active events)", nil) end
    self.listbox:addItem(" ", nil)

    -- 3. INFLATION
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
                item.textColor = (val > 0) and {r=1, g=0.6, b=0.6, a=1} or {r=0.6, g=0.6, b=1, a=1}
            end
        end
    end
    if not anyHeat then self.listbox:addItem("  (Market is stable)", nil) end
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
    local ui = DynamicTradingInfoUI:new(500, 100, 300, 400)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingInfoUI.instance = ui
end

-- ==========================================================
-- CONTEXT MENU
-- ==========================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    context:addOption("Global Economy Stats", nil, DynamicTradingInfoUI.ToggleWindow)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)