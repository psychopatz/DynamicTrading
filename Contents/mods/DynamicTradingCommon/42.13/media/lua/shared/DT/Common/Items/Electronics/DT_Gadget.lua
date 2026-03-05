-- =============================================================================
-- DYNAMIC TRADING: ELECTRONICS - GADGET
-- =============================================================================
-- Root Category: Electronics
-- Sub Category: Gadget
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CordlessPhone",         basePrice=15, tags={"Electronics.Gadget.Phone", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.Earbuds",               basePrice=35, tags={"Electronics.Gadget.Audio", "Rarity.Common"}, stockRange={min=2, max=10} }, -- Useful for silent radio listening,
    { item="Base.HairDryer",             basePrice=15, tags={"Electronics.Gadget.Household", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.HairIron",              basePrice=15, tags={"Electronics.Gadget.Household", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.Headphones",            basePrice=45, tags={"Electronics.Gadget.Audio", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Pager",                 basePrice=15, tags={"Electronics.Gadget.Phone", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.WristWatch_Left_ClassicGold",     tags={"Electronics.Gadget.Wristwatch", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.WristWatch_Left_ClassicMilitary", tags={"Electronics.Gadget.Wristwatch", "Origin.Militia", "Rarity.Uncommon"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_DigitalBlack",    tags={"Electronics.Gadget.Wristwatch", "Rarity.Common"},    basePrice=15,  stockRange={min=3, max=10} },
    { item="Base.WristWatch_Left_Expensive",       tags={"Electronics.Gadget.Wristwatch", "Quality.Luxury", "Rarity.Rare"},     basePrice=150, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Electronics/Gadget Registry Loaded.")
