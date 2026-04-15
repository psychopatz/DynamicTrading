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
    { item="Base.BurlapPiece", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
    { item="Base.CheeseCloth", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.DenimStrips", basePrice=97, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.DenimStripsBundle", basePrice=82, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.DenimStripsDirty", basePrice=29, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=24} },
    { item="Base.DenimStripsDirtyBundle", basePrice=25, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.DentalFloss", basePrice=84, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FabricRoll_Cotton", basePrice=81, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimBlack", basePrice=81, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimBlue", basePrice=81, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimDarkBlue", basePrice=81, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Flax", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxBagSeed_Empty", basePrice=19, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=44} },
    { item="Base.FlaxBroken", basePrice=19, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=21} },
    { item="Base.FlaxDried", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxHeckled", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxRippled", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxScutched", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxTow", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Rope", basePrice=82, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.RopeStack", basePrice=94, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SheetRope", basePrice=97, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.SheetRopeBundle", basePrice=111, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SteelWool", basePrice=92, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
    { item="Base.String", basePrice=77, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Thread", basePrice=90, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Thread_Aramid", basePrice=90, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Thread_Sinew", basePrice=90, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Twine", basePrice=103, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.WoolRaw", basePrice=64, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Yarn", basePrice=84, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Textile Registry Complete")
