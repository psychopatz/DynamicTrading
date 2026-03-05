-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - UTILITY
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Utility
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.AlarmClock2",      basePrice=25, tags={"Electronics.Utility.Clock", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Trap component / Waking up,
})

print("[DynamicTrading] Electronics/Utility Registry Loaded.")
