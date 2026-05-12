local Internal = DT_TradingItemUtils.Internal

function Internal.rememberSellScanCacheKey(cacheKey)
    local order = Internal.SellScanCacheOrder
    local index
    local oldestKey

    for index = #order, 1, -1 do
        if order[index] == cacheKey then
            table.remove(order, index)
        end
    end

    order[#order + 1] = cacheKey
    while #order > Internal.SELL_SCAN_CACHE_LIMIT do
        oldestKey = table.remove(order, 1)
        Internal.SellScanCache[oldestKey] = nil
    end
end

function Internal.removeSellScanCachedKey(cacheKey)
    local order = Internal.SellScanCacheOrder
    local index

    Internal.SellScanCache[cacheKey] = nil
    for index = #order, 1, -1 do
        if order[index] == cacheKey then
            table.remove(order, index)
        end
    end
end

function Internal.invalidateSellScanCaches(reason)
    Internal.SellScanCache = {}
    Internal.SellScanCacheOrder = {}
    Internal.sellScanPerfLog("SellScan", "Invalidated all sell scan caches (" .. tostring(reason or "unspecified") .. ")")
end

function Internal.invalidateSellScanCacheForTrader(traderID, reason)
    local cache = Internal.SellScanCache
    local cacheKey
    local entry

    if not traderID or type(cache) ~= "table" then
        return
    end

    for cacheKey, entry in pairs(cache) do
        if entry and entry.traderID == traderID then
            Internal.removeSellScanCachedKey(cacheKey)
        end
    end

    Internal.sellScanPerfLog("SellScan", "Invalidated sell scan cache for trader " .. tostring(traderID) .. " (" .. tostring(reason or "unspecified") .. ")")
end
