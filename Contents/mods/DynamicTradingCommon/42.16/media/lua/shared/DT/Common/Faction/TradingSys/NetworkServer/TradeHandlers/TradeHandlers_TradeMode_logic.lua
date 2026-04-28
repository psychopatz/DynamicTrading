-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_TradeMode_logic.lua
-- Logic: Archetype-based trade mode gating helpers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers

    function Helpers.GetTraderArchetypeID(soul, stockData)
        if soul then
            return soul.archetypeID or soul.archetype or "General"
        end

        if stockData then
            return stockData.archetype or "General"
        end

        return "General"
    end

    function Helpers.IsTradeModeAllowed(archetypeID, txType)
        if txType == "buy" then
            return not DynamicTrading.IsArchetypeBuyTabEnabled
                or DynamicTrading.IsArchetypeBuyTabEnabled(archetypeID)
        end

        if txType == "sell" or txType == "gift" then
            return not DynamicTrading.IsArchetypeSellTabEnabled
                or DynamicTrading.IsArchetypeSellTabEnabled(archetypeID)
        end

        return true
    end

    function Helpers.GetTradeModeDisabledMessage(txType)
        if txType == "sell" or txType == "gift" then
            return "This trader is not buying items."
        end

        return "This trader is not selling items."
    end
end
