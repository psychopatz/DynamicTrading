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

    -- [Resource.Material.Mineral] [Rarity.Common] (5 items)
    { item="Base.Hematite", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Common", "Resource.Craftable"}, stockRange={min=4, max=10} },
    { item="Base.HematiteLarge", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Common", "Resource.Craftable"}, stockRange={min=4, max=10} },
    { item="Base.LargeStone", basePrice=3, tags={"Resource.Material.Mineral", "Rarity.Common", "Resource.Craftable"}, stockRange={min=1, max=4} },
    { item="Base.Malachite", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Common", "Resource.Craftable"}, stockRange={min=4, max=10} },
    { item="Base.MalachiteLarge", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Common", "Resource.Craftable"}, stockRange={min=4, max=10} },

    -- [Resource.Material.Mineral] [Rarity.Rare] (53 items)
    { item="Base.BucketCarvedClayCement", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarvedConcreteFull", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarvedPlasterFull", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketClayCement", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketConcreteFull", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.BucketPlasterFull", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Clay", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.Claybag", basePrice=6, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.ClayBarMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBarMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBenchAnvilMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBenchAnvilMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBlacksmithAnvilMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBlacksmithAnvilMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBlockAnvilMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBlockAnvilMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBowlUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBrick", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayBrickUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayCrudeBenchVisePartsMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayCrudeBenchVisePartsMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayIngotMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayIngotMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayJarUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayMugUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.ClayPlateUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=50} },
    { item="Base.ClayPot", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayPotUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClaySheetMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClaySheetMoldUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayShingle", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayShingleUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayTile", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayTileUnfired", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ClayTool", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.ConcretePowder", basePrice=7, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.CopperOre", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Police", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.FlatStone", basePrice=5, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Gravelbag", basePrice=6, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.IronOre", basePrice=4, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Limestone", basePrice=8, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.OreganoBagSeed_Empty", basePrice=3, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=100} },
    { item="Base.PlasterPowder", basePrice=7, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.PlasterTrowel", basePrice=8, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.Sandbag", basePrice=6, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=10} },
    { item="Base.SharpedStone", basePrice=8, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.StoneBlade", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.StoneBladeLong", basePrice=8, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.StoneBlock", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.StoneMaulHead", basePrice=8, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=20} },
    { item="Base.StoneWheel", basePrice=4, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneWheelSmall", basePrice=4, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.WoodenBrickMold", basePrice=9, tags={"Resource.Material.Mineral", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=30} },
})

print("[DynamicTrading] Mineral Registry Complete")
