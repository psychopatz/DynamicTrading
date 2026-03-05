-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - WEARABLE
-- =============================================================================
-- Root Category: Container
-- Sub Category: Wearable
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.AmmoStrap_Brown_Bullets",      basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
    { item="Base.AmmoStrap_Brown_Shells",       basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
    { item="Base.AmmoStrap_Bullets",            basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
    { item="Base.AmmoStrap_Bullets_308",        basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
    { item="Base.AmmoStrap_Shells",             basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Container/Wearable Registry Loaded.")
