require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- HIGH-END JEWELRY (Diamonds & Gems)
    -- =============================================================================
    -- Logic: Base prices are set lower (15-25) because the "Jewelry" (3.0x) 
    -- and "Luxury" tags will multiply the final value significantly.
    
    -- NECKLACES
    { item="Base.Necklace_GoldDiamond",        tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_GoldDiamond",    tags={"Jewelry", "Luxury", "Rare"}, basePrice=25, stockRange={min=0, max=1} },
    { item="Base.Necklace_Pearl",              tags={"Jewelry", "Luxury", "Rare"}, basePrice=22, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldRuby",           tags={"Jewelry", "Luxury", "Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Necklace_SilverDiamond",      tags={"Jewelry", "Luxury", "Rare"}, basePrice=18, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_SilverDiamond",  tags={"Jewelry", "Luxury", "Rare"}, basePrice=18, stockRange={min=0, max=1} },
    
    -- RINGS
    { item="Base.Ring_Left_RingFinger_GoldDiamond",  tags={"Jewelry", "Luxury", "Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", tags={"Jewelry", "Luxury", "Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Ring_Left_RingFinger_GoldRuby",     tags={"Jewelry", "Luxury", "Rare"}, basePrice=18, stockRange={min=0, max=1} },

    -- BODY
    { item="Base.Earring_Dangly_Diamond",      tags={"Jewelry", "Luxury", "Rare"}, basePrice=15, stockRange={min=0, max=2} },
    { item="Base.Earring_Dangly_Ruby",         tags={"Jewelry", "Luxury", "Rare"}, basePrice=14, stockRange={min=0, max=2} },
    { item="Base.BellyButton_RingGoldDiamond", tags={"Jewelry", "Luxury", "Rare"}, basePrice=12, stockRange={min=0, max=2} },

    -- =============================================================================
    -- STANDARD PRECIOUS METALS (Gold & Silver)
    -- =============================================================================
    
    -- GOLD
    { item="Base.Necklace_Gold",               tags={"Jewelry", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_Gold",           tags={"Jewelry", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Gold",   tags={"Jewelry", "Uncommon"}, basePrice=8,  stockRange={min=1, max=3} },
    { item="Base.Earring_Stud_Gold",           tags={"Jewelry", "Uncommon"}, basePrice=5,  stockRange={min=2, max=6} },
    { item="Base.NoseRing_Gold",               tags={"Jewelry", "Uncommon"}, basePrice=5,  stockRange={min=2, max=6} },
    { item="Base.Medal_Gold",                  tags={"Jewelry", "Rare"},     basePrice=20, stockRange={min=0, max=1} },

    -- SILVER / OTHER
    { item="Base.Necklace_SilverSapphire",     tags={"Jewelry", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_SilverSapphire", tags={"Jewelry", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.Necklace_Silver",             tags={"Jewelry", "Common"},   basePrice=7,  stockRange={min=1, max=3} },
    { item="Base.NecklaceLong_Silver",         tags={"Jewelry", "Common"},   basePrice=7,  stockRange={min=1, max=3} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond",tags={"Jewelry", "Uncommon"}, basePrice=10, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_MiddleFinger_Signet",tags={"Jewelry", "Common"},  basePrice=8,  stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Silver", tags={"Jewelry", "Common"},   basePrice=4,  stockRange={min=2, max=5} },
    { item="Base.NoseStud_Silver",             tags={"Jewelry", "Common"},   basePrice=2,  stockRange={min=3, max=8} },
    { item="Base.Medal_Silver",                tags={"Jewelry", "Uncommon"}, basePrice=14, stockRange={min=0, max=1} },
    { item="Base.Medal_Bronze",                tags={"Jewelry", "Common"},   basePrice=8,  stockRange={min=0, max=2} },

    -- PERSONAL / SENTIMENTAL
    { item="Base.Locket",              tags={"Jewelry", "Personal", "Common"}, basePrice=8, stockRange={min=1, max=3} },
    { item="Base.Necklace_Crucifix",   tags={"Jewelry", "Personal", "Common"}, basePrice=5, stockRange={min=1, max=4} },

    -- =============================================================================
    -- WRISTWATCHES
    -- =============================================================================
    
    -- LUXURY TIMEPIECES (Trade Goods)
    { item="Base.WristWatch_Left_Expensive",      tags={"Jewelry", "Luxury", "Rare"}, basePrice=30, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Right_Expensive",     tags={"Jewelry", "Luxury", "Rare"}, basePrice=30, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Left_ClassicGold",    tags={"Jewelry", "Luxury", "Rare"}, basePrice=20, stockRange={min=0, max=2} },
    
    -- FUNCTIONAL (Electronics/Utility)
    { item="Base.WristWatch_Left_ClassicMilitary",tags={"Electronics", "Military", "Uncommon"}, basePrice=15, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_DigitalDress",   tags={"Electronics", "General", "Common"},    basePrice=10, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_ClassicBlack",   tags={"Electronics", "General", "Common"},    basePrice=6,  stockRange={min=2, max=5} },
    { item="Base.WristWatch_Left_DigitalBlack",   tags={"Electronics", "General", "Common"},    basePrice=2,  stockRange={min=3, max=10} },

    -- BRACELETS (Friendship bracelets are Junk)
    { item="Base.Bracelet_BangleLeftGold",        tags={"Jewelry", "Luxury", "Uncommon"}, basePrice=12, stockRange={min=1, max=2} },
    { item="Base.Bracelet_ChainLeftSilver",       tags={"Jewelry", "Common"},             basePrice=6,  stockRange={min=1, max=4} },
    { item="Base.Bracelet_LeftFriendshipTINT",    tags={"Clothing", "Junk"},              basePrice=1,  stockRange={min=5, max=15} },

    -- =============================================================================
    -- PRIMITIVE & BONE (Survivalist)
    -- =============================================================================
    -- Logic: These are cheap to make but have style value. Tagged Survivalist.

    { item="Base.Cuirass_BasicBone",          tags={"Clothing", "Survivalist", "Common"}, basePrice=10, stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullMammal_Multi", tags={"Clothing", "Survivalist", "Common"}, basePrice=6,  stockRange={min=1, max=3} },
    { item="Base.Necklace_BoarTusk_Multi",    tags={"Clothing", "Survivalist", "Common"}, basePrice=5,  stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullSmall",        tags={"Clothing", "Survivalist", "Common"}, basePrice=3,  stockRange={min=2, max=5} },
    { item="Base.Necklace_Teeth",             tags={"Clothing", "Survivalist", "Common"}, basePrice=2,  stockRange={min=2, max=6} },
    { item="Base.Earring_BirdSkull",          tags={"Clothing", "Survivalist", "Common"}, basePrice=2,  stockRange={min=2, max=6} },

})

print("[DynamicTrading] Luxury Items Registered.")