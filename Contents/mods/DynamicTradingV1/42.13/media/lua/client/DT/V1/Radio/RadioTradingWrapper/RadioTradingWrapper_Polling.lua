-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - POLLING
-- =============================================================================
-- Auto-refresh logic for the trading UI when stock data changes.
-- =============================================================================

V1_RadioTradingWrapper_Polling_logic = {}

-- Stock version tracking for polling-based refresh
local _lastStockVersion = nil
local _currentTraderID = nil

function V1_RadioTradingWrapper_Polling_logic.OnPreUIDraw()
    if not DT_TradingWindow or not DT_TradingWindow.instance then return end
    if not DT_TradingWindow.instance:getIsVisible() then return end
    
    local ui = DT_TradingWindow.instance
    local traderID = ui.traderID
    if not traderID then return end
    
    -- Get current stock from cache
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if not stockData or not stockData[traderID] then return end
    
    local stock = stockData[traderID]
    
    -- Build a version fingerprint from factionWealth + total qty
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
    
    -- Track player inventory count for sell mode refreshing
    local playerItemCount = 0
    if not ui.isBuying then
        local player = getSpecificPlayer(0)
        if player and not player:isDead() and player:getInventory() then
            playerItemCount = player:getInventory():getItems():size()
        end
    end
    
    local version = tostring(stock.factionWealth or 0) .. "_" .. tostring(totalQty) .. "_" .. tostring(playerItemCount)
    
    -- Check if version changed
    if _currentTraderID == traderID and _lastStockVersion and _lastStockVersion ~= version then
        DynamicTrading.Log("DTV1", "UI", "Refresh", "Stock version changed, refreshing UI")
        _lastStockVersion = version
        ui:populateList()
    elseif _currentTraderID ~= traderID then
        _currentTraderID = traderID
        _lastStockVersion = version
    elseif not _lastStockVersion then
        _lastStockVersion = version
    end
end

Events.OnPreUIDraw.Remove(V1_RadioTradingWrapper_Polling_logic.OnPreUIDraw)
Events.OnPreUIDraw.Add(V1_RadioTradingWrapper_Polling_logic.OnPreUIDraw)

DynamicTrading.Log("DTV1", "Init", "Polling", "V1 Radio Trading Polling Logic Loaded")
