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
    { item="Base.Broccoli", basePrice=56, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Cabbage", basePrice=87, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=6} },
    { item="Base.CabbageRoll", basePrice=76, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=3} },
    { item="Base.CakeCarrot", basePrice=44, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.Carrots", basePrice=62, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRings", basePrice=62, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.FriedOnionRingsCraft", basePrice=62, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.GriddlePanFriedVegetables", basePrice=53, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Leek", basePrice=69, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Lettuce", basePrice=71, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.MixedVegetables", basePrice=102, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=4} },
    { item="Base.Onion", basePrice=75, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.PanFriedVegetables", basePrice=65, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetables2", basePrice=53, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=2} },
    { item="Base.PanFriedVegetablesForged", basePrice=66, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.MediumNutrition"}, stockRange={min=0, max=2} },
    { item="Base.Potato", basePrice=101, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.PotatoPancakes", basePrice=74, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
    { item="Base.SweetPotato", basePrice=99, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=6} },
    { item="Base.Tomato", basePrice=80, tags={"Food.Perishable.Vegetable", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Vegetable Registry Complete")
