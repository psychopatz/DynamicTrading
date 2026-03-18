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

    -- [Food.Drink.NonAlcoholic] [Rarity.Rare] (40 items)
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
    { item="Base.JuiceBox", basePrice=88, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxApple", basePrice=88, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxFruitpunch", basePrice=88, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxOrange", basePrice=88, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceCranberry", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceFruitpunch", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceGrape", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceLemon", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceOrange", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceTomato", basePrice=114, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Milk", basePrice=100, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.Milk_Personalsized", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.MilkBottle", basePrice=100, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.MilkChocolate_Personalsized", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.Pop", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Pop2", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Pop3", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.PopBottle", basePrice=129, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.PopBottleRare", basePrice=129, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.SodaCan", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.WaterRationCan_Box", basePrice=79, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCan_Open", basePrice=61, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=9} },
    { item="Base.WaterRationCanEmpty", basePrice=27, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=15} },
})

print("[DynamicTrading] Drink Registry Complete")
