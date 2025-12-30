require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================
-- HANDGUNS & REVOLVERS
-- ==========================================

-- M36 Revolver: Low damage but the quietest gun in the game. Very reliable.
DynamicTrading.AddItem("BuyM36Revolver", {
    item = "Base.Revolver",
    category = "Weapon",
    tags = {"Gun", "Police", "Civilian"},
    basePrice = 180,
    stockRange = { min=1, max=3 }
})

-- M9 Pistol: Standard 15-round mag. Common but reliable for clearing small groups.
DynamicTrading.AddItem("BuyM9Pistol", {
    item = "Base.Pistol",
    category = "Weapon",
    tags = {"Gun", "Police"},
    basePrice = 220,
    stockRange = { min=1, max=4 }
})

-- M1911 Pistol: Higher damage than M9, but smaller magazine (7 rounds).
DynamicTrading.AddItem("BuyM1911Pistol", {
    item = "Base.Pistol2",
    category = "Weapon",
    tags = {"Gun", "Police"},
    basePrice = 280,
    stockRange = { min=1, max=3 }
})

-- M625 Revolver: Uses .45 Auto. Hard-hitting civilian/police revolver.
DynamicTrading.AddItem("BuyM625Revolver", {
    item = "Base.Revolver_Long",
    category = "Weapon",
    tags = {"Gun", "Police"},
    basePrice = 260,
    stockRange = { min=1, max=2 }
})

-- Desert Eagle (DE Pistol): Very high damage, very loud, rare.
DynamicTrading.AddItem("BuyDEPistol", {
    item = "Base.Pistol3",
    category = "Weapon",
    tags = {"Gun", "Rare", "Military"},
    basePrice = 450,
    stockRange = { min=0, max=1 }
})

-- Magnum: The most powerful handgun. Iconic and deadly.
DynamicTrading.AddItem("BuyMagnum", {
    item = "Base.Revolver",
    category = "Weapon",
    tags = {"Gun", "Rare"},
    basePrice = 500,
    stockRange = { min=0, max=1 }
})

-- ==========================================
-- SHOTGUNS
-- ==========================================

-- JS-2000 Shotgun: The "Gold Standard" for PZ. High capacity, massive crowd clearing.
DynamicTrading.AddItem("BuyJS2000", {
    item = "Base.Shotgun",
    category = "Weapon",
    tags = {"Gun", "Police", "Hunting"},
    basePrice = 450,
    stockRange = { min=1, max=3 }
})

-- Double Barrel Shotgun: Higher crit chance and damage than JS-2000, but only 2 shots.
DynamicTrading.AddItem("BuyDoubleBarrel", {
    item = "Base.DoubleBarrelShotgun",
    category = "Weapon",
    tags = {"Gun", "Hunting", "Civilian"},
    basePrice = 400,
    stockRange = { min=1, max=2 }
})

-- ==========================================
-- RIFLES & ASSAULT RIFLES
-- ==========================================

-- Varmint Rifle (M700): Lower damage rifle, good for training at range.
DynamicTrading.AddItem("BuyVarmintRifle", {
    item = "Base.VarmintRifle",
    category = "Weapon",
    tags = {"Gun", "Hunting"},
    basePrice = 350,
    stockRange = { min=1, max=2 }
})

-- Hunting Rifle (M788): Significant damage and range. Great for picking off targets.
DynamicTrading.AddItem("BuyHuntingRifle", {
    item = "Base.HuntingRifle",
    category = "Weapon",
    tags = {"Gun", "Hunting", "Rare"},
    basePrice = 550,
    stockRange = { min=0, max=2 }
})

-- M14 Rifle: Semi-auto, high damage, uses 20-round mags. 
DynamicTrading.AddItem("BuyM14Rifle", {
    item = "Base.AssaultRifle2",
    category = "Weapon",
    tags = {"Gun", "Military", "Rare"},
    basePrice = 750,
    stockRange = { min=0, max=1 }
})

