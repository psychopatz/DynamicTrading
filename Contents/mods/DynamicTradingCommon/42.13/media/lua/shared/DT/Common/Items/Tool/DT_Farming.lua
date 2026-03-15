-- ============================================================================
-- Tool Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Tool.Farming] [Rarity.Rare] (6 items)
    { item="Base.GardenHoeHead", basePrice=34, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.HandScytheBlade", basePrice=57, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.PickAxeHead", basePrice=22, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.Scythe", basePrice=17, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.ScytheBlade", basePrice=34, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.ScytheForged", basePrice=17, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Farming Registry Complete")
