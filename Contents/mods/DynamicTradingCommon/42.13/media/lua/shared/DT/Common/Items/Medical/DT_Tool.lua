-- =============================================================================
-- DYNAMIC TRADING: MEDICAL - TOOL
-- =============================================================================
-- Root Category: Medical
-- Sub Category: Tool
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.HotWaterBottle",   tags={"Medical.Tool", "Theme.Clinical", "Rarity.Common"}, basePrice=12, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Medical/Tool Registry Loaded.")
