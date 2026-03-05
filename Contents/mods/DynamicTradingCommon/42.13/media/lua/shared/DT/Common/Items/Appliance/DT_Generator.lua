-- =============================================================================
-- DYNAMIC TRADING: APPLIANCE - GENERATOR
-- =============================================================================
-- Root Category: Appliance
-- Sub Category: Generator
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Generator", basePrice=1200, tags={"Appliance.Generator", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Blue", basePrice=1000, tags={"Appliance.Generator", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Old", basePrice=600, tags={"Appliance.Generator", "Quality.Waste", "Rarity.Common"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Yellow", basePrice=1800, tags={"Appliance.Generator", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Appliance/Generator Registry Loaded.")
