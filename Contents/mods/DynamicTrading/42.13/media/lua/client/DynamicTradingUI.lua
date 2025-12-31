require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "DynamicTrading_Config" -- FORCE LOAD CONFIGURATION

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Market Prices")
    self:setResizable(false)
    self.collapsed = {} 
    
    self.drawFrame = true
    self.backgroundColor = {r=0, g=0, b=0, a=0.9}
    self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
end

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. MERCHANT HEADER
    self.merchantHeader = ISLabel:new(self.width / 2, 20, 20, "TRADER: ???", 1, 0.8, 0.4, 1, UIFont.Medium, true)
    self.merchantHeader:setAnchorTop(true)
    self.merchantHeader:setAnchorBottom(false)
    self:addChild(self.merchantHeader)

    -- 2. LISTBOX
    self.listbox = ISScrollingListBox:new(10, 50, self.width - 20, self.height - 100)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox:addScrollBars(true)
    self.listbox.doDrawItem = self.drawListItem
    
    self.listbox.onMouseDown = function(target, x, y)
        ISScrollingListBox.onMouseDown(target, x, y) 
        local row = target:rowAt(x, y)
        if row == -1 then return end
        
        local item = target.items[row]
        if item and item.item and item.item.isCategory then
            local cat = item.item.categoryName
            local ui = DynamicTradingUI.instance
            if ui.collapsed[cat] then ui.collapsed[cat] = false else ui.collapsed[cat] = true end
            ui:populateList() 
        end
    end
    self:addChild(self.listbox)
    
    -- 3. BUY BUTTON
    self.buyButton = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY ITEM", self, self.onBuyClick)
    self.buyButton:initialise()
    self.buyButton:setAnchorTop(false)
    self.buyButton:setAnchorBottom(true)
    self.buyButton:setAnchorRight(true)
    self.buyButton:setAnchorLeft(false)
    self.buyButton:setVisible(true)
    self.buyButton.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.buyButton)

    -- 4. FOOTER
    self.restockLabel = ISLabel:new(10, self.height - 30, 16, "Restock: ???", 1, 1, 1, 0.5, UIFont.Small, true)
    self.restockLabel:setAnchorTop(false)
    self.restockLabel:setAnchorBottom(true)
    self:addChild(self.restockLabel)

    self:populateList()
end

-- =================================================
-- VISUAL UPDATE (Button State)
-- =================================================
function DynamicTradingUI:prerender()
    ISCollapsableWindow.prerender(self)
    
    local selection = self.listbox.selected
    local canAfford = false
    local soldOut = false
    local price = 0
    local isItemSelected = false
    
    if selection > 0 then
        local itemObj = self.listbox.items[selection]
        if itemObj and itemObj.item and not itemObj.item.isCategory then
            local data = itemObj.item
            local master = DynamicTrading.Config.MasterList[data.key]
            
            if master then
                isItemSelected = true
                price = data.price
                if data.stock <= 0 then soldOut = true end
                
                -- Check Wealth
                local player = getSpecificPlayer(0)
                if player then
                    local inv = player:getInventory()
                    local wealth = inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
                    if wealth >= price then canAfford = true end
                end
            end
        end
    end

    -- Button Logic
    if not isItemSelected then
        self.buyButton.title = "SELECT ITEM"
        self.buyButton:setEnable(false)
        self.buyButton.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
        self.buyButton.textColor = {r=0.5, g=0.5, b=0.5, a=1}
    elseif soldOut then
        self.buyButton.title = "SOLD OUT"
        self.buyButton:setEnable(false)
        -- Darker Red background + Pure White text for readability
        self.buyButton.backgroundColor = {r=0.6, g=0.0, b=0.0, a=1} 
        self.buyButton.textColor = {r=1.0, g=1.0, b=1.0, a=1}
    elseif not canAfford then
        self.buyButton.title = "NEED $" .. price
        self.buyButton:setEnable(false)
        -- Darker Red background + Pure White text for readability
        self.buyButton.backgroundColor = {r=0.6, g=0.0, b=0.0, a=1}
        self.buyButton.textColor = {r=1.0, g=1.0, b=1.0, a=1}
    else
        self.buyButton.title = "BUY"
        self.buyButton:setEnable(true)
        -- Green background + Pure White text
        self.buyButton.backgroundColor = {r=0.1, g=0.5, b=0.1, a=1} 
        self.buyButton.textColor = {r=1.0, g=1.0, b=1.0, a=1}
    end
