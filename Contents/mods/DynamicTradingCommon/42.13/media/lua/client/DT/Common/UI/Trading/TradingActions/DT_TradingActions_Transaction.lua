function DT_TradingWindow:onAction()
    if self.resetIdleTimer then self:resetIdleTimer() end

    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end

    local d = selItem.item
    local player = getSpecificPlayer(0)
    local trader = self.dataProvider:getTrader(self.traderID, self.archetype)

    local diagArgs = {
        itemName = d.name,
        price = d.price,
        basePrice = d.data and d.data.basePrice or d.price
    }

    if self.isBuying then
        if d.qty <= 0 then
            diagArgs.success = false
            diagArgs.failReason = "SoldOut"

            local playerMsg = self.dataProvider:getPlayerMessage("Buy", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom", "transaction")

            return
        end

        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"

            local playerMsg = self.dataProvider:getPlayerMessage("Buy", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, true, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom", "transaction")

            return
        end
    end

    if not self.isBuying then
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

        if trader and trader.budget and trader.budget < d.price then
            diagArgs.success = false
            diagArgs.failReason = "NoCash"

            local playerMsg = self.dataProvider:getPlayerMessage("Sell", diagArgs)
            self:queueMessage(playerMsg, false, true, 0, nil, "transaction")

            local failMsg = self.dataProvider:getTransactionMessage(trader, false, diagArgs)
            self:queueMessage(failMsg, true, false, 10, "DT_RadioRandom", "transaction")

            return
        end
    end

    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = d.data.tags[1] or "Misc",
        qty = 1,
        itemID = d.itemID or -1
    }

    local pAction = self.isBuying and "Buy" or "Sell"
    local pMsg = self.dataProvider:getPlayerMessage(pAction, diagArgs)
    self:queueMessage(pMsg, false, true, 0, nil, "transaction")

    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end
