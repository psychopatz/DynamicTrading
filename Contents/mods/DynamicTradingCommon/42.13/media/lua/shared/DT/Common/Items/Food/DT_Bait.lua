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

    -- [Food.NonPerishable.Bait] [Rarity.Rare] (2 items)
    { item="Base.Chum", basePrice=1, tags={"Food.NonPerishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=7} },
    { item="Base.GummyWorms", basePrice=37, tags={"Food.NonPerishable.Bait", "Rarity.Rare", "Food.LowNutrition"}, stockRange={min=0, max=12} },

    -- [Food.Perishable.Bait] [Rarity.Rare] (10 items)
    { item="Base.AmericanLadyCaterpillar", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.BaitFish", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.BandedWoolyBearCaterpillar", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Cricket", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Grasshopper", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Maggots", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=25} },
    { item="Base.MonarchCaterpillar", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.SilkMothCaterpillar", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.SwallowtailCaterpillar", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=12} },
    { item="Base.Worm", basePrice=1, tags={"Food.Perishable.Bait", "Rarity.Rare", "Food.LowNutrition", "Food.LowQuality"}, stockRange={min=0, max=25} },
})

print("[DynamicTrading] Bait Registry Complete")
