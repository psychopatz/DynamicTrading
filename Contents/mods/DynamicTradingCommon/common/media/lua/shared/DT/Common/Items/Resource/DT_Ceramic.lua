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
    { item="Base.CeramicCrucible_Iron", basePrice=74, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CeramicCrucible_Steel", basePrice=74, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CeramicCrucibleSmall_Iron", basePrice=77, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CeramicCrucibleSmall_Steel", basePrice=77, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CeramicCrucibleSmallUnfired", basePrice=58, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.CeramicCrucibleUnfired", basePrice=57, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleWithGlass", basePrice=77, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CeramicIngotCast", basePrice=58, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.CeramicIngotCastUnfired", basePrice=58, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.CeramicMortarandPestleUnfired", basePrice=72, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicTeacupUnfired", basePrice=58, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=14} },
    { item="Base.WoodenCrucibleMold", basePrice=58, tags={"Resource.Material.Ceramic", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
})

print("[DynamicTrading] Ceramic Registry Complete")
