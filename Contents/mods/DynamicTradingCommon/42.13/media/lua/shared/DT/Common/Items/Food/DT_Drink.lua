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
    { item="Base.HotDrink", basePrice=680, tags={"Food.Drink.NonAlcoholic", "Rarity.Common", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=2, max=15} },

    -- [Food.Drink.NonAlcoholic] [Rarity.Rare] (40 items)
    { item="Base.AnimalMilkPowder", basePrice=2295, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.CannedFruitBeverage_Box", basePrice=1143, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedFruitBeverageOpen", basePrice=963, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedMilk_Box", basePrice=1143, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedMilkOpen", basePrice=1221, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Coffee2", basePrice=1711, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=5} },
    { item="Base.HotDrinkClay", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkCopper", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkGold", basePrice=3736, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.HotDrinkMetal", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkRed", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkSilver", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkSpiffo", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTea", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTeaCeramic", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkTumbler", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.HotDrinkWhite", basePrice=1175, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.JuiceBox", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxApple", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxFruitpunch", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceBoxOrange", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.JuiceCranberry", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceFruitpunch", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceGrape", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceLemon", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceOrange", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.JuiceTomato", basePrice=1179, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.Milk", basePrice=1164, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.Milk_Personalsized", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.MilkBottle", basePrice=1164, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.MilkChocolate_Personalsized", basePrice=1153, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=13} },
    { item="Base.Pop", basePrice=1154, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Pop2", basePrice=1154, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.Pop3", basePrice=1154, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.PopBottle", basePrice=1193, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.PopBottleRare", basePrice=1193, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=14} },
    { item="Base.SodaCan", basePrice=1154, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=8} },
    { item="Base.WaterRationCan_Box", basePrice=1143, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCan_Open", basePrice=828, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=9} },
    { item="Base.WaterRationCanEmpty", basePrice=346, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=15} },
})

print("[DynamicTrading] Drink Registry Complete")
