local Internal = DT_EconomyPriceInternal

Internal.Common = DynamicTrading.Economy.Common

function Internal.GetEffectiveBasePrice(itemKey, itemData)
    if DynamicTrading and DynamicTrading.PriceConfig and DynamicTrading.PriceConfig.GetEffectiveBasePrice then
        return DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData)
    end
    return itemData and itemData.basePrice or 0
end
