require "DT/Common/UI/Trading/DT_TradingItemUtils"

function DT_TradingWindow.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()
    local ui = DT_TradingWindow.instance

    -- 1. DRAW CATEGORY HEADER
    if d.isCategory then
        listbox:drawRect(0, y, width, height, 0.9, 0.1, 0.1, 0.1)
        listbox:drawRectBorder(0, y, width, height, 0.3, 0.5, 0.5, 0.5)

        local isCol = ui and ui.collapsed[d.categoryName]
        local prefix = isCol and "[+] " or "[-] "

        listbox:drawText(prefix .. d.text, 10, y + (height/2) - 7, 1, 0.8, 0.3, 1, UIFont.Medium)
        return y + height
    end

    -- 2. LOCK CHECK
    local isLocked = false
    if ui and ui.isItemLocked and d.itemID then
        isLocked = ui:isItemLocked(d.itemID)
    end

    -- 3. DRAW LIST ITEM (BACKGROUND)
    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif isLocked then
        listbox:drawRect(0, y, width, height, 0.4, 0.1, 0.1, 0.1)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end

    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- 4. DRAW ICON
    local invItem = d.invItem -- [PERFORMANCE] Use cached reference
    
    local tex = DT_TradingWindow.GetItemTexture(d.data.item, invItem)

    if tex then
        local alpha = isLocked and 0.4 or 1.0
        listbox:drawTextureScaled(tex, 6, y + 4, 32, 32, alpha, 1, 1, 1)
    end

    -- 5. DRAW NAME & STATUS
    local nameColor = {r=0.9, g=0.9, b=0.9}
    if isLocked then
        nameColor = {r=0.5, g=0.5, b=0.5}
    elseif d.isBuy and (tonumber(d.qty) or 0) <= 0 then
        nameColor = {r=0.5, g=0.5, b=0.5}
    end

    -- Use Pre-calculated values by default
    local statusSuffix = d.statusSuffix or ""
    local isRotten = d.isRotten or false
    local itemName = d.displayName or d.name or "Unknown Item"

    -- [DYNAMIC UPDATE] Live Refresh for Owned Items
    -- Allows liquids/durability to update instantly without full list rebuilds
    if invItem then
        local scriptItem = d.scriptItem or getScriptManager():getItem(d.data.item)
        if scriptItem then
            statusSuffix, isRotten = DT_TradingItemUtils.getStatusSuffix(d, invItem, scriptItem)
            itemName = DT_TradingItemUtils.getItemDisplayName(d, invItem, scriptItem)
        end
    end
    
    if isRotten then
        nameColor = {r=0.8, g=0.3, b=0.3}
    end

    local finalName = itemName .. statusSuffix
    local maxNameWidth = width - 210
    local displayName = DT_TradingWindow.TruncateString(finalName, listbox.font, maxNameWidth)
    listbox:drawText(displayName, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)

    -- [NEW] DRAW TAGS ON HIGHLIGHT
    if listbox.selected == item.index and d.data and d.data.tags then
        local tagsStr = table.concat(d.data.tags, ", ")
        local maxTagWidth = width - 180
        local displayTags = DT_TradingWindow.TruncateString(tagsStr, UIFont.Small, maxTagWidth)
        listbox:drawText(displayTags, 45, y + 24, 0.4, 0.7, 0.9, 1, UIFont.Small)
    end

    if isLocked then
        local nameWid = TextManager.instance:MeasureStringX(listbox.font, displayName)
        listbox:drawText("(LOCKED)", 50 + nameWid, y + 12, 1, 0.2, 0.2, 1, listbox.font)
    end

    -- 6. PRICE COLORING
    local priceR, priceG, priceB = DT_TradingItemUtils.getPriceColors(d, isLocked)

    -- 7. STOCK DISPLAY
    if d.isBuy then
        local qty = tonumber(d.qty) or 0
        if qty <= 0 then
            listbox:drawText("(SOLD OUT)", width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText("Stock: " .. qty, width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        end
    end

    -- [DYNAMIC UPDATE] Live Price Recalculation
    local displayPrice = d.price
    if invItem and ui and ui.dataProvider and ui.traderID then
        local trader = ui.dataProvider:getTrader(ui.traderID, ui.archetype)
        if trader then
            displayPrice = ui.dataProvider:getSellPrice(invItem, d.key, trader)
        end
    end

    listbox:drawText("$" .. displayPrice, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)

    return y + height
end

function DT_TradingWindow:populateList()
    local oldScroll = self.listbox:getYScroll()
    self.listbox:clear()
    
    -- [NEW] Rejection Tracking
    self.scanRejections = {}

    local dataProvider = self.dataProvider
    if not dataProvider or not self.traderID then return end

    local trader = dataProvider:getTrader(self.traderID, self.archetype)
    if not trader then return end

    self:updateIdentityDisplay(trader)
    self:updateWallet()

    local categorized = {}
    local categories = {}

    -- SCAN DATA USING UTILITY
    if self.isBuying then
        DT_TradingItemUtils.scanBuyableItems(trader, dataProvider, categorized, categories, self.scanRejections)
    else
        local player = getSpecificPlayer(0)
        local activeRadioID = -1
        if self.radioObj and instanceof(self.radioObj, "InventoryItem") then
            activeRadioID = self.radioObj:getID()
        end
        DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, self.scanRejections)
    end

    -- BUILD THE LISTBOX
    table.sort(categories)
    for _, catName in ipairs(categories) do
        local itemsInCat = categorized[catName]
        if itemsInCat and #itemsInCat > 0 then
            local header = self.listbox:addItem(string.upper(catName), {isCategory = true})
            header.item = {isCategory = true, categoryName = catName, text = string.upper(catName)}
            header.height = 32

            if not self.collapsed[catName] then
                table.sort(itemsInCat, function(a, b) return a.name < b.name end)
                for _, prod in ipairs(itemsInCat) do
                    self.listbox:addItem(prod.name, prod)
                end
            end
        end
    end

    -- RESTORE SELECTION & BUTTON LOGIC
    local foundValidSelection = false
    
    if self.selectedKey then
        local targetIndex = -1
        for i = 1, #self.listbox.items do
            local listItem = self.listbox.items[i]
            if listItem.item and not listItem.item.isCategory and listItem.item.key == self.selectedKey then
                targetIndex = i
                break
            end
        end

        if targetIndex ~= -1 then
            local checkItem = self.listbox.items[targetIndex].item
            local isLocked = false
            if self.isItemLocked then
                isLocked = self:isItemLocked(checkItem.itemID)
            end

            if not isLocked then
                self.listbox.selected = targetIndex
                foundValidSelection = true
            else
                for i = targetIndex + 1, #self.listbox.items do
                    local nextItem = self.listbox.items[i].item
                    if nextItem and not nextItem.isCategory and not self:isItemLocked(nextItem.itemID) then
                        self.listbox.selected = i
                        self.selectedKey = nextItem.key
                        self.selectedItemID = nextItem.itemID
                        foundValidSelection = true
                        break
                    end
                end
            end
        end
    end

    -- Final Visual State update
    if foundValidSelection then
        local sel = self.listbox.items[self.listbox.selected].item
        local actionStr = self.isBuying and "BUY" or "SELL"
        self.btnAction:setTitle(actionStr .. " ($" .. sel.price .. ")")
        
        if self.isBuying then
            self.btnAction:setEnable(sel.qty > 0)
        else
            local isCurrentlyLocked = false
            if self.isItemLocked then isCurrentlyLocked = self:isItemLocked(sel.itemID) end
            
            if isCurrentlyLocked then
                self.btnLock:setTitle("UNLOCK ITEM")
                self.btnAction:setEnable(false)
            else
                self.btnLock:setTitle("LOCK ITEM")
                self.btnAction:setEnable(true)
            end
        end
    else
        self.listbox.selected = -1
        self.selectedKey = nil
        self.selectedItemID = -1
        self.btnAction:setEnable(false)
        self.btnAction:setTitle("SELECT AN ITEM")
        if self.btnLock then self.btnLock:setTitle("LOCK ITEM") end
    end

    self.listbox:setYScroll(oldScroll)
end
