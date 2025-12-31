require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Config"

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

-- =================================================
-- INITIALIZATION
-- =================================================
function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Market Trading")
    self:setResizable(false)
    
    self.collapsed = {}     
    self.isBuying = true    
    
    self.drawFrame = true
    self.backgroundColor = {r=0, g=0, b=0, a=0.9}
    self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
end

-- =================================================
-- CREATE CHILDREN
-- =================================================
function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- HEADER
    self.merchantHeader = ISLabel:new(self.width / 2, 18, 20, "TRADER", 1, 0.9, 0.9, 0.9, UIFont.Medium, true)
    self.merchantHeader:setAnchorTop(true)
    self.merchantHeader.center = true
    self:addChild(self.merchantHeader)
    
    -- NEWS TICKER
    self.newsLabel = ISLabel:new(self.width / 2, 40, 15, "", 1, 0.7, 0.7, 0.7, UIFont.Small, true)
    self.newsLabel.center = true
    self:addChild(self.newsLabel)

    -- SWITCH BUTTON
    self.switchModeBtn = ISButton:new(self.width - 110, 15, 100, 20, "SELL ITEMS", self, self.onToggleMode)
    self.switchModeBtn:initialise()
    self.switchModeBtn:setAnchorRight(true)
    self:addChild(self.switchModeBtn)

    -- LISTBOX
    self.listbox = ISScrollingListBox:new(10, 65, self.width - 20, self.height - 115)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    -- Assign Static Draw Function to prevent 'self' loss
    self.listbox.doDrawItem = DynamicTradingUI.drawItem
    
    -- CLICK HANDLING
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
    
    -- ACTION BUTTON
    self.actionButton = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY ITEM", self, self.onActionClick)
    self.actionButton:initialise()
    self.actionButton:setAnchorTop(false)
    self.actionButton:setAnchorBottom(true)
    self.actionButton:setAnchorRight(true)
    self:addChild(self.actionButton)

    -- FOOTER
    self.restockLabel = ISLabel:new(10, self.height - 30, 16, "Restock: ???", 1, 1, 1, 0.5, UIFont.Small, true)
    self.restockLabel:setAnchorTop(false)
    self.restockLabel:setAnchorBottom(true)
    self:addChild(self.restockLabel)

    self:populateList()
end

-- =================================================
-- LOGIC: WEALTH HELPER
-- =================================================
function DynamicTradingUI:getPlayerWealth(player)
    if not player then return 0 end
    local inv = player:getInventory()
    local money = inv:getItemCount("Base.Money")
    local bundles = inv:getItemCount("Base.MoneyBundle")
    return money + (bundles * 100)
end

-- =================================================
-- LOGIC: ACTION HANDLER
-- =================================================
function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self.switchModeBtn.title = self.isBuying and "SELL" or "BUY"
    self.listbox.selected = -1
    self:populateList()
end

function DynamicTradingUI:onActionClick()
    -- FIX: Ensure selection is a number and floored (integer)
    local selection = math.floor(tonumber(self.listbox.selected) or -1)
    if selection < 1 then return end
    
    local itemObj = self.listbox.items[selection]
    -- Validate selection
    if not itemObj or not itemObj.item or itemObj.item.isCategory or itemObj.item.isEmptyMessage then return end
    
    local data = itemObj.item
    local player = getSpecificPlayer(0)
    
    if self.isBuying then
        if DynamicTrading.Shared.PerformTrade then
            DynamicTrading.Shared.PerformTrade(player, data.key, data.price, data.name)
        end
    else
        if DynamicTrading.Shared.PerformSell then
            DynamicTrading.Shared.PerformSell(player, data.itemObj, data.price, data.key, data.name)
        end
    end
end

