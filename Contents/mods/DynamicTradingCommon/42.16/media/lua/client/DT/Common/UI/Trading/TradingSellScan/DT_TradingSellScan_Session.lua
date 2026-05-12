local Internal = DT_TradingItemUtils.Internal

local function getCachedMasterKey(session, fullType)
    local cache = session.caches.masterKeyCache
    local cached = cache[fullType]
    local masterKey

    if cached ~= nil then
        return cached or nil
    end

    if type(session.getMasterKeyFn) == "function" then
        masterKey = session.dataProvider:getMasterKey(fullType)
    else
        masterKey = DynamicTrading.Utils.GetMasterKey(fullType)
    end

    cache[fullType] = masterKey or false
    return masterKey
end

local function getCachedItemData(session, masterKey)
    local cache = session.caches.itemDataCache
    local cached = cache[masterKey]
    local itemData

    if cached ~= nil then
        return cached or nil
    end

    itemData = session.dataProvider:getItemData(masterKey)
    cache[masterKey] = itemData or false
    return itemData
end

local function getCachedScriptItem(session, itemType)
    local cache
    local cached
    local scriptItem

    if not itemType then
        return nil
    end

    cache = session.caches.scriptItemCache
    cached = cache[itemType]
    if cached ~= nil then
        return cached or nil
    end

    scriptItem = session.scriptManager and session.scriptManager:getItem(itemType) or nil
    cache[itemType] = scriptItem or false
    return scriptItem
end

local function getCachedPriceModifier(session, masterKey, tags)
    local normalizedTags = tags or {}
    local cacheKey = tostring(masterKey) .. "|" .. table.concat(normalizedTags, ",")
    local cache = session.caches.priceModifierCache
    local cached = cache[cacheKey]
    local priceModifier

    if cached ~= nil then
        return cached
    end

    priceModifier = session.dataProvider:getPriceModifier(normalizedTags)
    cache[cacheKey] = priceModifier
    return priceModifier
end

local function buildPriceCacheKey(session, invItem, masterKey)
    return table.concat({
        tostring(session.traderID or ""),
        tostring(session.contextVersion or ""),
        tostring(masterKey or ""),
        Internal.getSellScanItemStateToken(invItem)
    }, "::")
end

local function getCachedPrice(session, invItem, masterKey)
    local priceKey = buildPriceCacheKey(session, invItem, masterKey)
    local cache = session.caches.priceCache
    local cached = cache[priceKey]
    local price

    if cached ~= nil then
        session.priceCacheHits = (tonumber(session.priceCacheHits) or 0) + 1
        return tonumber(cached) or 0
    end

    price = session.dataProvider:getSellPrice(invItem, masterKey, session.trader)
    cache[priceKey] = tonumber(price) or 0
    session.priceCacheMisses = (tonumber(session.priceCacheMisses) or 0) + 1
    return cache[priceKey]
end

Internal.getCachedSellScanMasterKey = getCachedMasterKey
Internal.getCachedSellScanItemData = getCachedItemData
Internal.getCachedSellScanScriptItem = getCachedScriptItem
Internal.getCachedSellScanPriceModifier = getCachedPriceModifier
Internal.buildSellScanPriceCacheKey = buildPriceCacheKey
Internal.getCachedSellScanPrice = getCachedPrice

function Internal.createSellScanSession(player, trader, dataProvider, activeRadioID, rejections)
    local cacheKey, inventorySignature, contextVersion = Internal.buildSellScanCacheKey(player, trader, dataProvider, activeRadioID)
    local cached = Internal.SellScanCache[cacheKey]
    local inventory
    local session

    if cached then
        Internal.rememberSellScanCacheKey(cacheKey)
        return {
            cacheKey = cacheKey,
            traderID = trader and trader.traderID or nil,
            trader = trader,
            dataProvider = dataProvider,
            activeRadioID = activeRadioID,
            rejections = rejections,
            inventorySignature = inventorySignature,
            contextVersion = contextVersion,
            categorized = cached.categorized or {},
            categories = cached.categories or {},
            groupedEntries = cached.groupedEntries or {},
            processedCount = tonumber(cached.processedCount) or 0,
            completed = true,
            reusedCachedResults = true,
            startedAt = Internal.sellScanNowMs(),
            completedAt = Internal.sellScanNowMs(),
            priceCacheHits = 0,
            priceCacheMisses = 0,
            needsListRefresh = false,
            caches = {
                masterKeyCache = {},
                itemDataCache = {},
                scriptItemCache = {},
                priceModifierCache = {},
                priceCache = cached.priceCache or {},
            }
        }
    end

    inventory = player and player.getInventory and player:getInventory() or nil
    session = {
        scanId = tostring(trader and trader.traderID or "unknown") .. ":" .. tostring(Internal.sellScanNowMs()),
        cacheKey = cacheKey,
        traderID = trader and trader.traderID or nil,
        trader = trader,
        dataProvider = dataProvider,
        getMasterKeyFn = dataProvider and dataProvider.getMasterKey or nil,
        activeRadioID = activeRadioID or -1,
        rejections = rejections,
        inventorySignature = inventorySignature,
        inventoryRevision = Internal.getInventoryRevision(player),
        contextVersion = contextVersion,
        pendingContainers = {},
        categorized = {},
        categories = {},
        groupedEntries = {},
        signatureParts = {},
        nestedContainerCount = 0,
        processedCount = 0,
        completed = false,
        needsListRefresh = false,
        traderStocks = trader and trader.stocks or nil,
        scriptManager = getScriptManager and getScriptManager() or nil,
        lockedItems = player and player.getModData and player:getModData().DT_LockedItems or nil,
        caches = Internal.createSellScanSessionCaches(),
        priceCacheHits = 0,
        priceCacheMisses = 0,
        startedAt = Internal.sellScanNowMs(),
    }

    if inventory then
        session.pendingContainers[#session.pendingContainers + 1] = {
            container = inventory,
            index = 0,
        }
    else
        Internal.finalizeSellScanSession(session)
    end

    return session
end
