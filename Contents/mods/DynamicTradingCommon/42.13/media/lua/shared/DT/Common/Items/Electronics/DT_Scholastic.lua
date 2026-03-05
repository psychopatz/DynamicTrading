-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - SCHOLASTIC
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Scholastic
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Calculator",       basePrice=25, tags={"Electronics.Scholastic", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Electronics/Scholastic Registry Loaded.")
