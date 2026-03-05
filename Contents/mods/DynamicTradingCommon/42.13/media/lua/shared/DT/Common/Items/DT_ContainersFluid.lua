
require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- =============================================================================
    -- 1. INDUSTRIAL & BULK STORAGE (Tools & Fuel)
    -- =============================================================================
    -- Logic: Gas Cans are "Liquid Gold" (Fuel tag boosts price in Winter). 
    -- Sprayers are essential for Farming.

    { item="Base.KnapsackSprayer",         tags={"Tool.Farmer", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=280, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed",  tags={"Tool.Farmer", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=250, stockRange={min=0, max=1} },
    { item="Base.WaterDispenserBottle",    tags={"Container.Fluid", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=2} },
    
    -- FUEL CONTAINERS (Taxonomy Identity: Fluid)
    -- (Consolidated in DT_Fuel.lua)
    { item="Base.JerryCan",                tags={"Container.Fluid", "Theme.Survival", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=2} },

    -- =============================================================================
    -- 2. PERSONAL HYDRATION
    -- =============================================================================
    
    -- MILITARY / SURVIVAL (High Value)
    -- MILITARY / SURVIVAL
    { item="Base.Bag_HydrationBackpack",      tags={"Container.Backpack.Hydration", "Origin.Militia", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=1} },
    { item="Base.Bag_HydrationBackpack_Camo", tags={"Container.Backpack.Hydration", "Origin.Militia", "Rarity.Rare"}, basePrice=450, stockRange={min=0, max=1} },
    { item="Base.CanteenMilitaryFull",        tags={"Container.Fluid", "Origin.Militia", "Rarity.Uncommon"}, basePrice=120, stockRange={min=1, max=2} },
    { item="Base.CanteenMilitary",            tags={"Container.Fluid", "Origin.Militia", "Rarity.Uncommon"}, basePrice=100, stockRange={min=1, max=2} },
    
    -- CIVILIAN
    { item="Base.CanteenCowboy",       tags={"Container.Fluid", "Theme.Survival", "Rarity.Common"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.Canteen",             tags={"Container.Fluid", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=4} },
    { item="Base.CanteenClay",         tags={"Container.Fluid", "Quality.Primitive", "Rarity.Common"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Flask",               tags={"Container.Fluid", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=2} },
    { item="Base.Sportsbottle",        tags={"Container.Fluid", "Rarity.Common"}, basePrice=25, stockRange={min=2, max=5} },
    { item="Base.Bag_LeatherWaterBag", tags={"Container.Fluid", "Origin.Nomad", "Rarity.Common"}, basePrice=85, stockRange={min=1, max=2} },

    -- =============================================================================
    -- 3. COOKING & RAIN COLLECTION
    -- =============================================================================
    -- Logic: Items that can boil water are "Tools". 
    -- Copper items get "Luxury" (3.0x price) or "Uncommon" (1.25x).

    -- BUCKETS (Rain Collection)
    { item="Base.BucketLargeWood", tags={"Container.Fluid", "Resource.Material.Wood", "Rarity.Common"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.BucketEmpty",     tags={"Container.Fluid", "Resource.Material.Plastic", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=6} },
    { item="Base.BucketWood",      tags={"Container.Fluid", "Origin.Nomad", "Rarity.Common"},     basePrice=15, stockRange={min=2, max=5} },
    { item="Base.BucketForged",    tags={"Container.Fluid", "Resource.Material.Metal", "Rarity.Uncommon"},      basePrice=45, stockRange={min=0, max=2} },
    { item="Base.WateredCan",      tags={"Container.Fluid", "Theme.Utility", "Rarity.Common"},          basePrice=25, stockRange={min=1, max=3} },

    -- POTS & PANS (Boiling Water)
    { item="Base.Pot",            tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=15, stockRange={min=1, max=4} },
    { item="Base.PotForged",      tags={"Container.Cooking.Boiling", "Rarity.Uncommon"}, basePrice=25, stockRange={min=0, max=2} },
    { item="Base.Kettle",         tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.Saucepan",       tags={"Container.Cooking.Boiling", "Rarity.Common"},  basePrice=10, stockRange={min=2, max=5} },
    { item="Base.RoastingPan",    tags={"Container.Cooking.Baking", "Rarity.Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.BakingPan",      tags={"Container.Cooking.Baking", "Rarity.Common"},  basePrice=8,  stockRange={min=2, max=6} },
    
    -- FANCY COOKWARE
    { item="Base.Kettle_Copper",    tags={"Container.Cooking.Boiling", "Quality.Luxury", "Rarity.Rare"}, basePrice=30, stockRange={min=0, max=2} },
    { item="Base.SaucepanCopper",   tags={"Container.Cooking.Boiling", "Quality.Luxury", "Rarity.Rare"}, basePrice=25, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 4. ALCOHOL & BEVERAGES
    -- =============================================================================
    -- Logic: Added "Alcohol" tag. This allows the "Smugglers" event to affect them.
    -- High proof alcohol is valuable for medical use/panic reduction.

    { item="Base.Whiskey",       tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=120, stockRange={min=1, max=3} },
    { item="Base.Vodka",         tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Gin",           tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Rum",           tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Tequila",       tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    { item="Base.Brandy",        tags={"Food.Drink.Alcohol", "Resource.Medical", "Rarity.Common"}, basePrice=100, stockRange={min=1, max=3} },
    
    -- LUXURY ALCOHOL
    { item="Base.WineAged",      tags={"Food.Drink.Alcohol", "Quality.Luxury", "Rarity.Rare"}, basePrice=35, stockRange={min=0, max=2} },
    { item="Base.Champagne",     tags={"Food.Drink.Alcohol", "Quality.Luxury", "Rarity.Rare"}, basePrice=40, stockRange={min=0, max=2} },
    
    -- LOW GRADE ALCOHOL
    { item="Base.BeerImported",  tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=10, stockRange={min=2, max=6} },
    { item="Base.BeerBottle",    tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=8,  stockRange={min=3, max=10} },
    { item="Base.WineBox",       tags={"Food.Drink.Alcohol", "Rarity.Common"},         basePrice=18, stockRange={min=1, max=4} },

    -- =============================================================================
    -- 5. CONSUMABLES & UTILITY FLUIDS
    -- =============================================================================

    -- (Consolidated in DT_Medical.lua)
    { item="Base.Bleach",           tags={"Medical.Utility.Clinical", "Quality.Waste", "Rarity.Common"},   basePrice=15, stockRange={min=2, max=8} },
    { item="Base.CleaningLiquid2",  tags={"Medical.Utility.Clinical", "Rarity.Common"},              basePrice=12,  stockRange={min=2, max=6} },
    { item="Base.IndustrialDye",    tags={"Resource.Material.Dye", "Rarity.Uncommon"},        basePrice=25, stockRange={min=1, max=5} },
    { item="Base.Cologne",          tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"},            basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Perfume",          tags={"Misc.Hygiene", "Quality.Luxury", "Rarity.Uncommon"},            basePrice=35, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 6. RECYCLED CONTAINERS (JUNK)
    -- =============================================================================
    -- Logic: Added "Junk" tag. This automatically applies a 0.5x price multiplier.
    -- Empty Jars are NOT junk (vital for preservation).

    { item="Base.WaterBottle",      tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=4, stockRange={min=5, max=15} },
    { item="Base.PopBottle",        tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=3, stockRange={min=5, max=15} },
    { item="Base.BeerEmpty",        tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.BeerCanEmpty",     tags={"Container.Fluid", "Resource.Material.Metal", "Origin.Civ"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.PopEmpty",         tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.TinCanEmpty",      tags={"Resource.Material.Metal", "Origin.Civ", "Rarity.Common"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.MayonnaiseEmpty",  tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"}, basePrice=2, stockRange={min=2, max=8} },
    
    -- PRESERVATION TOOLS (Not Junk)
    { item="Base.EmptyJar",         tags={"Container.Food", "Rarity.Common"}, basePrice=8, stockRange={min=5, max=20} },
    { item="Base.JarCrafted",       tags={"Container.Food", "Rarity.Common"}, basePrice=5, stockRange={min=5, max=15} },

    -- =============================================================================
    -- 7. LUXURY CUPS & TROPHIES
    -- =============================================================================
    -- Logic: Added "Luxury" tag (3.0x Multiplier). 
    -- These are useless functionally but high trade value.

    { item="Base.TrophyGold",     tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=20, stockRange={min=0, max=1} }, -- Real: 60
    { item="Base.TrophySilver",   tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=15, stockRange={min=0, max=1} },
    { item="Base.TrophyBronze",   tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=10, stockRange={min=0, max=1} },
    { item="Base.GoldCup",        tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=18, stockRange={min=0, max=2} },
    { item="Base.SilverCup",      tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=12, stockRange={min=0, max=2} },
    { item="Base.Goblet_Gold",    tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Goblet_Silver",  tags={"Misc.Decor", "Origin.Civ", "Quality.Luxury", "Rarity.Rare"}, basePrice=14, stockRange={min=0, max=2} },
    { item="Base.Goblet_Wood",    tags={"Container.Fluid", "Origin.Civ", "Rarity.Common"},         basePrice=4,  stockRange={min=1, max=4} },

    -- =============================================================================
    -- 8. HOUSEHOLD ITEMS
    -- =============================================================================

    { item="Base.Bowl",             tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.ClayBowl",         tags={"Container.Cooking.Serving", "Origin.Nomad", "Rarity.Common"},    basePrice=1, stockRange={min=5, max=10} },
    { item="Base.DrinkingGlass",    tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=3, stockRange={min=5, max=10} },
    { item="Base.MugWhite",         tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.CeramicTeacup",    tags={"Container.Cooking.Serving", "Origin.Civ", "Rarity.Common"},      basePrice=4, stockRange={min=2, max=8} },
    { item="Base.HotWaterBottle",   tags={"Medical.Tool", "Theme.Clinical", "Rarity.Common"}, basePrice=12, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Containers (Fluid) Registry Complete \n.")
