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
    { item="Base.CandyFruitSlices", basePrice=2012, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.JamFruit", basePrice=2512, tags={"Food.NonPerishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Fruit] [Rarity.Rare] (29 items)
    { item="Base.Apple", basePrice=1204, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Avocado", basePrice=1223, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Banana", basePrice=1200, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BeautyBerry", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlack", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryBlue", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric1", basePrice=1174, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric2", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric3", basePrice=1174, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric4", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryGeneric5", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.BerryPoisonIvy", basePrice=1174, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CakeStrawberryShortcake", basePrice=1166, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CandiedApple", basePrice=1211, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FruitSalad", basePrice=1241, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.FruitSaladClay", basePrice=1241, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.HighNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Grapefruit", basePrice=1269, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.HollyBerry", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.LemonBar", basePrice=1167, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MuffinFruit", basePrice=1175, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Orange", basePrice=1199, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Peach", basePrice=1191, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Pear", basePrice=1204, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PieApple", basePrice=1662, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieBlueberry", basePrice=1662, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieKeyLime", basePrice=1662, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.PieLemonMeringue", basePrice=1662, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.Pineapple", basePrice=1681, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=3} },
    { item="Base.WinterBerry", basePrice=1186, tags={"Food.Perishable.Fruit", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Fruit Registry Complete")
