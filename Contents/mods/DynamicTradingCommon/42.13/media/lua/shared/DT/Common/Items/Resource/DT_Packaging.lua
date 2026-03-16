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

    -- [Resource.Material.Packaging] [Rarity.Rare] (56 items)
    { item="Base.BarleyBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.BasilBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.BellPepperBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.BlackSageBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.BroadleafPlantainBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.BroccoliBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CabbageBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CarrotBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CauliflowerBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ChamomileBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ChivesBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CilantroBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ComfreyBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CommonMallowBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.CucumberBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.Dirtbag", basePrice=26, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.GarlicBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.GreenpeasBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.HabaneroBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.HempBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.HopsBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.JalapenoBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.KaleBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.LavenderBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.LeekBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.LemonGrassBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.LettuceBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.MarigoldBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.MintBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.OnionBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ParsleyBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.PoppyBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.PotatoBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.PumpkinBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.RedRadishBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.RippedSheetsBundle", basePrice=77, tags={"Resource.Material.Packaging", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.RippedSheetsDirtyBundle", basePrice=23, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=7} },
    { item="Base.RippedSheetsSterilizedBundle", basePrice=77, tags={"Resource.Material.Packaging", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.RoseBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.RosemaryBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.RyeBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SageBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SoybeansBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SpinachBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.StrewberrieBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SugarBeetBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SunflowerBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.SweetPotatoBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ThymeBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.TobaccoBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.TomatoBagSeed2_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.TurnipBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.WatermelonBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.WheatBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.WildGarlicBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
    { item="Base.ZucchiniBagSeed_Empty", basePrice=17, tags={"Resource.Material.Packaging", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=36} },
})

print("[DynamicTrading] Packaging Registry Complete")