end

-- =================================================
-- CLICK HANDLER
-- =================================================
function DynamicTradingUI:onBuyClick()
    local selection = self.listbox.selected
    if selection < 1 then return end
    
    local itemObj = self.listbox.items[selection]
    if not itemObj or not itemObj.item or itemObj.item.isCategory then return end
    
    local recipeKey = itemObj.item.key
    local player = getSpecificPlayer(0)
    
    if DynamicTrading.Shared.PerformTrade then
        DynamicTrading.Shared.PerformTrade(player, recipeKey)
        -- Note: PerformTrade triggers populateList(), which now handles selection persistence
    end
end

-- =================================================
-- DRAW LIST ITEM
-- =================================================
function DynamicTradingUI:drawListItem(y, item, alt)
    if not item.height then item.height = self.itemheight end

    -- Category
    if item.item.isCategory then
        self:drawRect(0, y, self:getWidth(), item.height, 0.85, 0.15, 0.15, 0.15)
        self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, 0.6, 0.6, 0.6)
        
        local prefix = DynamicTradingUI.instance.collapsed[item.item.categoryName] and "[+] " or "[-] "
        local fullText = prefix .. item.text
        local textWid = getTextManager():MeasureStringX(UIFont.Medium, fullText)
        self:drawText(fullText, (self:getWidth()/2) - (textWid/2), y + (item.height - 18)/2, 1, 0.9, 0.4, 1, UIFont.Medium)
        return y + item.height
    end

    -- Product
    local data = item.item 
    if not DynamicTrading.Config or not DynamicTrading.Config.MasterList then return y + item.height end
    local master = DynamicTrading.Config.MasterList[data.key]
    if not master then return y + item.height end

    -- Background
    if data.stock <= 0 then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.6, 0.2, 0.0, 0.0) 
    elseif self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.2, 0.3, 0.3, 0.3)
    end
    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.1, 1, 1, 1)

    -- Icon
    local itemScript = ScriptManager.instance:getItem(master.item)
    if itemScript then
        local iconName = itemScript:getIcon()
        if iconName then
            local tex = getTexture("Item_" .. iconName)
            if not tex then tex = getTexture(iconName) end
            if tex then self:drawTextureScaled(tex, 6, y + (item.height - 28)/2, 28, 28, 1, 1, 1, 1) end
        end
    end

    -- Colors
    local nameR, nameG, nameB = 0.9, 0.9, 0.9
    local priceR, priceG, priceB = 1, 1, 1
    if data.stock <= 0 then
        nameR, nameG, nameB = 0.6, 0.6, 0.6
        priceR, priceG, priceB = 0.6, 0.6, 0.6
    else
        if data.price > master.basePrice * 1.15 then priceR, priceG, priceB = 1, 0.4, 0.4 
        elseif data.price < master.basePrice * 0.85 then priceR, priceG, priceB = 0.4, 1, 0.4 end
        if DynamicTrading.Economy and DynamicTrading.Economy.GetEnvironmentModifier then
            local envMod = DynamicTrading.Economy.GetEnvironmentModifier(master.tags or {})
            if envMod > 0.2 then nameR, nameG, nameB = 0.6, 0.8, 1.0 end
        end
    end

    -- Truncation
    local availableWidth = self:getWidth() - 200 
    local displayName = item.text
    local textManager = getTextManager()
    if textManager:MeasureStringX(self.font, displayName) > availableWidth then
        while textManager:MeasureStringX(self.font, displayName .. "...") > availableWidth and string.len(displayName) > 0 do
             displayName = string.sub(displayName, 1, -2) 
        end
        displayName = displayName .. "..."
    end

    self:drawText(displayName, 45, y + (item.height - 15)/2, nameR, nameG, nameB, 1, self.font)
    self:drawText("$" .. data.price, self:getWidth() - 60, y + (item.height - 15)/2, priceR, priceG, priceB, 1, self.font)
    
    if data.stock <= 0 then
        self:drawText("SOLD OUT", self:getWidth() - 145, y + (item.height - 15)/2, 1, 0.1, 0.1, 1, self.font)
    else
        self:drawText("Qty: " .. data.stock, self:getWidth() - 130, y + (item.height - 15)/2, 0.8, 0.8, 0.8, 1, self.font)
    end
    return y + item.height
