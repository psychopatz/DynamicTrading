if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

--- Returns the most appropriate display name, handling fluid renaming.
function DT_TradingItemUtils.getItemDisplayName(listItem, invItem, scriptItem)
    local isBuy = listItem.isBuy

    local fluidContainer = nil
    if isBuy then
        if scriptItem and scriptItem.getFluidContainer then
            fluidContainer = scriptItem:getFluidContainer()
        end
    else
        if invItem and invItem.getFluidContainer then
            fluidContainer = invItem:getFluidContainer()
        end
    end

    if fluidContainer then
        local amt = 0
        if isBuy then
            amt = (listItem.customData and listItem.customData.fluidAmount or 0)
        elseif fluidContainer.getAmount then
            amt = fluidContainer:getAmount()
        end

        if amt > 0 then
            local fType = isBuy and listItem.customData.fluidType or nil
            local fName = DT_TradingItemUtils.Internal.getFluidName(fluidContainer, fType)

            if fName and fName ~= "" then
                local containerName = scriptItem and scriptItem.getDisplayName and scriptItem:getDisplayName() or ""
                if scriptItem and scriptItem.getReplaceOnDeplete then
                    local emptyType = scriptItem:getReplaceOnDeplete()
                    if emptyType then
                        local emptyScript = getScriptManager():getItem(emptyType)
                        if emptyScript and emptyScript.getDisplayName then
                            containerName = emptyScript:getDisplayName()
                        end
                    end
                end

                return fName .. " (" .. containerName .. ")"
            end
        end
    end

    if not isBuy and invItem and invItem.getDisplayName then
        return invItem:getDisplayName()
    end

    return listItem.name or (scriptItem and scriptItem.getDisplayName and scriptItem:getDisplayName()) or "Unknown Item"
end

--- Generates a suffix like " (Rotten)" or " (50%)" for display.
function DT_TradingItemUtils.getStatusSuffix(listItem, invItem, scriptItem)
    local statusSuffix = ""
    local isRotten = false

    if listItem.isBuy then
        local customData = listItem.customData
        if customData then
            if (customData.fluidAmount or 0) > 0 then
                if scriptItem and scriptItem.getFluidContainer and scriptItem:getFluidContainer() then
                    local fc = scriptItem:getFluidContainer()
                    if fc.getCapacity then
                        local cap = fc:getCapacity()
                        if cap > 0 then
                            local amtStr = string.format("%.2f", customData.fluidAmount)
                            local capStr = string.format("%.1f", cap)
                            statusSuffix = " (" .. amtStr .. "/" .. capStr .. "L)"
                        end
                    end
                end
            elseif customData.usedDelta then
                local pct = math.floor(customData.usedDelta * 100)
                if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
            elseif customData.hungerChange then
                if scriptItem and scriptItem.getHungerChange then
                    local base = DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem)
                    if base < 0 then
                        local pct = math.floor((customData.hungerChange / base) * 100)
                        if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                    end
                end
            elseif customData.condition then
                if scriptItem and scriptItem.getConditionMax and scriptItem:getConditionMax() > 0 then
                    local pct = math.floor((customData.condition / scriptItem:getConditionMax()) * 100)
                    if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
                end
            end
        end
    elseif invItem then
        if invItem.getFluidContainer and invItem:getFluidContainer() then
            local fluidContainer = invItem:getFluidContainer()
            local cap = fluidContainer.getCapacity and fluidContainer:getCapacity() or 0
            local amt = fluidContainer.getAmount and fluidContainer:getAmount() or 0

            if cap > 0 then
                local amtStr = string.format("%.2f", amt)
                local capStr = string.format("%.1f", cap)
                statusSuffix = " (" .. amtStr .. "/" .. capStr .. "L)"
            end
        end

        if invItem.isRotten and invItem:isRotten() then
            statusSuffix = " (Rotten)"
            isRotten = true
        elseif invItem.getHungerChange and scriptItem and scriptItem.getHungerChange then
            local current = invItem:getHungerChange()
            local base = DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem)
            if base < 0 then
                local pct = math.floor((current / base) * 100)
                if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
            end
        elseif invItem.IsDrainable and invItem:IsDrainable() then
            local delta = 0
            if DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.GetItemCharge then
                delta = DynamicTrading.Economy.Common.GetItemCharge(invItem)
            else
                delta = invItem.getDrainableUsesFloat and invItem:getDrainableUsesFloat() or (invItem.getUsedDelta and invItem:getUsedDelta() or 0)
            end

            local pct = math.floor(delta * 100)
            if pct < 100 then statusSuffix = " (" .. pct .. "%)" end
        end
    end

    return statusSuffix, isRotten
end
