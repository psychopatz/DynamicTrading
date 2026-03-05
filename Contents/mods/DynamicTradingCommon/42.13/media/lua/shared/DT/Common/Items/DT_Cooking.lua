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
-- (Consolidated in DT_ContainersFluid.lua)

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
-- (Consolidated in DT_ContainersFluid.lua)

-- Serving
-- (Consolidated in DT_ContainersFluid.lua)

-- Boards
{ item="Base.CuttingBoardPlastic",  basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.CuttingBoardWooden",   basePrice=3,  tags={"Tool.Cooking", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. CONSUMABLE INGREDIENTS
-- =============================================================================
{ item="Base.BakingSoda",           basePrice=5,  tags={"Food.Cooking.Ingredient", "Rarity.Common"}, stockRange={min=2, max=10} },
-- (Consolidated in DT_Electronics.lua)

})

print("[DynamicTrading] Cooking Registry Complete \n.")
