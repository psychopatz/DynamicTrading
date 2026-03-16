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
    { item="Base.CandyFruitSlices", basePrice=23, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.JamFruit", basePrice=99, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fruit] [Rarity.Rare] (29 items)
    { item="Base.Apple", basePrice=85, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Avocado", basePrice=103, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Banana", basePrice=81, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BeautyBerry", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlack", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlue", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric1", basePrice=55, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric2", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric3", basePrice=54, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric4", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric5", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryPoisonIvy", basePrice=55, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeStrawberryShortcake", basePrice=47, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CandiedApple", basePrice=91, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FruitSalad", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.FruitSaladClay", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Grapefruit", basePrice=149, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.HollyBerry", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.LemonBar", basePrice=48, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MuffinFruit", basePrice=56, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Orange", basePrice=80, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Peach", basePrice=72, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Pear", basePrice=84, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PieApple", basePrice=119, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieBlueberry", basePrice=119, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieKeyLime", basePrice=119, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieLemonMeringue", basePrice=119, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Pineapple", basePrice=138, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.WinterBerry", basePrice=67, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Fruit Registry Complete")
