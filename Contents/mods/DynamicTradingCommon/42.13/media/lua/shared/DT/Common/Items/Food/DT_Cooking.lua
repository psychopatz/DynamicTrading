-- =============================================================================
-- DYNAMIC TRADING: FOOD - COOKING
-- =============================================================================
-- Root Category: Food
-- Sub Category: Cooking
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BakingSoda",           basePrice=5,  tags={"Food.Cooking.Ingredient", "Rarity.Common"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Food/Cooking Registry Loaded.")