end

-- =================================================
-- POPULATE LIST (Updated to Persist Selection)
-- =================================================
function DynamicTradingUI:populateList()
    -- 1. CAPTURE CURRENT SELECTION
    local savedSelectionKey = nil
    if self.listbox.selected > 0 then
        local currentItem = self.listbox.items[self.listbox.selected]
        if currentItem and currentItem.item and not currentItem.item.isCategory then
            savedSelectionKey = currentItem.item.key
        end
    end

    self.listbox:clear()
    
    if not DynamicTrading or not DynamicTrading.Shared or not DynamicTrading.Config then return end
    local data = DynamicTrading.Shared.GetData()
    local masterList = DynamicTrading.Config.MasterList
    if not masterList then return end
    
    local merchantName = data.currentMerchant or "Unknown Trader"
    if self.merchantHeader then self.merchantHeader:setName("TRADER: " .. string.upper(merchantName)) end
    
    if not data.stocks then return end

    local categorized = {}
    local categories = {} 
    
    for key, stockQty in pairs(data.stocks) do
        local config = masterList[key]
        if config then
            local cat = config.category or "Misc"
            if not categorized[cat] then 
                categorized[cat] = {} 
                table.insert(categories, cat)
            end
            
            local itemName = config.item
            local scriptItem = ScriptManager.instance:getItem(config.item)
            if scriptItem then itemName = scriptItem:getDisplayName() 
            else
                local _, _, name = string.find(config.item, "%.(%w+)")
                if name then itemName = name end
            end

            table.insert(categorized[cat], {
                key = key,
                name = itemName,
                stock = stockQty,
                price = data.prices[key] or config.basePrice
            })
        end
    end
    
    table.sort(categories)

    for _, catName in ipairs(categories) do
        local headerItem = self.listbox:addItem(string.upper(catName), nil)
        headerItem.item = { isCategory = true, text = string.upper(catName), categoryName = catName }
        headerItem.height = 30 
        
        if not self.collapsed[catName] then
            table.sort(categorized[catName], function(a,b) return a.name < b.name end)
            for _, product in ipairs(categorized[catName]) do
                local item = self.listbox:addItem(product.name, nil)
                item.item = product
            end
        end
    end

    -- 2. RESTORE SELECTION
    if savedSelectionKey then
        for i, item in ipairs(self.listbox.items) do
            if item.item and item.item.key == savedSelectionKey then
                -- Only restore selection if stock > 0
                if item.item.stock > 0 then
                    self.listbox.selected = i
                else
                    self.listbox.selected = -1 -- Deselect if Sold Out
                end
                break
            end
        end
    end

    local gt = GameTime:getInstance()
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    local currentDay = math.floor(gt:getDaysSurvived())
    local lastReset = data.lastResetDay or 0
    local nextDay = lastReset + interval
    local daysLeft = nextDay - currentDay
    if daysLeft <= 0 then daysLeft = 1 end
    
    if self.restockLabel then
        self.restockLabel:setName("Next Restock: " .. (daysLeft > 1 and ("in " .. daysLeft .. " days") or "Tomorrow"))
    end
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
    local ui = DynamicTradingUI:new(100, 100, 420, 600)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingUI.instance = ui
end