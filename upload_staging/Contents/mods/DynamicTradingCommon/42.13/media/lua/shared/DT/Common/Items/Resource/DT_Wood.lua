-- ============================================================================
-- Resource Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Resource.Material.Wood] [Rarity.Rare] (12 items)
    { item="Base.LargePlank", basePrice=55, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Log", basePrice=79, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks2", basePrice=68, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks3", basePrice=67, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks4", basePrice=66, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Twigs", basePrice=72, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.WoodenBarCastMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBenchAnvilMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBlacksmithAnvilMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBlockAnvilMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenShingleMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenTileMold", basePrice=58, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Wood Registry Complete")