-- =================================================
-- LOGIC: PRERENDER
-- =================================================
function DynamicTradingUI:prerender()
    ISCollapsableWindow.prerender(self)
    
    -- FIX: Ensure selection is a number
    local selection = math.floor(tonumber(self.listbox.selected) or -1)
    local canDo = false
    local label = "SELECT"
    local btnColor = {r=0.2, g=0.2, b=0.2}
    local txtColor = {r=1, g=1, b=1}

    if selection and selection > 0 then
        local itemObj = self.listbox.items[selection]
        
        if itemObj and itemObj.item then
            if itemObj.item.isCategory then
                label = "CATEGORY"
            elseif itemObj.item.isEmptyMessage then
                label = "EMPTY"
            else
                local data = itemObj.item
                local player = getSpecificPlayer(0)
                
                if self.isBuying then
                    -- === BUY MODE ===
                    local wealth = self:getPlayerWealth(player)
                    
                    if data.stock <= 0 then
                        label = "SOLD OUT"
                        btnColor = {r=0.3, g=0.3, b=0.3} 
                        txtColor = {r=0.7, g=0.7, b=0.7}
                    elseif wealth < data.price then
                        local missing = data.price - wealth
                        label = "MISSING $" .. missing
                        btnColor = {r=0.8, g=0.1, b=0.1} -- Red
                        txtColor = {r=1, g=1, b=1}       
                    else
                        label = "BUY"
                        canDo = true
                        btnColor = {r=0.1, g=0.6, b=0.1} -- Green
                    end
                else
                    -- === SELL MODE ===
                    label = "SELL"
                    if data.itemObj then
                         canDo = true
                         btnColor = {r=0.1, g=0.6, b=0.1} -- Green
                    end
                end
            end
        end
    end

    self.actionButton.title = label
    self.actionButton:setEnable(canDo)
    self.actionButton.backgroundColor = {r=btnColor.r, g=btnColor.g, b=btnColor.b, a=1}
    self.actionButton.textColor = {r=txtColor.r, g=txtColor.g, b=txtColor.b, a=1}
end

-- =================================================
-- DRAW HELPERS
-- =================================================
function DynamicTradingUI.truncateText(listbox, text, maxWidth)
    if not text then return "" end
    local tm = getTextManager()
    if tm:MeasureStringX(listbox.font, text) <= maxWidth then return text end
    
    while tm:MeasureStringX(listbox.font, text .. "...") > maxWidth and string.len(text) > 0 do
        text = string.sub(text, 1, -2)
    end
    return text .. "..."
end