-- M16 Assault Rifle: The rarest and highest DPS gun in the game.
DynamicTrading.AddItem("BuyM16", {
    item = "Base.AssaultRifle",
    category = "Weapon",
    tags = {"Gun", "Military", "Rare"},
    basePrice = 1200, -- The "Grail" weapon
    stockRange = { min=0, max=1 }
})


-- ==========================================
-- AXES (High Damage & Utility)
-- ==========================================

-- Fire Axe: The gold standard. Perfectly balanced damage and durability.
DynamicTrading.AddItem("BuyFireAxe", {
    item = "Base.Axe",
    category = "Weapon",
    tags = {"Blade", "Tool", "Build", "Military"},
    basePrice = 120,
    stockRange = { min=1, max=3 }
})

-- Hand Axe: One-handed, faster swing, but less reach. Great for secondary slots.
DynamicTrading.AddItem("BuyHandAxe", {
    item = "Base.HandAxe",
    category = "Weapon",
    tags = {"Blade", "Tool", "Survival", "Police"},
    basePrice = 70,
    stockRange = { min=1, max=5 }
})

-- Wood Axe: Heaviest damage, but extremely high endurance cost. Best for trees.
DynamicTrading.AddItem("BuyWoodAxe", {
    item = "Base.WoodAxe",
    category = "Weapon",
    tags = {"Blade", "Tool", "Build", "Heavy"},
    basePrice = 140,
    stockRange = { min=0, max=2 }
})

-- Pickaxe: Massive damage and reach. Rare and very heavy.
DynamicTrading.AddItem("BuyPickaxe", {
    item = "Base.PickAxe",
    category = "Weapon",
    tags = {"Blade", "Tool", "Heavy"},
    basePrice = 150,
    stockRange = { min=0, max=1 }
})

-- Stone Axe: Low durability, crude survivalist tool.
DynamicTrading.AddItem("BuyStoneAxe", {
    item = "Base.StoneAxe",
    category = "Weapon",
    tags = {"Blade", "Survival", "Junk"},
    basePrice = 15,
    stockRange = { min=2, max=6 }
})

-- ==========================================
-- NEW B42/SPECIALIZED AXES
-- ==========================================

-- Splitting Axe: High damage, specialized for wood.
DynamicTrading.AddItem("BuySplittingAxe", {
    item = "Base.SplittingAxe",
    category = "Weapon",
    tags = {"Blade", "Tool", "Build"},
    basePrice = 110,
    stockRange = { min=0, max=2 }
})

-- Hatchet: Lightweight, similar to Hand Axe but often found in hardware stores.
DynamicTrading.AddItem("BuyHatchet", {
    item = "Base.Hatchet",
    category = "Weapon",
    tags = {"Blade", "Tool", "Survival"},
    basePrice = 65,
    stockRange = { min=1, max=4 }
})



-- ==========================================
-- LONG BLUNT WEAPONS
-- ==========================================

-- Sledgehammer: The ultimate tool. Extremely rare and allows players to break stairs/walls.
DynamicTrading.AddItem("BuySledgehammer", {
    item = "Base.Sledgehammer",
    category = "Weapon",
    tags = {"Tool", "Build", "Heavy", "Rare"},
    basePrice = 450, -- Most expensive tool due to game-changing utility
    stockRange = { min=0, max=1 }
})

-- Crowbar: The survivor's favorite. Practically infinite durability.
DynamicTrading.AddItem("BuyCrowbar", {
    item = "Base.Crowbar",
    category = "Weapon",
    tags = {"Tool", "Mechanic", "Heavy"},
    basePrice = 110,
    stockRange = { min=1, max=4 }
})

-- Baseball Bat: High knockback and iconic. Can be upgraded by the player.
DynamicTrading.AddItem("BuyBaseballBat", {
    item = "Base.BaseballBat",
    category = "Weapon",
    tags = {"Sports", "Civilian"},
    basePrice = 60,
    stockRange = { min=1, max=5 }
})

