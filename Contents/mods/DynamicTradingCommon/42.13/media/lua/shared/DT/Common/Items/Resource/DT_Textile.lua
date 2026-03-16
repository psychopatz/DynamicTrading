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
    { item="Base.BurlapPiece", basePrice=968, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
    { item="Base.CheeseCloth", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.DenimStrips", basePrice=1002, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.DenimStripsBundle", basePrice=987, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.DenimStripsDirty", basePrice=300, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=24} },
    { item="Base.DenimStripsDirtyBundle", basePrice=296, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.DentalFloss", basePrice=989, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FabricRoll_Cotton", basePrice=986, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimBlack", basePrice=986, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimBlue", basePrice=986, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FabricRoll_DenimDarkBlue", basePrice=986, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Flax", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxBagSeed_Empty", basePrice=291, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=44} },
    { item="Base.FlaxBroken", basePrice=291, tags={"Resource.Material.Textile", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=21} },
    { item="Base.FlaxDried", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxHeckled", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxRippled", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxScutched", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.FlaxTow", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Rope", basePrice=987, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.RopeStack", basePrice=998, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SheetRope", basePrice=1001, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.SheetRopeBundle", basePrice=1015, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SteelWool", basePrice=997, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
    { item="Base.String", basePrice=982, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Thread", basePrice=995, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Thread_Aramid", basePrice=995, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Thread_Sinew", basePrice=995, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Twine", basePrice=1008, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=12} },
    { item="Base.WoolRaw", basePrice=969, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=18} },
    { item="Base.Yarn", basePrice=988, tags={"Resource.Material.Textile", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Textile Registry Complete")
