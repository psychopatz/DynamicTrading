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

    -- [Container.Liquid.Bottle] [Rarity.Rare] (24 items)
    { item="Base.BeerEmpty", basePrice=8, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Bleach", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.BottleCrafted", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CleaningLiquid2", basePrice=23, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Cologne", basePrice=21, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Curacao", basePrice=25, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.FeedingBottle", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Flask", basePrice=23, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Grenadine", basePrice=25, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.HairDyeCommon", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeRare", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeUncommon", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HotWaterBottle", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.IndustrialDye", basePrice=34, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Theme.Industrial", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=9} },
    { item="Base.MayonnaiseEmpty", basePrice=6, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Perfume", basePrice=21, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.RemouladeEmpty", basePrice=10, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Scotch", basePrice=25, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Sherry", basePrice=25, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.SimpleSyrup", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Sportsbottle", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Vermouth", basePrice=25, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterBottle", basePrice=26, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.WaterDispenserBottle", basePrice=104, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Bucket] [Rarity.Rare] (9 items)
    { item="Base.Bucket", basePrice=77, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarved", basePrice=75, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.BucketEmpty", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketForged", basePrice=77, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketLargeWood", basePrice=122, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.BucketWaterDebug", basePrice=14, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketWood", basePrice=77, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.PaintbucketEmpty", basePrice=23, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterDish", basePrice=22, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },

    -- [Container.Liquid.Can] [Rarity.Common] (1 item)
    { item="Base.Canteen", basePrice=16, tags={"Container.Liquid.Can", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Can] [Rarity.Rare] (9 items)
    { item="Base.BeerCanEmpty", basePrice=7, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.CanteenClay", basePrice=23, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JerryCan", basePrice=72, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.PetrolCan", basePrice=76, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.Pop2Empty", basePrice=7, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Pop3Empty", basePrice=7, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.PopEmpty", basePrice=7, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.TinCanEmpty", basePrice=7, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.WateredCan", basePrice=64, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Can] [Rarity.Uncommon] (2 items)
    { item="Base.CanteenMilitary", basePrice=21, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },
    { item="Base.CanteenMilitaryFull", basePrice=21, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },

    -- [Container.Liquid.Cup] [Rarity.Common] (1 item)
    { item="Base.Mugl", basePrice=15, tags={"Container.Liquid.Cup", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Cup] [Rarity.Rare] (22 items)
    { item="Base.Bowl", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.CeramicTeacup", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.ClayBowl", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CopperCup", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.DrinkingGlass", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.FountainCup", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.FountainCupWater", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GlassChampagne", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassTumbler", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassWine", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Goblet", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Gold", basePrice=36, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Goblet_Silver", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Wood", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GoldCup", basePrice=36, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.MetalCup", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.MugSpiffo", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MugWhite", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PlasticCup", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.SilverCup", basePrice=22, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Teacup", basePrice=21, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.General] [Rarity.Common] (2 items)
    { item="Base.DebugFluid", basePrice=50, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },
    { item="Base.TestDebugWater", basePrice=50, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },

    -- [Container.Liquid.General] [Rarity.Rare] (7 items)
    { item="Base.Bag_HydrationBackpack", basePrice=169, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HydrationBackpack_Camo", basePrice=169, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible", basePrice=30, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleSmall", basePrice=29, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.TrophyBronze", basePrice=19, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.TrophyGold", basePrice=30, tags={"Container.Liquid.General", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.TrophySilver", basePrice=19, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Jar] [Rarity.Rare] (4 items)
    { item="Base.ClayJar", basePrice=34, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayJarGlazed", basePrice=34, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.EmptyJar", basePrice=8, tags={"Container.Liquid.Jar", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.JarCrafted", basePrice=26, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.Wearable] [Rarity.Rare] (4 items)
    { item="Base.Bag_LeatherWaterBag", basePrice=26, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.CanteenCowboy", basePrice=26, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.KnapsackSprayer", basePrice=106, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed", basePrice=106, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Liquid Registry Complete")