-- Spiked Baseball Bat: Pre-upgraded version with significantly higher damage.
DynamicTrading.AddItem("BuyBaseballBatSpiked", {
    item = "Base.BaseballBatSpiked",
    category = "Weapon",
    tags = {"Weapon", "Illegal"},
    basePrice = 95,
    stockRange = { min=0, max=2 }
})

-- Shovel: Great reach and high damage. Essential for gardening/graves.
DynamicTrading.AddItem("BuyShovel", {
    item = "Base.Shovel",
    category = "Weapon",
    tags = {"Tool", "Gardening", "Build"},
    basePrice = 75,
    stockRange = { min=1, max=3 }
})

-- Snow Shovel: Longer reach than a standard shovel but slightly less damage.
DynamicTrading.AddItem("BuySnowShovel", {
    item = "Base.SnowShovel",
    category = "Weapon",
    tags = {"Tool", "Gardening"},
    basePrice = 70,
    stockRange = { min=0, max=2 }
})

-- Garden Hoe: Specifically for farmers, decent weapon reach.
DynamicTrading.AddItem("BuyGardenHoe", {
    item = "Base.GardenHoe",
    category = "Weapon",
    tags = {"Tool", "Gardening", "Farmer"},
    basePrice = 65,
    stockRange = { min=1, max=3 }
})

-- Lead Pipe: Heavy, decent damage, very durable.
DynamicTrading.AddItem("BuyLeadPipe", {
    item = "Base.LeadPipe",
    category = "Weapon",
    tags = {"Material", "Scavenge"},
    basePrice = 45,
    stockRange = { min=1, max=4 }
})

-- Metal Pipe: Slightly lighter and faster than the lead pipe.
DynamicTrading.AddItem("BuyMetalPipe", {
    item = "Base.MetalPipe",
    category = "Weapon",
    tags = {"Material", "Scavenge"},
    basePrice = 40,
    stockRange = { min=2, max=6 }
})

-- Golf Club: Fast swing speed but low durability.
DynamicTrading.AddItem("BuyGolfClub", {
    item = "Base.GolfClub",
    category = "Weapon",
    tags = {"Sports", "Civilian"},
    basePrice = 35,
    stockRange = { min=1, max=4 }
})

-- Canoe Paddle: Longest reach in the category, but fragile.
DynamicTrading.AddItem("BuyCanoePaddle", {
    item = "Base.CanoePaddle",
    category = "Weapon",
    tags = {"Survival", "Civilian"},
    basePrice = 30,
    stockRange = { min=1, max=3 }
})



-- ==========================================
-- SHORT BLUNT (Tools & Compact Weapons)
-- ==========================================

-- Nightstick: Extremely durable, high knockback. The best pure combat short blunt.
DynamicTrading.AddItem("BuyNightstick", {
    item = "Base.Nightstick",
    category = "Weapon",
    tags = {"Weapon", "Police"},
    basePrice = 85,
    stockRange = { min=1, max=3 }
})

-- Hammer: The most essential tool in the game for construction.
DynamicTrading.AddItem("BuyHammer", {
    item = "Base.Hammer",
    category = "Weapon",
    tags = {"Tool", "Build", "Carpenter"},
    basePrice = 50,
    stockRange = { min=2, max=6 }
})

-- Ball Peen Hammer: Great weapon speed, used in mechanics and metalworking.
DynamicTrading.AddItem("BuyBallPeenHammer", {
    item = "Base.BallPeenHammer",
    category = "Weapon",
    tags = {"Tool", "Mechanic", "Scavenge"},
    basePrice = 40,
    stockRange = { min=1, max=4 }
})

-- Club Hammer: Heavier and slower than a standard hammer, but hits harder.
DynamicTrading.AddItem("BuyClubHammer", {
    item = "Base.ClubHammer",
    category = "Weapon",
    tags = {"Tool", "Build", "Heavy"},
    basePrice = 55,
    stockRange = { min=1, max=3 }
})

