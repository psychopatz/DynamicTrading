-- =============================================================================
-- DYNAMIC TRADING: COMMON TRADING PROVIDER - PRICING
-- =============================================================================
-- Shared pricing helpers for V1/V2 wrappers.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.TradingProvider = DynamicTrading.TradingProvider or {}

function DynamicTrading.TradingProvider.AttachPricing(provider)
    if not provider then return end

    if provider.getItemData == nil then
        function provider:getItemData(key)
            return DynamicTrading.Config.MasterList[key]
        end
    end

    if provider.getBuyPrice == nil then
        function provider:getBuyPrice(key, customData, verbose)
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
                end
            else
                require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon"
                if DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.GetBuyPrice then
                    return DynamicTrading.Economy.Common.GetBuyPrice(key, itemData, diff, modifiers, verbose)
                end
            end

            return 99999
        end
    end

    if provider.getSellPrice == nil then
        function provider:getSellPrice(invItem, masterKey, trader, verbose)
            local traderID = self._currentTraderID
            if not traderID or not invItem then return 0 end

            local itemData = DynamicTrading.Config.MasterKey and DynamicTrading.Config.MasterList[masterKey]
            if not itemData then itemData = DynamicTrading.Config.MasterList[masterKey] end
            if not itemData then return 0 end

            local diff = DynamicTrading.Config.GetDifficultyData()
            local archetypeID = trader and trader.archetype or "General"
            local archetype = DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetypeID]

            local modifiers = {
                tagsConfig = DynamicTrading.Config.Tags,
                getPriceModifier = function(tags)
                    return self:getPriceModifier(tags, verbose)
                end
            }

            if DynamicTrading.Economy and DynamicTrading.Economy.Common then
                if DynamicTrading.Economy.Common.GetSellPrice then
                    return DynamicTrading.Economy.Common.GetSellPrice(masterKey, itemData, invItem, diff, archetype, modifiers, verbose)
                end
            end

            return 0
        end
    end

    if provider.getPriceModifier == nil then
        function provider:getPriceModifier(tags, verbose)
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
    end
end
