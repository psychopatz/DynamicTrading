-- ============================================================================
-- Container Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Container.Liquid.Bottle] [Rarity.Rare] (52 items)
    { item="Base.BeerBottle", basePrice=3, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.BeerEmpty", basePrice=5, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.BeerImported", basePrice=3, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Bleach", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.BottleCrafted", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Brandy", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Champagne", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Cider", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.CleaningLiquid2", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.CoffeeLiquer", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Cologne", basePrice=2, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Curacao", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Disinfectant", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.FeedingBottle", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Flask", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Gin", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Grenadine", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.HairDyeCommon", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeRare", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeUncommon", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HotWaterBottle", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.IndustrialDye", basePrice=10, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Theme.Industrial", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=9} },
    { item="Base.JuiceCranberry", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceFruitpunch", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceGrape", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceLemon", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceOrange", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceTomato", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MayonnaiseEmpty", basePrice=2, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.MilkBottle", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Perfume", basePrice=2, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PopBottle", basePrice=10, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PopBottleRare", basePrice=10, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Port", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.RemouladeEmpty", basePrice=8, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Rum", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Scotch", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Sherry", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.SimpleSyrup", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Sportsbottle", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Tequila", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Vermouth", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Vodka", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterBottle", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.WaterDispenserBottle", basePrice=22, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.Whiskey", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Wine", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Wine2", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Wine2Open", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WineAged", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WineOpen", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WineScrewtop", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },

    -- [Container.Liquid.Bucket] [Rarity.Rare] (9 items)
    { item="Base.Bucket", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarved", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.BucketEmpty", basePrice=20, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketForged", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketLargeWood", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.BucketWaterDebug", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketWood", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.PaintbucketEmpty", basePrice=20, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterDish", basePrice=8, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },

    -- [Container.Liquid.Can] [Rarity.Common] (1 item)
    { item="Base.Canteen", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Can] [Rarity.Rare] (15 items)
    { item="Base.BeerCan", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.BeerCanEmpty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.CanteenClay", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JerryCan", basePrice=21, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.PetrolCan", basePrice=21, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.Pop", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Pop2", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Pop2Empty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Pop3", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Pop3Empty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.PopEmpty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.SodaCan", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.TinCanEmpty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.WateredCan", basePrice=17, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.WaterRationCanEmpty", basePrice=3, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },

    -- [Container.Liquid.Can] [Rarity.Uncommon] (2 items)
    { item="Base.CanteenMilitary", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },
    { item="Base.CanteenMilitaryFull", basePrice=4, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },

    -- [Container.Liquid.Cup] [Rarity.Common] (1 item)
    { item="Base.Mugl", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Cup] [Rarity.Rare] (22 items)
    { item="Base.Bowl", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.CeramicTeacup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.ClayBowl", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CopperCup", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.DrinkingGlass", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.FountainCup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.FountainCupWater", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GlassChampagne", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassTumbler", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassWine", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Goblet", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Gold", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Goblet_Silver", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Wood", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GoldCup", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.MetalCup", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.MugSpiffo", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MugWhite", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PlasticCup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.SilverCup", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Teacup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.General] [Rarity.Common] (2 items)
    { item="Base.DebugFluid", basePrice=23, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },
    { item="Base.TestDebugWater", basePrice=23, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },

    -- [Container.Liquid.General] [Rarity.Rare] (15 items)
    { item="Base.Bag_HydrationBackpack", basePrice=23, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HydrationBackpack_Camo", basePrice=23, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible", basePrice=10, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleSmall", basePrice=7, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceBox", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceBoxApple", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceBoxFruitpunch", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JuiceBoxOrange", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Milk", basePrice=6, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Milk_Personalsized", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MilkChocolate_Personalsized", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.TrophyBronze", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.TrophyGold", basePrice=6, tags={"Container.Liquid.General", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.TrophySilver", basePrice=4, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.WineBox", basePrice=6, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.Jar] [Rarity.Rare] (4 items)
    { item="Base.ClayJar", basePrice=12, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayJarGlazed", basePrice=12, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.EmptyJar", basePrice=7, tags={"Container.Liquid.Jar", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.JarCrafted", basePrice=8, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.Wearable] [Rarity.Rare] (4 items)
    { item="Base.Bag_LeatherWaterBag", basePrice=11, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.CanteenCowboy", basePrice=11, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.KnapsackSprayer", basePrice=32, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed", basePrice=32, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Liquid Registry Complete")
