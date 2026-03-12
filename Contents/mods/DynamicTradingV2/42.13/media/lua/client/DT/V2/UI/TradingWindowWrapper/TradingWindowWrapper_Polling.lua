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

    local totalQty = 0
    if stock.items then
        for _, item in pairs(stock.items) do
            if type(item) == "table" then
                totalQty = totalQty + (item.qty or 0)
            else
                totalQty = totalQty + (item or 0)
            end
        end
    end

    local playerItemCount = 0
    if not ui.isBuying then
        local player = getSpecificPlayer(0)
        if player and not player:isDead() and player:getInventory() then
            playerItemCount = player:getInventory():getItems():size()
        end
    end

    local version = tostring(stock.factionWealth or 0) .. "_" .. tostring(totalQty) .. "_" .. tostring(playerItemCount)

    if DT_TradingWindowWrapper_State.currentTraderID == traderID
        and DT_TradingWindowWrapper_State.lastStockVersion
        and DT_TradingWindowWrapper_State.lastStockVersion ~= version then
        DynamicTrading.Log("DTV2", "Trade", "Sync", "Stock version changed for " .. tostring(traderID) .. ", refreshing UI")
        DT_TradingWindowWrapper_State.lastStockVersion = version
        ui:populateList()
    elseif DT_TradingWindowWrapper_State.currentTraderID ~= traderID then
        DT_TradingWindowWrapper_State.currentTraderID = traderID
        DT_TradingWindowWrapper_State.lastStockVersion = version
    elseif not DT_TradingWindowWrapper_State.lastStockVersion then
        DT_TradingWindowWrapper_State.lastStockVersion = version
    end
end

Events.OnPreUIDraw.Add(OnPreUIDraw)
