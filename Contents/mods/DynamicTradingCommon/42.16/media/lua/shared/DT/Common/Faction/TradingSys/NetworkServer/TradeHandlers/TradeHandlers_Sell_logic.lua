-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_Sell_logic.lua
-- Logic: Sell transaction processing
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers
    local DataHandlers = context.DataHandlers

    function Helpers.HandleSellTransaction(player, args, tx)
        local isGift = tx.txType == "gift"
        local sellItems, unitPrice, baseUnitPrice = Helpers.ResolveSellItems(tx.inv, args, tx.traderID, tx.key, tx.clientQty)
        if not sellItems or #sellItems ~= tx.clientQty then
            Helpers.SendTransactionResult(player, { success = false, msg = unitPrice or "Item missing!" })
            return
        end

        local totalGain = unitPrice * tx.clientQty
        local totalBaseGain = baseUnitPrice * tx.clientQty
        local repValue = isGift and (totalGain * 2) or totalGain

        DynamicTrading.Log(
            "DTCommons",
            "Trade",
            "Logic",
            (isGift and "Gift" or "Sell") .. ": " .. tx.key .. " @ $" .. totalGain .. " (Base: $" .. totalBaseGain .. ")"
        )

        if not isGift then
            local session = DT_TraderSession.GetSession(tx.traderID)
            local traderBudget = session and session.budget or 999999
            if traderBudget < totalGain then
                Helpers.SendTransactionResult(player, { success = false, msg = "Trader cannot afford this!" })
                return
            end
        end

        for _, itemObj in ipairs(sellItems) do
            if player:getPrimaryHandItem() == itemObj then
                player:setPrimaryHandItem(nil)
            end
            if player:getSecondaryHandItem() == itemObj then
                player:setSecondaryHandItem(nil)
            end
        end

        for _, itemObj in ipairs(sellItems) do
            DynamicTrading.ServerHelpers.RemoveItem(itemObj)
        end

        if not isGift then
            local bundles = math.floor(totalGain / 100)
            local loose = totalGain % 100
            if bundles > 0 then
                DynamicTrading.ServerHelpers.AddItem(tx.inv, "Base.MoneyBundle", bundles)
            end
            if loose > 0 then
                DynamicTrading.ServerHelpers.AddItem(tx.inv, "Base.Money", loose)
            end
        end

        if tx.factionData and not isGift then
            DT_TraderSession.OnSell(tx.traderID, totalGain)
        end

        tx.stockData.playerInteracted = true
        tx.stockData.tradeInteracted = true
        tx.stockData.lastTradeKind = isGift and "gift" or "sell"
        tx.stockData.lastTradeBy = player and player.getUsername and player:getUsername() or nil
        tx.stockData.lastTradeAt = getTimeInMillis and getTimeInMillis() or nil
        tx.stockData.totalTradeVolume = (tonumber(tx.stockData.totalTradeVolume) or 0) + totalGain

        if not tx.stockData.deflation then
            tx.stockData.deflation = {}
        end
        tx.stockData.deflation[tx.key] = (tx.stockData.deflation[tx.key] or 0) + tx.clientQty
        if DynamicTrading_Stock and DynamicTrading_Stock.BumpVersion then
            DynamicTrading_Stock.BumpVersion(tx.traderID, isGift and "gift" or "sell")
        end

        ModData.transmit("DynamicTrading_Stock")

        local sellFluidType, sellFluidAmount = Helpers.ResolveInventoryFluidState(sellItems[1])
        local category = DynamicTrading.Economy.Common.GetPrimaryTradeTag(tx.itemData, sellFluidType, sellFluidAmount)
        local engineData = DynamicTrading_Engine.GetEngineData()

        if engineData and engineData.WorldEconomy then
            if not engineData.WorldEconomy.DeflatedGlobal then
                engineData.WorldEconomy.DeflatedGlobal = {}
            end

            if not engineData.WorldEconomy.DeflatedGlobal[tx.key] then
                local chance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.SellDeflationChance) or 30
                local roll = ZombRand(chance) + 1

                if roll == 1 then
                    local sensitivity = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.CategoryDeflation) or 0.02
                    DynamicTrading_Engine.UpdateHeat(category, -(sensitivity * tx.clientQty))
                    engineData.WorldEconomy.DeflatedGlobal[tx.key] = true
                    DynamicTrading.Log(
                        "DTCommons",
                        "Trade",
                        "Logic",
                        "GLOBAL DEFLATION triggered for category: " .. tostring(category) .. " ( - " .. tostring(sensitivity * tx.clientQty) .. ")"
                    )
                else
                    DynamicTrading.Log("DTCommons", "Trade", "Logic", "Deflation Roll Failed: " .. roll .. "/" .. chance)
                end
            else
                DynamicTrading.Log("DTCommons", "Trade", "Logic", "Deflation Skipped: Already deflated this item type today.")
            end
        end

        local soldItemName = sellItems[1] and sellItems[1]:getDisplayName() or tx.safeDisplayName
        if tx.clientQty > 1 then
            soldItemName = soldItemName .. " x" .. tostring(tx.clientQty)
        end

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "SUCCESS: " .. (isGift and "Gifted " or "Sold ") .. soldItemName)

        DataHandlers.SendSyncStockToPlayer(player, tx.traderID)
        DataHandlers.BroadcastSyncStock(tx.traderID, player)
        Helpers.SendTransactionResult(player, {
            success = true,
            itemName = soldItemName,
            price = totalGain,
            basePrice = totalBaseGain,
            repValue = repValue,
            isBuy = false,
            transactionKind = isGift and "gift" or "sell",
            qty = tx.clientQty
        })

        local factionID = tx.factionData and tx.factionData.id or nil
        if (not isGift) and factionID then
            local repGain = math.floor(totalGain / 500)
            if repGain >= 1 then
                Helpers.SyncFactionBiasDelta(player, factionID, repGain, "trade_sell")
                local factionName = tx.factionData.name or "Independent"
                     if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddPlayerRadioEvent then
                         DynamicTrading.GameplayLogs.AddPlayerRadioEvent(player, DynamicTrading.GameplayEvents.TRADE_REP_GAINED, {tostring(factionName), tostring(repGain)})
                end
            end
        end
    end
end
