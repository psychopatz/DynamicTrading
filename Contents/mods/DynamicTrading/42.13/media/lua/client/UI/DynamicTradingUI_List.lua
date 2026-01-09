-- =============================================================================
-- File: media/lua/client/UI/DynamicTradingUI_List.lua
-- =============================================================================

function DynamicTradingUI.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()

    -- 1. DRAW CATEGORY HEADER
    if d.isCategory then
        listbox:drawRect(0, y, width, height, 0.9, 0.1, 0.1, 0.1)
        listbox:drawRectBorder(0, y, width, height, 0.3, 0.5, 0.5, 0.5)

        local ui = DynamicTradingUI.instance
        local isCol = ui and ui.collapsed[d.categoryName]
        local prefix = isCol and "[+] " or "[-] "

        listbox:drawText(prefix .. d.text, 10, y + (height/2) - 7, 1, 0.8, 0.3, 1, UIFont.Medium)
        return y + height
    end

    -- 2. DRAW LIST ITEM (BACKGROUND)
    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end

    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- 3. DRAW ICON
    local scriptItem = getScriptManager():getItem(d.data.item)
    if scriptItem then
        local icon = scriptItem:getIcon()
        if icon then
            local tex = getTexture("Item_" .. icon) or getTexture(icon)
            if tex then
                listbox:drawTextureScaled(tex, 6, y + 4, 32, 32, 1, 1, 1, 1)
            end
        end
    end

    -- 4. DRAW NAME
    local nameColor = {r=0.9, g=0.9, b=0.9}
    if d.isBuy and (tonumber(d.qty) or 0) <= 0 then
        nameColor = {r=0.5, g=0.5, b=0.5}
    end

    local maxNameWidth = width - 195
    local displayName = DynamicTradingUI.TruncateString(d.name, listbox.font, maxNameWidth)
    listbox:drawText(displayName, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)

    -- 5. PRICE COLORING
    local priceR, priceG, priceB = 0.6, 1.0, 0.6
    if d.isBuy then
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 end
        if d.priceMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 end
    else
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.8, 0.2 end
    end

    -- 6. STOCK / SOLD OUT
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
    -- MODE: BUYING
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

    -- ==========================================================
    -- MODE: SELLING
    -- ==========================================================
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")

        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        
        -- Get the Unique ID of the radio currently in use
        local activeRadioID = self.radioObj and self.radioObj:getID() or -1

        for i = 0, items:size() - 1 do
            local invItem = items:get(i)
            
            if invItem then 
                local fullType = invItem:getFullType()

                if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" then
                    
                    -- [ROBUST ID PROTECTION] 
                    -- We check the physical ID of the item. 
                    -- This allows selling identical radios as long as they aren't the physical one being held.
                    local isActuallyInUse = (invItem:getID() == activeRadioID)

                    if not isActuallyInUse then
                        local masterKey = nil
                        for k, v in pairs(DynamicTrading.Config.MasterList) do
                            if v.item == fullType then
                                masterKey = k
                                break
                            end
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
                                    itemID = invItem:getID(), -- Store the ID for exact transaction
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
    -- DRAW LIST
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

    -- Persistence logic (Keeps the button enabled for bulk clicking)
    local foundSelection = false
    if self.selectedKey then
        for i = 1, #self.listbox.items do
            local listItem = self.listbox.items[i]
            if listItem.item and not listItem.item.isCategory and listItem.item.key == self.selectedKey then
                self.listbox.selected = i
                foundSelection = true

                local actionStr = self.isBuying and "BUY" or "SELL"
                self.btnAction:setTitle(actionStr .. " ($" .. listItem.item.price .. ")")
                
                if self.isBuying then
                    self.btnAction:setEnable(listItem.item.qty > 0)
                else
                    self.btnAction:setEnable(true)
                end
                break
            end
        end
    end

    if not foundSelection then
        self.listbox.selected = -1
        self.selectedKey = nil
        self.btnAction:setEnable(false)
        self.btnAction:setTitle("SELECT AN ITEM")
    end

    self.listbox:setYScroll(oldScroll)
end