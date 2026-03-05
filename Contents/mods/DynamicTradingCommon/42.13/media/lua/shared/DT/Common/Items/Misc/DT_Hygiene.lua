-- =============================================================================
-- DYNAMIC TRADING: MISC - HYGIENE
-- =============================================================================
-- Root Category: Misc
-- Sub Category: Hygiene
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Cologne",          tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"},            basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Comb",                 basePrice=5,   tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Hairgel",          basePrice=10, tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=2, max=8} },
    { item="Base.Hairspray2",       basePrice=15, tags={"Misc.Hygiene", "Resource.Fuel.Aerosol", "Rarity.Common"},   stockRange={min=2, max=8} },
    { item="Base.Mirror", basePrice=25, tags={"Misc.Hygiene", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=3} },
    { item="Base.Perfume",          tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"},            basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Razor", basePrice=15, tags={"Misc.Hygiene", "Theme.Leisure", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.ToiletPaper",          basePrice=60,  tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.Toothbrush",           basePrice=15,  tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Toothpaste",           basePrice=25,  tags={"Misc.Hygiene", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Misc/Hygiene Registry Loaded.")
