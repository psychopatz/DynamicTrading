local Internal = DT_TradingItemUtils.Internal

Internal.SELL_SCAN_BATCH_SIZE = tonumber(Internal.SELL_SCAN_BATCH_SIZE) or 75
Internal.SELL_SCAN_MAX_FRAME_MS = tonumber(Internal.SELL_SCAN_MAX_FRAME_MS) or 8
Internal.SELL_SCAN_CACHE_LIMIT = tonumber(Internal.SELL_SCAN_CACHE_LIMIT) or 12
Internal.SellScanCache = Internal.SellScanCache or {}
Internal.SellScanCacheOrder = Internal.SellScanCacheOrder or {}

function Internal.sellScanNowMs()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    return math.floor((os.time() or 0) * 1000)
end

function Internal.isSellScanPerfDebugEnabled()
    return DynamicTrading and DynamicTrading.DebugPerformance == true
end

function Internal.sellScanPerfLog(scope, message)
    if not Internal.isSellScanPerfDebugEnabled() then
        return
    end

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "TradePerf", tostring(scope or "SellScan"), tostring(message or ""))
    else
        print("[DT TradePerf][" .. tostring(scope or "SellScan") .. "] " .. tostring(message or ""))
    end
end

function Internal.createSellScanSessionCaches()
    return {
        masterKeyCache = {},
        itemDataCache = {},
        scriptItemCache = {},
        priceModifierCache = {},
        priceCache = {},
    }
end
