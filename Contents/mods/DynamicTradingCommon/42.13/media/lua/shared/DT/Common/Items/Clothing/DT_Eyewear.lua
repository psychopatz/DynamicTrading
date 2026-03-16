-- ============================================================================
-- Clothing Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Clothing.Accessory.Eyes] [Rarity.Common] (42 items)
    { item="Base.Glasses", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_3dGlasses", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_70s_Gold", basePrice=93, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=2, max=16} },
    { item="Base.Glasses_Aviators", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_CatsEye", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_CatsEye_Sun", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Cosmetic_70s_Gold", basePrice=93, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=2, max=16} },
    { item="Base.Glasses_Cosmetic_CatsEye", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Cosmetic_HalfMoon", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Cosmetic_MonocleLeft", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=8, max=47} },
    { item="Base.Glasses_Cosmetic_MonocleRight", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=8, max=47} },
    { item="Base.Glasses_Cosmetic_Normal", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Cosmetic_Normal_HornRimmed", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Cosmetic_Round_Normal", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Groucho", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_HalfMoon", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_JackieO", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Macho", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_MonocleLeft", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=8, max=47} },
    { item="Base.Glasses_MonocleRight", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=8, max=47} },
    { item="Base.Glasses_NewWave", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Normal", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Normal_HornRimmed", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Novelty_Xray", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_OldWeldingGoggles", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_Aviators", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_CatsEye_Sun", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_JackieO", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_Round_Shades", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_Shooting", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Prescription_Sun", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Reading", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Round_HoloSkulls", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Round_Normal", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Round_Shades", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Shooting", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_SkiGoggles", basePrice=19, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Sun", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_SunCheap", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_SwimmingGoggles", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },
    { item="Base.Glasses_Venetian", basePrice=18, tags={"Clothing.Accessory.Eyes", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=23} },

    -- [Clothing.Accessory.Eyes] [Rarity.Rare] (2 items)
    { item="Base.Glasses_Eyepatch_Left", basePrice=35, tags={"Clothing.Accessory.Eyes", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=25} },
    { item="Base.Glasses_Eyepatch_Right", basePrice=35, tags={"Clothing.Accessory.Eyes", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=25} },
})

print("[DynamicTrading] Eyewear Registry Complete")
