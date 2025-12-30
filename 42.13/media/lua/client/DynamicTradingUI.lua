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

    -- Header
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

function DynamicTradingUI:populateList()
    self.listbox:clear()
    
    local data = DynamicTrading.Shared.GetData()
    local config = DynamicTrading.Config
    
    -- Helper to get display name
    local function getItemName(fullType)
        local item = ScriptManager.instance:getItem(fullType)
        if item then return item:getDisplayName() end
        return fullType
    end

    for key, cfg in pairs(config) do
        local stock = data.stocks[key] or 0
        local price = data.prices[key] or cfg.basePrice
        local name = getItemName(cfg.item)
        
        -- Color code based on stock
        local color = {r=1, g=1, b=1, a=1}
        if stock == 0 then color = {r=0.5, g=0.5, b=0.5, a=1} end -- Grey if empty

        local text = string.format("%s   |   Qty: %d   |   $%d", name, stock, price)
        self.listbox:addItem(text, nil)
    end
end

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end

-- =================================================
-- OPEN UI FUNCTION
-- =================================================
function DynamicTradingUI.ToggleWindow()
    if DynamicTradingUI.instance then
        DynamicTradingUI.instance:close()
        return
    end

    local ui = DynamicTradingUI:new(100, 100, 300, 250)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingUI.instance = ui
end

-- =================================================
-- CONTEXT MENU INTEGRATION
-- =================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    local option = context:addOption("Check Market Prices", nil, DynamicTradingUI.ToggleWindow)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)