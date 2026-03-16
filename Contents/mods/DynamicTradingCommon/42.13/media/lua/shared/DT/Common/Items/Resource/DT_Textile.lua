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

    -- [Resource.Material.Textile] [Rarity.Rare] (31 items)
    { item="Base.BurlapPiece", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.CheeseCloth", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.DenimStrips", basePrice=14, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.DenimStripsBundle", basePrice=8, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.DenimStripsDirty", basePrice=4, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.DenimStripsDirtyBundle", basePrice=2, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.DentalFloss", basePrice=20, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FabricRoll_Cotton", basePrice=17, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.FabricRoll_DenimBlack", basePrice=17, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.FabricRoll_DenimBlue", basePrice=17, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.FabricRoll_DenimDarkBlue", basePrice=17, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Flax", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxBagSeed_Empty", basePrice=3, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.FlaxBroken", basePrice=3, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxDried", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxHeckled", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxRippled", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxScutched", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.FlaxTow", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Rope", basePrice=8, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.RopeStack", basePrice=6, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SheetRope", basePrice=14, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.SheetRopeBundle", basePrice=11, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SteelWool", basePrice=26, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.String", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Thread", basePrice=20, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Thread_Aramid", basePrice=20, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Thread_Sinew", basePrice=20, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Twine", basePrice=20, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.WoolRaw", basePrice=9, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.Yarn", basePrice=14, tags={"Resource.Material.Textile", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Textile Registry Complete")
