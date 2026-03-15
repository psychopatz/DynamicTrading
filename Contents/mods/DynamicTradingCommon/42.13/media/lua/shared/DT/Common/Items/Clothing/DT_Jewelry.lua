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

    -- [Clothing.Accessory.Jewelry.Belly] [Rarity.Rare] (15 items)
    { item="Base.BellyButton_DangleGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_DangleGoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_DangleSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_DangleSilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingGoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingGoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingSilverAmethyst", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingSilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_RingSilverRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_StudGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_StudGoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_StudSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.BellyButton_StudSilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Jewelry.Ears] [Rarity.Rare] (21 items)
    { item="Base.Earring_BirdSkull", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_BoarTusk", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Dangly_Diamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Dangly_Emerald", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Dangly_Pearl", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Dangly_Ruby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Dangly_Sapphire", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopLrg_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopLrg_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopMed_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopMed_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopSmall_Gold_Both", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopSmall_Gold_Top", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopSmall_Silver_Both", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_LoopSmall_Silver_Top", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Pearl", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Stone_Emerald", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Stone_Ruby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Stone_Sapphire", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Stud_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Earring_Stud_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Jewelry.Necklace] [Rarity.Rare] (36 items)
    { item="Base.Locket", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Medal_Bronze", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=6} },
    { item="Base.Medal_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=6} },
    { item="Base.Medal_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=6} },
    { item="Base.Necklace_BoarTusk", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_BoarTusk_Multi", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Crucifix", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_DogTag", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_DogTag_Female", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_DogTag_Male", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_GoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Pearl", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SilverCrucifix", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SilverSapphire", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SkullMammal", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SkullMammal_Multi", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SkullSmall", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_SkullSmall_Multi", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_Teeth", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Necklace_YingYang", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_Amber", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SilverEmerald", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SilverSapphire", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SkullMammal", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SkullMammal_Multi", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SkullSmall", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_SkullSmall_Multi", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NecklaceLong_Teeth", basePrice=1, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Jewelry.Nose] [Rarity.Rare] (4 items)
    { item="Base.NoseRing_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NoseRing_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NoseStud_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.NoseStud_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Jewelry.Ring] [Rarity.Rare] (24 items)
    { item="Base.Ring_Left_MiddleFinger_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_MiddleFinger_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_MiddleFinger_GoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_MiddleFinger_Signet", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_MiddleFinger_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_MiddleFinger_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_GoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_Signet", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_GoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_Signet", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_MiddleFinger_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_Gold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_GoldRuby", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_Signet", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_Silver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Ring_Right_RingFinger_SilverDiamond", basePrice=1, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },

    -- [Clothing.Accessory.Jewelry.Wrist] [Rarity.Rare] (10 items)
    { item="Base.Bracelet_BangleLeftGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_BangleLeftSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_BangleRightGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_BangleRightSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_ChainLeftGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_ChainLeftSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_ChainRightGold", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_ChainRightSilver", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_LeftFriendshipTINT", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
    { item="Base.Bracelet_RightFriendshipTINT", basePrice=1, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Clothing.Accessory", "Clothing.Accessory.Jewelry"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Jewelry Registry Complete")
