-- =============================================================================
-- TradingWindowWrapper_Polling.lua
-- Polling-based stock refresh while the trading window is visible.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}
DT_TradingWindowWrapper_State = DT_TradingWindowWrapper_State or {
    lastStockVersion = nil,
    currentTraderID = nil
}

local function OnPreUIDraw()
    if not DT_TradingWindow or not DT_TradingWindow.instance then return end
    if not DT_TradingWindow.instance:getIsVisible() then return end

    local ui = DT_TradingWindow.instance
    local traderID = ui.traderID
    if not traderID then return end

    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
        or ModData.get("DynamicTrading_Stock")
    if not stockData or not stockData[traderID] then return end

    local stock = stockData[traderID]

    local version = V2_DataProvider.getStockVersion and V2_DataProvider:getStockVersion(traderID)
    if not version then
        version = tostring(stock.version or stock.factionWealth or 0)
    end

    if DT_TradingWindowWrapper_State.currentTraderID == traderID
        and DT_TradingWindowWrapper_State.lastStockVersion
        and DT_TradingWindowWrapper_State.lastStockVersion ~= version then
        DynamicTrading.Log("DTV2", "Trade", "Sync", "Stock version changed for " .. tostring(traderID) .. ", refreshing UI")
        DT_TradingWindowWrapper_State.lastStockVersion = version
        if V2_DataProvider.invalidateTraderCache then
            V2_DataProvider:invalidateTraderCache(traderID)
        end
        if DT_TradingItemUtils and DT_TradingItemUtils.Internal and DT_TradingItemUtils.Internal.invalidateSellScanCacheForTrader then
            DT_TradingItemUtils.Internal.invalidateSellScanCacheForTrader(traderID, "stock-version-change")
        end
        -- Defer rebuild into the window update loop so we don't mutate list rows
        -- while the UI is handling mouse input for the current frame.
        ui.inventoryDirty = true
        ui.refreshCooldown = 0
    elseif DT_TradingWindowWrapper_State.currentTraderID ~= traderID then
        DT_TradingWindowWrapper_State.currentTraderID = traderID
        DT_TradingWindowWrapper_State.lastStockVersion = version
    elseif not DT_TradingWindowWrapper_State.lastStockVersion then
        DT_TradingWindowWrapper_State.lastStockVersion = version
    end
end

Events.OnPreUIDraw.Add(OnPreUIDraw)
