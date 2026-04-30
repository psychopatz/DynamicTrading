if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

local Internal = DT_TradingItemUtils.Internal

Internal.SELL_SCAN_BATCH_SIZE = tonumber(Internal.SELL_SCAN_BATCH_SIZE) or 75
Internal.SELL_SCAN_MAX_FRAME_MS = tonumber(Internal.SELL_SCAN_MAX_FRAME_MS) or 8
Internal.SELL_SCAN_CACHE_LIMIT = tonumber(Internal.SELL_SCAN_CACHE_LIMIT) or 12
Internal.SellScanCache = Internal.SellScanCache or {}
Internal.SellScanCacheOrder = Internal.SellScanCacheOrder or {}

local function nowMs()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    return math.floor((os.time() or 0) * 1000)
end

local function isPerfDebugEnabled()
    return DynamicTrading and DynamicTrading.DebugPerformance == true
end

local function perfLog(scope, message)
    if not isPerfDebugEnabled() then
        return
    end

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "TradePerf", tostring(scope or "SellScan"), tostring(message or ""))
    else
        print("[DT TradePerf][" .. tostring(scope or "SellScan") .. "] " .. tostring(message or ""))
    end
end

local function rememberCacheKey(cacheKey)
    local order = Internal.SellScanCacheOrder
    for index = #order, 1, -1 do
        if order[index] == cacheKey then
            table.remove(order, index)
        end
    end

    order[#order + 1] = cacheKey
    while #order > Internal.SELL_SCAN_CACHE_LIMIT do
        local oldestKey = table.remove(order, 1)
        Internal.SellScanCache[oldestKey] = nil
    end
end

local function removeCachedKey(cacheKey)
    Internal.SellScanCache[cacheKey] = nil
    local order = Internal.SellScanCacheOrder
    for index = #order, 1, -1 do
        if order[index] == cacheKey then
            table.remove(order, index)
        end
    end
end

local function appendSignaturePart(parts, value)
    parts[#parts + 1] = tostring(value or "")
end

local function getItemConditionToken(invItem)
    local current = invItem and invItem.getCondition and invItem:getCondition() or 0
    local max = invItem and invItem.getConditionMax and invItem:getConditionMax() or 0
    return tostring(current) .. "/" .. tostring(max)
end

local function getItemDrainToken(invItem)
    if not invItem then
        return ""
    end

    if invItem.IsDrainable and invItem:IsDrainable() and invItem.getUsedDelta then
        return string.format("%.4f", tonumber(invItem:getUsedDelta()) or 0)
    end

    if invItem.getHungerChange then
        return tostring(invItem:getHungerChange() or "")
    end

    return ""
end

local function getItemFluidToken(invItem)
    if not invItem or not invItem.getFluidContainer then
        return ""
    end

    local fluidContainer = invItem:getFluidContainer()
    if not fluidContainer then
        return ""
    end

    local amount = tonumber(fluidContainer.getAmount and fluidContainer:getAmount() or 0) or 0
    local fluidType = Internal.getFluidTypeID and Internal.getFluidTypeID(fluidContainer) or nil
    return tostring(fluidType or "") .. "@" .. string.format("%.4f", amount)
end

local function getItemStateToken(invItem)
    if not invItem then
        return ""
    end

    local parts = {}
    appendSignaturePart(parts, invItem:getID())
    appendSignaturePart(parts, invItem:getFullType())
    appendSignaturePart(parts, getItemConditionToken(invItem))
    appendSignaturePart(parts, getItemDrainToken(invItem))
    appendSignaturePart(parts, getItemFluidToken(invItem))
    appendSignaturePart(parts, invItem.isRotten and invItem:isRotten() and "1" or "0")
    return table.concat(parts, "|")
end

local function copyScanResults(targetCategorized, targetCategories, sourceCategorized, sourceCategories)
    for key, _ in pairs(targetCategorized) do
        targetCategorized[key] = nil
    end
    for index = #targetCategories, 1, -1 do
        targetCategories[index] = nil
    end

    for _, category in ipairs(sourceCategories or {}) do
        targetCategories[#targetCategories + 1] = category
        targetCategorized[category] = sourceCategorized[category]
    end
end

function Internal.invalidateSellScanCaches(reason)
    Internal.SellScanCache = {}
    Internal.SellScanCacheOrder = {}
    perfLog("SellScan", "Invalidated all sell scan caches (" .. tostring(reason or "unspecified") .. ")")
end

function Internal.invalidateSellScanCacheForTrader(traderID, reason)
    local cache = Internal.SellScanCache
    if not traderID or type(cache) ~= "table" then
        return
    end

    for cacheKey, entry in pairs(cache) do
        if entry and entry.traderID == traderID then
            removeCachedKey(cacheKey)
        end
    end

    perfLog("SellScan", "Invalidated sell scan cache for trader " .. tostring(traderID) .. " (" .. tostring(reason or "unspecified") .. ")")
end

function Internal.getInventorySignature(player, activeRadioID)
    local inventory = player and player.getInventory and player:getInventory() or nil
    if not inventory then
        return "no-inventory"
    end

    local parts = {}
    local nestedContainers = 0
    local pendingContainers = {
        {
            container = inventory,
            index = 0,
        }
    }

    while #pendingContainers > 0 do
        local frame = pendingContainers[#pendingContainers]
        local container = frame and frame.container or nil
        local items = container and container.getItems and container:getItems() or nil

        if not items or frame.index >= items:size() then
            table.remove(pendingContainers)
        else
            local invItem = items:get(frame.index)
            frame.index = frame.index + 1

            if invItem then
                if invItem:getID() ~= activeRadioID then
                    parts[#parts + 1] = getItemStateToken(invItem)
                end

                if instanceof(invItem, "InventoryContainer") then
                    local subContainer = invItem:getItemContainer()
                    if subContainer then
                        nestedContainers = nestedContainers + 1
                        pendingContainers[#pendingContainers + 1] = {
                            container = subContainer,
                            index = 0,
                        }
                    end
                end
            end
        end
    end

    return table.concat({
        "root=" .. tostring(inventory:getItems():size()),
        "nested=" .. tostring(nestedContainers),
        table.concat(parts, ";")
    }, "|")
end

function Internal.getInventoryRevision(player)
    local modData = player and player.getModData and player:getModData() or nil
    return tonumber(modData and modData.DT_SellScanRevision or 0) or 0
end

function Internal.getQuickInventoryKey(player, activeRadioID)
    local inventory = player and player.getInventory and player:getInventory() or nil
    local rootCount = inventory and inventory.getItems and inventory:getItems():size() or 0
    return table.concat({
        tostring(Internal.getInventoryRevision(player)),
        tostring(rootCount),
        tostring(activeRadioID or -1)
    }, "|")
end

function Internal.getSellContextVersion(dataProvider, trader)
    local stockVersion = nil
    if dataProvider and dataProvider.getSellPriceContextVersion then
        stockVersion = dataProvider:getSellPriceContextVersion(trader)
    elseif dataProvider and dataProvider.getStockVersion then
        stockVersion = dataProvider:getStockVersion(trader)
    end

    if stockVersion == nil and trader then
        stockVersion = trader.sessionVersion or trader.stockVersion or trader.version
    end

    local priceVersion = DynamicTrading and DynamicTrading.PriceConfig and (DynamicTrading.PriceConfig.version or DynamicTrading.PriceConfig.VERSION) or 0
    return table.concat({
        tostring(stockVersion or ""),
        tostring(trader and trader.factionID or ""),
        tostring(trader and trader.budget or 0),
        tostring(priceVersion or 0)
    }, "|")
end

function Internal.buildSellScanCacheKey(player, trader, dataProvider, activeRadioID)
    local inventorySignature = Internal.getQuickInventoryKey(player, activeRadioID)
    local contextVersion = Internal.getSellContextVersion(dataProvider, trader)
    local traderID = trader and trader.traderID or "unknown"

    return table.concat({
        tostring(traderID),
        tostring(contextVersion),
        tostring(inventorySignature)
    }, "::"), inventorySignature, contextVersion
end

local function createSessionCaches()
    return {
        masterKeyCache = {},
        itemDataCache = {},
        scriptItemCache = {},
        priceModifierCache = {},
        priceCache = {},
    }
end

local function getCachedMasterKey(session, fullType)
    local cache = session.caches.masterKeyCache
    local cached = cache[fullType]
    if cached ~= nil then
        return cached or nil
    end

    local masterKey = nil
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
    if cached ~= nil then
        return cached or nil
    end

    local itemData = session.dataProvider:getItemData(masterKey)
    cache[masterKey] = itemData or false
    return itemData
end

local function getCachedScriptItem(session, itemType)
    if not itemType then
        return nil
    end

    local cache = session.caches.scriptItemCache
    local cached = cache[itemType]
    if cached ~= nil then
        return cached or nil
    end

    local scriptItem = session.scriptManager and session.scriptManager:getItem(itemType) or nil
    cache[itemType] = scriptItem or false
    return scriptItem
end

local function getCachedPriceModifier(session, masterKey, tags)
    local normalizedTags = tags or {}
    local cacheKey = tostring(masterKey) .. "|" .. table.concat(normalizedTags, ",")
    local cache = session.caches.priceModifierCache
    local cached = cache[cacheKey]
    if cached ~= nil then
        return cached
    end

    local priceModifier = session.dataProvider:getPriceModifier(normalizedTags)
    cache[cacheKey] = priceModifier
    return priceModifier
end

local function buildPriceCacheKey(session, invItem, masterKey)
    return table.concat({
        tostring(session.traderID or ""),
        tostring(session.contextVersion or ""),
        tostring(masterKey or ""),
        getItemStateToken(invItem)
    }, "::")
end

local function getCachedPrice(session, invItem, masterKey)
    local priceKey = buildPriceCacheKey(session, invItem, masterKey)
    local cache = session.caches.priceCache
    local cached = cache[priceKey]
    if cached ~= nil then
        session.priceCacheHits = (tonumber(session.priceCacheHits) or 0) + 1
        return tonumber(cached) or 0
    end

    local price = session.dataProvider:getSellPrice(invItem, masterKey, session.trader)
    cache[priceKey] = tonumber(price) or 0
    session.priceCacheMisses = (tonumber(session.priceCacheMisses) or 0) + 1
    return cache[priceKey]
end

local function addSellListItem(session, invItem, masterKey, itemData, price)
    local cat = (itemData.tags and itemData.tags[1]) or "Misc"
    local effectiveTags = itemData.tags

    if invItem.getFluidContainer and invItem:getFluidContainer() then
        local fluidContainer = invItem:getFluidContainer()
        if fluidContainer:getAmount() > 0 then
            local fluidType = Internal.getFluidTypeID and Internal.getFluidTypeID(fluidContainer) or nil
            local fluidCategory = Internal.getFluidCategory and Internal.getFluidCategory(fluidType) or nil
            if fluidCategory then
                cat = fluidCategory
                effectiveTags = Internal.getFluidTags and Internal.getFluidTags(fluidType) or effectiveTags
            end
        end
    end

    if invItem.isRotten and invItem:isRotten() then
        cat = "Rotten"
    end

    if not session.categorized[cat] then
        session.categorized[cat] = {}
        session.categories[#session.categories + 1] = cat
    end

    local scriptItem = getCachedScriptItem(session, itemData.item)
    local listItem = {
        key = masterKey,
        itemID = invItem:getID(),
        name = invItem:getDisplayName(),
        price = tonumber(price) or 0,
        data = itemData,
        scriptItem = scriptItem,
        isBuy = false,
        invItem = invItem,
        qty = 1,
        itemIDs = { invItem:getID() },
        effectiveCategory = cat,
        effectiveTags = effectiveTags,
    }

    listItem.priceMod = getCachedPriceModifier(session, masterKey, effectiveTags)
    listItem.displayName = DT_TradingItemUtils.getItemDisplayName(listItem, invItem, scriptItem)
    listItem.statusSuffix, listItem.isRotten = DT_TradingItemUtils.getStatusSuffix(listItem, invItem, scriptItem)
    listItem.isLocked = session.lockedItems and session.lockedItems[invItem:getID()] == true or false
    listItem.selectionKey = masterKey .. ":" .. tostring(invItem:getID())

    local canGroup = (not listItem.isLocked) and (not instanceof(invItem, "InventoryContainer"))
    if canGroup then
        local groupKey = table.concat({
            tostring(masterKey),
            tostring(invItem:getFullType()),
            tostring(listItem.price),
            tostring(cat),
            tostring(listItem.displayName or listItem.name or ""),
            tostring(listItem.statusSuffix or ""),
            listItem.isRotten and "1" or "0"
        }, "|")

        local existing = session.groupedEntries[groupKey]
        if existing then
            existing.qty = (existing.qty or 1) + 1
            existing.isGrouped = true
            existing.itemIDs[#existing.itemIDs + 1] = invItem:getID()
            return
        end

        session.groupedEntries[groupKey] = listItem
        listItem.selectionKey = groupKey
    end

    session.categorized[cat][#session.categorized[cat] + 1] = listItem
end

local function processSellItem(session, invItem)
    if not invItem then
        return
    end

    if invItem:getID() ~= session.activeRadioID then
        session.signatureParts[#session.signatureParts + 1] = getItemStateToken(invItem)
    end

    if invItem.isFavorite and invItem:isFavorite() then
        session.dataProvider:lockItem(invItem:getID())
    end

    local fullType = invItem:getFullType()
    if fullType == "Base.Money" or fullType == "Base.MoneyBundle" or invItem:getID() == session.activeRadioID then
        return
    end

    local masterKey = getCachedMasterKey(session, fullType)
    if not masterKey then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Item not found in Master Registry"
        end
        return
    end

    if session.traderStocks and session.traderStocks[masterKey] ~= nil then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Trader already has this key in stock"
        end
        return
    end

    local itemData = getCachedItemData(session, masterKey)
    if not itemData then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Missing item data"
        end
        return
    end

    local price = getCachedPrice(session, invItem, masterKey)
    if price <= 0 then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Price is 0"
        end
        return
    end

    addSellListItem(session, invItem, masterKey, itemData, price)
    session.needsListRefresh = true
end

local function finalizeSession(session)
    session.inventorySignature = table.concat({
        "rev=" .. tostring(session.inventoryRevision or 0),
        "nested=" .. tostring(session.nestedContainerCount or 0),
        table.concat(session.signatureParts or {}, ";")
    }, "|")
    session.completed = true
    session.completedAt = nowMs()
    session.needsListRefresh = true

    Internal.SellScanCache[session.cacheKey] = {
        traderID = session.traderID,
        inventorySignature = session.inventorySignature,
        contextVersion = session.contextVersion,
        categorized = session.categorized,
        categories = session.categories,
        groupedEntries = session.groupedEntries,
        processedCount = session.processedCount,
        priceCache = session.caches.priceCache,
    }
    rememberCacheKey(session.cacheKey)

    perfLog(
        "SellScan",
        "Completed scan trader=" .. tostring(session.traderID)
            .. " processed=" .. tostring(session.processedCount)
            .. " visibleCats=" .. tostring(#(session.categories or {}))
            .. " durationMs=" .. tostring((session.completedAt or nowMs()) - (session.startedAt or nowMs()))
            .. " priceCacheHits=" .. tostring(session.priceCacheHits or 0)
            .. " priceCacheMisses=" .. tostring(session.priceCacheMisses or 0)
    )
end

function Internal.createSellScanSession(player, trader, dataProvider, activeRadioID, rejections)
    local cacheKey, inventorySignature, contextVersion = Internal.buildSellScanCacheKey(player, trader, dataProvider, activeRadioID)
    local cached = Internal.SellScanCache[cacheKey]
    if cached then
        rememberCacheKey(cacheKey)
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
            startedAt = nowMs(),
            completedAt = nowMs(),
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

    local inventory = player and player.getInventory and player:getInventory() or nil
    local session = {
        scanId = tostring(trader and trader.traderID or "unknown") .. ":" .. tostring(nowMs()),
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
        caches = createSessionCaches(),
        priceCacheHits = 0,
        priceCacheMisses = 0,
        startedAt = nowMs(),
    }

    if inventory then
        session.pendingContainers[#session.pendingContainers + 1] = {
            container = inventory,
            index = 0,
        }
    else
        finalizeSession(session)
    end

    return session
end

function Internal.processSellScanSession(session, batchSize, maxFrameMs)
    if not session or session.completed then
        return false
    end

    local itemLimit = math.max(1, math.floor(tonumber(batchSize) or Internal.SELL_SCAN_BATCH_SIZE or 1))
    local frameBudgetMs = math.max(1, math.floor(tonumber(maxFrameMs) or Internal.SELL_SCAN_MAX_FRAME_MS or 1))
    local startedAt = nowMs()
    local processedThisChunk = 0

    while #session.pendingContainers > 0 and processedThisChunk < itemLimit do
        if (nowMs() - startedAt) >= frameBudgetMs then
            break
        end

        local frame = session.pendingContainers[#session.pendingContainers]
        local container = frame and frame.container or nil
        local items = container and container.getItems and container:getItems() or nil

        if not items or frame.index >= items:size() then
            table.remove(session.pendingContainers)
        else
            local invItem = items:get(frame.index)
            frame.index = frame.index + 1

            if invItem then
                processSellItem(session, invItem)
                session.processedCount = session.processedCount + 1
                processedThisChunk = processedThisChunk + 1

                if instanceof(invItem, "InventoryContainer") then
                    local subContainer = invItem:getItemContainer()
                    if subContainer then
                        session.nestedContainerCount = (tonumber(session.nestedContainerCount) or 0) + 1
                        session.pendingContainers[#session.pendingContainers + 1] = {
                            container = subContainer,
                            index = 0,
                        }
                    end
                end
            end
        end
    end

    session.lastChunkDurationMs = nowMs() - startedAt
    session.lastChunkProcessed = processedThisChunk

    if #session.pendingContainers <= 0 then
        finalizeSession(session)
    end

    return processedThisChunk > 0 or session.completed
end

function Internal.consumeSellScanResults(session, categorized, categories)
    if not session then
        return
    end

    copyScanResults(categorized, categories, session.categorized, session.categories)
end

--- Compatibility wrapper for legacy callers that still expect a synchronous scan.
function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, rejections)
    categorized = categorized or {}
    categories = categories or {}

    local session = Internal.createSellScanSession(player, trader, dataProvider, activeRadioID, rejections)
    while session and not session.completed do
        Internal.processSellScanSession(session, 500, 250)
    end

    Internal.consumeSellScanResults(session, categorized, categories)
end
