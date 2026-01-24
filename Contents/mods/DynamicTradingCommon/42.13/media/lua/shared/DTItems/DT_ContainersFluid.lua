require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- 1. INDUSTRIAL & BULK STORAGE (Tools & Fuel)
    -- =============================================================================
    -- Logic: Gas Cans are "Liquid Gold" (Fuel tag boosts price in Winter). 
    -- Sprayers are essential for Farming.

    { item="Base.KnapsackSprayer",         tags={"Tool", "Farmer", "Heavy", "Uncommon"}, basePrice=60, stockRange={min=0, max=2} },
    { item="Base.KnapsackSprayer_Stowed",  tags={"Tool", "Farmer", "Heavy", "Uncommon"}, basePrice=55, stockRange={min=0, max=1} },
    { item="Base.WaterDispenserBottle",    tags={"Tool", "Water", "Heavy", "Uncommon"},  basePrice=50, stockRange={min=1, max=3} },
    
    -- FUEL CONTAINERS (Critical for vehicles/generators)
    { item="Base.PetrolCan",               tags={"Tool", "Fuel", "Mechanic", "Common"},  basePrice=50, stockRange={min=1, max=4} },
    { item="Base.JerryCan",                tags={"Tool", "Fuel", "Mechanic", "Common"},  basePrice=60, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 2. PERSONAL HYDRATION
    -- =============================================================================
    
    -- MILITARY / SURVIVAL (High Value)
    { item="Base.Bag_HydrationBackpack",      tags={"Clothing", "Container", "Military", "Rare"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.Bag_HydrationBackpack_Camo", tags={"Clothing", "Container", "Military", "Rare"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.CanteenMilitaryFull",        tags={"Water", "Military", "Uncommon"},             basePrice=25, stockRange={min=1, max=3} },
    { item="Base.CanteenMilitary",            tags={"Water", "Military", "Uncommon"},             basePrice=20, stockRange={min=1, max=4} },
    
    -- CIVILIAN (Standard)
    { item="Base.CanteenCowboy",       tags={"Water", "Survivalist", "Common"}, basePrice=15, stockRange={min=1, max=3} },
    { item="Base.Canteen",             tags={"Water", "General", "Common"},     basePrice=12, stockRange={min=2, max=5} },
    { item="Base.CanteenClay",         tags={"Water", "Scavenger", "Common"},   basePrice=8,  stockRange={min=1, max=4} },
    { item="Base.Flask",               tags={"Water", "General", "Common"},     basePrice=14, stockRange={min=1, max=3} },
    { item="Base.Sportsbottle",        tags={"Water", "General", "Common"},     basePrice=8,  stockRange={min=2, max=6} },
    { item="Base.Bag_LeatherWaterBag", tags={"Water", "Survivalist", "Common"}, basePrice=18, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 3. COOKING & RAIN COLLECTION
    -- =============================================================================
    -- Logic: Items that can boil water are "Tools". 
    -- Copper items get "Luxury" (3.0x price) or "Uncommon" (1.25x).

    -- BUCKETS (Rain Collection)
    { item="Base.BucketLargeWood", tags={"Tool", "Farmer", "Build", "Common"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.BucketEmpty",     tags={"Tool", "Farmer", "Build", "Common"}, basePrice=20, stockRange={min=2, max=6} },
    { item="Base.BucketWood",      tags={"Tool", "Survivalist", "Common"},     basePrice=15, stockRange={min=2, max=5} },
    { item="Base.BucketForged",    tags={"Tool", "Mechanic", "Uncommon"},      basePrice=35, stockRange={min=0, max=2} },
    { item="Base.WateredCan",      tags={"Tool", "Farmer", "Common"},          basePrice=25, stockRange={min=1, max=3} },

    -- POTS & PANS (Boiling Water)
    { item="Base.Pot",            tags={"Tool", "Cooking", "General", "Common"},  basePrice=15, stockRange={min=1, max=4} },
    { item="Base.PotForged",      tags={"Tool", "Cooking", "Mechanic", "Uncommon"}, basePrice=25, stockRange={min=0, max=2} },
    { item="Base.Kettle",         tags={"Tool", "Cooking", "General", "Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.Saucepan",       tags={"Tool", "Cooking", "General", "Common"},  basePrice=10, stockRange={min=2, max=5} },
    { item="Base.RoastingPan",    tags={"Tool", "Cooking", "Butcher", "Common"},  basePrice=12, stockRange={min=1, max=3} },
    { item="Base.BakingPan",      tags={"Tool", "Cooking", "General", "Common"},  basePrice=8,  stockRange={min=2, max=6} },
    
    -- FANCY COOKWARE
    { item="Base.Kettle_Copper",    tags={"Tool", "Cooking", "Luxury", "Rare"}, basePrice=30, stockRange={min=0, max=2} },
    { item="Base.SaucepanCopper",   tags={"Tool", "Cooking", "Luxury", "Rare"}, basePrice=25, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 4. ALCOHOL & BEVERAGES
    -- =============================================================================
    -- Logic: Added "Alcohol" tag. This allows the "Smugglers" event to affect them.
    -- High proof alcohol is valuable for medical use/panic reduction.

    { item="Base.Whiskey",       tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=25, stockRange={min=1, max=3} },
    { item="Base.Vodka",         tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=22, stockRange={min=1, max=3} },
    { item="Base.Gin",           tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=22, stockRange={min=1, max=3} },
    { item="Base.Rum",           tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=22, stockRange={min=1, max=3} },
    { item="Base.Tequila",       tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=22, stockRange={min=1, max=3} },
    { item="Base.Brandy",        tags={"Drink", "Alcohol", "Medical", "Common"}, basePrice=22, stockRange={min=1, max=3} },
    
    -- LUXURY ALCOHOL
    { item="Base.WineAged",      tags={"Drink", "Alcohol", "Luxury", "Rare"}, basePrice=35, stockRange={min=0, max=2} },
    { item="Base.Champagne",     tags={"Drink", "Alcohol", "Luxury", "Rare"}, basePrice=40, stockRange={min=0, max=2} },
    
    -- LOW GRADE ALCOHOL
    { item="Base.BeerImported",  tags={"Drink", "Alcohol", "Common"},         basePrice=10, stockRange={min=2, max=6} },
    { item="Base.BeerBottle",    tags={"Drink", "Alcohol", "Common"},         basePrice=8,  stockRange={min=3, max=10} },
    { item="Base.WineBox",       tags={"Drink", "Alcohol", "Common"},         basePrice=18, stockRange={min=1, max=4} },

    -- =============================================================================
    -- 5. CONSUMABLES & UTILITY FLUIDS
    -- =============================================================================

    { item="Base.Disinfectant",     tags={"Medical", "Clean", "Uncommon"}, basePrice=20, stockRange={min=2, max=6} },
    { item="Base.Bleach",           tags={"Medical", "Clean", "Common"},   basePrice=12, stockRange={min=2, max=8} },
    { item="Base.CleaningLiquid2",  tags={"Clean", "Common"},              basePrice=8,  stockRange={min=2, max=6} },
    { item="Base.IndustrialDye",    tags={"Material", "Scavenger"},        basePrice=12, stockRange={min=1, max=5} },
    { item="Base.Cologne",          tags={"Luxury", "General"},            basePrice=15, stockRange={min=1, max=3} },
    { item="Base.Perfume",          tags={"Luxury", "General"},            basePrice=15, stockRange={min=1, max=3} },

    -- =============================================================================
    -- 6. RECYCLED CONTAINERS (JUNK)
    -- =============================================================================
    -- Logic: Added "Junk" tag. This automatically applies a 0.5x price multiplier.
    -- Empty Jars are NOT junk (vital for preservation).

    { item="Base.WaterBottle",      tags={"Container", "Scavenger", "Junk"}, basePrice=4, stockRange={min=5, max=15} }, -- Real Price: 2
    { item="Base.PopBottle",        tags={"Container", "Scavenger", "Junk"}, basePrice=3, stockRange={min=5, max=15} },
    { item="Base.BeerEmpty",        tags={"Container", "Scavenger", "Junk"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.BeerCanEmpty",     tags={"Container", "Scavenger", "Junk"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.PopEmpty",         tags={"Container", "Scavenger", "Junk"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.TinCanEmpty",      tags={"Container", "Scavenger", "Junk"}, basePrice=1, stockRange={min=10, max=30} },
    { item="Base.MayonnaiseEmpty",  tags={"Container", "Scavenger", "Junk"}, basePrice=2, stockRange={min=2, max=8} },
    
    -- PRESERVATION TOOLS (Not Junk)
    { item="Base.EmptyJar",         tags={"Tool", "Farmer", "Food", "Common"}, basePrice=8, stockRange={min=5, max=20} },
    { item="Base.JarCrafted",       tags={"Tool", "Farmer", "Food", "Common"}, basePrice=5, stockRange={min=5, max=15} },

    -- =============================================================================
    -- 7. LUXURY CUPS & TROPHIES
    -- =============================================================================
    -- Logic: Added "Luxury" tag (3.0x Multiplier). 
    -- These are useless functionally but high trade value.

    { item="Base.TrophyGold",     tags={"Luxury", "Scavenger", "Rare"}, basePrice=20, stockRange={min=0, max=1} }, -- Real: 60
    { item="Base.TrophySilver",   tags={"Luxury", "Scavenger", "Rare"}, basePrice=15, stockRange={min=0, max=1} },
    { item="Base.TrophyBronze",   tags={"Luxury", "Scavenger", "Rare"}, basePrice=10, stockRange={min=0, max=1} },
    { item="Base.GoldCup",        tags={"Luxury", "Scavenger", "Rare"}, basePrice=18, stockRange={min=0, max=2} },
    { item="Base.SilverCup",      tags={"Luxury", "Scavenger", "Rare"}, basePrice=12, stockRange={min=0, max=2} },
    { item="Base.Goblet_Gold",    tags={"Luxury", "Scavenger", "Rare"}, basePrice=20, stockRange={min=0, max=1} },
    { item="Base.Goblet_Silver",  tags={"Luxury", "Scavenger", "Rare"}, basePrice=14, stockRange={min=0, max=2} },
    { item="Base.Goblet_Wood",    tags={"Scavenger", "Common"},         basePrice=4,  stockRange={min=1, max=4} },

    -- =============================================================================
    -- 8. HOUSEHOLD ITEMS
    -- =============================================================================

    { item="Base.Bowl",             tags={"Food", "General", "Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.ClayBowl",         tags={"Food", "Scavenger", "Common"},    basePrice=1, stockRange={min=5, max=10} },
    { item="Base.DrinkingGlass",    tags={"Food", "General", "Common"},      basePrice=3, stockRange={min=5, max=10} },
    { item="Base.MugWhite",         tags={"Food", "General", "Common"},      basePrice=2, stockRange={min=5, max=15} },
    { item="Base.CeramicTeacup",    tags={"Food", "General", "Common"},      basePrice=4, stockRange={min=2, max=8} },
    { item="Base.HotWaterBottle",   tags={"Medical", "Pharmacist", "Common"}, basePrice=12, stockRange={min=1, max=3} },
})