-- Pipe Wrench: Heavy damage and essential for plumbing/sink installation.
DynamicTrading.AddItem("BuyPipeWrench", {
    item = "Base.PipeWrench",
    category = "Weapon",
    tags = {"Tool", "Mechanic", "Car"},
    basePrice = 75,
    stockRange = { min=1, max=3 }
})

-- Wrench: Essential for vehicle repair.
DynamicTrading.AddItem("BuyWrench", {
    item = "Base.Wrench",
    category = "Weapon",
    tags = {"Tool", "Mechanic", "Car"},
    basePrice = 45,
    stockRange = { min=2, max=5 }
})

-- Wooden Mallet: High knockback, but lower damage than metal hammers.
DynamicTrading.AddItem("BuyWoodenMallet", {
    item = "Base.WoodenMallet",
    category = "Weapon",
    tags = {"Tool", "Build"},
    basePrice = 30,
    stockRange = { min=1, max=4 }
})

-- ==========================================
-- KITCHENWARE & IMPROVISED
-- ==========================================

-- Frying Pan: Iconic, decent durability, loud "clang" sound.
DynamicTrading.AddItem("BuyFryingPan", {
    item = "Base.Pan",
    category = "Weapon",
    tags = {"Kitchen", "Food", "Civilian"},
    basePrice = 20,
    stockRange = { min=2, max=5 }
})

-- Griddle Pan: Slightly heavier and more durable than a frying pan.
DynamicTrading.AddItem("BuyGriddlePan", {
    item = "Base.GriddlePan",
    category = "Weapon",
    tags = {"Kitchen", "Food", "Civilian"},
    basePrice = 25,
    stockRange = { min=1, max=3 }
})

-- Saucepan: Common kitchen weapon.
DynamicTrading.AddItem("BuySaucepan", {
    item = "Base.Saucepan",
    category = "Weapon",
    tags = {"Kitchen", "Food", "Civilian"},
    basePrice = 15,
    stockRange = { min=2, max=5 }
})

-- Rolling Pin: Low damage, mostly a backup weapon.
DynamicTrading.AddItem("BuyRollingPin", {
    item = "Base.RollingPin",
    category = "Weapon",
    tags = {"Kitchen", "Food", "Civilian"},
    basePrice = 12,
    stockRange = { min=1, max=4 }
})

-- Meat Masher: High attack speed kitchen weapon.
DynamicTrading.AddItem("BuyMeatMasher", {
    item = "Base.MeatMasher",
    category = "Weapon",
    tags = {"Kitchen", "Meat", "Butcher"},
    basePrice = 25,
    stockRange = { min=1, max=3 }
})

-- Plunger: Effectively a joke weapon with very low damage.
DynamicTrading.AddItem("BuyPlunger", {
    item = "Base.Plunger",
    category = "Weapon",
    tags = {"Junk"},
    basePrice = 5,
    stockRange = { min=1, max=2 }
})



-- ==========================================
-- LONG BLADES (Elite Melee Weapons)
-- ==========================================

-- Katana: The rarest and most powerful melee weapon in the game. 
-- It cannot be repaired in vanilla, making it a high-cost "disposable" power item.
DynamicTrading.AddItem("BuyKatana", {
    item = "Base.Katana",
    category = "Weapon",
    tags = {"Blade", "Rare", "Military"},
    basePrice = 1500, -- The "Grail" of melee weapons
    stockRange = { min=0, max=1 }
})

-- Machete: Extremely high damage and can be attached to spears. 
-- Rare, but repairable, making it a sustainable endgame weapon.
DynamicTrading.AddItem("BuyMachete", {
    item = "Base.Machete",
    category = "Weapon",
    tags = {"Blade", "Rare", "Military", "Survival"},
    basePrice = 350,
    stockRange = { min=0, max=2 }
})

