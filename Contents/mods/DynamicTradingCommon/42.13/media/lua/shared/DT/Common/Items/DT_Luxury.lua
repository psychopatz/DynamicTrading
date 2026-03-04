require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- ==========================================================
    -- 1. HIGH-END JEWELRY (Diamonds, Pearls, Gems)
    -- ==========================================================
    -- Tags: 'Luxury' applies 3.0x Price Multiplier. 'Rare' applies 2.0x.
    
    { item="Base.Necklace_Pearl",                  tags={"Luxury.Jewelry", "Rarity.Legendary"}, basePrice=1500, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldDiamond",            tags={"Luxury.Jewelry", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_GoldDiamond",        tags={"Luxury.Jewelry", "Rarity.Legendary"}, basePrice=1200, stockRange={min=0, max=1} },
    { item="Base.Necklace_GoldRuby",               tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=900, stockRange={min=0, max=1} },
    { item="Base.Necklace_SilverDiamond",          tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },
    { item="Base.NecklaceLong_SilverDiamond",      tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=800, stockRange={min=0, max=1} },
    
    { item="Base.Ring_Left_RingFinger_GoldDiamond",  tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
    { item="Base.Ring_Right_RingFinger_GoldDiamond", tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=750, stockRange={min=0, max=1} },
    { item="Base.Ring_Left_RingFinger_GoldRuby",     tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=650, stockRange={min=0, max=1} },
    
    { item="Base.Earring_Dangly_Diamond",          tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=500, stockRange={min=0, max=2} },
    { item="Base.Earring_Dangly_Ruby",             tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=2} },
    { item="Base.BellyButton_RingGoldDiamond",     tags={"Luxury.Jewelry", "Rarity.Rare"}, basePrice=350, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 2. PRECIOUS METALS (Gold & Silver)
    -- ==========================================================
    -- Tags: 'Jewelry' (High value) but 'Common' availability.

    -- Gold
    { item="Base.Necklace_Gold",                   tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_Gold",               tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Gold",       tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=250, stockRange={min=1, max=3} },
    { item="Base.Earring_Stud_Gold",               tags={"Luxury.Jewelry", "Rarity.Common"},   basePrice=150,  stockRange={min=2, max=6} },
    { item="Base.NoseRing_Gold",                   tags={"Luxury.Jewelry", "Rarity.Common"},   basePrice=120,  stockRange={min=2, max=6} },
    
    -- Silver / Stones
    { item="Base.Necklace_SilverSapphire",         tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=2} },
    { item="Base.NecklaceLong_SilverSapphire",     tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=2} },
    { item="Base.Necklace_Silver",                 tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=180,  stockRange={min=1, max=3} },
    { item="Base.NecklaceLong_Silver",             tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=180,  stockRange={min=1, max=3} },
    { item="Base.Ring_Left_RingFinger_SilverDiamond", tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=2} },
    { item="Base.Ring_Left_MiddleFinger_Signet",   tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=150,  stockRange={min=1, max=2} },
    { item="Base.Ring_Left_RingFinger_Silver",     tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=100,  stockRange={min=2, max=5} },
    { item="Base.NoseStud_Silver",                 tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=50,  stockRange={min=3, max=8} },

    -- Personal / Medals
    { item="Base.Locket",                          tags={"Luxury.Jewelry", "Quality.Luxury", "Rarity.Common"}, basePrice=120, stockRange={min=1, max=3} },
    { item="Base.Necklace_Crucifix",               tags={"Luxury.Jewelry", "Rarity.Common"}, basePrice=65,  stockRange={min=1, max=4} },
    { item="Base.Medal_Gold",                      tags={"Luxury.Jewelry", "Rarity.Rare"},     basePrice=500, stockRange={min=0, max=1} },
    { item="Base.Medal_Silver",                    tags={"Luxury.Jewelry", "Rarity.Uncommon"}, basePrice=350, stockRange={min=0, max=1} },
    { item="Base.Medal_Bronze",                    tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=150, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 3. WATCHES & BRACELETS
    -- ==========================================================
    
    -- Luxury Watches (Trade Goods)
    -- Luxury Watches (Trade Goods)
    { item="Base.WristWatch_Left_Expensive",       tags={"Luxury.Jewelry.Watch", "Quality.Luxury", "Rarity.Rare"},     basePrice=150, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Right_Expensive",      tags={"Luxury.Jewelry.Watch", "Quality.Luxury", "Rarity.Rare"},     basePrice=150, stockRange={min=0, max=1} },
    { item="Base.WristWatch_Left_ClassicGold",     tags={"Luxury.Jewelry.Watch", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=85,  stockRange={min=0, max=2} },
    
    -- Functional Watches (Electronics)
    { item="Base.WristWatch_Left_ClassicMilitary", tags={"Electronics.Gadget.Wristwatch", "Origin.Military", "Rarity.Uncommon"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_DigitalDress",    tags={"Electronics.Gadget.Wristwatch", "Rarity.Common"},    basePrice=35, stockRange={min=1, max=3} },
    { item="Base.WristWatch_Left_ClassicBlack",    tags={"Electronics.Gadget.Wristwatch", "Rarity.Common"},    basePrice=25,  stockRange={min=2, max=5} },
    { item="Base.WristWatch_Left_DigitalBlack",    tags={"Electronics.Gadget.Wristwatch", "Rarity.Common"},    basePrice=15,  stockRange={min=3, max=10} },

    -- Bracelets
    { item="Base.Bracelet_BangleLeftGold",         tags={"Luxury.Jewelry", "Quality.Luxury", "Rarity.Uncommon"}, basePrice=45, stockRange={min=1, max=2} },
    { item="Base.Bracelet_ChainLeftSilver",        tags={"Luxury.Jewelry", "Rarity.Common"},             basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.Bracelet_LeftFriendshipTINT",     tags={"Luxury.Jewelry", "Quality.Junk", "Rarity.Common"}, basePrice=2,  stockRange={min=5, max=15} },

    -- ==========================================================
    -- 4. PRIMITIVE & BONE JEWELRY (Survivalist)
    -- ==========================================================
    -- Logic: Cheap, crafted items. 'Survivalist' tag fits Merchant themes.
    
    { item="Base.Cuirass_BasicBone",               tags={"Clothing.Armor.Torso", "Origin.Primitive", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullMammal_Multi",      tags={"Luxury.Jewelry", "Origin.Primitive", "Rarity.Common"}, basePrice=25,  stockRange={min=1, max=3} },
    { item="Base.Necklace_BoarTusk_Multi",         tags={"Luxury.Jewelry", "Origin.Primitive", "Rarity.Common"}, basePrice=20,  stockRange={min=1, max=3} },
    { item="Base.Necklace_SkullSmall",             tags={"Luxury.Jewelry", "Origin.Primitive", "Rarity.Common"}, basePrice=15,  stockRange={min=2, max=5} },
    { item="Base.Necklace_Teeth",                  tags={"Luxury.Jewelry", "Origin.Primitive", "Rarity.Common"}, basePrice=10,  stockRange={min=2, max=6} },
    { item="Base.Earring_BirdSkull",               tags={"Luxury.Jewelry", "Origin.Primitive", "Rarity.Common"}, basePrice=10,  stockRange={min=2, max=6} },

})

print("[DynamicTrading] Luxury Registry Complete \n.")
