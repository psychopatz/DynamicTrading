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

    -- [Clothing.Dress] [Rarity.Rare] (27 items)
    { item="Base.Dress_Knees", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Knees_Crafted_Burlap", basePrice=12, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Knees_Crafted_Cotton", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Knees_Crafted_Denim", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Knees_Crafted_DenimBlack", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Knees_Crafted_DenimLight", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long_Crafted_Burlap", basePrice=2, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long_Crafted_Cotton", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long_Crafted_Denim", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long_Crafted_DenimBlack", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Long_Crafted_DenimLight", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_long_Straps", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Normal", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SatinNegligee", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Short", basePrice=3, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallBlackStrapless", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallBlackStraps", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallDeerHideStrapless", basePrice=21, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallGarbageStrapless", basePrice=12, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallHideStrapless", basePrice=21, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallStrapless", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallStraps", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_SmallTarpStrapless", basePrice=18, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Dress_Straps", basePrice=1, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.DressKnees_Straps", basePrice=5, tags={"Clothing.Dress", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.HospitalGown", basePrice=3, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Clinical", "Clothing.Medical"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Dress Registry Complete")
