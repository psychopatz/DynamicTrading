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
    { item="Base.Bitters", basePrice=58, tags={"Food.Drink.Alcohol", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=1, max=10} },

    -- [Food.Drink.Alcohol] [Rarity.Rare] (4 items)
    { item="Base.BeerCanPack", basePrice=91, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.BeerPack", basePrice=91, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=2} },
    { item="Base.WineRed_Boxed", basePrice=83, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
    { item="Base.WineWhite_Boxed", basePrice=83, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Alcohol Registry Complete")
