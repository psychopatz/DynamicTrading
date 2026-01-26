require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end
Register({
-- =============================================================================
-- 1. ESSENTIAL TOOLS (Openers)
-- =============================================================================
-- Gatekeepers to calories.
{ item="Base.TinOpener", basePrice=10, tags={"Cooking", "Tool", "Common"}, stockRange={min=2, max=10} },
{ item="Base.TinOpener_Old", basePrice=8, tags={"Cooking", "Tool", "Common"}, stockRange={min=2, max=10} },
{ item="Base.P38", basePrice=15, tags={"Cooking", "Tool", "Military", "Durable"}, stockRange={min=1, max=5} }, -- Lightweight & durable
{ item="Base.BottleOpener", basePrice=2, tags={"Cooking", "Tool", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.BottleOpener_Keychain",basePrice=2, tags={"Cooking", "Tool", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Corkscrew", basePrice=2, tags={"Cooking", "Tool", "Junk"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 2. POTS & PANS (Water & Evolved Recipes)
-- =============================================================================
-- Tier 1: High Capacity (Soup/Stew/Roast)
{ item="Base.Pot",                  basePrice=20, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },
{ item="Base.PotForged",            basePrice=25, tags={"Cooking", "Container", "Metal", "Durable"}, stockRange={min=1, max=5} },
{ item="Base.RoastingPan",          basePrice=20, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },

-- Tier 2: Mid Capacity (Stir Fry)
{ item="Base.Pan",                  basePrice=15, tags={"Cooking", "Container", "Metal", "Weapon"}, stockRange={min=2, max=8} }, -- Decent blunt weapon
{ item="Base.PanForged",            basePrice=20, tags={"Cooking", "Container", "Metal", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.GridlePan",            basePrice=15, tags={"Cooking", "Container", "Metal", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Saucepan",             basePrice=12, tags={"Cooking", "Container", "Metal"}, stockRange={min=2, max=8} },
{ item="Base.SaucepanCopper",       basePrice=15, tags={"Cooking", "Container", "Luxury"}, stockRange={min=1, max=5} },

-- Tier 3: Baking
{ item="Base.BakingPan",            basePrice=10, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },
{ item="Base.BakingTray",           basePrice=10, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },
{ item="Base.MuffinTray",           basePrice=10, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },

-- Tier 4: Boiling Water / Beverage
{ item="Base.Kettle",               basePrice=15, tags={"Cooking", "Container", "Metal"}, stockRange={min=1, max=5} },
{ item="Base.Kettle_Copper",        basePrice=20, tags={"Cooking", "Container", "Luxury"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. CUTLERY & KNIVES (Tools & Weapons)
-- =============================================================================
-- Lethal Weapons
{ item="Base.MeatCleaver",          basePrice=25, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=3} },
{ item="Base.MeatCleaverForged",    basePrice=30, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=3} },
{ item="Base.KitchenKnife",         basePrice=15, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=2, max=10} },
{ item="Base.KitchenKnifeForged",   basePrice=20, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=5} },
{ item="Base.KnifeFillet",          basePrice=12, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=5} }, -- Essential for fishing/filleting
{ item="Base.KnifeSushi",           basePrice=12, tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=5} },

-- Minor Tools / Weak Weapons
{ item="Base.BreadKnife",           basePrice=8,  tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=2, max=8} },
{ item="Base.SteakKnife",           basePrice=8,  tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=2, max=8} },
{ item="Base.KnifeParing",          basePrice=5,  tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=2, max=8} },
{ item="Base.PizzaCutter",          basePrice=3,  tags={"Cooking", "Tool", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.DullBoneKnife",        basePrice=2,  tags={"Cooking", "Weapon", "Primitive"}, stockRange={min=1, max=5} },

-- Junk / Luxury Knives
{ item="Base.ButterKnife",          basePrice=2,  tags={"Cooking", "Weapon", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.PlasticKnife",         basePrice=0.1,tags={"Cooking", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.ButterKnife_Silver",   basePrice=10, tags={"Cooking", "Luxury", "Silver"}, stockRange={min=0, max=2} },
{ item="Base.ButterKnife_Gold",     basePrice=15, tags={"Cooking", "Luxury", "Gold"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 4. UTENSILS & PREP (Mixing)
-- =============================================================================
-- Functional Tools
{ item="Base.RollingPin",           basePrice=10, tags={"Cooking", "Weapon", "Wood"}, stockRange={min=2, max=8} }, -- Solid blunt weapon
{ item="Base.Spatula",              basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Whisk",                basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Ladle",                basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.KitchenTongs",         basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.CheeseGrater",         basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.GrillBrush",           basePrice=2,  tags={"Cooking", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.BastingBrush",         basePrice=2,  tags={"Cooking", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.IcePick",              basePrice=5,  tags={"Cooking", "Weapon", "Sharp"}, stockRange={min=1, max=5} },

-- Cutlery (Junk to Luxury)
{ item="Base.Spoon",                basePrice=1,  tags={"Cooking", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Fork",                 basePrice=1,  tags={"Cooking", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.SpoonForged",          basePrice=2,  tags={"Cooking", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.ForkForged",           basePrice=2,  tags={"Cooking", "Junk"}, stockRange={min=2, max=10} },

-- Primitive/Disposable
{ item="Base.WoodenSpoon",          basePrice=0.5,tags={"Cooking", "Junk", "Wood"}, stockRange={min=5, max=20} },
{ item="Base.WoodenFork",           basePrice=0.5,tags={"Cooking", "Junk", "Wood"}, stockRange={min=5, max=20} },
{ item="Base.Spoon_Bone",           basePrice=0.5,tags={"Cooking", "Junk", "Primitive"}, stockRange={min=5, max=20} },
{ item="Base.Fork_Bone",            basePrice=0.5,tags={"Cooking", "Junk", "Primitive"}, stockRange={min=5, max=20} },
{ item="Base.PlasticSpoon",         basePrice=0.1,tags={"Cooking", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.PlasticFork",          basePrice=0.1,tags={"Cooking", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Chopsticks",           basePrice=0.5,tags={"Cooking", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.SkewersWooden",        basePrice=0.1,tags={"Cooking", "Junk"}, stockRange={min=10, max=50} },

-- Luxury Cutlery
{ item="Base.Spoon_Silver",         basePrice=10, tags={"Cooking", "Luxury", "Silver"}, stockRange={min=0, max=2} },
{ item="Base.Fork_Silver",          basePrice=10, tags={"Cooking", "Luxury", "Silver"}, stockRange={min=0, max=2} },
{ item="Base.Spoon_Gold",           basePrice=15, tags={"Cooking", "Luxury", "Gold"}, stockRange={min=0, max=2} },
{ item="Base.Fork_Gold",            basePrice=15, tags={"Cooking", "Luxury", "Gold"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. SERVING & STORAGE (Preservation)
-- =============================================================================
-- Preservation (Critical for Winter)
{ item="Base.BoxOfJars",            basePrice=40, tags={"Cooking", "Preservation", "Stockpile"}, stockRange={min=1, max=3} },
{ item="Base.EmptyJar",             basePrice=5,  tags={"Cooking", "Preservation"}, stockRange={min=2, max=10} },
{ item="Base.JarCrafted",           basePrice=5,  tags={"Cooking", "Preservation"}, stockRange={min=2, max=10} },
{ item="Base.JarLid",               basePrice=2,  tags={"Cooking", "Preservation"}, stockRange={min=5, max=20} },

-- Serving
{ item="Base.Bowl",                 basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=5, max=20} },
{ item="Base.ClayBowl",             basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=5, max=20} },
{ item="Base.Plate",                basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=5, max=20} },
{ item="Base.ClayPlate",            basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=5, max=20} },

-- Cups & Mugs
{ item="Base.MugWhite",             basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },
{ item="Base.Mugl",                 basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },
{ item="Base.ClayMug",              basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },
{ item="Base.Teacup",               basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },
{ item="Base.CeramicTeacup",        basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },
{ item="Base.MetalCup",             basePrice=2,  tags={"Cooking", "Container"}, stockRange={min=2, max=10} },

-- Luxury Cups
{ item="Base.CopperCup",            basePrice=10, tags={"Cooking", "Luxury", "Copper"}, stockRange={min=0, max=2} },
{ item="Base.SilverCup",            basePrice=15, tags={"Cooking", "Luxury", "Silver"}, stockRange={min=0, max=2} },
{ item="Base.GoldCup",              basePrice=25, tags={"Cooking", "Luxury", "Gold"}, stockRange={min=0, max=2} },

-- Boards
{ item="Base.CuttingBoardPlastic",  basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.CuttingBoardWooden",   basePrice=3,  tags={"Cooking", "Tool"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. CONSUMABLE INGREDIENTS
-- =============================================================================
{ item="Base.BakingSoda",           basePrice=5,  tags={"Cooking", "Ingredient"}, stockRange={min=2, max=10} },
{ item="Base.Timer",                basePrice=8,  tags={"Cooking", "Electronics"}, stockRange={min=1, max=5} }, -- Component for bombs too

})

print("[DynamicTrading] Cooking Registry Complete.")
