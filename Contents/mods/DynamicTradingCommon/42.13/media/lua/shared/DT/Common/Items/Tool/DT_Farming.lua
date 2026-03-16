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
    { item="Base.GardenFork", basePrice=54, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenFork_Forged", basePrice=54, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenHoe", basePrice=68, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenHoeForged", basePrice=68, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.HandFork", basePrice=47, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandScythe", basePrice=45, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandScytheForged", basePrice=45, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.HandShovel", basePrice=47, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=1, max=7} },
    { item="Base.LeafRake", basePrice=43, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=1, max=7} },
    { item="Base.PickAxe", basePrice=74, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.PickAxeForged", basePrice=74, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.PrimitiveScythe", basePrice=55, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Theme.Primitive", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Rake", basePrice=43, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.Shovel", basePrice=68, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.Shovel2", basePrice=68, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.SnowShovel", basePrice=68, tags={"Tool.Farming", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },

    -- [Tool.Farming] [Rarity.Rare] (6 items)
    { item="Base.GardenHoeHead", basePrice=87, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.HandScytheBlade", basePrice=75, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.PickAxeHead", basePrice=94, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
    { item="Base.Scythe", basePrice=86, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
    { item="Base.ScytheBlade", basePrice=87, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.ScytheForged", basePrice=86, tags={"Tool.Farming", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Farming Registry Complete")
