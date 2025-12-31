require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Config"

-- ==========================================================
-- DYNAMIC TRADING UI (Main Shop Window)
-- Handles Buying, Selling, and Event Visualization
-- ==========================================================

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

-- =================================================
-- INITIALIZATION
-- =================================================
function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Market Trading")
    self:setResizable(false)
    
    self.collapsed = {}     -- Tracks collapsed categories
    self.isBuying = true    -- Default mode is Buying from Trader
    
    -- Visual Styling
    self.drawFrame = true
    self.backgroundColor = {r=0, g=0, b=0, a=0.9}
    self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
end

-- =================================================
-- WIDGET CREATION
-- =================================================
function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. TRADER HEADER
    self.merchantHeader = ISLabel:new(self.width / 2, 18, 20, "TRADER", 1, 0.9, 0.9, 0.9, UIFont.Medium, true)
    self.merchantHeader:setAnchorTop(true)
    self.merchantHeader.center = true
    self:addChild(self.merchantHeader)
    
    -- 2. NEWS TICKER (Rumors)
    self.newsLabel = ISLabel:new(self.width / 2, 40, 15, "", 1, 0.7, 0.7, 0.7, UIFont.Small, true)
    self.newsLabel.center = true
    self:addChild(self.newsLabel)

    -- 3. MODE SWITCH BUTTON (Top Right)
    self.switchModeBtn = ISButton:new(self.width - 110, 15, 100, 20, "SELL ITEMS", self, self.onToggleMode)
    self.switchModeBtn:initialise()
    self.switchModeBtn:setAnchorRight(true)
    self.switchModeBtn:setAnchorLeft(false)
    self.switchModeBtn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
    self.switchModeBtn.borderColor = {r=1, g=1, b=1, a=0.3}
    self:addChild(self.switchModeBtn)

    -- 4. SCROLLING LISTBOX
    self.listbox = ISScrollingListBox:new(10, 65, self.width - 20, self.height - 115)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    -- Custom Draw Function for list items
    self.listbox.doDrawItem = self.drawListItem
    
    -- Mouse Click Handler (for Category collapsing)
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
    
    -- 5. ACTION BUTTON (Bottom Right)
    self.actionButton = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY ITEM", self, self.onActionClick)
    self.actionButton:initialise()
    self.actionButton:setAnchorTop(false)
    self.actionButton:setAnchorBottom(true)
    self.actionButton:setAnchorRight(true)
    self.actionButton:setAnchorLeft(false)
    self:addChild(self.actionButton)

    -- 6. FOOTER LABEL (Restock Info)
    self.restockLabel = ISLabel:new(10, self.height - 30, 16, "Restock: ???", 1, 1, 1, 0.5, UIFont.Small, true)
    self.restockLabel:setAnchorTop(false)
    self.restockLabel:setAnchorBottom(true)
    self:addChild(self.restockLabel)

    -- Initial Population
    self:populateList()
end

-- =================================================
-- TOGGLE LOGIC (Buy <-> Sell)
-- =================================================
function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    
    if self.isBuying then
        self.switchModeBtn.title = "SELL ITEMS"
    else
        self.switchModeBtn.title = "BUY ITEMS"
    end
    
    -- Reset selection
    self.listbox.selected = -1
    self:populateList()
end

-- =================================================
-- PRE-RENDER (Button State Updates)
-- =================================================
function DynamicTradingUI:prerender()
    ISCollapsableWindow.prerender(self)
    
    local selection = self.listbox.selected
    local canDo = false
    local label = "SELECT"
    local btnColor = {r=0.2, g=0.2, b=0.2}
    
    if selection > 0 then
        local itemObj = self.listbox.items[selection]
        if itemObj and itemObj.item and not itemObj.item.isCategory then
            local data = itemObj.item
            
            if self.isBuying then
                -- === BUY MODE VALIDATION ===
                label = "BUY"
                local player = getSpecificPlayer(0)
                local inv = player:getInventory()
                local wealth = inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
                
                if data.stock <= 0 then
                    label = "SOLD OUT"
                    btnColor = {r=0.6, g=0.1, b=0.1}
                elseif wealth < data.price then
                    label = "NEED $" .. data.price
                    btnColor = {r=0.6, g=0.1, b=0.1}
                else
                    canDo = true
                    btnColor = {r=0.1, g=0.5, b=0.1}
                end
            else
                -- === SELL MODE VALIDATION ===
                label = "SELL"
                if data.itemObj then
                     canDo = true
                     btnColor = {r=0.1, g=0.5, b=0.1}
                end
            end
        end
    end

    self.actionButton.title = label
    self.actionButton:setEnable(canDo)
    self.actionButton.backgroundColor = {r=btnColor.r, g=btnColor.g, b=btnColor.b, a=1}
    self.actionButton.textColor = {r=1, g=1, b=1, a=1}
end

