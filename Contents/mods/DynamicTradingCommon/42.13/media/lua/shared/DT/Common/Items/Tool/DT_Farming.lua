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
    { item="Base.GardenFork", basePrice=256, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenFork_Forged", basePrice=256, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenHoe", basePrice=270, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenHoeForged", basePrice=270, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.HandFork", basePrice=249, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandScythe", basePrice=247, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandScytheForged", basePrice=247, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandShovel", basePrice=249, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=1, max=7} },
    { item="Base.LeafRake", basePrice=245, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=1, max=7} },
    { item="Base.PickAxe", basePrice=276, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.PickAxeForged", basePrice=276, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.PrimitiveScythe", basePrice=410, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Theme.Primitive", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Rake", basePrice=245, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.Shovel", basePrice=270, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.Shovel2", basePrice=270, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.SnowShovel", basePrice=270, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },

    -- [Tool.Farming] [Rarity.Rare] (6 items)
    { item="Base.GardenHoeHead", basePrice=560, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.HandScytheBlade", basePrice=548, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.PickAxeHead", basePrice=567, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
    { item="Base.Scythe", basePrice=559, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
    { item="Base.ScytheBlade", basePrice=560, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.ScytheForged", basePrice=559, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Farming Registry Complete")
