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
    { item="Base.LargePlank", basePrice=960, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Log", basePrice=984, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks2", basePrice=973, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks3", basePrice=972, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.LogStacks4", basePrice=971, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Twigs", basePrice=977, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.WoodenBarCastMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBenchAnvilMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBlacksmithAnvilMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenBlockAnvilMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenShingleMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WoodenTileMold", basePrice=963, tags={"Resource.Material.Wood", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Wood Registry Complete")
