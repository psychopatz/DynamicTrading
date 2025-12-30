require "ISUI/ISCollapsableWindow"

DynamicTradingDebugUI = ISCollapsableWindow:derive("DynamicTradingDebugUI")
DynamicTradingDebugUI.instance = nil

function DynamicTradingDebugUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("DEBUG: Sales History")
    self:setResizable(true)
end

function DynamicTradingDebugUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 25
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.listbox)
    
    self:populateList()
end

function DynamicTradingDebugUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Shared.GetData()
    local config = DynamicTrading.Config
    
    -- Headers
    self.listbox:addItem("Item ID | Sold Count | Est. Inflation", nil)
    self.listbox:addItem("-----------------------------------", nil)

    local inflationMult = 1.0
    if SandboxVars.DynamicTrading then
        inflationMult = SandboxVars.DynamicTrading.PriceInflation or 1.0
    end

    for key, cfg in pairs(config) do
        local sold = data.salesHistory[key] or 0
        local base = cfg.basePrice
        -- Estimate logic matching the main script
        local demandCost = sold * (base * (0.1 * inflationMult))
        
        local text = string.format("%s : %d sold (+$%d est)", key, sold, demandCost)
        
        local item = self.listbox:addItem(text, nil)
        
        -- Color code high sales
        if sold > 0 then
            item.textColor = {r=0.4, g=1, b=0.4, a=1} -- Green text for active items
        else
            item.textColor = {r=0.6, g=0.6, b=0.6, a=1} -- Grey for inactive
        end
    end
end

function DynamicTradingDebugUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingDebugUI.instance = nil
end

function DynamicTradingDebugUI.ToggleWindow()
    if DynamicTradingDebugUI.instance then
        DynamicTradingDebugUI.instance:close()
        return
    end

    local ui = DynamicTradingDebugUI:new(450, 100, 350, 400)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingDebugUI.instance = ui
end