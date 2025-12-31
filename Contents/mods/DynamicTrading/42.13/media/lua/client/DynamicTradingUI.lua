require "ISUI/ISCollapsableWindow"
require "DynamicTrading_Config" -- FORCE LOAD CONFIGURATION

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Market Prices")
    self:setResizable(false)
    self.collapsed = {} 
end

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. MERCHANT HEADER
    self.merchantHeader = ISLabel:new(self.width / 2, 20, 20, "TRADER: ???", 1, 0.8, 0.4, 1, UIFont.Medium, true)
    self.merchantHeader:setAnchorTop(true)
    self.merchantHeader:setAnchorBottom(false)
    self:addChild(self.merchantHeader)

    -- 2. LISTBOX SETUP
    self.listbox = ISScrollingListBox:new(10, 50, self.width - 20, self.height - 80)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    self.listbox:addScrollBars(true)
    self.listbox.doDrawItem = self.drawListItem
    
    -- CLICK HANDLER
    self.listbox.onMouseDown = function(target, x, y)
        ISScrollingListBox.onMouseDown(target, x, y) 
        
        local row = target:rowAt(x, y)
        if row == -1 then return end
        
        local item = target.items[row]
        if item and item.item and item.item.isCategory then
            local cat = item.item.categoryName
            local ui = DynamicTradingUI.instance
            
            if ui.collapsed[cat] then
                ui.collapsed[cat] = false 
            else
                ui.collapsed[cat] = true  
            end
            
            ui:populateList() 
        end
    end
    
    self:addChild(self.listbox)
    
    -- 3. FOOTER
    self.restockLabel = ISLabel:new(10, self.height - 25, 16, "Next Restock: ???", 1, 1, 1, 0.5, UIFont.Small, true)
    self.restockLabel:setAnchorTop(false)
    self.restockLabel:setAnchorBottom(true)
    self:addChild(self.restockLabel)

    self:populateList()
end

