-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - SECRET
-- =============================================================================
-- Root Category: Container
-- Sub Category: Secret
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.HollowBook",                   basePrice=10,  tags={"Container.Secret"}, stockRange={min=1, max=5} },
    { item="Base.HollowBook_Handgun",           basePrice=15,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
    { item="Base.HollowBook_Kids",              basePrice=10,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
    { item="Base.HollowBook_Prison",            basePrice=10,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
    { item="Base.HollowBook_Valuables",         basePrice=20,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
    { item="Base.HollowBook_Whiskey",           basePrice=15,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
    { item="Base.HollowFancyBook",              basePrice=15,  tags={"Container.Secret", "Quality.Luxury"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Container/Secret Registry Loaded.")
