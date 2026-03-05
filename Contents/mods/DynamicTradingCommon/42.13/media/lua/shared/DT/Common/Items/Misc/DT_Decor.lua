-- =============================================================================
-- DYNAMIC TRADING: MISC - DECOR
-- =============================================================================
-- Root Category: Misc
-- Sub Category: Decor
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Bell",                 basePrice=5,   tags={"Misc.Decor", "Resource.Material.Metal", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.BookFancy_Prop",       basePrice=15,  tags={"Misc.Decor", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.Book_Prop",            basePrice=5,   tags={"Misc.Decor", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.BrassNameplate",       basePrice=10,  tags={"Misc.Decor", "Resource.Material.Metal", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Doily",            basePrice=2,   tags={"Misc.Decor", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Frame",                basePrice=15,  tags={"Misc.Decor", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.GemBag",                       basePrice=5,   tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=2, max=10} },
    { item="Base.Goblet_Gold",    tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Goblet_Silver",  tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=14, stockRange={min=0, max=2} },
    { item="Base.GoldCup",        tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=18, stockRange={min=0, max=2} },
    { item="Base.Humidor",                      basePrice=15,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=1, max=3} },
    { item="Base.JewelleryBox",                 basePrice=10,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=2, max=8} },
    { item="Base.JewelleryBox_Fancy",           basePrice=20,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=1, max=3} },
    { item="Base.SilverCup",      tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=12, stockRange={min=0, max=2} },
    { item="Base.TrophyBronze",   tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=10, stockRange={min=0, max=1} },
    { item="Base.TrophyGold",     tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=20, stockRange={min=0, max=1} }, -- Real: 60,
    { item="Base.TrophySilver",   tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=15, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Misc/Decor Registry Loaded.")
