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

    -- [Food.Drink.NonAlcoholic] [Rarity.Common] (1 item)
    { item="Base.HotDrink", basePrice=12, tags={"Food.Drink.NonAlcoholic", "Rarity.Common", "Food.LowNutrition"}, stockRange={min=3, max=15} },

    -- [Food.Drink.NonAlcoholic] [Rarity.Rare] (19 items)
    { item="Base.AnimalMilkPowder", basePrice=1, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedFruitBeverage_Box", basePrice=1, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedFruitBeverageOpen", basePrice=147, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedMilk_Box", basePrice=1, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedMilkOpen", basePrice=94, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Coffee2", basePrice=32, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=4} },
    { item="Base.HotDrinkClay", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkCopper", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Police", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkGold", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Luxury", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkMetal", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkRed", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkSilver", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkSpiffo", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTea", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTeaCeramic", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTumbler", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkWhite", basePrice=20, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.WaterRationCan_Box", basePrice=1, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCan_Open", basePrice=1, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Drink Registry Complete")
