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
    { item="Base.Hematite", basePrice=44, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HematiteLarge", basePrice=43, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LargeStone", basePrice=37, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Malachite", basePrice=44, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.MalachiteLarge", basePrice=43, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },

    -- [Resource.Material.Mineral] [Rarity.Rare] (53 items)
    { item="Base.BucketCarvedClayCement", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedConcreteFull", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedPlasterFull", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketClayCement", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketConcreteFull", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketPlasterFull", basePrice=100, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Clay", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.Claybag", basePrice=31, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ClayBarMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBarMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBowlUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrick", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrickUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayJarUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayMugUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPlateUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPot", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayPotUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMoldUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingle", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingleUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTile", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTileUnfired", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTool", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ConcretePowder", basePrice=81, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CopperOre", basePrice=62, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FlatStone", basePrice=70, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Gravelbag", basePrice=31, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.IronOre", basePrice=62, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Limestone", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.OreganoBagSeed_Empty", basePrice=22, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=31} },
    { item="Base.PlasterPowder", basePrice=87, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.PlasterTrowel", basePrice=82, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Sandbag", basePrice=31, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SharpedStone", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlade", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneBladeLong", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlock", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneMaulHead", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneWheel", basePrice=67, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.StoneWheelSmall", basePrice=69, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.WoodenBrickMold", basePrice=72, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Mineral Registry Complete")
