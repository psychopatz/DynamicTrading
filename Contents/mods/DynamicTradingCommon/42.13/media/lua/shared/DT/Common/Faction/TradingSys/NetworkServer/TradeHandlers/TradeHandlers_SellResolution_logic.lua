-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers_SellResolution_logic.lua
-- Logic: Sell item resolution and fluid-state helpers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Helpers = context.Helpers

    function Helpers.FindSellItem(inv, itemID)
        if not inv or not itemID then
            return nil
        end

        local itemObj = inv:getItemById(itemID)
        if itemObj then
            return itemObj
        end

        return DynamicTrading.ServerHelpers.FindItemByIDRecursive(inv, itemID)
    end

    function Helpers.ResolveSellItems(inv, args, traderID, key, requestedQty)
        local ids = args.itemIDs
        local items = {}
        local seenIDs = {}
        local firstPrice = nil
        local firstBasePrice = nil
        local firstFullType = nil

        if requestedQty <= 1 then
            local singleItem = Helpers.FindSellItem(inv, args.itemID)
            if not singleItem then
                return nil, "Item missing!"
            end

            items[1] = singleItem
            firstPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, singleItem, key)
            firstBasePrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, singleItem, key, false, true)
            return items, firstPrice, firstBasePrice
        end

        if type(ids) ~= "table" or #ids < requestedQty then
            return nil, "Items missing!"
        end

        for i = 1, requestedQty do
            local itemID = tonumber(ids[i])
            if not itemID or seenIDs[itemID] then
                return nil, "Invalid item selection"
            end

            local itemObj = Helpers.FindSellItem(inv, itemID)
            if not itemObj then
                return nil, "Items missing!"
            end

            local unitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key)
            local baseUnitPrice = DynamicTrading.Economy.V2.GetSellPrice(traderID, itemObj, key, false, true)

            if i == 1 then
                firstPrice = unitPrice
                firstBasePrice = baseUnitPrice
                firstFullType = itemObj:getFullType()
            elseif itemObj:getFullType() ~= firstFullType or unitPrice ~= firstPrice or baseUnitPrice ~= firstBasePrice then
                return nil, "Items no longer match"
            end

            seenIDs[itemID] = true
            items[#items + 1] = itemObj
        end

        return items, firstPrice, firstBasePrice
    end

    function Helpers.ResolveInventoryFluidState(itemObj)
        if not itemObj or not itemObj.getFluidContainer or not itemObj:getFluidContainer() then
            return nil, 0
        end

        local fluidContainer = itemObj:getFluidContainer()
        local amount = fluidContainer.getAmount and fluidContainer:getAmount() or 0
        local fluidType = nil

        if fluidContainer.getPrimaryFluid then
            local pFluid = fluidContainer:getPrimaryFluid()
            if pFluid then
                if pFluid.getFluidType then
                    fluidType = pFluid:getFluidType()
                end
                if (not fluidType or fluidType == "") and pFluid.getFluid then
                    local fluidObj = pFluid:getFluid()
                    if fluidObj and fluidObj.getName then
                        fluidType = fluidObj:getName()
                    end
                end
            end
        end

        if (not fluidType or fluidType == "") and fluidContainer.getFluidType then
            fluidType = fluidContainer:getFluidType()
        end

        return fluidType, amount
    end
end
