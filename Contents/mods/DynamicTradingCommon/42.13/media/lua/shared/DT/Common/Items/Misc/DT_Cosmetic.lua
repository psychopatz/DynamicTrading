-- =============================================================================
-- DYNAMIC TRADING: MISC - COSMETIC
-- =============================================================================
-- Root Category: Misc
-- Sub Category: Cosmetic
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Earring_Dangly_Diamond",          tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=500, stockRange={min=0, max=2} },
    { item="Base.Earring_Dangly_Ruby",             tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=2} },
    { item="Base.HairDyeCommon",    basePrice=45,  tags={"Misc.Cosmetic", "Theme.Leisure", "Rarity.Common"},   stockRange={min=1, max=3} },
    { item="Base.HairDyeRare",      basePrice=250, tags={"Misc.Cosmetic", "Theme.Leisure", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.HairDyeUncommon",  basePrice=85,  tags={"Misc.Cosmetic", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
    { item="Base.Lipstick",         basePrice=35,  tags={"Misc.Cosmetic", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.MakeupEyeshadow",  basePrice=35,  tags={"Misc.Cosmetic", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.MakeupFoundation", basePrice=35,  tags={"Misc.Cosmetic", "Theme.Leisure", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
    { item="Base.NecklaceLong_GoldDiamond",        tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_SilverDiamond",      tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },
    { item="Base.Necklace_BoarTusk_Multi",         tags={"Misc.Cosmetic", "Origin.Nomad", "Rarity.Common"}, basePrice=20,  stockRange={min=1, max=3} },
    { item="Base.Necklace_Gold",                   tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
    { item="Base.Necklace_GoldDiamond",            tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldRuby",               tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=900, stockRange={min=0, max=1} },
    { item="Base.Necklace_Pearl",                  tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Legendary"}, basePrice=1500, stockRange={min=0, max=1} },
    { item="Base.Necklace_SilverDiamond",          tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },
    { item="Base.Necklace_SilverSapphire",         tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=2} },
    { item="Base.Necklace_SkullMammal_Multi",      tags={"Misc.Cosmetic", "Origin.Nomad", "Rarity.Common"}, basePrice=25,  stockRange={min=1, max=3} },
    { item="Base.Ring_Left_RingFinger_Gold",       tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=250, stockRange={min=1, max=3} },
    { item="Base.Ring_Left_RingFinger_GoldDiamond",  tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
    { item="Base.Ring_Left_RingFinger_GoldRuby",     tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond", tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=2} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", tags={"Misc.Cosmetic", "Quality.Luxury", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Misc/Cosmetic Registry Loaded.")
