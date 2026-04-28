-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_Transaction_logic.lua
-- Logic: Trade transaction command registration
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local Helpers = context.Helpers

    Handlers.TradeTransaction = function(player, args)
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "TradeTransaction received")
        DynamicTrading.Log("DTCommons", "Trade", "Logic", "Type: " .. tostring(args.type) .. ", TraderID: " .. tostring(args.traderID))

        local tx = Helpers.BuildTradeTransactionContext(player, args)
        if not tx then
            return
        end

        if tx.txType == "buy" then
            Helpers.HandleBuyTransaction(player, tx)
        elseif tx.txType == "sell" or tx.txType == "gift" then
            Helpers.HandleSellTransaction(player, args, tx)
        end
    end
end
