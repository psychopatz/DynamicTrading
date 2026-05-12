local Internal = DT_EconomyPriceInternal
local Common = Internal.Common

function Internal.ApplyBuyCustomStatePrice(itemData, diffData, modifiers, effectiveBasePrice, price, verbose)
    local cd
    local scale
    local script
    local containerBase
    local fluidTotal
    local fData
    local fluidAmount
    local fType
    local containerMults
    local fluidMults
    local maxFluidTagMult
    local tagConfig
    local eventMult
    local heat

    if not modifiers or not modifiers.customData then
        return price
    end

    cd = modifiers.customData
    scale = 1.0

    if cd.fluidAmount ~= nil and itemData.item then
        script = getScriptManager():getItem(itemData.item)
        containerBase = 0
        fluidTotal = 0
        fData = nil
        fluidAmount = math.max(0, tonumber(cd.fluidAmount) or 0)

        containerBase = Common.ResolveContainerBasePrice(itemData, script)

        fType = Common.NormalizeFluidType(cd.fluidType)
        if fType then
            fData = Common.GetFluidData(fType)
            if fData then
                fluidTotal = Common.GetFluidUnitPrice(fType) * fluidAmount
            end
        end

        containerMults = 1.0
        if effectiveBasePrice > 0 then
            containerMults = price / effectiveBasePrice
        end

        fluidMults = diffData.buyMult or 1.0
        if fData and fData.tags then
            maxFluidTagMult = 1.0
            for _, tag in ipairs(fData.tags) do
                tagConfig = Common.ResolveMappedValue({ tag }, modifiers.tagsConfig or {})
                if tagConfig and tagConfig.priceMult and tagConfig.priceMult > maxFluidTagMult then
                    maxFluidTagMult = tagConfig.priceMult
                end
            end
            fluidMults = fluidMults * maxFluidTagMult

            if modifiers.getPriceModifier then
                eventMult = modifiers.getPriceModifier(fData.tags)
                fluidMults = fluidMults * eventMult
            end

            for _, tag in ipairs(fData.tags) do
                heat = (modifiers.globalHeat or {})[tag]
                if heat and heat ~= 0 then
                    fluidMults = fluidMults * (1.0 + heat)
                    if verbose then
                        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FluidHeat(" .. tag .. "): " .. heat)
                    end
                end
            end
        end

        price = (containerBase * containerMults) + (fluidTotal * fluidMults)

        if verbose then
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DYNAMIC CONTENT DETECTED")
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "|   Container Price: " .. math.floor(containerBase * containerMults))
            DynamicTrading.Log("DTCommons", "Trade", "Trace", "|   FluidTotal: " .. math.floor(fluidTotal * fluidMults) .. " (" .. tostring(fType) .. ")")
        end

        return math.ceil(price)
    elseif cd.usedDelta then
        scale = cd.usedDelta
    elseif cd.hungerChange then
        script = getScriptManager():getItem(itemData.item)
        if script then
            local base = Common.GetNormalizedHunger(script)
            if base < 0 then
                scale = cd.hungerChange / base
            end
        end
    elseif cd.condition and itemData.item then
        script = getScriptManager():getItem(itemData.item)
        if script and script.getConditionMax and script:getConditionMax() > 0 then
            scale = cd.condition / script:getConditionMax()
        end
    end

    price = price * math.max(0.2, scale)
    if verbose and scale ~= 1.0 then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| ItemScale: " .. scale)
    end

    return price
end
