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

    -- [Resource.Material.Adhesive] [Rarity.Rare] (11 items)
    { item="Base.AdhesiveTapeBox", basePrice=8, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.BucketCarvedWallpaperPaste", basePrice=17, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketWallpaperPaste", basePrice=17, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.DuctTape", basePrice=20, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.DuctTapeBox", basePrice=7, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.Epoxy", basePrice=20, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.FiberglassTape", basePrice=20, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Glue", basePrice=20, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Scotchtape", basePrice=9, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WallpaperPastePowder", basePrice=8, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.Woodglue", basePrice=20, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
})

print("[DynamicTrading] Adhesive Registry Complete")