-- Scythe: (Found in B42/Farming contexts) Large reach, unique swing arc.
DynamicTrading.AddItem("BuyScythe", {
    item = "Base.Scythe",
    category = "Weapon",
    tags = {"Blade", "Farmer", "Heavy"},
    basePrice = 180,
    stockRange = { min=0, max=1 }
})




-- ==========================================
-- SHORT BLADES (Stealth & Low Endurance)
-- ==========================================

-- Hunting Knife: The best in class. High crit chance, durable, and lethal.
DynamicTrading.AddItem("BuyHuntingKnife", {
    item = "Base.HuntingKnife",
    category = "Weapon",
    tags = {"Blade", "Survival", "Military", "Hunting"},
    basePrice = 85,
    stockRange = { min=1, max=4 }
})

-- Meat Cleaver: The "heavy" short blade. High damage, great for the Butcher.
DynamicTrading.AddItem("BuyMeatCleaver", {
    item = "Base.MeatCleaver",
    category = "Weapon",
    tags = {"Blade", "Meat", "Butcher", "Kitchen"},
    basePrice = 60,
    stockRange = { min=1, max=3 }
})

-- Kitchen Knife: Common civilian blade. Good for early game stealth kills.
DynamicTrading.AddItem("BuyKitchenKnife", {
    item = "Base.KitchenKnife",
    category = "Weapon",
    tags = {"Blade", "Kitchen", "Civilian"},
    basePrice = 25,
    stockRange = { min=2, max=6 }
})

-- Scalpel: Extremely high crit multiplier but very low durability.
DynamicTrading.AddItem("BuyScalpel", {
    item = "Base.Scalpel",
    category = "Weapon",
    tags = {"Blade", "Medical", "Rare"},
    basePrice = 45,
    stockRange = { min=1, max=3 }
})

-- Ice Pick: High penetration, high durability for a short blade.
DynamicTrading.AddItem("BuyIcePick", {
    item = "Base.IcePick",
    category = "Weapon",
    tags = {"Blade", "Kitchen", "Scavenge"},
    basePrice = 40,
    stockRange = { min=1, max=2 }
})

-- Letter Opener: Low damage, desperate backup weapon.
DynamicTrading.AddItem("BuyLetterOpener", {
    item = "Base.LetterOpener",
    category = "Weapon",
    tags = {"Blade", "Junk", "Civilian"},
    basePrice = 10,
    stockRange = { min=1, max=3 }
})

-- Bread Knife: Fragile kitchen tool.
DynamicTrading.AddItem("BuyBreadKnife", {
    item = "Base.BreadKnife",
    category = "Weapon",
    tags = {"Blade", "Kitchen", "Food"},
    basePrice = 15,
    stockRange = { min=2, max=5 }
})

-- Butter Knife: The most fragile "weapon" in the game.
DynamicTrading.AddItem("BuyButterKnife", {
    item = "Base.ButterKnife",
    category = "Weapon",
    tags = {"Blade", "Kitchen", "Junk"},
    basePrice = 5,
    stockRange = { min=2, max=10 }
})

-- Stone Knife: Primitive survival tool.
DynamicTrading.AddItem("BuyStoneKnife", {
    item = "Base.StoneKnife",
    category = "Weapon",
    tags = {"Blade", "Survival", "Scavenge"},
    basePrice = 12,
    stockRange = { min=1, max=4 }
})

-- Hand Fork: Gardening tool used as a crude stabbing weapon.
DynamicTrading.AddItem("BuyHandFork", {
    item = "Base.HandFork",
    category = "Weapon",
    tags = {"Blade", "Gardening", "Farmer"},
    basePrice = 20,
    stockRange = { min=1, max=3 }
})

-- Flensing Knife (B42/Specialized): Used for animal processing.
DynamicTrading.AddItem("BuyFlensingKnife", {
    item = "Base.FlensingKnife",
    category = "Weapon",
    tags = {"Blade", "Butcher", "Survival"},
    basePrice = 55,
    stockRange = { min=0, max=2 }
})