if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

--- Populates a table with items sellable by the player.
function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, rejections)
    local inv = player:getInventory()
    local getMasterKeyFn = dataProvider and dataProvider.getMasterKey
    local traderStocks = trader and trader.stocks
    local scriptManager = getScriptManager()
    local modData = player and player:getModData() or nil
    local lockedItems = modData and modData.DT_LockedItems or nil
    local masterKeyCache = {}
    local itemDataCache = {}
    local scriptItemCache = {}
    local priceModifierCache = {}
    local groupedEntries = {}

    local function getCachedMasterKey(fullType)
        local cached = masterKeyCache[fullType]
        if cached ~= nil then
            return cached or nil
        end

        local masterKey = nil
        if type(getMasterKeyFn) == "function" then
            masterKey = dataProvider:getMasterKey(fullType)
        else
            masterKey = DynamicTrading.Utils.GetMasterKey(fullType)
        end

        masterKeyCache[fullType] = masterKey or false
        return masterKey
    end

    local function getCachedItemData(masterKey)
        local cached = itemDataCache[masterKey]
        if cached ~= nil then
            return cached or nil
        end

        local itemData = dataProvider:getItemData(masterKey)
        itemDataCache[masterKey] = itemData or false
        return itemData
    end

    local function getCachedScriptItem(itemType)
        if not itemType then
            return nil
        end

        local cached = scriptItemCache[itemType]
        if cached ~= nil then
            return cached or nil
        end

        local scriptItem = scriptManager:getItem(itemType)
        scriptItemCache[itemType] = scriptItem or false
        return scriptItem
    end

    local function getCachedPriceModifier(masterKey, tags)
        local cacheKey = tostring(masterKey) .. "|" .. table.concat(tags or {}, ",")
        local cached = priceModifierCache[cacheKey]
        if cached ~= nil then
            return cached
        end

        local priceModifier = dataProvider:getPriceModifier(tags or {})
        priceModifierCache[cacheKey] = priceModifier
        return priceModifier
    end

    local function processItem(invItem)
        if not invItem then
            return
        end

        if invItem:isFavorite() then
            dataProvider:lockItem(invItem:getID())
        end

        local fullType = invItem:getFullType()
        if fullType == "Base.Money" or fullType == "Base.MoneyBundle" or invItem:getID() == activeRadioID then
            return
        end

        local masterKey = getCachedMasterKey(fullType)
        if not masterKey then
            if rejections then
                table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Item not found in Master Registry")
            end
            return
        end

        if traderStocks and traderStocks[masterKey] ~= nil then
            if rejections then
                table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Trader already has this key in stock")
            end
            return
        end

        local itemData = getCachedItemData(masterKey)
        if not itemData then
            if rejections then
                table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Missing item data")
            end
            return
        end

        local price = dataProvider:getSellPrice(invItem, masterKey, trader)
        if price <= 0 then
            if rejections then
                table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Price is 0")
            end
            return
        end

        local cat = (itemData.tags and itemData.tags[1]) or "Misc"
        local effectiveTags = itemData.tags

        if invItem.getFluidContainer and invItem:getFluidContainer() then
            local fc = invItem:getFluidContainer()
            if fc:getAmount() > 0 then
                local fluidType = DT_TradingItemUtils.Internal.getFluidTypeID(fc)
                local fluidCategory = DT_TradingItemUtils.Internal.getFluidCategory(fluidType)
                if fluidCategory then
                    cat = fluidCategory
                    effectiveTags = DT_TradingItemUtils.Internal.getFluidTags(fluidType) or effectiveTags
                end
            end
        end

        if invItem.isRotten and invItem:isRotten() then
            cat = "Rotten"
        end

        if not categorized[cat] then
            categorized[cat] = {}
            table.insert(categories, cat)
        end

        local scriptItem = getCachedScriptItem(itemData.item)
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

        listItem.priceMod = getCachedPriceModifier(masterKey, effectiveTags)
        listItem.displayName = DT_TradingItemUtils.getItemDisplayName(listItem, invItem, scriptItem)
        listItem.statusSuffix, listItem.isRotten = DT_TradingItemUtils.getStatusSuffix(listItem, invItem, scriptItem)
        listItem.isLocked = lockedItems and lockedItems[invItem:getID()] == true or false
        listItem.selectionKey = masterKey .. ":" .. tostring(invItem:getID())

        local canGroup = (not listItem.isLocked) and (not instanceof(invItem, "InventoryContainer"))
        if canGroup then
            local groupKey = table.concat({
                tostring(masterKey),
                tostring(fullType),
                tostring(listItem.price),
                tostring(cat),
                tostring(listItem.displayName or listItem.name or ""),
                tostring(listItem.statusSuffix or ""),
                listItem.isRotten and "1" or "0"
            }, "|")

            local existing = groupedEntries[groupKey]
            if existing then
                existing.qty = (existing.qty or 1) + 1
                existing.isGrouped = true
                table.insert(existing.itemIDs, invItem:getID())
                return
            end

            groupedEntries[groupKey] = listItem
            listItem.selectionKey = groupKey
        end

        table.insert(categorized[cat], listItem)
    end

    local function collectItems(container)
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            processItem(item)
            if instanceof(item, "InventoryContainer") then
                local subContainer = item:getItemContainer()
                if subContainer then
                    collectItems(subContainer)
                end
            end
        end
    end

    collectItems(inv)
end
