-- =============================================================================
-- DYNAMIC TRADING: APPLIANCE - RADIO
-- =============================================================================
-- Root Category: Appliance
-- Sub Category: Radio
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.RadioBlack",            basePrice=25,  tags={"Appliance.Radio", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.RadioMakeShift",        basePrice=5,   tags={"Appliance.Radio", "Quality.Waste"}, stockRange={min=1, max=3} },
    { item="Base.RadioRed",              basePrice=45,  tags={"Appliance.Radio", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Appliance/Radio Registry Loaded.")