-- =================================================
-- ACTION CLICK (Buy or Sell)
-- =================================================
function DynamicTradingUI:onActionClick()
    local selection = self.listbox.selected
    if selection < 1 then return end
    
    local itemObj = self.listbox.items[selection]
    if not itemObj or not itemObj.item or itemObj.item.isCategory then return end
    
    local data = itemObj.item
    local player = getSpecificPlayer(0)
    
    if self.isBuying then
        -- Execute Buy
        if DynamicTrading.Shared.PerformTrade then
            DynamicTrading.Shared.PerformTrade(player, data.key)
        end
    else
        -- Execute Sell
        if DynamicTrading.Shared.PerformSell then
            DynamicTrading.Shared.PerformSell(player, data.itemObj, data.price, data.key)
        end
    end
end

-- =================================================
-- DRAW LIST ITEM (Visuals)
-- =================================================
function DynamicTradingUI:drawListItem(y, item, alt)
    if not item.height then item.height = self.itemheight end
    
    -- === 1. DRAW CATEGORY HEADER ===
    if item.item.isCategory then
        self:drawRect(0, y, self:getWidth(), item.height, 0.85, 0.15, 0.15, 0.15)
        self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, 0.6, 0.6, 0.6)
        
        local prefix = DynamicTradingUI.instance.collapsed[item.item.categoryName] and "[+] " or "[-] "
        self:drawText(prefix .. item.text, 20, y + (item.height - 18)/2, 1, 0.9, 0.4, 1, UIFont.Medium)
        return y + item.height
    end

    -- === 2. DRAW PRODUCT ITEM ===
    local data = item.item
    
    -- Background
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.2, 0.3, 0.3, 0.3)
    end
    
    -- Sold Out Background Overlay
    if self.isBuying and data.stock <= 0 then
         self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.1, 0.0, 0.0) 
    end
    
    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.1, 1, 1, 1)

    -- === ICON DRAWING (FIXED CRASH) ===
    if data.icon then
        local tex = nil
        
        -- CHECK TYPE TO PREVENT CRASH
        if type(data.icon) == "string" then
            -- It's a name (e.g., "Axe"), try loading texture
            tex = getTexture("Item_" .. data.icon)
            if not tex then tex = getTexture(data.icon) end
        else
            -- It's already a Texture Object (Userdata/Table)
            tex = data.icon
        end
        
        if tex then 
            self:drawTextureScaled(tex, 6, y + (item.height - 28)/2, 28, 28, 1, 1, 1, 1) 
        end
    end

    -- Name
    local nameColor = {r=0.9, g=0.9, b=0.9}
    if self.isBuying and data.stock <= 0 then nameColor = {r=0.6, g=0.6, b=0.6} end
    self:drawText(data.name, 45, y + (item.height - 15)/2, nameColor.r, nameColor.g, nameColor.b, 1, self.font)
    
    if self.isBuying then
        -- === BUY MODE VISUALS ===
        self:drawText("$" .. data.price, self:getWidth() - 60, y + (item.height - 15)/2, 1, 1, 1, 1, self.font)
        
        local stockTxt = "Qty: " .. data.stock
        local stockColor = {r=0.8, g=0.8, b=0.8}
        
        if data.stock <= 0 then
            stockTxt = "SOLD OUT"
            stockColor = {r=1.0, g=0.2, b=0.2}
        end
        
        self:drawText(stockTxt, self:getWidth() - 140, y + (item.height - 15)/2, stockColor.r, stockColor.g, stockColor.b, 1, self.font)
        
    else
        -- === SELL MODE VISUALS ===
        local priceTxt = "+$" .. data.price
        local priceColor = {r=0.4, g=1.0, b=0.4}
        
        if data.isOverstocked then
            priceColor = {r=1.0, g=0.6, b=0.6}
        end
        self:drawText(priceTxt, self:getWidth() - 60, y + (item.height - 15)/2, priceColor.r, priceColor.g, priceColor.b, 1, self.font)
        
        if data.cond then
            self:drawText(data.cond, self:getWidth() - 120, y + (item.height - 15)/2, 0.6, 0.6, 0.6, 1, self.font)
        end
        
        if data.isOverstocked then
             self:drawText("(Low Demand)", self:getWidth() - 220, y + (item.height - 15)/2, 1, 0.5, 0.5, 1, self.font)
        end
    end

    return y + item.height
end

