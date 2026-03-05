-- =============================================================================
-- DYNAMIC TRADING: CLOTHING - HANDS
-- =============================================================================
-- Root Category: Clothing
-- Sub Category: Hands
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Gloves_Surgical",      basePrice=40, tags={"Clothing.Hands.Gloves", "Origin.Healthcare", "Quality.Sterile"}, stockRange={min=2, max=12} },
})

print("[DynamicTrading] Clothing/Hands Registry Loaded.")
