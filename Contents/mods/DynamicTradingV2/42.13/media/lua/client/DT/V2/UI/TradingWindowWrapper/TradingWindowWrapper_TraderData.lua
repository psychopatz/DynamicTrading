-- =============================================================================
-- TradingWindowWrapper_TraderData.lua
-- Trader proxy construction and stock/faction cache reads.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}

function V2_DataProvider:getTrader(traderID, archetype)
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
        or ModData.get("DynamicTrading_Stock")

    if not stockData or not stockData[traderID] then
        return nil
    end

    local stock = stockData[traderID]

    local processedStocks = {}
    if stock.items then
        for key, itemStock in pairs(stock.items) do
            processedStocks[key] = itemStock
        end
    end

    self._stockItems = stock.items or {}

    local factionWealth = stock.factionWealth or 0
    if factionWealth == 0 and stock.factionID then
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions)
            or ModData.get("DynamicTrading_Factions")
        if factionData and factionData[stock.factionID] then
            factionWealth = factionData[stock.factionID].wealth or 0
        end
    end

    local trader = {
        traderID = traderID,
        archetype = stock.archetype or archetype or "General",
        name = stock.name or "Trader",
        wallet = stock.wallet or factionWealth or 0,
        budget = factionWealth,
        stocks = processedStocks,
        deflation = stock.deflation or {},
        factionID = stock.factionID,
        identitySeed = stock.identitySeed,
        gender = stock.gender or "Male",
        returnTime = stock.returnTime,
        npcRef = self._currentNPC
    }

    if DT_ReputationManager then
        trader.personalRep = DT_ReputationManager.GetPersonalRep(traderID)
        trader.factionRep = DT_ReputationManager.GetFactionRep(stock.factionID)
        trader.reputation = DT_ReputationManager.GetEffectiveRep(traderID, stock.factionID)
        trader.reputationStage = DT_ReputationManager.GetStageData(trader.reputation).label
        trader.tradeProgress = DT_ReputationManager.GetTradeProgress(traderID)
        trader.totalBought = DT_ReputationManager.GetTotalBought(traderID)
        trader.totalSold = DT_ReputationManager.GetTotalSold(traderID)
    end

    return trader
end