-- =================================================
-- DRAW ITEM
-- =================================================
function DynamicTradingUI:drawListItem(y, item, alt)
    if not item.height then item.height = self.itemheight end

    -- === CASE 1: CATEGORY HEADER ===
    if item.item.isCategory then
        self:drawRect(0, y, self:getWidth(), item.height, 0.85, 0.15, 0.15, 0.15)
        self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, 0.6, 0.6, 0.6)
        
        local prefix = "[-] "
        if DynamicTradingUI.instance.collapsed[item.item.categoryName] then
            prefix = "[+] "
        end
        
        local fullText = prefix .. item.text
        local textWid = getTextManager():MeasureStringX(UIFont.Medium, fullText)
        self:drawText(fullText, (self:getWidth()/2) - (textWid/2), y + (item.height - 18)/2, 1, 0.9, 0.4, 1, UIFont.Medium)
        
        return y + item.height
    end

    -- === CASE 2: PRODUCT ITEM ===
    local data = item.item 
    
    -- SAFETY CHECK
    if not DynamicTrading.Config or not DynamicTrading.Config.MasterList then
        return y + item.height
    end

    local master = DynamicTrading.Config.MasterList[data.key]
    if not master then return y + item.height end

    -- Background Logic
    if data.stock <= 0 then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.6, 0.2, 0.0, 0.0) 
    elseif self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), item.height-1, 0.2, 0.3, 0.3, 0.3)
    end
    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.1, 1, 1, 1)

    -- Icon Logic
    local itemScript = ScriptManager.instance:getItem(master.item)
    if itemScript then
        local iconName = itemScript:getIcon()
        if iconName then
            local tex = getTexture("Item_" .. iconName)
            if not tex then tex = getTexture(iconName) end
            if tex then
                self:drawTextureScaled(tex, 6, y + (item.height - 28)/2, 28, 28, 1, 1, 1, 1)
            end
        end
    end

    -- Text Colors
    local nameR, nameG, nameB = 0.9, 0.9, 0.9
    local priceR, priceG, priceB = 1, 1, 1

    if data.stock <= 0 then
        nameR, nameG, nameB = 0.6, 0.6, 0.6
        priceR, priceG, priceB = 0.6, 0.6, 0.6
    else
        if data.price > master.basePrice * 1.15 then
            priceR, priceG, priceB = 1, 0.4, 0.4 
        elseif data.price < master.basePrice * 0.85 then
            priceR, priceG, priceB = 0.4, 1, 0.4 
        end

        if DynamicTrading.Economy and DynamicTrading.Economy.GetEnvironmentModifier then
            local envMod = DynamicTrading.Economy.GetEnvironmentModifier(master.tags or {})
            if envMod > 0.2 then
                nameR, nameG, nameB = 0.6, 0.8, 1.0 
            end
        end
    end

    -- === TEXT TRUNCATION LOGIC ===
    -- Calculate how much space we have for the name.
    -- Width - 45 (Icon padding) - 155 (Right side buffer for Qty/Price)
    local availableWidth = self:getWidth() - 200 
    local displayName = item.text
    local textManager = getTextManager()
    
    if textManager:MeasureStringX(self.font, displayName) > availableWidth then
        while textManager:MeasureStringX(self.font, displayName .. "...") > availableWidth and string.len(displayName) > 0 do
             displayName = string.sub(displayName, 1, -2) -- Remove last character
        end
        displayName = displayName .. "..."
    end

    -- Draw Name
    self:drawText(displayName, 45, y + (item.height - 15)/2, nameR, nameG, nameB, 1, self.font)
    
    -- Draw Price (Right Aligned)
    local priceText = "$" .. data.price
    self:drawText(priceText, self:getWidth() - 60, y + (item.height - 15)/2, priceR, priceG, priceB, 1, self.font)
    
    -- Draw Quantity / SOLD OUT (Right Aligned)
    if data.stock <= 0 then
        self:drawText("SOLD OUT", self:getWidth() - 145, y + (item.height - 15)/2, 1, 0.1, 0.1, 1, self.font)
    else
        local stockText = "Qty: " .. data.stock
        self:drawText(stockText, self:getWidth() - 130, y + (item.height - 15)/2, 0.8, 0.8, 0.8, 1, self.font)
    end

    return y + item.height
end

-- =================================================
-- POPULATE LIST
-- =================================================
function DynamicTradingUI:populateList()
    self.listbox:clear()
    
    -- CRITICAL SAFETY CHECK
    if not DynamicTrading or not DynamicTrading.Shared or not DynamicTrading.Config then
        print("[DynamicTradingUI] Warning: DynamicTrading not ready yet.")
        return
    end

    local data = DynamicTrading.Shared.GetData()
    local masterList = DynamicTrading.Config.MasterList
    
    if not masterList then
        print("[DynamicTradingUI] Warning: MasterList is empty or nil.")
        return
    end
    
    -- UPDATE HEADER TEXT
    local merchantName = data.currentMerchant or "Unknown Trader"
    if self.merchantHeader then
        self.merchantHeader:setName("TRADER: " .. string.upper(merchantName))
    end
    
    if not data.stocks then return end

    -- 1. Sort into Categories
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
            if scriptItem then 
                itemName = scriptItem:getDisplayName() 
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

    -- 2. Build List
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

    -- 3. Footer
    local gt = GameTime:getInstance()
    local interval = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RestockInterval or 1
    local currentDay = math.floor(gt:getDaysSurvived())
    local lastReset = data.lastResetDay or 0
    local nextDay = lastReset + interval
    local daysLeft = nextDay - currentDay
    
    if daysLeft <= 0 then daysLeft = 1 end
    
    local dateStr = "Tomorrow"
    if daysLeft > 1 then dateStr = "in " .. daysLeft .. " days" end
    
    if self.restockLabel then
        self.restockLabel:setName("Next Restock: " .. dateStr)
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