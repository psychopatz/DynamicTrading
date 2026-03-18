if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

--- Populates a table with items sellable by the player.
function DT_TradingItemUtils.scanSellableItems(player, trader, dataProvider, categorized, categories, activeRadioID, rejections)
    local inv = player:getInventory()
    local itemList = {}
    local getMasterKeyFn = dataProvider and dataProvider.getMasterKey

    local function collectItems(container)
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            table.insert(itemList, item)
            if instanceof(item, "InventoryContainer") then
                local subContainer = item:getItemContainer()
                if subContainer then
                    collectItems(subContainer)
                end
            end
        end
    end

    collectItems(inv)

    for _, invItem in ipairs(itemList) do
        if invItem then
            if invItem:isFavorite() then
                dataProvider:lockItem(invItem:getID())
            end

            local fullType = invItem:getFullType()
            if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" and invItem:getID() ~= activeRadioID then
                local masterKey = nil
                if type(getMasterKeyFn) == "function" then
                    masterKey = dataProvider:getMasterKey(fullType)
                else
                    masterKey = DynamicTrading.Utils.GetMasterKey(fullType)
                end

                if masterKey then
                    local isInTraderStock = trader.stocks and trader.stocks[masterKey] ~= nil
                    if not isInTraderStock then
                        local itemData = dataProvider:getItemData(masterKey)
                        local price = dataProvider:getSellPrice(invItem, masterKey, trader)

                        if price > 0 then
                            local cat = itemData.tags[1] or "Misc"

                            if invItem.getFluidContainer and invItem:getFluidContainer() then
                                local fc = invItem:getFluidContainer()
                                if fc:getAmount() > 0 then
                                    local fluidCategory = DT_TradingItemUtils.Internal.getFluidCategory(
                                        DT_TradingItemUtils.Internal.getFluidTypeID(fc)
                                    )
                                    if fluidCategory then
                                        cat = fluidCategory
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

                            local scriptItem = getScriptManager():getItem(itemData.item)
                            table.insert(categorized[cat], {
                                key = masterKey,
                                itemID = invItem:getID(),
                                name = invItem:getDisplayName(),
                                price = tonumber(price) or 0,
                                data = itemData,
                                scriptItem = scriptItem,
                                isBuy = false,
                                priceMod = dataProvider:getPriceModifier(itemData.tags),
                                invItem = invItem,
                                displayName = DT_TradingItemUtils.getItemDisplayName({isBuy=false}, invItem, scriptItem),
                                statusSuffix = DT_TradingItemUtils.getStatusSuffix({isBuy=false}, invItem, scriptItem),
                                isRotten = (invItem.isRotten and invItem:isRotten()) or false
                            })
                        elseif rejections then
                            table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Price is 0")
                        end
                    elseif rejections then
                        table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Trader already has this key in stock")
                    end
                elseif rejections then
                    table.insert(rejections, "[Sell] " .. fullType .. " | REJECTED: Item not found in Master Registry")
                end
            end
        end
    end
end
