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
    { item="Base.Broccoli", basePrice=111, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Cabbage", basePrice=164, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CabbageRoll", basePrice=131, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeCarrot", basePrice=99, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Carrots", basePrice=117, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRings", basePrice=117, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRingsCraft", basePrice=117, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.GriddlePanFriedVegetables", basePrice=108, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Leek", basePrice=124, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Lettuce", basePrice=126, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MixedVegetables", basePrice=157, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Onion", basePrice=130, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PanFriedVegetables", basePrice=142, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetables2", basePrice=108, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetablesForged", basePrice=143, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Potato", basePrice=157, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.PotatoPancakes", basePrice=129, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.SweetPotato", basePrice=154, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Tomato", basePrice=135, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Vegetable Registry Complete")
