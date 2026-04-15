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

    -- [Container.Bag.Handbag] [Rarity.Rare] (2 items)
    { item="Base.Handbag", basePrice=192, tags={"Container.Bag.Handbag", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Purse", basePrice=197, tags={"Container.Bag.Handbag", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Handbag Registry Complete")
