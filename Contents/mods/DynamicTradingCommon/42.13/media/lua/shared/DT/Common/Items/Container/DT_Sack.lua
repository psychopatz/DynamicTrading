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

    -- [Container.Bag.Sack] [Rarity.Rare] (5 items)
    { item="Base.Bag_HideSack", basePrice=255, tags={"Container.Bag.Sack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Bag_TarpSack", basePrice=255, tags={"Container.Bag.Sack", "Rarity.Rare", "Container.Capacity.High", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.EmptySandbag", basePrice=191, tags={"Container.Bag.Sack", "Rarity.Rare", "Quality.Waste", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.WheatSack", basePrice=191, tags={"Container.Bag.Sack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.WheatSeedSack", basePrice=191, tags={"Container.Bag.Sack", "Rarity.Rare", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Sack Registry Complete")
