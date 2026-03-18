-- ============================================================================
-- Container Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Container.Bag.Cooler] [Rarity.Rare] (5 items)
    { item="Base.Cooler", basePrice=226, tags={"Container.Bag.Cooler", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Cooler_Beer", basePrice=226, tags={"Container.Bag.Cooler", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Cooler_Meat", basePrice=226, tags={"Container.Bag.Cooler", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Cooler_Seafood", basePrice=226, tags={"Container.Bag.Cooler", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Cooler_Soda", basePrice=226, tags={"Container.Bag.Cooler", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Cooler Registry Complete")
