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

    -- [Container.Bag.Fanny] [Rarity.Rare] (6 items)
    { item="Base.Bag_FannyPackBack", basePrice=39, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=10} },
    { item="Base.Bag_FannyPackBack_Hide", basePrice=35, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=10} },
    { item="Base.Bag_FannyPackBack_Tarp", basePrice=34, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=10} },
    { item="Base.Bag_FannyPackFront", basePrice=39, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=10} },
    { item="Base.Bag_FannyPackFront_Hide", basePrice=35, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=10} },
    { item="Base.Bag_FannyPackFront_Tarp", basePrice=34, tags={"Container.Bag.Fanny", "Rarity.Rare", "Container.Capacity.Tiny", "Container.WeightReduction.Medium", "Container.Wearable"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Fanny Registry Complete")
