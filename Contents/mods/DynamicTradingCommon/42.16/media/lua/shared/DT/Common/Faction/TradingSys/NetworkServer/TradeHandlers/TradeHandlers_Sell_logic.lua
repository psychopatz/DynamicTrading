-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_Sell_logic.lua
-- Logic: Sell transaction processing
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers
    local DataHandlers = context.DataHandlers

    function Helpers.HandleSellTransaction(player, args, tx)
        local sellItems, unitPrice, baseUnitPrice = Helpers.ResolveSellItems(tx.inv, args, tx.traderID, tx.key, tx.clientQty)
        if not sellItems or #sellItems ~= tx.clientQty then
            Helpers.SendTransactionResult(player, { success = false, msg = unitPrice or "Item missing!" })
            return
        end

        local totalGain = unitPrice * tx.clientQty
        local totalBaseGain = baseUnitPrice * tx.clientQty

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "Sell: " .. tx.key .. " @ $" .. totalGain .. " (Base: $" .. totalBaseGain .. ")")

        local session = DT_TraderSession.GetSession(tx.traderID)
        local traderBudget = session and session.budget or 999999
        if traderBudget < totalGain then
            Helpers.SendTransactionResult(player, { success = false, msg = "Trader cannot afford this!" })
            return
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

        local bundles = math.floor(totalGain / 100)
        local loose = totalGain % 100
        if bundles > 0 then
            DynamicTrading.ServerHelpers.AddItem(tx.inv, "Base.MoneyBundle", bundles)
        end
        if loose > 0 then
            DynamicTrading.ServerHelpers.AddItem(tx.inv, "Base.Money", loose)
        end

        if tx.factionData then
            DT_TraderSession.OnSell(tx.traderID, totalGain)
        end

        if not tx.stockData.deflation then
            tx.stockData.deflation = {}
        end
        tx.stockData.deflation[tx.key] = (tx.stockData.deflation[tx.key] or 0) + tx.clientQty

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

        DynamicTrading.Log("DTCommons", "Trade", "Logic", "SUCCESS: Sold " .. soldItemName)

        DataHandlers.SendSyncStockToPlayer(player, tx.traderID)
        Helpers.SendTransactionResult(player, {
            success = true,
            itemName = soldItemName,
            price = totalGain,
            basePrice = totalBaseGain,
            isBuy = false,
            qty = tx.clientQty
        })

        local factionID = tx.factionData and tx.factionData.id or nil
        if factionID and DynamicTrading_Factions and DynamicTrading_Factions.ModifyReputation then
            local repGain = math.floor(totalGain / 500)
            if repGain >= 1 then
                DynamicTrading_Factions.ModifyReputation(factionID, player:getUsername(), repGain)
                local factionName = tx.factionData.name or "Independent"
                     if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddPlayerRadioEvent then
                         DynamicTrading.GameplayLogs.AddPlayerRadioEvent(player, DynamicTrading.GameplayEvents.TRADE_REP_GAINED, {tostring(factionName), tostring(repGain)})
                end
            end
        end
    end
end
