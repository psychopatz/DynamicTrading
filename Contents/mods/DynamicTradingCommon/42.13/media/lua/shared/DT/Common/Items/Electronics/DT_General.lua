-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - GENERAL
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: General
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.ElectronicsScrap",      basePrice=5,   tags={"Electronics.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=30} },
})

print("[DynamicTrading] Electronics/General Registry Loaded.")
