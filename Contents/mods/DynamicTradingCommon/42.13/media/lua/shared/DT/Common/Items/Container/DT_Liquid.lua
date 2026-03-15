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
    { item="Base.BeerEmpty", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Bleach", basePrice=21, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.BottleCrafted", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.CleaningLiquid2", basePrice=7, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.Cologne", basePrice=2, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Curacao", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.FeedingBottle", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Flask", basePrice=21, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Grenadine", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HairDyeCommon", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.HairDyeRare", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.HairDyeUncommon", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.HotWaterBottle", basePrice=11, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.IndustrialDye", basePrice=85, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Origin.Industrial", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.MayonnaiseEmpty", basePrice=8, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Perfume", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.RemouladeEmpty", basePrice=85, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Scotch", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Sherry", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.SimpleSyrup", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Sportsbottle", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Vermouth", basePrice=4, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.WaterBottle", basePrice=42, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.WaterDispenserBottle", basePrice=32, tags={"Container.Liquid.Bottle", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Bucket] [Rarity.Rare] (9 items)
    { item="Base.Bucket", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.BucketCarved", basePrice=21, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=2} },
    { item="Base.BucketEmpty", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.BucketForged", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.BucketLargeWood", basePrice=8, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.High"}, stockRange={min=0, max=1} },
    { item="Base.BucketWaterDebug", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.BucketWood", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.PaintbucketEmpty", basePrice=42, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.WaterDish", basePrice=4, tags={"Container.Liquid.Bucket", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },

    -- [Container.Liquid.Can] [Rarity.Common] (1 item)
    { item="Base.Canteen", basePrice=6, tags={"Container.Liquid.Can", "Rarity.Common", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=5, max=25} },

    -- [Container.Liquid.Can] [Rarity.Rare] (9 items)
    { item="Base.BeerCanEmpty", basePrice=13, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.CanteenClay", basePrice=11, tags={"Container.Liquid.Can", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.JerryCan", basePrice=11, tags={"Container.Liquid.Can", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=2} },
    { item="Base.PetrolCan", basePrice=27, tags={"Container.Liquid.Can", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Pop2Empty", basePrice=13, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Pop3Empty", basePrice=13, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.PopEmpty", basePrice=13, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.TinCanEmpty", basePrice=6, tags={"Container.Liquid.Can", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.WateredCan", basePrice=17, tags={"Container.Liquid.Can", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Low"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Can] [Rarity.Uncommon] (2 items)
    { item="Base.CanteenMilitary", basePrice=8, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Militia", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=5, max=25} },
    { item="Base.CanteenMilitaryFull", basePrice=8, tags={"Container.Liquid.Can", "Rarity.Uncommon", "Origin.Militia", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=5, max=25} },

    -- [Container.Liquid.Cup] [Rarity.Common] (1 item)
    { item="Base.Mugl", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Common", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=5, max=25} },

    -- [Container.Liquid.Cup] [Rarity.Rare] (22 items)
    { item="Base.Bowl", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.CeramicTeacup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.ClayBowl", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.ClayMug", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.CopperCup", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Origin.Police", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.DrinkingGlass", basePrice=3, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.FountainCup", basePrice=13, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.FountainCupWater", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.GlassChampagne", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.GlassTumbler", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.GlassWine", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.Goblet", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Gold", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Silver", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.Goblet_Wood", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.GoldCup", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Quality.Luxury", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.MetalCup", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.MugSpiffo", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.MugWhite", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.PlasticCup", basePrice=8, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.SilverCup", basePrice=4, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.Teacup", basePrice=2, tags={"Container.Liquid.Cup", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },

    -- [Container.Liquid.General] [Rarity.Common] (2 items)
    { item="Base.DebugFluid", basePrice=2500, tags={"Container.Liquid.General", "Rarity.Common", "Container.Liquid", "Container.Capacity.High"}, stockRange={min=5, max=25} },
    { item="Base.TestDebugWater", basePrice=2500, tags={"Container.Liquid.General", "Rarity.Common", "Container.Liquid", "Container.Capacity.High"}, stockRange={min=5, max=25} },

    -- [Container.Liquid.General] [Rarity.Rare] (7 items)
    { item="Base.Bag_HydrationBackpack", basePrice=94, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.Bag_HydrationBackpack_Camo", basePrice=94, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium", "Container.WeightReduction.High", "Container.Wearable"}, stockRange={min=0, max=4} },
    { item="Base.CeramicCrucible", basePrice=3, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=2} },
    { item="Base.CeramicCrucibleSmall", basePrice=32, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.TrophyBronze", basePrice=1, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=2} },
    { item="Base.TrophyGold", basePrice=1, tags={"Container.Liquid.General", "Rarity.Rare", "Quality.Luxury", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=2} },
    { item="Base.TrophySilver", basePrice=1, tags={"Container.Liquid.General", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=2} },

    -- [Container.Liquid.Jar] [Rarity.Rare] (4 items)
    { item="Base.ClayJar", basePrice=35, tags={"Container.Liquid.Jar", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.ClayJarGlazed", basePrice=35, tags={"Container.Liquid.Jar", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=6} },
    { item="Base.EmptyJar", basePrice=21, tags={"Container.Liquid.Jar", "Rarity.Rare", "Quality.Waste", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },
    { item="Base.JarCrafted", basePrice=21, tags={"Container.Liquid.Jar", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny"}, stockRange={min=0, max=10} },

    -- [Container.Liquid.Wearable] [Rarity.Rare] (4 items)
    { item="Base.Bag_LeatherWaterBag", basePrice=14, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.CanteenCowboy", basePrice=14, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Tiny", "Container.Wearable"}, stockRange={min=0, max=6} },
    { item="Base.KnapsackSprayer", basePrice=14, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
    { item="Base.KnapsackSprayer_Stowed", basePrice=14, tags={"Container.Liquid.Wearable", "Rarity.Rare", "Container.Liquid", "Container.Capacity.Medium", "Container.Wearable"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Liquid Registry Complete")
