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
    { item="Base.LargePlank", basePrice=1, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Log", basePrice=1, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LogStacks2", basePrice=1, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LogStacks3", basePrice=1, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LogStacks4", basePrice=1, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Twigs", basePrice=8, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.WoodenBarCastMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoodenBenchAnvilMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoodenBlacksmithAnvilMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoodenBlockAnvilMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoodenShingleMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoodenTileMold", basePrice=6, tags={"Resource.Material.Wood", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Wood Registry Complete")
