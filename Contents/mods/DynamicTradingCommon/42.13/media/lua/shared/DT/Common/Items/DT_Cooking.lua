require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. ESSENTIAL TOOLS (Openers)
-- =============================================================================
-- Gatekeepers to calories.
{ item="Base.TinOpener", basePrice=45, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.TinOpener_Old", basePrice=35, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.P38", basePrice=85, tags={"Tool.Crafting.Mechanic", "Origin.Militia", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.BottleOpener", basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.BottleOpener_Keychain",basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Corkscrew", basePrice=10, tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 2. POTS & PANS (Water & Evolved Recipes)
-- =============================================================================
-- Tier 1: High Capacity (Soup/Stew/Roast)
{ item="Base.Pot",                  basePrice=75, tags={"Container.Cooking", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.PotForged",            basePrice=120, tags={"Container.Cooking", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.RoastingPan",          basePrice=75, tags={"Container.Cooking", "Rarity.Common"}, stockRange={min=1, max=3} },

-- Tier 2: Mid Capacity (Stir Fry)
{ item="Base.Pan",                  basePrice=55, tags={"Container.Cooking", "Rarity.Common"}, stockRange={min=1, max=4} },
{ item="Base.PanForged",            basePrice=95, tags={"Container.Cooking", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.GridlePan",            basePrice=55, tags={"Container.Cooking", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Saucepan",             basePrice=45, tags={"Container.Cooking", "Rarity.Common"}, stockRange={min=1, max=4} },
{ item="Base.SaucepanCopper",       basePrice=150, tags={"Container.Cooking", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },

-- Tier 3: Baking
{ item="Base.BakingPan",            basePrice=10, tags={"Container.Cooking.Baking", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.BakingTray",           basePrice=10, tags={"Container.Cooking.Baking", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.MuffinTray",           basePrice=10, tags={"Container.Cooking.Baking", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Tier 4: Boiling Water / Beverage
{ item="Base.Kettle",               basePrice=15, tags={"Container.Cooking.Boiling", "Resource.Material.Metal", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Kettle_Copper",        basePrice=20, tags={"Container.Cooking.Boiling", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. CUTLERY & KNIVES (Tools & Weapons)
-- =============================================================================
-- Lethal Weapons
{ item="Base.MeatCleaver",          basePrice=180, tags={"Weapon.Melee.Sharp", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.MeatCleaverForged",    basePrice=250, tags={"Weapon.Melee.Sharp", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.KitchenKnife",         basePrice=85, tags={"Weapon.Melee.Sharp", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.KitchenKnifeForged",   basePrice=140, tags={"Weapon.Melee.Sharp", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.KnifeFillet",          basePrice=65, tags={"Tool.Cooking", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.KnifeSushi",           basePrice=65, tags={"Tool.General", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- Minor Tools / Weak Weapons
{ item="Base.BreadKnife",           basePrice=8,  tags={"Weapon.Melee.Sharp", "Theme.Cooking", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.SteakKnife",           basePrice=8,  tags={"Weapon.Melee.Sharp", "Theme.Cooking", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.KnifeParing",          basePrice=5,  tags={"Weapon.Melee.Sharp", "Theme.Cooking", "Rarity.Common"}, stockRange={min=2, max=8} },
{ item="Base.PizzaCutter",          basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.DullBoneKnife",        basePrice=2,  tags={"Weapon.Melee.Sharp", "Origin.Nomad", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Junk / Luxury Knives
{ item="Base.ButterKnife",          basePrice=2,  tags={"Weapon.Melee.Sharp", "Quality.Waste", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.PlasticKnife",         basePrice=0,  tags={"Weapon.Melee.Sharp", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.ButterKnife_Silver",   basePrice=10, tags={"Weapon.Melee.Sharp", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.ButterKnife_Gold",     basePrice=15, tags={"Weapon.Melee.Sharp", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 4. UTENSILS & PREP (Mixing)
-- =============================================================================
-- Functional Tools
{ item="Base.RollingPin",           basePrice=10, tags={"Weapon.Melee.Blunt", "Theme.Cooking", "Resource.Material.Wood", "Rarity.Common"}, stockRange={min=2, max=8} }, -- Solid blunt weapon
{ item="Base.Spatula",              basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Whisk",                basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Ladle",                basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.KitchenTongs",         basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.CheeseGrater",         basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.GrillBrush",           basePrice=2,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.BastingBrush",         basePrice=2,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.IcePick",              basePrice=5,  tags={"Weapon.Melee.Sharp", "Theme.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },

-- Cutlery (Junk to Luxury)
{ item="Base.Spoon",                basePrice=1,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Fork",                 basePrice=1,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.SpoonForged",          basePrice=2,  tags={"Tool.General", "Quality.Basic", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.ForkForged",           basePrice=2,  tags={"Tool.General", "Quality.Basic", "Rarity.Common"}, stockRange={min=2, max=10} },

-- Primitive/Disposable
{ item="Base.WoodenSpoon",          basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.WoodenFork",           basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Spoon_Bone",           basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Fork_Bone",            basePrice=1,  tags={"Tool.General", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.PlasticSpoon",         basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.PlasticFork",          basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.Chopsticks",           basePrice=1,  tags={"Tool.Cooking.Utensil", "Theme.Asian", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.SkewersWooden",        basePrice=0,  tags={"Tool.General", "Quality.Waste", "Rarity.Common"}, stockRange={min=10, max=50} },

-- Luxury Cutlery
{ item="Base.Spoon_Silver",         basePrice=10, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Fork_Silver",          basePrice=10, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.Spoon_Gold",           basePrice=15, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },
{ item="Base.Fork_Gold",            basePrice=15, tags={"Tool.Cooking.Utensil", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. SERVING & STORAGE (Preservation)
-- =============================================================================
-- Preservation (Critical for Winter)
{ item="Base.BoxOfJars",            basePrice=40, tags={"Resource.Storage.Preservation", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.EmptyJar",             basePrice=5,  tags={"Resource.Storage.Preservation", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.JarCrafted",           basePrice=5,  tags={"Resource.Storage.Preservation", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.JarLid",               basePrice=2,  tags={"Resource.Storage.Preservation", "Rarity.Common"}, stockRange={min=5, max=20} },

-- Serving
{ item="Base.Bowl",                 basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.ClayBowl",             basePrice=2,  tags={"Container.Cooking.Serving", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.Plate",                basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.ClayPlate",            basePrice=2,  tags={"Container.Cooking.Serving", "Origin.Nomad", "Rarity.Common"}, stockRange={min=5, max=20} },

-- Cups & Mugs
{ item="Base.MugWhite",             basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Mugl",                 basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.ClayMug",              basePrice=2,  tags={"Container.Cooking.Serving", "Origin.Nomad", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Teacup",               basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.CeramicTeacup",        basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.MetalCup",             basePrice=2,  tags={"Container.Cooking.Serving", "Rarity.Common"}, stockRange={min=2, max=10} },

-- Luxury Cups
{ item="Base.CopperCup",            basePrice=10, tags={"Container.Cooking.Serving", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=2} },
{ item="Base.SilverCup",            basePrice=15, tags={"Container.Cooking.Serving", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },
{ item="Base.GoldCup",              basePrice=25, tags={"Container.Cooking.Serving", "Quality.Luxury", "Rarity.Legendary"}, stockRange={min=0, max=2} },

-- Boards
{ item="Base.CuttingBoardPlastic",  basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CuttingBoardWooden",   basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. CONSUMABLE INGREDIENTS
-- =============================================================================
{ item="Base.BakingSoda",           basePrice=5,  tags={"Food.Cooking.Ingredient", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Timer",                basePrice=8,  tags={"Electronics.Gadget.Utility", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Component for bombs too

})

print("[DynamicTrading] Cooking Registry Complete \n.")
