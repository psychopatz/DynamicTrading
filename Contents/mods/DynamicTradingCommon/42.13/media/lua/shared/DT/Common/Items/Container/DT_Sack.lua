-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - SACK
-- =============================================================================
-- Root Category: Container
-- Sub Category: Sack
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Bag_Gunny",                    basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
    { item="Base.Bag_HideSack",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
    { item="Base.Bag_TarpSack",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
    { item="Base.EmptySandbag",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
    { item="Base.WheatSack",                    basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
    { item="Base.WheatSeedSack",                basePrice=8,   tags={"Container.Sack.Material"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Container/Sack Registry Loaded.")
