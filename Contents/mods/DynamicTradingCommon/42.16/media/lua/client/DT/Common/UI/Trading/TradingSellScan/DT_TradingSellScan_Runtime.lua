local Internal = DT_TradingItemUtils.Internal

local function copyScanResults(targetCategorized, targetCategories, sourceCategorized, sourceCategories)
    local key
    local index
    local category

    for key in pairs(targetCategorized) do
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

local function addSellListItem(session, invItem, masterKey, itemData, price)
    local cat = (itemData.tags and itemData.tags[1]) or "Misc"
    local effectiveTags = itemData.tags
    local fluidContainer
    local fluidType
    local fluidCategory
    local scriptItem
    local listItem
    local canGroup
    local groupKey
    local existing

    if invItem.getFluidContainer and invItem:getFluidContainer() then
        fluidContainer = invItem:getFluidContainer()
        if fluidContainer:getAmount() > 0 then
            fluidType = Internal.getFluidTypeID and Internal.getFluidTypeID(fluidContainer) or nil
            fluidCategory = Internal.getFluidCategory and Internal.getFluidCategory(fluidType) or nil
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

    scriptItem = Internal.getCachedSellScanScriptItem(session, itemData.item)
    listItem = {
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

    listItem.priceMod = Internal.getCachedSellScanPriceModifier(session, masterKey, effectiveTags)
    listItem.displayName = DT_TradingItemUtils.getItemDisplayName(listItem, invItem, scriptItem)
    listItem.statusSuffix, listItem.isRotten = DT_TradingItemUtils.getStatusSuffix(listItem, invItem, scriptItem)
    listItem.isLocked = session.lockedItems and session.lockedItems[invItem:getID()] == true or false
    listItem.selectionKey = masterKey .. ":" .. tostring(invItem:getID())

    canGroup = (not listItem.isLocked) and (not instanceof(invItem, "InventoryContainer"))
    if canGroup then
        groupKey = table.concat({
            tostring(masterKey),
            tostring(invItem:getFullType()),
            tostring(listItem.price),
            tostring(cat),
            tostring(listItem.displayName or listItem.name or ""),
            tostring(listItem.statusSuffix or ""),
            listItem.isRotten and "1" or "0"
        }, "|")

        existing = session.groupedEntries[groupKey]
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
    local fullType
    local masterKey
    local itemData
    local price

    if not invItem then
        return
    end

    if invItem:getID() ~= session.activeRadioID then
        session.signatureParts[#session.signatureParts + 1] = Internal.getSellScanItemStateToken(invItem)
    end

    if invItem.isFavorite and invItem:isFavorite() then
        session.dataProvider:lockItem(invItem:getID())
    end

    fullType = invItem:getFullType()
    if fullType == "Base.Money" or fullType == "Base.MoneyBundle" or invItem:getID() == session.activeRadioID then
        return
    end

    masterKey = Internal.getCachedSellScanMasterKey(session, fullType)
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

    itemData = Internal.getCachedSellScanItemData(session, masterKey)
    if not itemData then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Missing item data"
        end
        return
    end

    price = Internal.getCachedSellScanPrice(session, invItem, masterKey)
    if price <= 0 then
        if session.rejections then
            session.rejections[#session.rejections + 1] = "[Sell] " .. fullType .. " | REJECTED: Price is 0"
        end
        return
    end

    addSellListItem(session, invItem, masterKey, itemData, price)
    session.needsListRefresh = true
end

function Internal.finalizeSellScanSession(session)
    session.inventorySignature = table.concat({
        "rev=" .. tostring(session.inventoryRevision or 0),
        "nested=" .. tostring(session.nestedContainerCount or 0),
        table.concat(session.signatureParts or {}, ";")
    }, "|")
    session.completed = true
    session.completedAt = Internal.sellScanNowMs()
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
    Internal.rememberSellScanCacheKey(session.cacheKey)

    Internal.sellScanPerfLog(
        "SellScan",
        "Completed scan trader=" .. tostring(session.traderID)
            .. " processed=" .. tostring(session.processedCount)
            .. " visibleCats=" .. tostring(#(session.categories or {}))
            .. " durationMs=" .. tostring((session.completedAt or Internal.sellScanNowMs()) - (session.startedAt or Internal.sellScanNowMs()))
            .. " priceCacheHits=" .. tostring(session.priceCacheHits or 0)
            .. " priceCacheMisses=" .. tostring(session.priceCacheMisses or 0)
    )
end

function Internal.processSellScanSession(session, batchSize, maxFrameMs)
    local itemLimit
    local frameBudgetMs
    local startedAt
    local processedThisChunk
    local frame
    local container
    local items
    local invItem
    local subContainer

    if not session or session.completed then
        return false
    end

    itemLimit = math.max(1, math.floor(tonumber(batchSize) or Internal.SELL_SCAN_BATCH_SIZE or 1))
    frameBudgetMs = math.max(1, math.floor(tonumber(maxFrameMs) or Internal.SELL_SCAN_MAX_FRAME_MS or 1))
    startedAt = Internal.sellScanNowMs()
    processedThisChunk = 0

    while #session.pendingContainers > 0 and processedThisChunk < itemLimit do
        if (Internal.sellScanNowMs() - startedAt) >= frameBudgetMs then
            break
        end

        frame = session.pendingContainers[#session.pendingContainers]
        container = frame and frame.container or nil
        items = container and container.getItems and container:getItems() or nil

        if not items or frame.index >= items:size() then
            table.remove(session.pendingContainers)
        else
            invItem = items:get(frame.index)
            frame.index = frame.index + 1

            if invItem then
                processSellItem(session, invItem)
                session.processedCount = session.processedCount + 1
                processedThisChunk = processedThisChunk + 1

                if instanceof(invItem, "InventoryContainer") then
                    subContainer = invItem:getItemContainer()
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

    session.lastChunkDurationMs = Internal.sellScanNowMs() - startedAt
    session.lastChunkProcessed = processedThisChunk

    if #session.pendingContainers <= 0 then
        Internal.finalizeSellScanSession(session)
    end

    return processedThisChunk > 0 or session.completed
end

function Internal.consumeSellScanResults(session, categorized, categories)
    if not session then
        return
    end

    copyScanResults(categorized, categories, session.categorized, session.categories)
end

function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, rejections)
    local session

    categorized = categorized or {}
    categories = categories or {}

    session = Internal.createSellScanSession(player, trader, dataProvider, activeRadioID, rejections)
    while session and not session.completed do
        Internal.processSellScanSession(session, 500, 250)
    end

    Internal.consumeSellScanResults(session, categorized, categories)
end
