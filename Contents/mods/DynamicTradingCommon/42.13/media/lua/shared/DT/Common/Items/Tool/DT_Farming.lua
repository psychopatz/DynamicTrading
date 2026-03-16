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

    -- [Tool.Farming] [Rarity.Common] (16 items)
    { item="Base.GardenFork", basePrice=43, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.GardenFork_Forged", basePrice=43, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.GardenHoe", basePrice=57, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.GardenHoeForged", basePrice=57, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.HandFork", basePrice=36, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.HandScythe", basePrice=34, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.HandScytheForged", basePrice=34, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.HandShovel", basePrice=36, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.LeafRake", basePrice=32, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.PickAxe", basePrice=63, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.PickAxeForged", basePrice=63, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.PrimitiveScythe", basePrice=34, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=2, max=10} },
    { item="Base.Rake", basePrice=32, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.Shovel", basePrice=57, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.Shovel2", basePrice=57, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },
    { item="Base.SnowShovel", basePrice=57, tags={"Tool.Farming", "Rarity.Common", "Tool.Fragile"}, stockRange={min=1, max=5} },

    -- [Tool.Farming] [Rarity.Rare] (6 items)
    { item="Base.GardenHoeHead", basePrice=63, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.HandScytheBlade", basePrice=50, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.PickAxeHead", basePrice=70, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.Scythe", basePrice=62, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.ScytheBlade", basePrice=63, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.ScytheForged", basePrice=62, tags={"Tool.Farming", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Farming Registry Complete")
