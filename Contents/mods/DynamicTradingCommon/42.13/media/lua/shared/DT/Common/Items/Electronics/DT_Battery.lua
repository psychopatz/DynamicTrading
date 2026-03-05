-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - BATTERY
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Battery
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Battery",             basePrice=12,  tags={"Electronics.Battery", "Rarity.Common"}, stockRange={min=5, max=15} },
    { item="Base.BatteryBox",          basePrice=120, tags={"Electronics.Battery", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Electronics/Battery Registry Loaded.")
