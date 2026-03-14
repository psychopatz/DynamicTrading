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

    -- [Food.NonPerishable.Fruit] [Rarity.Rare] (2 items)
    { item="Base.CandyFruitSlices", basePrice=37, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.JamFruit", basePrice=151, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fruit] [Rarity.Rare] (29 items)
    { item="Base.Apple", basePrice=98, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Avocado", basePrice=80, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Banana", basePrice=93, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BeautyBerry", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryBlack", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryBlue", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryGeneric1", basePrice=60, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryGeneric2", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryGeneric3", basePrice=60, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryGeneric4", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryGeneric5", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.BerryPoisonIvy", basePrice=61, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CakeStrawberryShortcake", basePrice=44, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CandiedApple", basePrice=107, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FruitSalad", basePrice=92, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=5} },
    { item="Base.FruitSaladClay", basePrice=92, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Grapefruit", basePrice=148, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.HollyBerry", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.LemonBar", basePrice=69, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MuffinFruit", basePrice=73, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Orange", basePrice=84, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Peach", basePrice=75, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Pear", basePrice=97, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PieApple", basePrice=73, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PieBlueberry", basePrice=73, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PieKeyLime", basePrice=73, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.PieLemonMeringue", basePrice=73, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.Pineapple", basePrice=121, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=7} },
    { item="Base.WinterBerry", basePrice=95, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Fruit Registry Complete")
