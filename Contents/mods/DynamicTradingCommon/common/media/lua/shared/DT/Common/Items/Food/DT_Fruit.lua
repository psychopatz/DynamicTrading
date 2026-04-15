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
    { item="Base.CandyFruitSlices", basePrice=122, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.JamFruit", basePrice=220, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fruit] [Rarity.Rare] (29 items)
    { item="Base.Apple", basePrice=140, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Avocado", basePrice=158, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Banana", basePrice=136, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BeautyBerry", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlack", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlue", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric1", basePrice=110, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric2", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric3", basePrice=110, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric4", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric5", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryPoisonIvy", basePrice=110, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeStrawberryShortcake", basePrice=102, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CandiedApple", basePrice=146, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FruitSalad", basePrice=177, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.FruitSaladClay", basePrice=177, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Grapefruit", basePrice=204, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.HollyBerry", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.LemonBar", basePrice=103, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MuffinFruit", basePrice=111, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Orange", basePrice=135, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Peach", basePrice=127, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Pear", basePrice=139, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PieApple", basePrice=196, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieBlueberry", basePrice=196, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieKeyLime", basePrice=196, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieLemonMeringue", basePrice=196, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Pineapple", basePrice=215, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.WinterBerry", basePrice=122, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Fruit Registry Complete")
