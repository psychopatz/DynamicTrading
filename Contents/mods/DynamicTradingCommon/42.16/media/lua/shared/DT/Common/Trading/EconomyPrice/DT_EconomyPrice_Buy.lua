local Internal = DT_EconomyPriceInternal
local Common = Internal.Common

function Common.GetBuyPrice(itemKey, itemData, diffData, modifiers, verbose)
    local tagsConfig
    local globalHeat
    local getPriceMod
    local effectiveBasePrice
    local price
    local maxTagMult

    if not itemData then
        return 99999
    end

    diffData = diffData or { buyMult = 1.0 }
    modifiers = modifiers or {}

    tagsConfig = modifiers.tagsConfig or {}
    globalHeat = modifiers.globalHeat or {}
    getPriceMod = modifiers.getPriceModifier

    effectiveBasePrice = Internal.GetEffectiveBasePrice(itemKey, itemData)
    price = effectiveBasePrice

    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "Buy Price Calc: " .. itemKey .. " | Base: " .. price)
    end

    maxTagMult = 1.0
    for _, tag in ipairs(itemData.tags) do
        local tagConfig = Common.ResolveMappedValue({ tag }, tagsConfig)
        if tagConfig and tagConfig.priceMult and tagConfig.priceMult > maxTagMult then
            maxTagMult = tagConfig.priceMult
        end
    end
    price = price * maxTagMult
    if verbose and maxTagMult ~= 1.0 then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| TagMult: " .. maxTagMult)
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

    price = price * diffData.buyMult
    if verbose and diffData.buyMult ~= 1.0 then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| DiffMult: " .. diffData.buyMult)
    end

    price = Internal.ApplyBuyCustomStatePrice(itemData, diffData, modifiers, effectiveBasePrice, price, verbose)

    if price < 1 then
        price = 1
    end

    if verbose then
        DynamicTrading.Log("DTCommons", "Trade", "Trace", "| FINAL: " .. math.floor(price))
    end

    return math.ceil(price)
end
