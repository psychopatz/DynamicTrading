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
    { item="Base.BeerEmpty", basePrice=264, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Bleach", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.BottleCrafted", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CleaningLiquid2", basePrice=878, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Cologne", basePrice=876, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Curacao", basePrice=880, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.FeedingBottle", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Flask", basePrice=879, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Grenadine", basePrice=880, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.HairDyeCommon", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeRare", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeUncommon", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HotWaterBottle", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.IndustrialDye", basePrice=1412, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Theme.Industrial", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=9} },
    { item="Base.MayonnaiseEmpty", basePrice=263, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Perfume", basePrice=876, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.RemouladeEmpty", basePrice=266, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Scotch", basePrice=880, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Sherry", basePrice=880, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.SimpleSyrup", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Sportsbottle", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Vermouth", basePrice=880, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterBottle", basePrice=881, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.WaterDispenserBottle", basePrice=960, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Bucket] [Rarity.Rare] (9 items)
    { item="Base.Bucket", basePrice=932, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarved", basePrice=931, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.BucketEmpty", basePrice=280, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketForged", basePrice=932, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketLargeWood", basePrice=977, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.BucketWaterDebug", basePrice=870, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketWood", basePrice=932, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.PaintbucketEmpty", basePrice=280, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterDish", basePrice=877, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },

    -- [Container.Liquid.Can] [Rarity.Common] (1 item)
    { item="Base.Canteen", basePrice=476, tags={"Container.Liquid.Can", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Can] [Rarity.Rare] (9 items)
    { item="Base.BeerCanEmpty", basePrice=263, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.CanteenClay", basePrice=878, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JerryCan", basePrice=928, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.PetrolCan", basePrice=931, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.Pop2Empty", basePrice=263, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Pop3Empty", basePrice=263, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.PopEmpty", basePrice=263, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.TinCanEmpty", basePrice=263, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.WateredCan", basePrice=919, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Can] [Rarity.Uncommon] (2 items)
    { item="Base.CanteenMilitary", basePrice=1281, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },
    { item="Base.CanteenMilitaryFull", basePrice=1281, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },

    -- [Container.Liquid.Cup] [Rarity.Common] (1 item)
    { item="Base.Mugl", basePrice=475, tags={"Container.Liquid.Cup", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Cup] [Rarity.Rare] (22 items)
    { item="Base.Bowl", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.CeramicTeacup", basePrice=876, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.ClayBowl", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CopperCup", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.DrinkingGlass", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.FountainCup", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.FountainCupWater", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GlassChampagne", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassTumbler", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassWine", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Goblet", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Gold", basePrice=3261, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Goblet_Silver", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Wood", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GoldCup", basePrice=3261, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.MetalCup", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.MugSpiffo", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MugWhite", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PlasticCup", basePrice=877, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.SilverCup", basePrice=878, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Teacup", basePrice=876, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.General] [Rarity.Common] (2 items)
    { item="Base.DebugFluid", basePrice=510, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },
    { item="Base.TestDebugWater", basePrice=510, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },

    -- [Container.Liquid.General] [Rarity.Rare] (7 items)
    { item="Base.Bag_HydrationBackpack", basePrice=1521, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HydrationBackpack_Camo", basePrice=1521, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible", basePrice=886, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleSmall", basePrice=884, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.TrophyBronze", basePrice=874, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.TrophyGold", basePrice=3255, tags={"Container.Liquid.General", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.TrophySilver", basePrice=874, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Jar] [Rarity.Rare] (4 items)
    { item="Base.ClayJar", basePrice=890, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayJarGlazed", basePrice=890, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.EmptyJar", basePrice=264, tags={"Container.Liquid.Jar", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.JarCrafted", basePrice=881, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.Wearable] [Rarity.Rare] (4 items)
    { item="Base.Bag_LeatherWaterBag", basePrice=881, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.CanteenCowboy", basePrice=881, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.KnapsackSprayer", basePrice=961, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed", basePrice=961, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Liquid Registry Complete")
