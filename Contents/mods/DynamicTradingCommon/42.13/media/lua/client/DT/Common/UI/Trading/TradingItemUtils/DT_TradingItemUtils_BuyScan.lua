if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

--- Populates a table with items buyable from the trader.
function DT_TradingItemUtils.scanBuyableItems(trader, dataProvider, categorized, categories, rejections)
    if not trader.stocks then return end

    for key, qty in pairs(trader.stocks) do
        local itemData = dataProvider:getItemData(key)
        if itemData then
            local scriptItem = getScriptManager():getItem(itemData.item)
            local sortName = scriptItem and scriptItem:getDisplayName() or key
            local cat = itemData.tags[1] or "Misc"
            local effectiveTags = itemData.tags

            if type(qty) == "table" and qty.customData and qty.customData.fluidType and (tonumber(qty.customData.fluidAmount) or 0) > 0 then
                local fluidCategory = DT_TradingItemUtils.Internal.getFluidCategory(qty.customData.fluidType)
                if fluidCategory then
                    cat = fluidCategory
                    effectiveTags = DT_TradingItemUtils.Internal.getFluidTags(qty.customData.fluidType) or effectiveTags
                end
            end

            if not categorized[cat] then
                categorized[cat] = {}
                table.insert(categories, cat)
            end

            local stockQty = 0
            local customData = nil
            if type(qty) == "table" then
                stockQty = tonumber(qty.qty) or 0
                customData = qty.customData
            else
                stockQty = tonumber(qty) or 0
            end

            local price = dataProvider:getBuyPrice(key, customData)

            table.insert(categorized[cat], {
                key = key,
                name = sortName,
                qty = stockQty,
                price = tonumber(price) or 0,
                data = itemData,
                isBuy = true,
                priceMod = dataProvider:getPriceModifier(effectiveTags or itemData.tags),
                customData = customData,
                effectiveCategory = cat,
                effectiveTags = effectiveTags,
                displayName = DT_TradingItemUtils.getItemDisplayName({isBuy=true, customData=customData, name=sortName}, nil, scriptItem),
                statusSuffix = DT_TradingItemUtils.getStatusSuffix({isBuy=true, customData=customData}, nil, scriptItem),
                isRotten = false
            })
        end
    end
end
