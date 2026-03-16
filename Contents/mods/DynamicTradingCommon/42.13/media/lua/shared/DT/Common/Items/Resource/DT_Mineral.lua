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
    { item="Base.Hematite", basePrice=544, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HematiteLarge", basePrice=543, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LargeStone", basePrice=537, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Malachite", basePrice=544, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.MalachiteLarge", basePrice=543, tags={"Resource.Material.Mineral", "Rarity.Common", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },

    -- [Resource.Material.Mineral] [Rarity.Rare] (53 items)
    { item="Base.BucketCarvedClayCement", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedConcreteFull", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketCarvedPlasterFull", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketClayCement", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketConcreteFull", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.BucketPlasterFull", basePrice=1005, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Clay", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.Claybag", basePrice=302, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ClayBarMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBarMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBenchAnvilMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlacksmithAnvilMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBlockAnvilMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBowlUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrick", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayBrickUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayCrudeBenchVisePartsMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayIngotMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayJarUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayMugUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPlateUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=13} },
    { item="Base.ClayPot", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayPotUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClaySheetMoldUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingle", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayShingleUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTile", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTileUnfired", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ClayTool", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.ConcretePowder", basePrice=986, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CopperOre", basePrice=967, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FlatStone", basePrice=975, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Gravelbag", basePrice=302, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.IronOre", basePrice=967, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Limestone", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.OreganoBagSeed_Empty", basePrice=293, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=31} },
    { item="Base.PlasterPowder", basePrice=992, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.PlasterTrowel", basePrice=987, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.Sandbag", basePrice=302, tags={"Resource.Material.Mineral", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SharpedStone", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlade", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneBladeLong", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneBlock", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.StoneMaulHead", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneWheel", basePrice=972, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.StoneWheelSmall", basePrice=973, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.WoodenBrickMold", basePrice=977, tags={"Resource.Material.Mineral", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Mineral Registry Complete")
