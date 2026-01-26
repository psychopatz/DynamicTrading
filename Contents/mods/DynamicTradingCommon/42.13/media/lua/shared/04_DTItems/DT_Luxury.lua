require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- ==========================================================
    -- 1. HIGH-END JEWELRY (Diamonds, Pearls, Gems)
    -- ==========================================================
    -- Tags: 'Luxury' applies 3.0x Price Multiplier. 'Rare' applies 2.0x.
    
    { item="Base.Necklace_Pearl",                  tags={"Jewelry", "Luxury", "Rare"}, basePrice=50, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldDiamond",            tags={"Jewelry", "Luxury", "Rare"}, basePrice=30, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_GoldDiamond",        tags={"Jewelry", "Luxury", "Rare"}, basePrice=30, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldRuby",               tags={"Jewelry", "Luxury", "Rare"}, basePrice=28, stockRange={min=0, max=1} },
    { item="Base.Necklace_SilverDiamond",          tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_SilverDiamond",      tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    
    { item="Base.Ring_Left_RingFinger_GoldDiamond",  tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    { item="Base.Ring_Left_RingFinger_GoldRuby",     tags={"Jewelry", "Luxury", "Rare"}, basePrice=22, stockRange={min=0, max=1} },
    
    { item="Base.Earring_Dangly_Diamond",          tags={"Jewelry", "Luxury", "Rare"}, basePrice=20, stockRange={min=0, max=2} },
    { item="Base.Earring_Dangly_Ruby",             tags={"Jewelry", "Luxury", "Rare"}, basePrice=18, stockRange={min=0, max=2} },
    { item="Base.BellyButton_RingGoldDiamond",     tags={"Jewelry", "Luxury", "Rare"}, basePrice=15, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 2. PRECIOUS METALS (Gold & Silver)
    -- ==========================================================
    -- Tags: 'Jewelry' (High value) but 'Common' availability.

    -- Gold
    { item="Base.Necklace_Gold",                   tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=15, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_Gold",               tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=15, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Gold",       tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=10, stockRange={min=1, max=3} },
    { item="Base.Earring_Stud_Gold",               tags={"Jewelry", "Luxury", "Common"},   basePrice=8,  stockRange={min=2, max=6} },
    { item="Base.NoseRing_Gold",                   tags={"Jewelry", "Luxury", "Common"},   basePrice=6,  stockRange={min=2, max=6} },
    
    -- Silver / Stones
    { item="Base.Necklace_SilverSapphire",         tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=14, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_SilverSapphire",     tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=14, stockRange={min=1, max=2} },
    { item="Base.Necklace_Silver",                 tags={"Jewelry", "Common"},             basePrice=8,  stockRange={min=1, max=3} },
    { item="Base.NecklaceLong_Silver",             tags={"Jewelry", "Common"},             basePrice=8,  stockRange={min=1, max=3} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond", tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_MiddleFinger_Signet",   tags={"Jewelry", "Common"},             basePrice=9,  stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Silver",     tags={"Jewelry", "Common"},             basePrice=5,  stockRange={min=2, max=5} },
    { item="Base.NoseStud_Silver",                 tags={"Jewelry", "Common"},             basePrice=3,  stockRange={min=3, max=8} },

    -- Personal / Medals
    { item="Base.Locket",                          tags={"Jewelry", "Personal", "Common"}, basePrice=10, stockRange={min=1, max=3} },
    { item="Base.Necklace_Crucifix",               tags={"Jewelry", "Personal", "Common"}, basePrice=5,  stockRange={min=1, max=4} },
    { item="Base.Medal_Gold",                      tags={"Jewelry", "Luxury", "Rare"},     basePrice=25, stockRange={min=0, max=1} },
    { item="Base.Medal_Silver",                    tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=18, stockRange={min=0, max=1} },
    { item="Base.Medal_Bronze",                    tags={"Jewelry", "Common"},             basePrice=10, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 3. WATCHES & BRACELETS
    -- ==========================================================
    
    -- Luxury Watches (Trade Goods)
    { item="Base.WristWatch_Left_Expensive",       tags={"Jewelry", "Luxury", "Rare"},     basePrice=40, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Right_Expensive",      tags={"Jewelry", "Luxury", "Rare"},     basePrice=40, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Left_ClassicGold",     tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=25, stockRange={min=0, max=2} },
    
    -- Functional Watches (Electronics)
    { item="Base.WristWatch_Left_ClassicMilitary", tags={"Electronics", "Military", "Uncommon"}, basePrice=15, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_DigitalDress",    tags={"Electronics", "General", "Common"},    basePrice=12, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_ClassicBlack",    tags={"Electronics", "General", "Common"},    basePrice=8,  stockRange={min=2, max=5} },
    { item="Base.WristWatch_Left_DigitalBlack",    tags={"Electronics", "General", "Common"},    basePrice=5,  stockRange={min=3, max=10} },

    -- Bracelets
    { item="Base.Bracelet_BangleLeftGold",         tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=15, stockRange={min=1, max=2} },
    { item="Base.Bracelet_ChainLeftSilver",        tags={"Jewelry", "Common"},             basePrice=8,  stockRange={min=1, max=4} },
    { item="Base.Bracelet_LeftFriendshipTINT",     tags={"Clothing", "Junk"},              basePrice=1,  stockRange={min=5, max=15} },

    -- ==========================================================
    -- 4. PRIMITIVE & BONE JEWELRY (Survivalist)
    -- ==========================================================
    -- Logic: Cheap, crafted items. 'Survivalist' tag fits Merchant themes.
    
    { item="Base.Cuirass_BasicBone",               tags={"Clothing", "Survivalist", "Common"}, basePrice=12, stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullMammal_Multi",      tags={"Clothing", "Survivalist", "Common"}, basePrice=8,  stockRange={min=1, max=3} },
    { item="Base.Necklace_BoarTusk_Multi",         tags={"Clothing", "Survivalist", "Common"}, basePrice=6,  stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullSmall",             tags={"Clothing", "Survivalist", "Common"}, basePrice=4,  stockRange={min=2, max=5} },
    { item="Base.Necklace_Teeth",                  tags={"Clothing", "Survivalist", "Common"}, basePrice=3,  stockRange={min=2, max=6} },
    { item="Base.Earring_BirdSkull",               tags={"Clothing", "Survivalist", "Common"}, basePrice=3,  stockRange={min=2, max=6} },

})

print("[DynamicTrading] Luxury Registry Complete.")
