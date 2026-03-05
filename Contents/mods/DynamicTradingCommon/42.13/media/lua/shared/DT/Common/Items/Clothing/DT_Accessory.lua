-- =============================================================================
-- DYNAMIC TRADING: CLOTHING - ACCESSORY
-- =============================================================================
-- Root Category: Clothing
-- Sub Category: Accessory
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BathTowel", basePrice=25, tags={"Clothing.Accessory.Towel", "Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.Hat_SurgicalMask",     basePrice=50, tags={"Clothing.Accessory.Mask", "Origin.Healthcare", "Quality.Sterile"}, stockRange={min=2, max=12} },
    { item="Base.Necklace_Choker_Bone",tags={"Clothing.Accessory.Neck", "Theme.Survival", "Rarity.Common"}, basePrice=45,  stockRange={min=1, max=7} },
    { item="Base.UmbrellaBlack",        basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.UmbrellaBlue",         basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.UmbrellaRed",          basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
    { item="Base.UmbrellaTINTED",       basePrice=60, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.UmbrellaWhite",        basePrice=45, tags={"Clothing.Accessory.Umbrella", "Theme.Seasonal", "Rarity.Common"}, stockRange={min=2, max=8} },
})

print("[DynamicTrading] Clothing/Accessory Registry Loaded.")
