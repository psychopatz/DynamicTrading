-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_Context_logic.lua
-- Logic: Shared trade transaction setup and responses
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers

    function Helpers.SendTransactionResult(player, payload)
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "TransactionResult", payload)
    end

    function Helpers.SyncFactionBiasDelta(player, factionID, amount, reason)
        if not player or not factionID then
            return false
        end

        local delta = tonumber(amount) or 0
        if delta == 0 then
            return false
        end

        return DynamicTrading.ServerHelpers.SendReputationSync(player, {
            action = "factionBiasDelta",
            factionID = tostring(factionID),
            amount = delta,
            reason = reason or "server_trade"
        })
    end

    function Helpers.BuildTradeTransactionContext(player, args)
        local txType = args.type
        local traderID = args.traderID
        local key = args.key
        local clientQty = tonumber(args.qty) or 1

        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if not stockData then
            DynamicTrading.Log("DTCommons", "Trade", "Logic", "ERROR: No stock data for trader")
            Helpers.SendTransactionResult(player, { success = false, msg = "Trader unavailable" })
            return nil
        end

        local itemData = DynamicTrading.Config.MasterList[key]
        if not itemData then
            DynamicTrading.Log("DTCommons", "Trade", "Logic", "ERROR: Item not in MasterList: " .. tostring(key))
            Helpers.SendTransactionResult(player, { success = false, msg = "Item not found" })
            return nil
        end

        local inv = player:getInventory()
        local scriptItem = getScriptManager():getItem(itemData.item)
        local safeDisplayName = scriptItem and scriptItem:getDisplayName() or "Unknown Item"
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
        local factionID = soul and soul.factionID or nil
        local factionData = factionID and DynamicTrading_Factions.GetFaction(factionID) or nil
        local archetypeID = Helpers.GetTraderArchetypeID(soul, stockData)

        DynamicTrading.Log(
            "DTCommons",
            "Trade",
            "Logic",
            "FactionID: " .. tostring(factionID) .. ", Faction wealth: $" .. tostring(factionData and factionData.wealth or 0)
        )

        if not Helpers.IsTradeModeAllowed(archetypeID, txType) then
            Helpers.SendTransactionResult(player, {
                success = false,
                msg = Helpers.GetTradeModeDisabledMessage(txType)
            })
            return nil
        end

        local sessionData = DT_TraderSession.GetSession(traderID)
        
        return {
            txType = txType,
            traderID = traderID,
            key = key,
            clientQty = clientQty,
            stockData = stockData,
            sessionData = sessionData,
            itemData = itemData,
            inv = inv,
            safeDisplayName = safeDisplayName,
            soul = soul,
            factionID = factionID,
            factionData = factionData,
            archetypeID = archetypeID
        }
    end
end
