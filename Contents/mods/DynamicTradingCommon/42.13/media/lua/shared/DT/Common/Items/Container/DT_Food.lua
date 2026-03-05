-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - FOOD
-- =============================================================================
-- Root Category: Container
-- Sub Category: Food
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.EmptyJar",         tags={"Container.Food", "Rarity.Common"}, basePrice=8, stockRange={min=5, max=20} },
    { item="Base.JarCrafted",       tags={"Container.Food", "Rarity.Common"}, basePrice=5, stockRange={min=5, max=15} },
})

print("[DynamicTrading] Container/Food Registry Loaded.")
