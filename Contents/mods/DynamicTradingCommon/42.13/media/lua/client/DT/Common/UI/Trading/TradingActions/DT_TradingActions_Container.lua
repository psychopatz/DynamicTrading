function DT_TradingWindow:onConfirmSell(invItem, data)
    if not data or not invItem then return end
    self:sendSellTransaction(data, 1, invItem:getDisplayName())
end

function DT_TradingWindow:onUnpackContainer(invItem)
    if not invItem then return end

    local player = getSpecificPlayer(0)
    local args = {
        itemID = invItem:getID()
    }

    sendClientCommand(player, "DynamicTrading", "UnpackContainer", args)
end
