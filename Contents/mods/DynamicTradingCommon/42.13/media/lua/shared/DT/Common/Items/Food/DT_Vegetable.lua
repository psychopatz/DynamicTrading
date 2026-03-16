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
    { item="Base.Broccoli", basePrice=1175, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Cabbage", basePrice=1629, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CabbageRoll", basePrice=1195, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeCarrot", basePrice=1164, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Carrots", basePrice=1181, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRings", basePrice=1181, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRingsCraft", basePrice=1181, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.GriddlePanFriedVegetables", basePrice=1173, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Leek", basePrice=1188, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Lettuce", basePrice=1191, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MixedVegetables", basePrice=1221, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Onion", basePrice=1195, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PanFriedVegetables", basePrice=1608, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetables2", basePrice=1173, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetablesForged", basePrice=1609, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Potato", basePrice=1221, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.PotatoPancakes", basePrice=1193, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.SweetPotato", basePrice=1218, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Tomato", basePrice=1199, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Origin.Vanilla", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Vegetable Registry Complete")
