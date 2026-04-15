local V2 = DynamicTrading.Economy.V2
local Internal = V2._Internal

-- =============================================================================
-- 2. V2 PRICING LOGIC (Wrapper)
-- =============================================================================
function V2.GetBuyPrice(traderUUID, itemFullType, customData, verbose, skipEvents)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local globalHeat = engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat or {}
    return Internal.ResolveBuyPriceWithHeat(traderUUID, itemFullType, customData, globalHeat, verbose, skipEvents)
end
