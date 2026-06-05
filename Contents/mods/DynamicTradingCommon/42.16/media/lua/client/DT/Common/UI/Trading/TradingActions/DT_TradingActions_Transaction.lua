local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_TradingWindow:getSellDisplayName(data, qty)
    local itemName = data and (data.displayName or data.name) or T("DTCommon_UI_Trading_Item", nil, "Item")
    local amount = tonumber(qty) or 1
    if amount > 1 then
        return itemName .. " x" .. amount
    end
    return itemName
end

function DT_TradingWindow:getBulkBuyPreview(data, qty)
    if not data or not DynamicTrading or not DynamicTrading.Economy or not DynamicTrading.Economy.V2 then
        return nil
    end

    return DynamicTrading.Economy.V2.GetBulkBuyPreview(self.traderID, data.key, data.customData, qty)
end

function DT_TradingWindow:getMaxBuyQuantity(data, playerWealth)
    local availableQty = tonumber(data and data.qty) or 0
    if availableQty < 1 then
        return { qty = 0, totalPrice = 0, totalBasePrice = 0 }
    end

    if not DynamicTrading or not DynamicTrading.Economy or not DynamicTrading.Economy.V2 then
        local unitPrice = tonumber(data and data.price) or 0
        if unitPrice <= 0 then
            return { qty = 0, totalPrice = 0, totalBasePrice = 0 }
        end

        local maxQty = math.min(availableQty, math.floor((playerWealth or 0) / unitPrice))
        return { qty = maxQty, totalPrice = maxQty * unitPrice, totalBasePrice = maxQty * unitPrice }
    end

    return DynamicTrading.Economy.V2.GetMaxAffordableBuyQuantity(
        self.traderID,
        data.key,
        data.customData,
        availableQty,
        playerWealth or 0
    )
end

function DT_TradingWindow:getMaxSellQuantity(data, trader)
    local availableQty = tonumber(data and data.qty) or 1
    if availableQty < 1 then
        return 0
    end

    if self:isGiftMode() then
        return availableQty
    end

    local unitPrice = tonumber(data and data.price) or 0
    if unitPrice <= 0 or not trader or not trader.budget then
        return availableQty
    end

    return math.min(availableQty, math.max(0, math.floor(trader.budget / unitPrice)))
end

