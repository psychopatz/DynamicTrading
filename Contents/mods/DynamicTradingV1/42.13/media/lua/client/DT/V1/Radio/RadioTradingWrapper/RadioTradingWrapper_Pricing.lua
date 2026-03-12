-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - PRICING
-- =============================================================================
-- Economy and price calculation logic, delegated to Common Economy.
-- =============================================================================

V1_RadioTradingWrapper_Pricing_logic = {}

function V1_Radio_DataProvider:getItemData(key)
    return DynamicTrading.Config.MasterList[key]
end

function V1_Radio_DataProvider:getBuyPrice(key, customData, verbose)
    local itemData = DynamicTrading.Config.MasterList[key]
    if not itemData then return 99999 end
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        customData = customData,
        getPriceModifier = function(tags) return self:getPriceModifier(tags, verbose) end
    }
    
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
    end
    
    return 99999
end

function V1_Radio_DataProvider:getSellPrice(invItem, masterKey, trader, verbose)
    local itemData = DynamicTrading.Config.MasterList[masterKey]
    if not itemData then return 0 end
    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetypeID = trader.archetype or "General"
    local archetype = DynamicTrading.Archetypes[archetypeID]
    
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        getPriceModifier = function(tags) return self:getPriceModifier(tags, verbose) end
    }
    
    if DynamicTrading.Economy and DynamicTrading.Economy.Common then
        return DynamicTrading.Economy.Common.GetSellPrice(masterKey, itemData, invItem, diff, archetype, modifiers, verbose)
    end
    
    return 0
end

function V1_Radio_DataProvider:getPriceModifier(tags, verbose)
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionPriceModifier then
        local factionID = self._currentFactionID
        local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                          or ModData.get("DynamicTrading_Stock")
                          
        if stockData and stockData[V1_Radio_DataProvider._currentTraderID] then
            factionID = stockData[V1_Radio_DataProvider._currentTraderID].factionID
        end
        
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
                            or ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionID and factionData[factionID]
        
        return DynamicTrading.Events.GetFactionPriceModifier(faction, tags, verbose)
    end
    
    return 1.0
end

DynamicTrading.Log("DTV1", "Init", "Pricing", "V1 Radio Trading Pricing Logic Loaded")