-- =================================================
-- POPULATE LIST (Data Fetching)
-- =================================================
function DynamicTradingUI:populateList()
    local savedSelectionKey = nil
    if self.listbox.selected > 0 then
        local item = self.listbox.items[self.listbox.selected]
        if item and item.item and not item.item.isCategory then
            if self.isBuying then savedSelectionKey = item.item.key
            else savedSelectionKey = item.item.itemObj end
        end
    end

    self.listbox:clear()
    
    if not DynamicTrading or not DynamicTrading.Shared then return end
    
    local data = DynamicTrading.Shared.GetData()
    local masterList = DynamicTrading.Config.MasterList
    if not masterList or not data then return end
    
    local merchantName = data.currentMerchant or "Unknown"

    -- HEADER UPDATE
    if self.isBuying then
        self.merchantHeader:setName("BUY FROM: " .. string.upper(merchantName))
    else
        self.merchantHeader:setName("SELL TO: " .. string.upper(merchantName))
    end
    
    -- RUMORS
    local rumorText = "The market is stable."
    if DynamicTrading.Events and DynamicTrading.Events.GetActiveState then
        local state = DynamicTrading.Events.GetActiveState({})
        if state.rumors and #state.rumors > 0 then
            rumorText = state.rumors[ZombRand(#state.rumors) + 1]
        end
    end
    self.newsLabel:setName(rumorText)
    
    -- RESTOCK TIME
    local gt = GameTime:getInstance()
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    local last = data.lastResetDay or 0
    local daysLeft = (last + interval) - math.floor(gt:getDaysSurvived())
    if daysLeft < 1 then daysLeft = 1 end
    self.restockLabel:setName("Next Restock: " .. daysLeft .. " day(s)")

    -- BUILD LIST
    local categorized = {}
    local categories = {} 
    
    if self.isBuying then
        -- === BUY MODE ===
        if data.stocks then
            for key, stockQty in pairs(data.stocks) do
                local config = masterList[key]
                if config then
                    local cat = config.category or "Misc"
                    if not categorized[cat] then categorized[cat] = {}; table.insert(categories, cat) end
                    
                    local itemName = config.item
                    local scriptItem = ScriptManager.instance:getItem(config.item)
                    local icon = "Question_On"
                    
                    if scriptItem then 
                        itemName = scriptItem:getDisplayName()
                        icon = scriptItem:getIcon()
                    else
                        local _, _, n = string.find(config.item, "%.(%w+)")
                        if n then itemName = n end
                    end

                    table.insert(categorized[cat], {
                        key = key,
                        name = itemName,
                        stock = stockQty,
                        price = data.prices[key] or config.basePrice,
                        icon = icon,
                        isCategory = false
                    })
                end
            end
        end
    else
        -- === SELL MODE ===
        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        local soldCounts = data.buyHistory or {}

        for i=0, items:size()-1 do
            local item = items:get(i)
            local fullType = item:getFullType()
            
            -- Matching
            local masterKey, masterData
            for k,v in pairs(masterList) do
                if v.item == fullType then 
                    masterKey = k; masterData = v; break 
                end
            end
            
            if masterData then
                local currentSold = soldCounts[masterKey] or 0
                local price = 0
                local limit = 999
                
                if DynamicTrading.Economy then
                    price = DynamicTrading.Economy.CalculateSellPrice(item, masterData, merchantName, currentSold)
                    limit = DynamicTrading.Economy.GetDemandLimit(masterKey, merchantName)
                end
                
                if price > 0 then
                    local cat = masterData.category or "Misc"
                    if not categorized[cat] then categorized[cat] = {}; table.insert(categories, cat) end
                    
                    local condStr = nil
                    if item:IsDrainable() or item:isBroken() then
                         local p = math.floor((item:getCondition() / item:getConditionMax()) * 100)
                         condStr = p .. "%"
                    end
                    
                    -- Use getTex() here to be safe, but fallback to getIcon if getTex returns null
                    local visualIcon = item:getTex() 
                    if not visualIcon then visualIcon = item:getIcon() end

                    table.insert(categorized[cat], {
                        key = masterKey,
                        name = item:getDisplayName(),
                        price = price,
                        icon = visualIcon, -- Pass the texture object or string
                        itemObj = item,
                        cond = condStr,
                        isOverstocked = (currentSold >= limit),
                        isCategory = false
                    })
                end
            end
        end
    end
    
    -- RENDER
    table.sort(categories)

    for _, catName in ipairs(categories) do
        local hItem = self.listbox:addItem(string.upper(catName), nil)
        hItem.item = { isCategory = true, text = string.upper(catName), categoryName = catName }
        hItem.height = 30
        
        if not self.collapsed[catName] then
            table.sort(categorized[catName], function(a,b) return a.name < b.name end)
            
            for _, product in ipairs(categorized[catName]) do
                local item = self.listbox:addItem(product.name, nil)
                item.item = product
            end
        end
    end

    -- RESTORE SELECTION
    if savedSelectionKey then
        for i, item in ipairs(self.listbox.items) do
            if item.item then
                local match = false
                if self.isBuying and item.item.key == savedSelectionKey then match = true end
                if not self.isBuying and item.item.itemObj == savedSelectionKey then match = true end
                if match then self.listbox.selected = i; break end
            end
        end
    end
end

-- =================================================
-- HELPER: TOGGLE WINDOW
-- =================================================
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