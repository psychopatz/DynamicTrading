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

    -- [Resource.Material.Ceramic] [Rarity.Rare] (12 items)
    { item="Base.CeramicCrucible_Iron", basePrice=1, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible_Steel", basePrice=1, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucibleSmall_Iron", basePrice=3, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucibleSmall_Steel", basePrice=3, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucibleSmallUnfired", basePrice=8, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.CeramicCrucibleUnfired", basePrice=1, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.CeramicCrucibleWithGlass", basePrice=2, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicIngotCast", basePrice=6, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.CeramicIngotCastUnfired", basePrice=6, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.CeramicMortarandPestleUnfired", basePrice=2, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.CeramicTeacupUnfired", basePrice=8, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.WoodenCrucibleMold", basePrice=6, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Ceramic Registry Complete")
