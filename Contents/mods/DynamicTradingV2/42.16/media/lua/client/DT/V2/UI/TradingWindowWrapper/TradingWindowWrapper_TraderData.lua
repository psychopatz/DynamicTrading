-- =============================================================================
-- TradingWindowWrapper_TraderData.lua
-- Trader proxy construction and stock/faction cache reads.
-- =============================================================================

require "DT/Common/Faction/TradingSys/TraderSession/DT_TraderSession"

V2_DataProvider = V2_DataProvider or {}
V2_DataProvider._traderSessionCache = V2_DataProvider._traderSessionCache or {}

local function buildFallbackStockVersion(stock)
    if type(stock) ~= "table" then
        return "missing"
    end

    local totalQty = 0
    if stock.items then
        for _, item in pairs(stock.items) do
            if type(item) == "table" then
                totalQty = totalQty + (tonumber(item.qty) or 0)
            else
                totalQty = totalQty + (tonumber(item) or 0)
            end
        end
    end

    return table.concat({
        tostring(stock.factionWealth or 0),
        tostring(totalQty),
        tostring(stock.lastTradeAt or ""),
        tostring(stock.lastInteractedAt or "")
    }, "|")
end

function V2_DataProvider:invalidateTraderCache(traderID)
    if not traderID then
        self._traderSessionCache = {}
        return
    end

    self._traderSessionCache = self._traderSessionCache or {}
    self._traderSessionCache[traderID] = nil
end

function V2_DataProvider:invalidateTradeCaches(traderID)
    self:invalidateTraderCache(traderID)
end

function V2_DataProvider:getStockVersion(trader)
    if type(trader) == "table" then
        return trader.stockVersion or trader.version or trader.sessionVersion
    end

    local traderID = trader or self._currentTraderID
    if not traderID then
        return nil
    end

    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
        or ModData.get("DynamicTrading_Stock")
    local stock = stockData and stockData[traderID] or nil
    if not stock then
        return nil
    end

    return tostring(stock.version or buildFallbackStockVersion(stock))
end

function V2_DataProvider:getTrader(traderID, archetype)
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
        or ModData.get("DynamicTrading_Stock")

    if not stockData or not stockData[traderID] then
        return nil
    end

    local stock = stockData[traderID]
    local stockVersion = tostring(stock.version or buildFallbackStockVersion(stock))

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

    local traderBudget = tonumber(stock.budget)
    if traderBudget == nil then
        traderBudget = sessionData and sessionData.budget or factionWealth
    end
    local cacheVersion = table.concat({
        tostring(stockVersion),
        tostring(factionWealth or 0),
        tostring(traderBudget or 0)
    }, "::")
    local cache = self._traderSessionCache or {}
    self._traderSessionCache = cache
    local cached = cache[traderID]
    if cached and cached.version == cacheVersion and cached.trader then
        self._stockItems = cached.stockItems or (stock.items or {})
        return cached.trader
    end

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
        npcRef = self._currentNPC,
        stockVersion = stockVersion,
        sessionVersion = cacheVersion
    }

    if DT_Reputation then
        trader.personalRep = DT_Reputation.GetPersonalRep(traderID, factionID)
        trader.factionRep = DT_Reputation.GetFactionRep(stock.factionID)
        trader.reputation = DT_Reputation.GetEffectiveRep(traderID, stock.factionID)
        trader.reputationStage = DT_Reputation.GetStageData(trader.reputation).label
        trader.tradeProgress = DT_Reputation.GetTradeProgress(traderID)
        trader.totalBought = DT_Reputation.GetTotalBought(traderID)
        trader.totalSold = DT_Reputation.GetTotalSold(traderID)
        trader.totalGifted = DT_Reputation.GetTotalGifted(traderID)
    end

    cache[traderID] = {
        version = cacheVersion,
        trader = trader,
        stockItems = stock.items or {},
    }

    return trader
end
