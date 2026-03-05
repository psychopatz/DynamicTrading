-- =============================================================================
-- DYNAMIC TRADING: APPLIANCE - TV
-- =============================================================================
-- Root Category: Appliance
-- Sub Category: TV
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.TvAntique",             basePrice=35, tags={"Appliance.TV", "Quality.Waste", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.TvBlack",               basePrice=65, tags={"Appliance.TV", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.TvWideScreen",          basePrice=150,tags={"Appliance.TV", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Appliance/TV Registry Loaded.")
