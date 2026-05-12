local Internal = DT_EconomyPriceInternal
local Common = Internal.Common

function Common.GetSellPrice(itemKey, itemData, itemObj, diffData, archetype, modifiers, verbose)
    local globalHeat
    local getPriceMod
    local localDeflationCount
    local effectiveBasePrice
    local price

    if not itemData then
        return 0
    end

    diffData = diffData or { sellMult = 0.5 }
    modifiers = modifiers or {}
    archetype = archetype or {}

    globalHeat = modifiers.globalHeat or {}
    getPriceMod = modifiers.getPriceModifier
    localDeflationCount = modifiers.localDeflationCount or 0

    effectiveBasePrice = Internal.GetEffectiveBasePrice(itemKey, itemData)
    price = effectiveBasePrice * diffData.sellMult

    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "Sell Price Calc: " .. itemKey .. " | Base: " .. price)
    end

    if itemObj then
        local conditionScale = 1.0
        local maxCond
        local scriptItem = nil

        if itemObj.isRotten and itemObj:isRotten() then
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| STATE: ROTTEN (PRICE = 1)")
            end
            return 1
        end

        maxCond = itemObj:getConditionMax()
        if maxCond > 0 then
            conditionScale = itemObj:getCondition() / maxCond
            price = price * conditionScale
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Condition: " .. math.floor(conditionScale * 100) .. "%")
            end
        end

        if itemObj.getScriptItem then
            scriptItem = itemObj:getScriptItem()
        end

        if itemObj.getFluidContainer and itemObj:getFluidContainer() then
            local fluidContainer = itemObj:getFluidContainer()
            local capacity = fluidContainer:getCapacity()
            local currentAmount = fluidContainer:getAmount()
            local ratio = 0
            local fluidType = nil
            local fluidValue = 0
            local fluidData
            local containerBase
            local containerValue
            local containerWantMult
            local containerWantTag

            if capacity > 0 then
                ratio = currentAmount / capacity
            end

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

            fluidType = Common.NormalizeFluidType(fluidType)
            fluidData = Common.GetFluidData(fluidType)
            containerBase = Common.ResolveContainerBasePrice(itemData, scriptItem)
            containerValue = (containerBase * diffData.sellMult) * conditionScale
            containerValue = Internal.ApplyEventAndHeat(containerValue, itemData.tags, getPriceMod, globalHeat, verbose, "Container")
            containerWantMult, containerWantTag = Internal.FindWantMultiplier(itemData.tags, archetype)
            if containerWantMult ~= 1.0 then
                containerValue = containerValue * containerWantMult
                if verbose then
                    DynamicTrading.Log("DTCommons", "Trade", "Trace", "ContainerWant(" .. tostring(containerWantTag) .. "): " .. containerWantMult)
                end
            end

            if fluidData then
                local baseFluidValue = (Common.GetFluidUnitPrice(fluidType) * currentAmount) * (diffData.sellMult or 0.5)
                local fluidWantMult
                local fluidWantTag

                fluidValue = Internal.ApplyEventAndHeat(baseFluidValue, fluidData.tags, getPriceMod, globalHeat, verbose, "Fluid")
                fluidWantMult, fluidWantTag = Internal.FindWantMultiplier(fluidData.tags, archetype)
                if fluidWantMult ~= 1.0 then
                    fluidValue = fluidValue * fluidWantMult
                    if verbose then
                        DynamicTrading.Log("DTCommons", "Trade", "Trace", "FluidWant(" .. tostring(fluidWantTag) .. "): " .. fluidWantMult)
                    end
                end
            else
                local unknownFluidBase = 1.0
                fluidValue = (unknownFluidBase * currentAmount) * diffData.sellMult
            end

            price = containerValue + fluidValue
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FLUID: " .. tostring(fluidType) .. " (" .. math.floor(ratio * 100) .. "%) | NewPrice: " .. price)
            end

            if localDeflationCount > 0 then
                local penaltyPerItem = 0.05
                local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
                if localMult < 0.2 then
                    localMult = 0.2
                end
                price = price * localMult
                if verbose then
                    DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Deflation: " .. localMult)
                end
            end

            if price < 0 then
                price = 0
            end
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price))
            end
            return math.floor(price)
        elseif itemObj.getHungerChange and scriptItem and scriptItem.getHungerChange then
            local currentHunger = itemObj:getHungerChange()
            local baseHunger = Common.GetNormalizedHunger(scriptItem)

            if baseHunger < 0 then
                local ratio = currentHunger / baseHunger
                price = price * math.max(0, math.min(1, ratio))
                if verbose then
                    DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FOOD: " .. math.floor(ratio * 100) .. "% | NewPrice: " .. price)
                end
            end
        elseif itemObj.IsDrainable and itemObj:IsDrainable() then
            local delta = Common.GetItemCharge(itemObj)
            price = price * delta
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DRAINABLE: " .. math.floor(delta * 100) .. "% | NewPrice: " .. price)
            end
        end
    end

    if getPriceMod then
        local eventMult = getPriceMod(itemData.tags)
        price = price * eventMult
        if verbose and eventMult ~= 1.0 then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "| EventMult: " .. eventMult)
        end
    end

    for _, tag in ipairs(itemData.tags) do
        local heat = globalHeat[tag]
        if heat and heat ~= 0 then
            price = price * (1.0 + heat)
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Heat(" .. tag .. "): " .. heat)
            end
        end
    end

    if localDeflationCount > 0 then
        local penaltyPerItem = 0.05
        local localMult = 1.0 - (localDeflationCount * penaltyPerItem)
        if localMult < 0.2 then
            localMult = 0.2
        end
        price = price * localMult
        if verbose then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "| Deflation: " .. localMult)
        end
    end

    do
        local wantMult
        local wantTag

        wantMult, wantTag = Internal.FindWantMultiplier(itemData.tags, archetype)
        if wantMult ~= 1.0 then
            price = price * wantMult
            if verbose then
                DynamicTrading.Log("DTCommons", "Trade", "Trace", "Want(" .. tostring(wantTag) .. "): " .. wantMult)
            end
        end
    end

    if price < 0 then
        price = 0
    end

    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price))
    end

    return math.floor(price)
end
