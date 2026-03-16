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
    { item="Base.Hematite", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HematiteLarge", basePrice=16, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LargeStone", basePrice=10, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Malachite", basePrice=17, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.MalachiteLarge", basePrice=16, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },

    -- [Resource.Material.Mineral] [Rarity.Rare] (53 items)
    { item="Base.BucketCarvedClayCement", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedConcreteFull", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedPlasterFull", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketClayCement", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketConcreteFull", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketPlasterFull", basePrice=52, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Clay", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.Claybag", basePrice=16, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ClayBarMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBarMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBowlUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrick", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrickUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayJarUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayMugUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPlateUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPot", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayPotUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMoldUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingle", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingleUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTile", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTileUnfired", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTool", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ConcretePowder", basePrice=33, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CopperOre", basePrice=14, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FlatStone", basePrice=22, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Gravelbag", basePrice=16, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.IronOre", basePrice=14, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Limestone", basePrice=24, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.OreganoBagSeed_Empty", basePrice=7, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=31} },
    { item="Base.PlasterPowder", basePrice=39, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.PlasterTrowel", basePrice=35, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Sandbag", basePrice=16, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SharpedStone", basePrice=24, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlade", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneBladeLong", basePrice=24, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlock", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneMaulHead", basePrice=24, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneWheel", basePrice=19, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.StoneWheelSmall", basePrice=21, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.WoodenBrickMold", basePrice=25, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Mineral Registry Complete")
