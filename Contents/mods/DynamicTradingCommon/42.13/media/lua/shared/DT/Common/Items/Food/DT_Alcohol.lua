-- ============================================================================
-- Food Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Food.Drink.Alcohol] [Rarity.Common] (1 item)
    { item="Base.Bitters", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Common", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=2, max=10} },

    -- [Food.Drink.Alcohol] [Rarity.Rare] (24 items)
    { item="Base.BeerBottle", basePrice=3, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.BeerCan", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.BeerCanPack", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.BeerImported", basePrice=3, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.BeerPack", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.Brandy", basePrice=8, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.Champagne", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Cider", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.CoffeeLiquer", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Gin", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Port", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Rum", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Tequila", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Vodka", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Whiskey", basePrice=6, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.Wine", basePrice=14, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.Wine2", basePrice=14, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.Wine2Open", basePrice=14, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.WineAged", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.WineBox", basePrice=21, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=10} },
    { item="Base.WineOpen", basePrice=14, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=6} },
    { item="Base.WineRed_Boxed", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
    { item="Base.WineScrewtop", basePrice=4, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=4} },
    { item="Base.WineWhite_Boxed", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Alcohol Registry Complete")
