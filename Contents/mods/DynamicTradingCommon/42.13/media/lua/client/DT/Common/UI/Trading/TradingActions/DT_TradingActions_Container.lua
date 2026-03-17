function DT_TradingWindow:onConfirmSell(invItem, data)
    if not data then return end

    local player = getSpecificPlayer(0)
    local args = {
        type = "sell",
        traderID = self.traderID,
        key = data.key,
        category = data.data and data.data.tags[1] or "Misc",
        qty = 1,
        itemID = data.itemID or -1,
        price = data.price
    }

    local pMsg = self.dataProvider:getPlayerMessage("Sell", {
        itemName = invItem:getDisplayName(),
        price = args.price or 0
    })
    self:queueMessage(pMsg, false, true, 0, nil, "transaction")

    sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
end

function DT_TradingWindow:onUnpackContainer(invItem)
    if not invItem then return end

    local player = getSpecificPlayer(0)
    local args = {
        itemID = invItem:getID()
    }

    sendClientCommand(player, "DynamicTrading", "UnpackContainer", args)
end
