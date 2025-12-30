require "ISUI/ISCollapsableWindow"

DynamicTradingDebugUI = ISCollapsableWindow:derive("DynamicTradingDebugUI")
DynamicTradingDebugUI.instance = nil

function DynamicTradingDebugUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Economy Debugger")
    self:setResizable(true)
end

function DynamicTradingDebugUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 20
    self.listbox.drawBorder = true
    self:addChild(self.listbox)
    
    self:populateList()
end

function DynamicTradingDebugUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Shared.GetData()
    local config = DynamicTrading.Config.MasterList
    
    -- === SECTION 1: CATEGORY INFLATION ===
    self.listbox:addItem("=== CATEGORY HEAT (INFLATION) ===", nil)
    if data.categoryHeat then
        for cat, val in pairs(data.categoryHeat) do
            local percent = math.floor(val * 100)
            local text = string.format("  %s: +%d%% Price", cat, percent)
            local item = self.listbox:addItem(text, nil)
            if percent > 0 then item.textColor = {r=1, g=0.5, b=0.5, a=1} end
        end
    else
        self.listbox:addItem("  No active inflation.", nil)
    end
    self.listbox:addItem(" ", nil)

    -- === SECTION 2: SALES HISTORY ===
    self.listbox:addItem("=== SALES TODAY ===", nil)
    for key, count in pairs(data.salesHistory) do
        if count > 0 then
            self.listbox:addItem("  " .. key .. ": " .. count, nil)
        end
    end
end

function DynamicTradingDebugUI.ToggleWindow()
    if DynamicTradingDebugUI.instance then
        DynamicTradingDebugUI.instance:setVisible(false)
        DynamicTradingDebugUI.instance:removeFromUIManager()
        DynamicTradingDebugUI.instance = nil
        return
    end

    local ui = DynamicTradingDebugUI:new(500, 100, 300, 400)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingDebugUI.instance = ui
end