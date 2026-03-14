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

    -- [Food.Perishable.Vegetable] [Rarity.Rare] (19 items)
    { item="Base.Broccoli", basePrice=56, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Cabbage", basePrice=136, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=12} },
    { item="Base.CabbageRoll", basePrice=70, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=7} },
    { item="Base.CakeCarrot", basePrice=40, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.Carrots", basePrice=55, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FriedOnionRings", basePrice=97, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.FriedOnionRingsCraft", basePrice=97, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.GriddlePanFriedVegetables", basePrice=10, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Leek", basePrice=32, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Lettuce", basePrice=88, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.MixedVegetables", basePrice=63, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Onion", basePrice=79, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.PanFriedVegetables", basePrice=12, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.PanFriedVegetables2", basePrice=11, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=5} },
    { item="Base.PanFriedVegetablesForged", basePrice=18, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=5} },
    { item="Base.Potato", basePrice=264, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.PotatoPancakes", basePrice=134, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
    { item="Base.SweetPotato", basePrice=222, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Tomato", basePrice=82, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Vegetable Registry Complete")
