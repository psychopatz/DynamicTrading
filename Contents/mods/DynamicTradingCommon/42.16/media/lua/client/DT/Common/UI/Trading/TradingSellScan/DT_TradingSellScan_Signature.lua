local Internal = DT_TradingItemUtils.Internal

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
    local fluidContainer
    local amount
    local fluidType

    if not invItem or not invItem.getFluidContainer then
        return ""
    end

    fluidContainer = invItem:getFluidContainer()
    if not fluidContainer then
        return ""
    end

    amount = tonumber(fluidContainer.getAmount and fluidContainer:getAmount() or 0) or 0
    fluidType = Internal.getFluidTypeID and Internal.getFluidTypeID(fluidContainer) or nil
    return tostring(fluidType or "") .. "@" .. string.format("%.4f", amount)
end

function Internal.getSellScanItemStateToken(invItem)
    local parts

    if not invItem then
        return ""
    end

    parts = {}
    appendSignaturePart(parts, invItem:getID())
    appendSignaturePart(parts, invItem:getFullType())
    appendSignaturePart(parts, getItemConditionToken(invItem))
    appendSignaturePart(parts, getItemDrainToken(invItem))
    appendSignaturePart(parts, getItemFluidToken(invItem))
    appendSignaturePart(parts, invItem.isRotten and invItem:isRotten() and "1" or "0")
    return table.concat(parts, "|")
end

function Internal.getInventorySignature(player, activeRadioID)
    local inventory = player and player.getInventory and player:getInventory() or nil
    local parts
    local nestedContainers
    local pendingContainers
    local frame
    local container
    local items
    local invItem
    local subContainer

    if not inventory then
        return "no-inventory"
    end

    parts = {}
    nestedContainers = 0
    pendingContainers = {
        {
            container = inventory,
            index = 0,
        }
    }

    while #pendingContainers > 0 do
        frame = pendingContainers[#pendingContainers]
        container = frame and frame.container or nil
        items = container and container.getItems and container:getItems() or nil

        if not items or frame.index >= items:size() then
            table.remove(pendingContainers)
        else
            invItem = items:get(frame.index)
            frame.index = frame.index + 1

            if invItem then
                if invItem:getID() ~= activeRadioID then
                    parts[#parts + 1] = Internal.getSellScanItemStateToken(invItem)
                end

                if instanceof(invItem, "InventoryContainer") then
                    subContainer = invItem:getItemContainer()
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
    local priceVersion

    if dataProvider and dataProvider.getSellPriceContextVersion then
        stockVersion = dataProvider:getSellPriceContextVersion(trader)
    elseif dataProvider and dataProvider.getStockVersion then
        stockVersion = dataProvider:getStockVersion(trader)
    end

    if stockVersion == nil and trader then
        stockVersion = trader.sessionVersion or trader.stockVersion or trader.version
    end

    priceVersion = DynamicTrading and DynamicTrading.PriceConfig and (DynamicTrading.PriceConfig.version or DynamicTrading.PriceConfig.VERSION) or 0
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
