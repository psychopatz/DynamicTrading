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
    { item="Base.Dress_Knees", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Burlap", basePrice=52, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Cotton", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Denim", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_DenimBlack", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_DenimLight", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Burlap", basePrice=52, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Cotton", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Denim", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_DenimBlack", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_DenimLight", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_long_Straps", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Normal", basePrice=49, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SatinNegligee", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Short", basePrice=48, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallBlackStrapless", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallBlackStraps", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallDeerHideStrapless", basePrice=56, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallGarbageStrapless", basePrice=52, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallHideStrapless", basePrice=56, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallStrapless", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallStraps", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallTarpStrapless", basePrice=54, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Straps", basePrice=49, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.DressKnees_Straps", basePrice=50, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HospitalGown", basePrice=74, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Clothing.Medical"}, stockRange={min=0, max=9} },
})

print("[DynamicTrading] Dress Registry Complete")