-- =================================================
-- DRAW FUNCTION (Static Method)
-- =================================================
function DynamicTradingUI.drawItem(listbox, y, item, alt)
    if not listbox or not item then return end -- CRASH PROTECTION
    
    local height = item.height
    local width = listbox:getWidth()
    local data = item.item
    
    -- FIX: Safe Index Comparison for the crash fix
    local isSelected = (math.floor(tonumber(listbox.selected) or -1) == item.index)

    -- 1. EMPTY MESSAGE
    if data.isEmptyMessage then
        listbox:drawRect(0, y, width, height, 0.1, 0.1, 0.1, 0.5)
        listbox:drawTextCentre("NO ITEMS TO SELL", width/2, y + (height/2) - 8, 0.6, 0.6, 0.6, 1, UIFont.Medium)
        return y + height
    end

    -- 2. CATEGORY
    if data.isCategory then
        listbox:drawRect(0, y, width, height, 0.85, 0.15, 0.15, 0.15)
        listbox:drawRectBorder(0, y, width, height, 0.5, 0.6, 0.6, 0.6)
        
        local ui = DynamicTradingUI.instance
        local prefix = (ui and ui.collapsed[data.categoryName]) and "[+] " or "[-] "
        listbox:drawText(prefix .. item.text, 20, y + (height - 18)/2, 1, 0.9, 0.4, 1, UIFont.Medium)
        return y + height
    end

    -- 3. PRODUCT
    -- Draw Background
    if isSelected then
        listbox:drawRect(0, y, width, height-1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        listbox:drawRect(0, y, width, height-1, 0.2, 0.3, 0.3, 0.3)
    end
    
    -- Overlay if Sold Out (Buy Mode)
    local ui = DynamicTradingUI.instance
    local isBuyMode = ui and ui.isBuying or false
    
    if isBuyMode and data.stock <= 0 then
         listbox:drawRect(0, y, width, height-1, 0.3, 0.1, 0.0, 0.0) 
    end
    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- Icon
    if data.icon then
        local tex = nil
        if type(data.icon) == "string" then
            tex = getTexture("Item_" .. data.icon) or getTexture(data.icon)
        else
            tex = data.icon
        end
        if tex then 
            listbox:drawTextureScaled(tex, 6, y + (height - 28)/2, 28, 28, 1, 1, 1, 1) 
        end
    end

    -- Name Truncation
    local availWidth = width - 220 
    local name = DynamicTradingUI.truncateText(listbox, data.name or "Unknown", availWidth)
    
    local nameR, nameG, nameB = 0.9, 0.9, 0.9
    if isBuyMode and data.stock <= 0 then nameR, nameG, nameB = 0.6, 0.6, 0.6 end
    
    listbox:drawText(name, 45, y + (height - 15)/2, nameR, nameG, nameB, 1, listbox.font)

    -- Right Side Info
    if isBuyMode then
        -- BUY MODE DISPLAY
        local pColor = (data.stock <= 0) and {0.6, 0.6, 0.6} or {1, 1, 1}
        listbox:drawText("$" .. data.price, width - 60, y + (height - 15)/2, pColor[1], pColor[2], pColor[3], 1, listbox.font)

        local stockTxt = "Qty: " .. data.stock
        local sR, sG, sB = 0.8, 0.8, 0.8
        if data.stock <= 0 then
            stockTxt = "SOLD OUT"
            sR, sG, sB = 1.0, 0.2, 0.2
        end
        listbox:drawText(stockTxt, width - 130, y + (height - 15)/2, sR, sG, sB, 1, listbox.font)
    else
        -- SELL MODE DISPLAY
        local priceColor = {r=0.4, g=1.0, b=0.4} 
        if data.isOverstocked then priceColor = {r=1.0, g=0.6, b=0.6} end 
        listbox:drawText("+$" .. data.price, width - 60, y + (height - 15)/2, priceColor.r, priceColor.g, priceColor.b, 1, listbox.font)

        if data.cond then
            listbox:drawText(data.cond, width - 120, y + (height - 15)/2, 0.6, 0.6, 0.6, 1, listbox.font)
        end
        if data.isOverstocked then
             listbox:drawText("(Low Demand)", width - 220, y + (height - 15)/2, 1, 0.5, 0.5, 1, listbox.font)
        end
    end

    return y + height
end

-- =================================================
-- POPULATION MAIN
-- =================================================
function DynamicTradingUI:populateList()
    local savedSelectionKey = nil
    
    -- FIX: Robustly capture the saved selection key
    local selIndex = math.floor(tonumber(self.listbox.selected) or -1)
    
    if selIndex > 0 and self.listbox.items and self.listbox.items[selIndex] then
        local item = self.listbox.items[selIndex]
        if item and item.item and not item.item.isCategory and not item.item.isEmptyMessage then
            if self.isBuying then 
                savedSelectionKey = item.item.key
            else 
                savedSelectionKey = item.item.itemObj 
            end
        end
    end

    self.listbox:clear()
    
    if not DynamicTrading or not DynamicTrading.Shared then return end
    local data = DynamicTrading.Shared.GetData()
    if not data then return end
    
    local merchantName = data.currentMerchant or "Unknown"

    local gt = GameTime:getInstance()
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    local last = data.lastResetDay or 0
    local daysLeft = (last + interval) - math.floor(gt:getDaysSurvived())
    local timeTxt = "in " .. daysLeft .. " day(s)"
    if daysLeft <= 1 then timeTxt = "Tomorrow" end 
    self.restockLabel:setName("Restock: " .. timeTxt)

    local rumorText = "The market is stable."
    if DynamicTrading.Events and DynamicTrading.Events.GetActiveState then
        local state = DynamicTrading.Events.GetActiveState({})
        if state.rumors and #state.rumors > 0 then
            rumorText = state.rumors[ZombRand(#state.rumors) + 1]
        end
    end
    self.newsLabel:setName(rumorText)

    if self.isBuying then
        self.merchantHeader:setName("-" .. string.upper(merchantName))
        self:populateBuyList(data, savedSelectionKey)
    else
        self.merchantHeader:setName("+" .. string.upper(merchantName))
        self:populateSellList(data, savedSelectionKey)
    end
end

-- =================================================
-- POPULATE HELPERS (Uniform Height = 40)
-- =================================================
function DynamicTradingUI:populateBuyList(data, savedKey)
    if not data.stocks then return end
    local categorized = {}
    local categories = {} 

    -- Get Wealth for Validation (Required to decide if we keep selection)
    local player = getSpecificPlayer(0)
    local wealth = self:getPlayerWealth(player)

    for key, stockQty in pairs(data.stocks) do
        local config = DynamicTrading.Config.MasterList[key]
        if config then
            local cat = config.category or "Misc"
            if not categorized[cat] then categorized[cat] = {}; table.insert(categories, cat) end
            
            local itemName = config.item
            local scriptItem = ScriptManager.instance:getItem(config.item)
            local icon = "Question_On"
            if scriptItem then 
                itemName = scriptItem:getDisplayName()
                icon = scriptItem:getIcon()
            end

            table.insert(categorized[cat], {
                key = key,
                name = itemName,
                stock = stockQty or 0, 
                price = data.prices[key] or config.basePrice,
                icon = icon,
                isCategory = false
            })
        end
    end

    -- FEATURE: Keep selected only if Buyable (Stock > 0 AND Enough Money)
    self:insertCategories(categories, categorized, function(item) 
        if item.key == savedKey then
            if item.stock > 0 and wealth >= item.price then
                return true -- Keep Selected
            end
        end
        return false -- Deselect
    end)
end

function DynamicTradingUI:populateSellList(data, savedKey)
    local masterList = DynamicTrading.Config.MasterList
    local player = getSpecificPlayer(0)
    local inv = player:getInventory()
    local items = inv:getItems()
    local soldCounts = data.buyHistory or {}

    local categorized = {}
    local categories = {} 
    local foundAny = false
    
    local typeMap = {}
    for k, v in pairs(masterList) do typeMap[v.item] = { key=k, data=v } end

    for i=0, items:size()-1 do
        local item = items:get(i)
        local mapRef = typeMap[item:getFullType()]
        
        if mapRef then
            local masterKey = mapRef.key
            local masterData = mapRef.data
            local currentSold = soldCounts[masterKey] or 0
            
            local price = 0
            if DynamicTrading.Economy then
                price = DynamicTrading.Economy.CalculateSellPrice(item, masterData, data.currentMerchant, currentSold)
            end

            if price > 0 then
                foundAny = true
                local cat = masterData.category or "Misc"
                if not categorized[cat] then categorized[cat] = {}; table.insert(categories, cat) end
                
                local condStr = nil
                if item:IsDrainable() or item:isBroken() then
                     local p = math.floor((item:getCondition() / item:getConditionMax()) * 100)
                     condStr = p .. "%"
                end
                
                local visualIcon = item:getTex() 
                if not visualIcon then visualIcon = item:getIcon() end

                table.insert(categorized[cat], {
                    key = masterKey,
                    name = item:getDisplayName(),
                    price = price,
                    icon = visualIcon, 
                    itemObj = item,
                    cond = condStr,
                    isOverstocked = false, 
                    isCategory = false
                })
            end
        end
    end

    if not foundAny then
        local item = self.listbox:addItem("Empty", nil)
        item.item = { isEmptyMessage = true }
        item.height = 40 -- Uniform Height
    else
        self:insertCategories(categories, categorized, function(item) return item.itemObj == savedKey end)
    end
end

function DynamicTradingUI:insertCategories(categories, categorized, selectionCheck)
    table.sort(categories)
    for _, catName in ipairs(categories) do
        local hItem = self.listbox:addItem(string.upper(catName), nil)
        hItem.item = { isCategory = true, text = string.upper(catName), categoryName = catName }
        hItem.height = 40 -- UNIFORM HEIGHT FIX
        
        if not self.collapsed[catName] then
            table.sort(categorized[catName], function(a,b) return a.name < b.name end)
            for _, product in ipairs(categorized[catName]) do
                local item = self.listbox:addItem(product.name, nil)
                item.item = product
                item.height = 40 -- UNIFORM HEIGHT FIX
                
                if selectionCheck and selectionCheck(product) then
                    -- FIX: Force index to be a number. This fixes the __lt error.
                    self.listbox.selected = math.floor(tonumber(item.index) or -1)
                end
            end
        end
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