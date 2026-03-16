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
    { item="Base.HotDrink", basePrice=38, tags={"Food.Drink.NonAlcoholic", "Rarity.Common", "Food.LowNutrition"}, stockRange={min=3, max=15} },

    -- [Food.Drink.NonAlcoholic] [Rarity.Rare] (40 items)
    { item="Base.AnimalMilkPowder", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedFruitBeverage_Box", basePrice=23, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedFruitBeverageOpen", basePrice=157, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.CannedMilk_Box", basePrice=23, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.CannedMilkOpen", basePrice=110, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Coffee2", basePrice=168, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.MediumNutrition", "Food.LowQuality"}, stockRange={min=0, max=4} },
    { item="Base.HotDrinkClay", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkCopper", basePrice=60, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Origin.Police", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkGold", basePrice=89, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Luxury", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkMetal", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkRed", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkSilver", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkSpiffo", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTea", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTeaCeramic", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkTumbler", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.HotDrinkWhite", basePrice=56, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.JuiceBox", basePrice=33, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceBoxApple", basePrice=33, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceBoxFruitpunch", basePrice=33, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceBoxOrange", basePrice=33, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceCranberry", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceFruitpunch", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceGrape", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceLemon", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceOrange", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.JuiceTomato", basePrice=59, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.Milk", basePrice=45, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.Milk_Personalsized", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.MilkBottle", basePrice=45, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.MilkChocolate_Personalsized", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.Pop", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Pop2", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Pop3", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PopBottle", basePrice=74, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.PopBottleRare", basePrice=74, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.SodaCan", basePrice=34, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.WaterRationCan_Box", basePrice=23, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCan_Open", basePrice=22, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=10} },
    { item="Base.WaterRationCanEmpty", basePrice=10, tags={"Food.Drink.NonAlcoholic", "Rarity.Rare", "Quality.Waste", "Food.LowNutrition"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Drink Registry Complete")
