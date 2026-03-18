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
    { item="Base.AdhesiveTapeBox", basePrice=57, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.BucketCarvedWallpaperPaste", basePrice=76, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketWallpaperPaste", basePrice=76, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.DuctTape", basePrice=84, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.DuctTapeBox", basePrice=57, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.Epoxy", basePrice=84, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.FiberglassTape", basePrice=84, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.Glue", basePrice=84, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Scotchtape", basePrice=64, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.WallpaperPastePowder", basePrice=73, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.Woodglue", basePrice=84, tags={"Resource.Material.Adhesive", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Adhesive Registry Complete")
