-- =============================================================================
-- DYNAMIC TRADING: FOOD - DRINK
-- =============================================================================
-- Root Category: Food
-- Sub Category: Drink
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BeerBottle",    tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=8,  stockRange={min=3, max=10} },
    { item="Base.BeerImported",  tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=10, stockRange={min=2, max=6} },
    { item="Base.Brandy",        tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Champagne",     tags={"Food.Drink.Alcohol", "Quality.Luxury", "Rarity.Rare"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.Gin",           tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Rum",           tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Tequila",       tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Vodka",         tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Whiskey",       tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=120, stockRange={min=1, max=3} },
    { item="Base.WineAged",      tags={"Food.Drink.Alcohol", "Quality.Luxury", "Rarity.Rare"}, basePrice=35, stockRange={min=0, max=2} },
    { item="Base.WineBox",       tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=18, stockRange={min=1, max=4} },
})

print("[DynamicTrading] Food/Drink Registry Loaded.")
