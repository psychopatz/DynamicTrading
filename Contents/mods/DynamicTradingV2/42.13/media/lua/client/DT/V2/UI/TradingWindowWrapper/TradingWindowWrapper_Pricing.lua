-- =============================================================================
-- TradingWindowWrapper_Pricing.lua
-- Server-authoritative buy/sell pricing for the trading provider.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}

function V2_DataProvider:getItemData(key)
    return DynamicTrading.Config.MasterList[key]
end

function V2_DataProvider:getBuyPrice(key, customData, verbose)
    local traderID = self._currentTraderID
    if not traderID then return 99999 end

    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then return 99999 end

    local diff = DynamicTrading.Config.GetDifficultyData()

    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        customData = customData,
        getPriceModifier = function(tags)
            return self:getPriceModifier(tags, verbose)
        end
    }

    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        if DynamicTrading.Economy.Common.GetBuyPrice then
            return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
        else
            DynamicTrading.Log("DTV2", "Trade", "Error", "DynamicTrading.Economy.Common exists but GetBuyPrice is missing!")
        end
    else
        DynamicTrading.Log("DTV2", "Trade", "Error", "DynamicTrading.Economy.Common is nil! Attempting emergency require...")
        require "DT/Common/Trading/DT_Economy_Common"
        if DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.GetBuyPrice then
            DynamicTrading.Log("DTV2", "Trade", "Init", "Emergency require successful.")
            return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
        end
    end

    return 99999
end

function V2_DataProvider:getSellPrice(invItem, masterKey, trader, verbose)
    local traderID = self._currentTraderID
    if not traderID or not invItem then return 0 end

    local itemData = DynamicTrading.Config.MasterKey and DynamicTrading.Config.MasterList[masterKey]
    if not itemData then itemData = DynamicTrading.Config.MasterList[masterKey] end
    if not itemData then return 0 end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetypeID = trader.archetype or "General"
    local archetype = DynamicTrading.Archetypes[archetypeID]

    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        getPriceModifier = function(tags)
            return self:getPriceModifier(tags, verbose)
        end
    }

    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        if DynamicTrading.Economy.Common.GetSellPrice then
            return DynamicTrading.Economy.Common.GetSellPrice(masterKey, itemData, invItem, diff, archetype, modifiers, verbose)
        else
            DynamicTrading.Log("DTV2", "Trade", "Error", "DynamicTrading.Economy.Common exists but GetSellPrice is missing!")
        end
    else
        DynamicTrading.Log("DTV2", "Trade", "Error", "DynamicTrading.Economy.Common is nil during Sell Price calc!")
    end

    return 0
end

function V2_DataProvider:getPriceModifier(tags, verbose)
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
        local factionID = self._currentFactionID
        if not factionID and self._currentTraderID then
            local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
                or ModData.get("DynamicTrading_Stock")
            if stockData and stockData[self._currentTraderID] then
                factionID = stockData[self._currentTraderID].factionID
            end
        end

        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
            or ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionID and factionData[factionID]

        return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
    end
    return 1.0
end
