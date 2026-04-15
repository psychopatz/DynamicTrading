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
    { item="Base.HotDrink", basePrice=70, tags={"Food.Drink.NonAlcoholic", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=2, max=15} },

    -- [Food.Drink.NonAlcoholic] [Rarity.Rare] (19 items)
    { item="Base.AnimalMilkPowder", basePrice=167, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.CannedFruitBeverage_Box", basePrice=79, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedFruitBeverageOpen", basePrice=196, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedMilk_Box", basePrice=79, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedMilkOpen", basePrice=166, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Coffee2", basePrice=245, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=5} },
    { item="Base.HotDrinkClay", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkCopper", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkGold", basePrice=270, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.HotDrinkMetal", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkRed", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkSilver", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkSpiffo", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTea", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTeaCeramic", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTumbler", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkWhite", basePrice=111, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.WaterRationCan_Box", basePrice=79, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCan_Open", basePrice=61, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=9} },
})

print("[DynamicTrading] Drink Registry Complete")
