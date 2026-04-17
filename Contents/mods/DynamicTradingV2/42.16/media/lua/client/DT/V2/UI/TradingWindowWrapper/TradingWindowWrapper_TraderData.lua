-- =============================================================================
-- TradingWindowWrapper_TraderData.lua
-- Trader proxy construction and stock/faction cache reads.
-- =============================================================================

require "DT/Common/Faction/TradingSys/TraderSession/DT_TraderSession"

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
            factionWealth = factionData[stock.factionID].ColonyWealth or factionData[stock.factionID].wealth or 0
        end
    end

    local sessionData = nil
    if DT_TraderSession and DT_TraderSession.GetSession then
        sessionData = DT_TraderSession.GetSession(traderID)
    end
    
    local traderBudget = sessionData and sessionData.budget or factionWealth

    local trader = {
        traderID = traderID,
        archetype = stock.archetype or archetype or "General",
        name = stock.name or "Trader",
        wallet = stock.wallet or 0,
        budget = traderBudget,
        stocks = processedStocks,
        deflation = stock.deflation or {},
        factionID = stock.factionID,
        identitySeed = stock.identitySeed,
        gender = stock.gender or "Male",
        returnTime = stock.returnTime,
        npcRef = self._currentNPC
    }

    if DT_Reputation then
        trader.personalRep = DT_Reputation.GetPersonalRep(traderID)
        trader.factionRep = DT_Reputation.GetFactionRep(stock.factionID)
        trader.reputation = DT_Reputation.GetEffectiveRep(traderID, stock.factionID)
        trader.reputationStage = DT_Reputation.GetStageData(trader.reputation).label
        trader.tradeProgress = DT_Reputation.GetTradeProgress(traderID)
        trader.totalBought = DT_Reputation.GetTotalBought(traderID)
        trader.totalSold = DT_Reputation.GetTotalSold(traderID)
    end

    return trader
end
