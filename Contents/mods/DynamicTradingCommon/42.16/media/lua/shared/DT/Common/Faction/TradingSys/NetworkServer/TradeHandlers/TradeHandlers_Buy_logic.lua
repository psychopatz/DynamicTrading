-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_Buy_logic.lua
-- Logic: Buy transaction processing
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers
    local DataHandlers = context.DataHandlers

    function Helpers.HandleBuyTransaction(player, tx)
        local itemStock = tx.stockData.items[tx.key]
        if not itemStock then
            Helpers.SendTransactionResult(player, { success = false, msg = "Not in stock" })
            return
        end

        local currentQty = type(itemStock) == "table" and itemStock.qty or itemStock
        local customData = type(itemStock) == "table" and itemStock.customData or nil

        local buyPreview = DynamicTrading.Economy.V2.GetBulkBuyPreview(tx.traderID, tx.key, customData, tx.clientQty)
        local unitPrice = buyPreview.lastUnitPrice or DynamicTrading.Economy.V2.GetBuyPrice(tx.traderID, tx.key, customData)
        local totalCost = buyPreview.totalPrice or (unitPrice * tx.clientQty)
        local baseUnitPrice = DynamicTrading.Economy.V2.GetBuyPrice(tx.traderID, tx.key, customData, false, true)
        local totalBaseCost = buyPreview.totalBasePrice or (baseUnitPrice * tx.clientQty)

        DynamicTrading.Log(
            "DTCommons",
            "Trade",
            "Logic",
            "Buy: " .. tx.key .. " x" .. tx.clientQty .. " @ $" .. unitPrice .. " (Base: $" .. baseUnitPrice .. ")"
        )

        if currentQty < tx.clientQty then
            Helpers.SendTransactionResult(player, { success = false, msg = "Sold Out!" })
            return
        end

        local playerWealth = DynamicTrading.ServerHelpers.GetWealth(player)
        if playerWealth < totalCost then
            Helpers.SendTransactionResult(player, { success = false, msg = "Not enough cash!" })
            return
        end

        if not DynamicTrading.ServerHelpers.RemoveMoney(player, totalCost) then
            Helpers.SendTransactionResult(player, { success = false, msg = "Transaction Error" })
            return
        end

        if type(itemStock) == "table" then
            itemStock.qty = itemStock.qty - tx.clientQty
        else
            tx.stockData.items[tx.key] = currentQty - tx.clientQty
        end

        if tx.factionData then
            DT_TraderSession.OnBuy(tx.traderID, totalCost)
        end

        local itemStockData = type(itemStock) == "table" and itemStock or {}
        customData = itemStockData.customData

        DynamicTrading.ServerHelpers.AddItemWithCondition(tx.inv, tx.itemData.item, tx.clientQty, customData)
        ModData.transmit("DynamicTrading_Stock")

        local category = DynamicTrading.Economy.Common.GetPrimaryTradeTag(
            tx.itemData,
            customData and customData.fluidType,
            customData and customData.fluidAmount
        )
        local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryInflation) or 0.05
        local change = sensitivity * tx.clientQty
        DynamicTrading_Engine.UpdateHeat(category, change)

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "Buy Inflation: Category=[" .. tostring(category) .. "] | Adding Heat: " .. tostring(change))
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "SUCCESS: Bought " .. tx.safeDisplayName)

        DataHandlers.SendSyncStockToPlayer(player, tx.traderID)
        Helpers.SendTransactionResult(player, {
            success = true,
            itemName = tx.safeDisplayName,
            price = totalCost,
            basePrice = totalBaseCost,
            isBuy = true
        })
    end
end
