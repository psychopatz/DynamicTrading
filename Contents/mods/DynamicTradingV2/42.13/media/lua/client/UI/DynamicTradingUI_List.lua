function DynamicTradingUI.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()
    local ui = DynamicTradingUI.instance

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
    local scriptItem = getScriptManager():getItem(d.data.item)
    if scriptItem then
        local icon = scriptItem:getIcon()
        if icon then
            local tex = getTexture("Item_" .. icon) or getTexture(icon)
            if tex then
                local alpha = isLocked and 0.4 or 1.0
                listbox:drawTextureScaled(tex, 6, y + 4, 32, 32, alpha, 1, 1, 1)
            end
        end
    end

    -- 5. DRAW NAME & LOCK STATUS
    local nameColor = {r=0.9, g=0.9, b=0.9}
    if isLocked then
        nameColor = {r=0.5, g=0.5, b=0.5}
    elseif d.isBuy and (tonumber(d.qty) or 0) <= 0 then
        nameColor = {r=0.5, g=0.5, b=0.5}
    end

    local maxNameWidth = width - 210
    local displayName = DynamicTradingUI.TruncateString(d.name, listbox.font, maxNameWidth)
    listbox:drawText(displayName, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)

    if isLocked then
        local nameWid = TextManager.instance:MeasureStringX(listbox.font, displayName)
        listbox:drawText("(LOCKED)", 50 + nameWid, y + 12, 1, 0.2, 0.2, 1, listbox.font)
    end

    -- 6. PRICE COLORING
    local priceR, priceG, priceB = 0.6, 1.0, 0.6
    if isLocked then
        priceR, priceG, priceB = 0.4, 0.4, 0.4
    elseif d.isBuy then
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 end
        if d.priceMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 end
    else
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.8, 0.2 end
    end

    -- 7. STOCK DISPLAY
    if d.isBuy then
        local qty = tonumber(d.qty) or 0
        if qty <= 0 then
            listbox:drawText("(SOLD OUT)", width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText("Stock: " .. qty, width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        end
    end

    listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)

    return y + height
end

function DynamicTradingUI:populateList()
    local oldScroll = self.listbox:getYScroll()
    self.listbox:clear()

    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end

    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end

    self:updateIdentityDisplay(trader)
    self:updateWallet()

    local categorized = {}
    local categories = {}

    -- ==========================================================
    -- DATA SCANNING
    -- ==========================================================
    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        if trader.stocks then
            for key, qty in pairs(trader.stocks) do
                local itemData = DynamicTrading.Config.MasterList[key]
                if itemData then
                    local scriptItem = getScriptManager():getItem(itemData.item)
                    local sortName = scriptItem and scriptItem:getDisplayName() or key
                    local price = DynamicTrading.Economy.GetBuyPrice(key, managerData.globalHeat or 0)
                    local cat = itemData.tags[1] or "Misc"

                    if not categorized[cat] then
                        categorized[cat] = {}
                        table.insert(categories, cat)
                    end

                    local priceMod = DynamicTrading.Events.GetPriceModifier and DynamicTrading.Events.GetPriceModifier(itemData.tags) or 1.0

                    table.insert(categorized[cat], {
                        key = key,
                        name = sortName,
                        qty = tonumber(qty) or 0,
                        price = tonumber(price) or 0,
                        data = itemData,
                        isBuy = true,
                        priceMod = priceMod
                    })
                end
            end
        end
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")
        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        local activeRadioID = -1
        if self.radioObj and instanceof(self.radioObj, "InventoryItem") then
            activeRadioID = self.radioObj:getID()
        end

        for i = 0, items:size() - 1 do
            local invItem = items:get(i)
            if invItem then 
                local fullType = invItem:getFullType()
                if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" then
                    -- Safety: Hide active communication radio
                    if invItem:getID() ~= activeRadioID then
                        local masterKey = nil
                        for k, v in pairs(DynamicTrading.Config.MasterList) do
                            if v.item == fullType then masterKey = k; break end
                        end

                        if masterKey then
                            local itemData = DynamicTrading.Config.MasterList[masterKey]
                            local price = DynamicTrading.Economy.GetSellPrice(invItem, masterKey, trader.archetype)
                            if price > 0 then
                                local cat = itemData.tags[1] or "Misc"
                                if not categorized[cat] then
                                    categorized[cat] = {}
                                    table.insert(categories, cat)
                                end
                                local priceMod = DynamicTrading.Events.GetPriceModifier and DynamicTrading.Events.GetPriceModifier(itemData.tags) or 1.0

                                table.insert(categorized[cat], {
                                    key = masterKey,
                                    itemID = invItem:getID(),
                                    name = invItem:getDisplayName(),
                                    price = tonumber(price) or 0,
                                    data = itemData,
                                    isBuy = false,
                                    priceMod = priceMod
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- ==========================================================
    -- BUILD THE LISTBOX
    -- ==========================================================
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

    -- ==========================================================
    -- RESTORE SELECTION & BUTTON LOGIC (FIXED)
    -- ==========================================================
    local foundValidSelection = false
    
    if self.selectedKey then
        local targetIndex = -1
        -- Look for the item we were previously selecting
        for i = 1, #self.listbox.items do
            local listItem = self.listbox.items[i]
            if listItem.item and not listItem.item.isCategory and listItem.item.key == self.selectedKey then
                targetIndex = i
                break
            end
        end

        if targetIndex ~= -1 then
            local checkItem = self.listbox.items[targetIndex].item
            -- Use the robust helper check
            local isLocked = false
            if self.isItemLocked then
                isLocked = self:isItemLocked(checkItem.itemID)
            end

            if not isLocked then
                -- Item is found and unlocked. Select it and ENABLE button.
                self.listbox.selected = targetIndex
                foundValidSelection = true
            else
                -- If locked, try to find the NEXT available unlocked item
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
            -- [FIX] Logic Check: Enable SELL if item is NOT locked.
            local isCurrentlyLocked = false
            if self.isItemLocked then isCurrentlyLocked = self:isItemLocked(sel.itemID) end
            
            if isCurrentlyLocked then
                self.btnLock:setTitle("UNLOCK ITEM")
                self.btnAction:setEnable(false)
            else
                self.btnLock:setTitle("LOCK ITEM")
                self.btnAction:setEnable(true) -- RE-ENABLED BULK SELLING
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