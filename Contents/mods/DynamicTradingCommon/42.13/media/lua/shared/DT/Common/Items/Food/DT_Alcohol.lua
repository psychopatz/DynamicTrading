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
    { item="Base.Bitters", basePrice=668, tags={"Food.Drink.Alcohol", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=1, max=10} },

    -- [Food.Drink.Alcohol] [Rarity.Rare] (24 items)
    { item="Base.BeerBottle", basePrice=1162, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.BeerCan", basePrice=1177, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.BeerCanPack", basePrice=1155, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.BeerImported", basePrice=1177, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.BeerPack", basePrice=1155, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.Brandy", basePrice=1172, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.Champagne", basePrice=1186, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Cider", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.CoffeeLiquer", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Gin", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Port", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Rum", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Tequila", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Vodka", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Whiskey", basePrice=1172, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.Wine", basePrice=1173, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.Wine2", basePrice=1173, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=8} },
    { item="Base.Wine2Open", basePrice=844, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.WineAged", basePrice=1171, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.WineBox", basePrice=1173, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=13} },
    { item="Base.WineOpen", basePrice=844, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.WineRed_Boxed", basePrice=1147, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
    { item="Base.WineScrewtop", basePrice=1186, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=5} },
    { item="Base.WineWhite_Boxed", basePrice=1147, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Alcohol Registry Complete")
