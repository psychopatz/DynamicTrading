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
    { item="Base.BellyButton_DangleGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_DangleGoldRuby", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_DangleSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BellyButton_DangleSilverDiamond", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_RingGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_RingGoldDiamond", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_RingGoldRuby", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_RingSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BellyButton_RingSilverAmethyst", basePrice=64, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BellyButton_RingSilverDiamond", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_RingSilverRuby", basePrice=64, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BellyButton_StudGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_StudGoldDiamond", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.BellyButton_StudSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BellyButton_StudSilverDiamond", basePrice=195, tags={"Clothing.Accessory.Jewelry.Belly", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },

    -- [Clothing.Accessory.Jewelry.Ears] [Rarity.Rare] (21 items)
    { item="Base.Earring_BirdSkull", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_BoarTusk", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Dangly_Diamond", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_Dangly_Emerald", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Dangly_Pearl", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Dangly_Ruby", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Dangly_Sapphire", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_LoopLrg_Gold", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_LoopLrg_Silver", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_LoopMed_Gold", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_LoopMed_Silver", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_LoopSmall_Gold_Both", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_LoopSmall_Gold_Top", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_LoopSmall_Silver_Both", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_LoopSmall_Silver_Top", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Pearl", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Stone_Emerald", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Stone_Ruby", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Stone_Sapphire", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Earring_Stud_Gold", basePrice=206, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Earring_Stud_Silver", basePrice=71, tags={"Clothing.Accessory.Jewelry.Ears", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Jewelry.Necklace] [Rarity.Rare] (36 items)
    { item="Base.Locket", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Medal_Bronze", basePrice=82, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Medal_Gold", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Medal_Silver", basePrice=82, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Necklace_BoarTusk", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_BoarTusk_Multi", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Crucifix", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_DogTag", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_DogTag_Female", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_DogTag_Male", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Gold", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_GoldDiamond", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_GoldRuby", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_Pearl", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Silver", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SilverCrucifix", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SilverDiamond", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Necklace_SilverSapphire", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SkullMammal", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SkullMammal_Multi", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SkullSmall", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_SkullSmall_Multi", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_Teeth", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Necklace_YingYang", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_Amber", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_Gold", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.NecklaceLong_GoldDiamond", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.NecklaceLong_Silver", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SilverDiamond", basePrice=225, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.NecklaceLong_SilverEmerald", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SilverSapphire", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SkullMammal", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SkullMammal_Multi", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SkullSmall", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_SkullSmall_Multi", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NecklaceLong_Teeth", basePrice=83, tags={"Clothing.Accessory.Jewelry.Necklace", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Jewelry.Nose] [Rarity.Rare] (4 items)
    { item="Base.NoseRing_Gold", basePrice=227, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.NoseRing_Silver", basePrice=84, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.NoseStud_Gold", basePrice=227, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.NoseStud_Silver", basePrice=84, tags={"Clothing.Accessory.Jewelry.Nose", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Accessory.Jewelry.Ring] [Rarity.Rare] (24 items)
    { item="Base.Ring_Left_MiddleFinger_Gold", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_MiddleFinger_GoldDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_MiddleFinger_GoldRuby", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_MiddleFinger_Signet", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Left_MiddleFinger_Silver", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Left_MiddleFinger_SilverDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_RingFinger_Gold", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_RingFinger_GoldDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_RingFinger_GoldRuby", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Left_RingFinger_Signet", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Left_RingFinger_Silver", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_MiddleFinger_Gold", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_MiddleFinger_GoldDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_MiddleFinger_GoldRuby", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_MiddleFinger_Signet", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Right_MiddleFinger_Silver", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Right_MiddleFinger_SilverDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_RingFinger_Gold", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_RingFinger_GoldRuby", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Ring_Right_RingFinger_Signet", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Right_RingFinger_Silver", basePrice=74, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Ring_Right_RingFinger_SilverDiamond", basePrice=211, tags={"Clothing.Accessory.Jewelry.Ring", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },

    -- [Clothing.Accessory.Jewelry.Wrist] [Rarity.Rare] (10 items)
    { item="Base.Bracelet_BangleLeftGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Bracelet_BangleLeftSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bracelet_BangleRightGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Bracelet_BangleRightSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bracelet_ChainLeftGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Bracelet_ChainLeftSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bracelet_ChainRightGold", basePrice=195, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Bracelet_ChainRightSilver", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bracelet_LeftFriendshipTINT", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bracelet_RightFriendshipTINT", basePrice=64, tags={"Clothing.Accessory.Jewelry.Wrist", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Jewelry Registry Complete")
