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

    -- [Food.Drink.Alcohol] [Rarity.Rare] (2 items)
    { item="Base.WineRed_Boxed", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
    { item="Base.WineWhite_Boxed", basePrice=1, tags={"Food.Drink.Alcohol", "Rarity.Rare", "Food.LowNutrition", "Food.Intoxicating"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Alcohol Registry Complete")
