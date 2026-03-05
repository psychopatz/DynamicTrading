-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - COOKING
-- =============================================================================
-- Root Category: Container
-- Sub Category: Cooking
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BakingPan",      tags={"Container.Cooking.Baking", "Rarity.Common"},  basePrice=8,  stockRange={min=2, max=6} },
    { item="Base.Bowl",             tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.CeramicTeacup",    tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=4, stockRange={min=2, max=8} },
    { item="Base.ClayBowl",         tags={"Container.Cooking.Serving", "Origin.Nomad", "Rarity.Common"},    basePrice=1, stockRange={min=5, max=10} },
    { item="Base.DrinkingGlass",    tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=3, stockRange={min=5, max=10} },
    { item="Base.Kettle",         tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.Kettle_Copper",    tags={"Container.Cooking.Boiling", "Quality.Luxury", "Rarity.Rare"}, basePrice=30, stockRange={min=0, max=2} },
    { item="Base.MugWhite",         tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.Pot",            tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=15, stockRange={min=1, max=4} },
    { item="Base.PotForged",      tags={"Container.Cooking.Boiling", "Rarity.Uncommon"}, basePrice=25, stockRange={min=0, max=2} },
    { item="Base.RoastingPan",    tags={"Container.Cooking.Baking", "Rarity.Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.Saucepan",       tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=10, stockRange={min=2, max=5} },
    { item="Base.SaucepanCopper",   tags={"Container.Cooking.Boiling", "Quality.Luxury", "Rarity.Rare"}, basePrice=25, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Container/Cooking Registry Loaded.")
