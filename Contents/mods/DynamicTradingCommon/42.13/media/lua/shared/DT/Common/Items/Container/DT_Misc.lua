-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - MISC
-- =============================================================================
-- Root Category: Container
-- Sub Category: Misc
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CookieJar",                    basePrice=5,   tags={"Container.Misc"}, stockRange={min=2, max=8} },
    { item="Base.CookieJar_Bear",               basePrice=8,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.HalloweenCandyBucket",         basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Parcel_ExtraLarge",            basePrice=15,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Parcel_ExtraSmall",            basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Parcel_Large",                 basePrice=10,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Parcel_Medium",                basePrice=8,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Parcel_Small",                 basePrice=5,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Present_ExtraLarge",           basePrice=20,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Present_ExtraSmall",           basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Present_Large",                basePrice=15,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Present_Medium",               basePrice=10,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
    { item="Base.Present_Small",                basePrice=5,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Container/Misc Registry Loaded.")