function DT_TradingWindow:sendSellTransaction(data, qty, itemNameOverride)
    if not data or not self:isTradeModeEnabled(false) then return end
    if self:isTradeRequestLocked() then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local amount = math.max(1, math.floor(tonumber(qty) or 1))
    local availableQty = tonumber(data.qty) or 1
    if amount > availableQty then
        amount = availableQty
    end

    local itemIDs = nil
    if data.itemIDs and amount > 1 then
        itemIDs = {}
        for i = 1, amount do
            local itemID = data.itemIDs[i]
            if itemID == nil then
                break
            end
            itemIDs[#itemIDs + 1] = itemID
        end
        amount = #itemIDs
    end

    if amount < 1 then
        return
    end

    local args = {
        type = self:isGiftMode() and "gift" or "sell",
        traderID = self.traderID,
        key = data.key,
        category = data.effectiveCategory or (data.data and data.data.tags[1]) or "Misc",
        qty = amount,
        itemID = data.itemID or -1,
        itemIDs = itemIDs,
        price = data.price
    }

    local totalPrice = (tonumber(args.price) or 0) * amount
    local effectiveBasePrice = self.dataProvider and self.dataProvider.getEffectiveBasePrice
        and self.dataProvider:getEffectiveBasePrice(data.key, data.data)
        or (data.data and data.data.basePrice or args.price or 0)
    local messageAction = self:isGiftMode() and "Gift" or "Sell"
    local pMsg = self.dataProvider:getPlayerMessage(messageAction, {
        transactionKind = self:getTransactionKind(),
        itemName = itemNameOverride or self:getSellDisplayName(data, amount),
        price = totalPrice,
        basePrice = effectiveBasePrice * amount
    })
    self:queueMessage(pMsg, false, true, 0, nil, "transaction")

    if not self:beginTradeRequest() then
        return
    end
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

function DT_TradingWindow:onConfirmQuantityBuy(data, qty)
    if not data or not self:isTradeModeEnabled(true) then return end
    if self:isTradeRequestLocked() then return end

    local amount = math.max(1, math.floor(tonumber(qty) or 1))
    local preview = self:getBulkBuyPreview(data, amount)
    local totalPrice = preview and preview.totalPrice or ((tonumber(data.price) or 0) * amount)
    local fallbackBasePrice = self.dataProvider and self.dataProvider.getEffectiveBasePrice
        and self.dataProvider:getEffectiveBasePrice(data.key, data.data)
        or (data.data and data.data.basePrice or data.price or 0)
    local totalBasePrice = preview and preview.totalBasePrice or (fallbackBasePrice * amount)

    local player = getSpecificPlayer(0)
    if not player then return end

    local pMsg = self.dataProvider:getPlayerMessage("Buy", {
        itemName = self:getSellDisplayName(data, amount),
        price = totalPrice,
        basePrice = totalBasePrice
    })
    self:queueMessage(pMsg, false, true, 0, nil, "transaction")

    if not self:beginTradeRequest() then
        return
    end
    sendClientCommand(player, "DynamicTrading", "TradeTransaction", {
        type = "buy",
        traderID = self.traderID,
        key = data.key,
        category = data.effectiveCategory or data.data.tags[1] or "Misc",
        qty = amount,
        itemID = -1
    })
end

function DT_TradingWindow:onConfirmQuantitySell(data, qty)
    if not self:isTradeModeEnabled(false) then return end
    self:sendSellTransaction(data, qty)
end

function DT_TradingWindow:onAction()
    if self.resetIdleTimer then self:resetIdleTimer() end
    if self:isTradeRequestLocked() then return end
    if not self:isTradeModeEnabled(self.isBuying) then
        self:populateList()
        return
    end

    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)
    local trader = self.dataProvider:getTrader(self.traderID, self.archetype)

    local diagArgs = {
        itemName = d.displayName or d.name,
        price = d.price,
        transactionKind = self:getTransactionKind(),
        basePrice = self.dataProvider and self.dataProvider.getEffectiveBasePrice
            and self.dataProvider:getEffectiveBasePrice(d.key, d.data)
            or (d.data and d.data.basePrice or d.price)
    }

    if self.isBuying then
        if (tonumber(d.qty) or 0) > 1 and DT_Trading_QuantityModal then
            local wealth = self:getPlayerWealth(player)
            local buyLimit = self:getMaxBuyQuantity(d, wealth)

            if (buyLimit.qty or 0) > 0 then
                DT_Trading_QuantityModal.Show({
                    title = T("DTCommon_UI_Trading_BuyMultiple", nil, "Buy Multiple"),
                    promptText = T("DTCommon_UI_Trading_BuyMultiplePrompt", nil, "Buy multiple items with live inflation pricing."),
                    actionLabel = T("DTCommon_UI_Trading_BuyAction", nil, "BUY"),
                    rangeLabelPrefix = T("DTCommon_UI_Trading_Stock", nil, "Stock"),
                    itemName = d.displayName or d.name,
                    unitPrice = d.price,
                    availableQty = tonumber(d.qty) or 0,
                    maxQty = buyLimit.qty,
                    defaultQty = math.min(1, buyLimit.qty),
                    target = self,
                    callback = self.onConfirmQuantityBuy,
                    previewTarget = self,
                    previewCallback = self.getBulkBuyPreview,
                    data = d
                })
                return
            end
        end

        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"

            local playerMsg = self.dataProvider:getPlayerMessage("Buy", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, nil, "transaction", self.buildNPCTradeAudio and self:buildNPCTradeAudio(failMsg, {
                tag = "transaction",
                isError = true,
            }) or nil)

            return
        end

        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"

            local playerMsg = self.dataProvider:getPlayerMessage("Buy", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, nil, "transaction", self.buildNPCTradeAudio and self:buildNPCTradeAudio(failMsg, {
                tag = "transaction",
                isError = true,
            }) or nil)

            return
        end
    end

    if not self.isBuying then
        local groupedQty = tonumber(d.qty) or 1
        if groupedQty > 1 then
            local maxQty = self:getMaxSellQuantity(d, trader)
            if maxQty <= 0 then
                diagArgs.success = false
                diagArgs.failReason = "NoCash"

                local playerMsg = self.dataProvider:getPlayerMessage(self:isGiftMode() and "Gift" or "Sell", diagArgs)
                self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

                local failMsg = self.dataProvider:getTransactionMessage(trader, false, diagArgs)
                self:queueMessage(failMsg, true, false, 10, nil, "transaction", self.buildNPCTradeAudio and self:buildNPCTradeAudio(failMsg, {
                    tag = "transaction",
                    isError = true,
                }) or nil)
                return
            end

            if DT_Trading_QuantityModal then
                DT_Trading_QuantityModal.Show({
                    title = self:isGiftMode()
                        and T("DTCommon_UI_Trading_GiftMultiple", nil, "Gift Multiple")
                        or T("DTCommon_UI_Trading_SellMultiple", nil, "Sell Multiple"),
                    promptText = self:isGiftMode()
                        and T("DTCommon_UI_Trading_GiftMultiplePrompt", nil, "Choose how many items to offer as a gift.")
                        or nil,
                    actionLabel = self:isGiftMode()
                        and T("DTCommon_UI_Trading_GiftAction", nil, "GIFT")
                        or T("DTCommon_UI_Trading_SellAction", nil, "SELL"),
                    itemName = d.displayName or d.name,
                    unitPrice = d.price,
                    availableQty = groupedQty,
                    maxQty = maxQty,
                    defaultQty = math.min(groupedQty, maxQty),
                    target = self,
                    callback = self.onConfirmQuantitySell,
                    data = d
                })
                return
            end
        end

        if d.itemID and d.itemID ~= -1 then
            local invItem = nil

            if player then
                local playerInv = player:getInventory()

                local function findItemRecursive(container)
                    local items = container:getItems()
                    for i = 0, items:size() - 1 do
                        local it = items:get(i)
                        if it:getID() == d.itemID then
                            return it
                        end
                        if instanceof(it, "InventoryContainer") then
                            local sub = it:getItemContainer()
                            if sub then
                                local found = findItemRecursive(sub)
                                if found then return found end
                            end
                        end
                    end
                    return nil
                end

                invItem = findItemRecursive(playerInv)
            end

            if invItem and instanceof(invItem, "InventoryContainer") then
                local container = invItem:getItemContainer()
                if container and container:getItems() and not container:getItems():isEmpty() then
                    if DT_Trading_Modal then
                        DT_Trading_Modal.Show(invItem, self, self.onConfirmSell, d, self.onUnpackContainer)
                        return
                    end
                end
            end
        end

        if (not self:isGiftMode()) and trader and trader.budget and trader.budget < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"

            local playerMsg = self.dataProvider:getPlayerMessage("Sell", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, false, diagArgs)
            self:queueMessage(failMsg, true, false, 10, nil, "transaction", self.buildNPCTradeAudio and self:buildNPCTradeAudio(failMsg, {
                tag = "transaction",
                isError = true,
            }) or nil)

            return
        end
    end

    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.effectiveCategory or d.data.tags[1] or "Misc",
        qty = 1,
        itemID = d.itemID or -1
    }

    local pAction = self.isBuying and "Buy" or (self:isGiftMode() and "Gift" or "Sell")
    local pMsg = self.dataProvider:getPlayerMessage(pAction, diagArgs)
    if self.isBuying then
        self:queueMessage(pMsg, false, true, 0, nil, "transaction")
        if not self:beginTradeRequest() then
            return
        end
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
    else
        self:sendSellTransaction(d, 1, d.displayName or d.name)
    end
end
