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
    { item="Base.Dress_Knees", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Burlap", basePrice=820, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Cotton", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_Denim", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_DenimBlack", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Knees_Crafted_DenimLight", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Burlap", basePrice=821, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Cotton", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_Denim", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_DenimBlack", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Long_Crafted_DenimLight", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_long_Straps", basePrice=819, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Normal", basePrice=817, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SatinNegligee", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Short", basePrice=817, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallBlackStrapless", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallBlackStraps", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallDeerHideStrapless", basePrice=825, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallGarbageStrapless", basePrice=820, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallHideStrapless", basePrice=825, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallStrapless", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallStraps", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_SmallTarpStrapless", basePrice=822, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Dress_Straps", basePrice=817, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.DressKnees_Straps", basePrice=818, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.HospitalGown", basePrice=915, tags={"Clothing.Dress", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Clothing.Medical"}, stockRange={min=0, max=9} },
})

print("[DynamicTrading] Dress Registry Complete")
