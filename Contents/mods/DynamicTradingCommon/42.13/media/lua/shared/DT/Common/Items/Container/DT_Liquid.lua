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
    { item="Base.BeerEmpty", basePrice=20, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Bleach", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.BottleCrafted", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CleaningLiquid2", basePrice=65, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Cologne", basePrice=63, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Curacao", basePrice=67, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.FeedingBottle", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Flask", basePrice=65, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Grenadine", basePrice=67, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.HairDyeCommon", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeRare", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HairDyeUncommon", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.HotWaterBottle", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.IndustrialDye", basePrice=101, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Theme.Industrial", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=9} },
    { item="Base.MayonnaiseEmpty", basePrice=19, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Perfume", basePrice=63, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.RemouladeEmpty", basePrice=22, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Scotch", basePrice=67, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Sherry", basePrice=67, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.SimpleSyrup", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Sportsbottle", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Vermouth", basePrice=67, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterBottle", basePrice=68, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.WaterDispenserBottle", basePrice=146, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Bucket] [Rarity.Rare] (9 items)
    { item="Base.Bucket", basePrice=119, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarved", basePrice=117, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.BucketEmpty", basePrice=36, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketForged", basePrice=119, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketLargeWood", basePrice=164, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.BucketWaterDebug", basePrice=57, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.BucketWood", basePrice=119, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.PaintbucketEmpty", basePrice=36, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.WaterDish", basePrice=64, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },

    -- [Container.Liquid.Can] [Rarity.Common] (1 item)
    { item="Base.Canteen", basePrice=39, tags={"Container.Liquid.Can", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Can] [Rarity.Rare] (9 items)
    { item="Base.BeerCanEmpty", basePrice=19, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.CanteenClay", basePrice=65, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.JerryCan", basePrice=115, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.PetrolCan", basePrice=118, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.Pop2Empty", basePrice=19, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.Pop3Empty", basePrice=19, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.PopEmpty", basePrice=19, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.TinCanEmpty", basePrice=19, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.WateredCan", basePrice=106, tags={"Container.Liquid.Can", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Can] [Rarity.Uncommon] (2 items)
    { item="Base.CanteenMilitary", basePrice=84, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },
    { item="Base.CanteenMilitaryFull", basePrice=84, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=1, max=12} },

    -- [Container.Liquid.Cup] [Rarity.Common] (1 item)
    { item="Base.Mugl", basePrice=38, tags={"Container.Liquid.Cup", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=2, max=21} },

    -- [Container.Liquid.Cup] [Rarity.Rare] (22 items)
    { item="Base.Bowl", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.CeramicTeacup", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.ClayBowl", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.CopperCup", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.DrinkingGlass", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.FountainCup", basePrice=64, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.FountainCupWater", basePrice=64, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GlassChampagne", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassTumbler", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.GlassWine", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.Goblet", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Gold", basePrice=196, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.Goblet_Silver", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Wood", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.GoldCup", basePrice=196, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=4} },
    { item="Base.MetalCup", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.MugSpiffo", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.MugWhite", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.PlasticCup", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.SilverCup", basePrice=65, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.Teacup", basePrice=63, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.General] [Rarity.Common] (2 items)
    { item="Base.DebugFluid", basePrice=73, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },
    { item="Base.TestDebugWater", basePrice=73, tags={"Container.Liquid.General", "Rarity.Common", "Origin.Vanilla", "Container.Capacity.High", "Container.Liquid"}, stockRange={min=1, max=14} },

    -- [Container.Liquid.General] [Rarity.Rare] (7 items)
    { item="Base.Bag_HydrationBackpack", basePrice=235, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HydrationBackpack_Camo", basePrice=235, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible", basePrice=72, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleSmall", basePrice=71, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },
    { item="Base.TrophyBronze", basePrice=61, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },
    { item="Base.TrophyGold", basePrice=190, tags={"Container.Liquid.General", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=1} },
    { item="Base.TrophySilver", basePrice=61, tags={"Container.Liquid.General", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Jar] [Rarity.Rare] (4 items)
    { item="Base.ClayJar", basePrice=76, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.ClayJarGlazed", basePrice=76, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=6} },
    { item="Base.EmptyJar", basePrice=20, tags={"Container.Liquid.Jar", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=13} },
    { item="Base.JarCrafted", basePrice=68, tags={"Container.Liquid.Jar", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid"}, stockRange={min=0, max=11} },

    -- [Container.Liquid.Wearable] [Rarity.Rare] (4 items)
    { item="Base.Bag_LeatherWaterBag", basePrice=68, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.CanteenCowboy", basePrice=68, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.KnapsackSprayer", basePrice=148, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed", basePrice=148, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.Liquid", "Container.Wearable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Liquid Registry Complete")
