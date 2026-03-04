require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- ==========================================================
    -- 1. AXES (Standard & Heavy)
    -- ==========================================================
    { item="Base.Axe",                tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Rarity.Common"}, basePrice=180, stockRange={min=1, max=5} }, 
    { item="Base.Axe_Old",            tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Quality.Waste"},  basePrice=120, stockRange={min=1, max=3} }, 
    { item="Base.WoodAxe",            tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=3} }, 
    { item="Base.WoodAxeForged",      tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Rarity.Rare"},     basePrice=420, stockRange={min=0, max=2} }, 
    { item="Base.PickAxe",            tags={"Weapon.Melee.Axe", "Tool.Mining", "Rarity.Uncommon"},        basePrice=240, stockRange={min=1, max=3} }, 
    { item="Base.PickAxeForged",      tags={"Weapon.Melee.Axe", "Tool.Mining", "Rarity.Rare"},            basePrice=360, stockRange={min=0, max=2} }, 

    -- ==========================================================
    -- 2. AXES (Small / One-Handed)
    -- ==========================================================
    { item="Base.HandAxe",            tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Rarity.Common"}, basePrice=90,  stockRange={min=2, max=10} }, -- Worth: 7.5
    { item="Base.HandAxe_Old",        tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Quality.Waste"},  basePrice=60,  stockRange={min=2, max=6} },
    { item="Base.HandAxeForged",      tags={"Weapon.Melee.Axe", "Tool.Resource.Wood", "Rarity.Rare"},    basePrice=150, stockRange={min=0, max=3} },  -- Worth: 12.5
    { item="Base.IceAxe",             tags={"Weapon.Melee.Axe", "Theme.Survival", "Rarity.Rare"},        basePrice=180, stockRange={min=0, max=2} },  -- Worth: 15.0
    { item="Base.MeatCleaver",        tags={"Weapon.Melee.Axe", "Tool.Kitchen", "Rarity.Common"},       basePrice=60,  stockRange={min=1, max=5} },  -- Worth: 5.0
    { item="Base.MeatCleaverForged",  tags={"Weapon.Melee.Axe", "Tool.Kitchen", "Rarity.Rare"},         basePrice=120, stockRange={min=0, max=2} },  -- Worth: 10.0
    { item="Base.HandScythe",         tags={"Weapon.Melee.Axe", "Tool.Farmer", "Rarity.Common"},        basePrice=72,  stockRange={min=1, max=5} },  -- Worth: 6.0
    { item="Base.HandScytheForged",   tags={"Weapon.Melee.Axe", "Tool.Farmer", "Rarity.Rare"},          basePrice=144, stockRange={min=0, max=2} },  -- Worth: 12.0

    -- ==========================================================
    -- 3. PRIMITIVE & BONE WEAPONS
    -- ==========================================================
    { item="Base.Hatchet_Bone",         tags={"Weapon.Melee.Axe", "Theme.Survival", "Rarity.Common"}, basePrice=36, stockRange={min=2, max=10} }, -- Worth: 3.0
    { item="Base.JawboneBovide_Axe",    tags={"Weapon.Melee.Axe", "Theme.Survival", "Rarity.Common"}, basePrice=48, stockRange={min=2, max=10} }, -- Worth: 4.0
    { item="Base.Saw_Flint",            tags={"Weapon.Melee.SmallAxe", "Theme.Survival", "Rarity.Common"}, basePrice=24, stockRange={min=2, max=10} }, -- Worth: 2.0
    { item="Base.PrimitiveScythe",      tags={"Weapon.Melee.Axe", "Theme.Survival", "Rarity.Common"}, basePrice=36, stockRange={min=1, max=5} }, -- Worth: 3.0
    { item="Base.LargeBoneClub_Spiked", tags={"Weapon.Melee.Blunt", "Theme.Survival", "Rarity.Common"}, basePrice=60, stockRange={min=1, max=5} }, -- Worth: 5.0
    { item="Base.Cudgel_Bone",          tags={"Weapon.Melee.ShortBlunt", "Theme.Survival", "Rarity.Common"}, basePrice=120, stockRange={min=1, max=5} }, -- Worth: 10.0
    { item="Base.Fleshing_Tool_Bone",   tags={"Tool.Survival", "Theme.Survival", "Rarity.Common"},   basePrice=12, stockRange={min=5, max=15} }, -- Worth: 1.0

    -- ==========================================================
    -- 4. SCRAP WEAPONS (The "Sawblade" & "RailSpike" Series)
    -- ==========================================================
    -- Axes & Cleavers
    { item="Base.Axe_ScrapCleaver",       tags={"Weapon.Melee.Axe", "Origin.Civ", "Quality.Waste"}, basePrice=60, stockRange={min=1, max=3} },
    { item="Base.Axe_Sawblade",           tags={"Weapon.Melee.Axe", "Origin.Civ", "Quality.Waste"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.Axe_Sawblade_Hatchet",   tags={"Weapon.Melee.Axe", "Origin.Civ", "Quality.Waste"}, basePrice=85, stockRange={min=1, max=3} },
    { item="Base.MeatCleaver_Scrap",      tags={"Weapon.Melee.Axe", "Origin.Civ", "Quality.Waste"}, basePrice=35, stockRange={min=1, max=4} },
    
    -- Blunts (Cudgels/Bats/Pipes)
    { item="Base.TableLeg_Sawblade",         tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RailSpike",     tags={"Weapon.Melee.Blunt", "Origin.Civ", "Quality.Waste"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Sawblade",      tags={"Weapon.Melee.Blunt", "Origin.Civ", "Quality.Waste"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.ShortBat_RailSpike",        tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.ShortBat_Sawblade",         tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.FieldHockeyStick_Sawblade", tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=55, stockRange={min=0, max=2} },
    { item="Base.MetalPipe_Railspike",       tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=55, stockRange={min=0, max=2} },
    { item="Base.TreeBranch_Railspike",      tags={"Weapon.Melee.ShortBlunt", "Theme.Survival", "Quality.Waste"}, basePrice=25, stockRange={min=1, max=4} },
    
    -- Long Handles
    { item="Base.LongHandle_Railspike",   tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=45,  stockRange={min=0, max=3} },
    { item="Base.LongHandle_Sawblade",    tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=50,  stockRange={min=0, max=3} },
    { item="Base.LongHandle_Can",         tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=55,  stockRange={min=1, max=5} },
    { item="Base.LongHandle_Brake",       tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=85,  stockRange={min=0, max=3} },
    { item="Base.LongHandle_Nails",       tags={"Weapon.Melee.LongBlunt", "Theme.Survival", "Quality.Waste"},  basePrice=45,  stockRange={min=1, max=5} },
    { item="Base.LongHandle_RakeHead",    tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Quality.Waste"},     basePrice=65,  stockRange={min=1, max=4} },

    -- Heavy Scrap (Brake Discs & Mauls)
    { item="Base.ScrapWeapon_Brake",      tags={"Weapon.Melee.HeavyBlunt", "Origin.Civ", "Rarity.Uncommon"}, basePrice=110, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Brake",           tags={"Weapon.Melee.HeavyBlunt", "Origin.Civ", "Rarity.Uncommon"}, basePrice=125, stockRange={min=0, max=1} },
    { item="Base.Cudgel_Sawblade",        tags={"Weapon.Melee.HeavyBlunt", "Origin.Civ", "Rarity.Uncommon"}, basePrice=115, stockRange={min=0, max=1} },
    { item="Base.Cudgel_SpadeHead",       tags={"Weapon.Melee.HeavyBlunt", "Origin.Civ", "Rarity.Uncommon"}, basePrice=105, stockRange={min=0, max=1} },
    { item="Base.Plank_Brake",            tags={"Weapon.Melee.Blunt", "Origin.Civ", "Quality.Waste"}, basePrice=65, stockRange={min=0, max=3} },
    { item="Base.Plank_Sawblade",         tags={"Weapon.Melee.Blunt", "Origin.Civ", "Quality.Waste"}, basePrice=55, stockRange={min=0, max=3} },

    -- ==========================================================
    -- 5. HEAVY TOOLS & BLUNTS (Sledgehammers & Crowbars)
    -- ==========================================================
    { item="Base.Sledgehammer",       tags={"Weapon.Melee.HeavyBlunt", "Tool.Demolition", "Rarity.Rare"}, basePrice=600, stockRange={min=0, max=2} }, -- Worth: 50.0
    { item="Base.Sledgehammer2",      tags={"Weapon.Melee.HeavyBlunt", "Tool.Demolition", "Rarity.Rare"}, basePrice=600, stockRange={min=0, max=2} },
    { item="Base.SledgehammerForged", tags={"Weapon.Melee.HeavyBlunt", "Tool.Demolition", "Rarity.Legendary"}, basePrice=960, stockRange={min=0, max=1} }, -- Worth: 80.0
    { item="Base.Crowbar",            tags={"Weapon.Melee.Blunt", "Tool.General", "Rarity.Common"},        basePrice=180, stockRange={min=2, max=10} }, -- Worth: 15.0
    { item="Base.CrowbarForged",      tags={"Weapon.Melee.Blunt", "Tool.General", "Rarity.Rare"},          basePrice=360, stockRange={min=0, max=3} }, -- Worth: 30.0
    
    -- Mauls & Heavy Blunts
    { item="Base.BlockMaul",          tags={"Weapon.Melee.HeavyBlunt", "Rarity.Uncommon"},     basePrice=300, stockRange={min=0, max=3} }, -- Worth: 25.0
    { item="Base.RailroadSpikePuller",tags={"Weapon.Melee.HeavyBlunt", "Tool.Industrial", "Rarity.Uncommon"}, basePrice=240, stockRange={min=0, max=2} }, -- Worth: 20.0
    { item="Base.LongMace",           tags={"Weapon.Melee.HeavyBlunt", "Theme.Survival"},      basePrice=180, stockRange={min=0, max=3} }, -- Worth: 15.0
    { item="Base.LongMace_Stone",     tags={"Weapon.Melee.HeavyBlunt", "Theme.Survival"},      basePrice=60,  stockRange={min=1, max=5} }, -- Worth: 5.0
    { item="Base.EngineMaul",         tags={"Weapon.Melee.HeavyBlunt", "Origin.Industrial"},   basePrice=240, stockRange={min=0, max=1} }, -- Worth: 20.0
    { item="Base.ScrapMaul",          tags={"Weapon.Melee.HeavyBlunt", "Quality.Waste"},        basePrice=150, stockRange={min=0, max=3} },
    { item="Base.StoneMaul",          tags={"Weapon.Melee.HeavyBlunt", "Theme.Survival"},      basePrice=72,  stockRange={min=1, max=5} }, -- Worth: 6.0
    
    -- Bucket & Kettle Maces
    { item="Base.BucketMace_Metal",   tags={"Weapon.Melee.HeavyBlunt", "Quality.Waste"}, basePrice=120, stockRange={min=0, max=3} }, -- Worth: 10.0
    { item="Base.BucketMace_Wood",    tags={"Weapon.Melee.HeavyBlunt", "Quality.Waste"}, basePrice=96,  stockRange={min=0, max=3} },
    { item="Base.KettleMace_Metal",   tags={"Weapon.Melee.HeavyBlunt", "Quality.Waste"}, basePrice=144, stockRange={min=0, max=3} },
    { item="Base.KettleMace_Wood",    tags={"Weapon.Melee.HeavyBlunt", "Quality.Waste"}, basePrice=120, stockRange={min=0, max=3} },
    { item="Base.BarBell",            tags={"Weapon.Melee.HeavyBlunt", "Quality.Luxury"}, basePrice=300, stockRange={min=0, max=3} },
    { item="Base.BarBell_Forged",     tags={"Weapon.Melee.HeavyBlunt", "Rarity.Rare"},   basePrice=480, stockRange={min=0, max=1} }, -- Worth: 40.0

    -- ==========================================================
    -- 6. BASEBALL BATS & SPORTS GEAR
    -- ==========================================================
    { item="Base.BaseballBat",                tags={"Weapon.Melee.Blunt", "Rarity.Common"},      basePrice=120, stockRange={min=2, max=10} }, -- Worth: 10.0
    { item="Base.BaseballBat_Crafted",        tags={"Weapon.Melee.Blunt", "Theme.Survival"},    basePrice=96,  stockRange={min=2, max=10} }, -- Worth: 8.0
    { item="Base.BaseballBat_Metal",          tags={"Weapon.Melee.Blunt", "Rarity.Rare"},        basePrice=240, stockRange={min=0, max=3} }, -- Worth: 20.0
    { item="Base.BaseballBat_Nails",          tags={"Weapon.Melee.Blunt", "Theme.Survival"},    basePrice=132, stockRange={min=1, max=5} }, -- Worth: 11.0
    { item="Base.BaseballBat_Spiked",         tags={"Weapon.Melee.Blunt", "Theme.Survival"},    basePrice=144, stockRange={min=1, max=5} }, -- Worth: 12.0
    { item="Base.BaseballBat_Can",            tags={"Weapon.Melee.Blunt", "Quality.Waste"},      basePrice=108, stockRange={min=0, max=4} },
    { item="Base.BaseballBat_ScrapSheet",     tags={"Weapon.Melee.Blunt", "Quality.Waste"},      basePrice=156, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_GardenForkHead", tags={"Weapon.Melee.Blunt", "Theme.Survival"},    basePrice=180, stockRange={min=0, max=3} }, -- Worth: 15.0
    { item="Base.BaseballBat_RakeHead",       tags={"Weapon.Melee.Blunt", "Theme.Survival"},    basePrice=168, stockRange={min=0, max=3} }, -- Worth: 14.0
    { item="Base.BaseballBat_Metal_Bolts",    tags={"Weapon.Melee.Blunt", "Rarity.Rare"},        basePrice=300, stockRange={min=0, max=2} }, -- Worth: 25.0
    { item="Base.BaseballBat_Metal_Sawblade", tags={"Weapon.Melee.Blunt", "Rarity.Rare"},        basePrice=360, stockRange={min=0, max=2} }, -- Worth: 30.0
    
    -- Other Sports
    { item="Base.Golfclub",                   tags={"Weapon.Melee.LongBlunt", "Rarity.Common"},  basePrice=60,  stockRange={min=2, max=10} }, -- Worth: 5.0
    { item="Base.Poolcue",                    tags={"Weapon.Melee.LongBlunt", "Rarity.Common"},  basePrice=24,  stockRange={min=2, max=10} }, -- Worth: 2.0
    { item="Base.FieldHockeyStick",           tags={"Weapon.Melee.LongBlunt", "Rarity.Common"},  basePrice=48,  stockRange={min=2, max=10} }, -- Worth: 4.0
    { item="Base.IceHockeyStick",             tags={"Weapon.Melee.LongBlunt", "Rarity.Common"},  basePrice=48,  stockRange={min=2, max=10} },
    { item="Base.LaCrosseStick",              tags={"Weapon.Melee.LongBlunt", "Rarity.Common"},  basePrice=60,  stockRange={min=1, max=5} },

    -- ==========================================================
    -- 7. GARDENING TOOLS (Weapons)
    -- ==========================================================
    { item="Base.Shovel",             tags={"Weapon.Melee.LongBlunt", "Tool.General", "Rarity.Common"}, basePrice=85, stockRange={min=1, max=4} },
    { item="Base.Shovel2",            tags={"Weapon.Melee.LongBlunt", "Tool.General", "Rarity.Common"}, basePrice=85, stockRange={min=1, max=4} },
    { item="Base.SpadeForged",        tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Rarity.Rare"},    basePrice=120, stockRange={min=0, max=2} },
    { item="Base.SnowShovel",         tags={"Weapon.Melee.LongBlunt", "Tool.General", "Rarity.Common"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.GardenHoe",          tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Rarity.Common"},  basePrice=75, stockRange={min=1, max=3} },
    { item="Base.GardenHoeForged",    tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Rarity.Rare"},    basePrice=110, stockRange={min=0, max=2} },
    { item="Base.Rake",               tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Rarity.Common"},  basePrice=45, stockRange={min=1, max=4} },
    { item="Base.LeafRake",           tags={"Weapon.Melee.LongBlunt", "Tool.Farmer", "Quality.Waste"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.EntrenchingTool",    tags={"Weapon.Melee.ShortBlunt", "Tool.General", "Origin.Militia", "Rarity.Common"},basePrice=75, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponGardenFork", tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.ScrapWeaponSpade",   tags={"Weapon.Melee.LongBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=80, stockRange={min=0, max=2} },
    
    -- Weaponized Tool Heads
    { item="Base.GardenForkHead",     tags={"Resource.Material.Metal", "Tool.Farmer", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=5} },
    { item="Base.SpadeHead",          tags={"Resource.Material.Metal", "Tool.Farmer", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=5} },

    -- ==========================================================
    -- 8. CUDGELS (Short Blunts)
    -- ==========================================================
    { item="Base.Cudgel_ScrapSheet",      tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=125, stockRange={min=0, max=2} },
    { item="Base.Cudgel_GardenForkHead",  tags={"Weapon.Melee.ShortBlunt", "Tool.Farmer", "Rarity.Uncommon"},   basePrice=120, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Nails",           tags={"Weapon.Melee.ShortBlunt", "Theme.Survival", "Quality.Waste"},   basePrice=75, stockRange={min=1, max=4} },
    { item="Base.Cudgel_Railspike",       tags={"Weapon.Melee.ShortBlunt", "Origin.Civ", "Quality.Waste"}, basePrice=115, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Spike",           tags={"Weapon.Melee.ShortBlunt", "Theme.Survival", "Quality.Waste"},   basePrice=85, stockRange={min=1, max=3} },

    -- ==========================================================
    -- 9. SPEARS
    -- ==========================================================
    -- Garden Tools as Spears
    { item="Base.GardenFork",             tags={"Weapon.Melee.Spear", "Tool.Farmer", "Rarity.Common"}, basePrice=110, stockRange={min=1, max=3} },
    { item="Base.GardenFork_Forged",      tags={"Weapon.Melee.Spear", "Tool.Farmer", "Rarity.Rare"},   basePrice=180, stockRange={min=0, max=2} },
    
    -- Attachment Spears
    { item="Base.SpearLong",              tags={"Weapon.Melee.Spear", "Rarity.Rare"},          basePrice=125, stockRange={min=0, max=2} },
    { item="Base.SpearHuntingKnife",      tags={"Weapon.Melee.Spear", "Theme.Combat", "Rarity.Uncommon"}, basePrice=160, stockRange={min=0, max=1} },
    { item="Base.SpearFightingKnife",     tags={"Weapon.Melee.Spear", "Origin.Militia", "Rarity.Rare"},    basePrice=180, stockRange={min=0, max=1} },
    { item="Base.SpearLargeKnife",        tags={"Weapon.Melee.Spear", "Theme.Combat", "Rarity.Uncommon"}, basePrice=150, stockRange={min=0, max=2} },
    { item="Base.SpearShort",             tags={"Weapon.Melee.Spear", "Origin.Civ", "Quality.Waste"},  basePrice=95,  stockRange={min=1, max=3} },
    { item="Base.SpearStone",             tags={"Weapon.Melee.Spear", "Theme.Survival", "Origin.Nomad"}, basePrice=65, stockRange={min=1, max=4} },
    { item="Base.SpearKnife",             tags={"Weapon.Melee.Spear", "Origin.Civ", "Quality.Waste"},  basePrice=85,  stockRange={min=1, max=4} },
    { item="Base.SpearScrewdriver",       tags={"Weapon.Melee.Spear", "Origin.Civ", "Quality.Waste"},  basePrice=75,  stockRange={min=1, max=3} },
    
    -- Basic Spears
    { item="Base.SpearCrafted",           tags={"Weapon.Melee.Spear", "Rarity.Common"},        basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.SpearCraftedFireHardened", tags={"Weapon.Melee.Spear", "Rarity.Common"},      basePrice=25,  stockRange={min=1, max=5} },
    { item="Base.ClosedUmbrellaBlack",    tags={"Weapon.Melee.Spear", "Quality.Waste"},          basePrice=10,  stockRange={min=1, max=3} },

    -- ==========================================================
    -- 10. FIREARMS
    -- ==========================================================
    -- Handguns
    { item="Base.Pistol",                 tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"},   basePrice=600, stockRange={min=0, max=3} }, -- Scaling 500-1000
    { item="Base.Pistol2",                tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=750, stockRange={min=0, max=2} },
    { item="Base.Pistol3",                tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Rare"},   basePrice=950, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short",         tags={"Weapon.Ranged.Firearm", "Rarity.Common"},                  basePrice=450, stockRange={min=1, max=3} },
    { item="Base.Revolver",               tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=650, stockRange={min=0, max=2} },
    { item="Base.Revolver_Long",          tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Rare"},    basePrice=850, stockRange={min=0, max=1} },
    
    -- Shotguns
    { item="Base.Shotgun",                tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=900, stockRange={min=0, max=2} },
    { item="Base.DoubleBarrelShotgun",    tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Uncommon"}, basePrice=850, stockRange={min=0, max=2} },
    { item="Base.ShotgunSawnoff",         tags={"Weapon.Ranged.Firearm", "Theme.Survival", "Rarity.Rare"},    basePrice=750, stockRange={min=0, max=1} },
    
    -- Rifles
    { item="Base.AssaultRifle",           tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Legendary"},basePrice=2500, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2",          tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Rare"},   basePrice=1800, stockRange={min=0, max=1} },
    { item="Base.HuntingRifle",           tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Uncommon"},  basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.VarmintRifle",           tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Common"},    basePrice=800,  stockRange={min=1, max=3} },
    
    -- Novelty
    { item="Base.Revolver_CapGun",        tags={"Misc.General", "Theme.Leisure", "Rarity.Common"}, basePrice=10, stockRange={min=1, max=2} },

    -- ==========================================================
    -- 11. WEAPON PARTS & ATTACHMENTS
    -- ==========================================================
    { item="Base.x8Scope",            tags={"Weapon.Part.Sight", "Origin.Militia", "Rarity.Rare"},    basePrice=650, stockRange={min=0, max=1} },
    { item="Base.x4Scope",            tags={"Weapon.Part.Sight", "Theme.Hunting", "Rarity.Uncommon"},  basePrice=380, stockRange={min=0, max=2} },
    { item="Base.x2Scope",            tags={"Weapon.Part.Sight", "Rarity.Common"},                  basePrice=210, stockRange={min=1, max=3} },
    { item="Base.RedDot",             tags={"Weapon.Part.Sight", "Origin.Militia", "Rarity.Uncommon"}, basePrice=320, stockRange={min=1, max=2} },
    { item="Base.Laser",              tags={"Weapon.Part.Utility", "Origin.Militia", "Rarity.Rare"},   basePrice=450, stockRange={min=0, max=1} },
    { item="Base.GunLight",           tags={"Weapon.Part.Utility", "Origin.Police", "Rarity.Uncommon"}, basePrice=180, stockRange={min=1, max=4} },
    { item="Base.AmmoStraps",         tags={"Weapon.Part.Utility", "Rarity.Common"},                  basePrice=120, stockRange={min=1, max=3} },
    { item="Base.RecoilPad",          tags={"Weapon.Part.Utility", "Rarity.Common"},                  basePrice=110, stockRange={min=1, max=3} },
    { item="Base.ChokeTubeFull",      tags={"Weapon.Part.Barrel", "Theme.Hunting", "Rarity.Uncommon"}, basePrice=180, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 12. EXPLOSIVES & TRAPS
    -- ==========================================================
    { item="Base.Molotov",            tags={"Weapon.Ranged.Explosive", "Theme.Survival", "Rarity.Common"},    basePrice=180, stockRange={min=1, max=4} },
    { item="Base.PipeBomb",           tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Uncommon"}, basePrice=280, stockRange={min=1, max=3} },
    { item="Base.Aerosolbomb",        tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Uncommon"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.FlameTrap",          tags={"Weapon.Ranged.Explosive", "Theme.Survival", "Rarity.Rare"},      basePrice=350, stockRange={min=0, max=2} },
    { item="Base.SmokeBomb",          tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Common"},    basePrice=110, stockRange={min=1, max=5} },
    { item="Base.NoiseTrap",          tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Common"},   basePrice=85,  stockRange={min=2, max=6} },
    { item="Base.PipeBombRemote",     tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Rare"},     basePrice=450, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV3",tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Legendary"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.NoiseTrapSensorV3",  tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Rare"},      basePrice=350, stockRange={min=0, max=1} },
    { item="Base.Firecracker",        tags={"Misc.General", "Theme.Leisure"}, stockRange={min=2, max=10}, basePrice=35 },

    -- ==========================================================
    -- 13. MUSICAL & IMPROVISED JUNK
    -- ==========================================================
    { item="Base.GuitarAcoustic",     tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Uncommon"}, basePrice=150, stockRange={min=0, max=2} },
    { item="Base.GuitarElectric",     tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"},     basePrice=250, stockRange={min=0, max=1} },
    { item="Base.GuitarElectricBass", tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"},     basePrice=260, stockRange={min=0, max=1} },
    { item="Base.Banjo",              tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Uncommon"}, basePrice=130, stockRange={min=0, max=2} },
    { item="Base.Saxophone",          tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"},     basePrice=300, stockRange={min=0, max=1} },
    { item="Base.Trumpet",            tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Rare"},     basePrice=220, stockRange={min=0, max=1} },
    { item="Base.Keytar",             tags={"Weapon.Melee.Blunt", "Literature.Music.Instrument", "Rarity.Legendary"},basePrice=450, stockRange={min=0, max=1} },
    
    { item="Base.Plank",              tags={"Resource.Material.Wood", "Rarity.Common"}, basePrice=15,  stockRange={min=5, max=20} },
    { item="Base.Plank_Nails",        tags={"Weapon.Melee.LongBlunt", "Theme.Survival", "Quality.Waste"}, basePrice=25, stockRange={min=2, max=10} },
    { item="Base.Plank_Saw",          tags={"Weapon.Melee.LongBlunt", "Theme.Survival", "Quality.Waste"}, basePrice=35, stockRange={min=1, max=5} },
    { item="Base.LongStick",          tags={"Weapon.Melee.LongBlunt", "Origin.Nomad"}, basePrice=12, stockRange={min=2, max=10} },
    { item="Base.LargeBranch",        tags={"Weapon.Melee.LongBlunt", "Origin.Nomad"}, basePrice=25, stockRange={min=2, max=8} },
    { item="Base.Broom",              tags={"Weapon.Melee.LongBlunt", "Theme.Survival", "Rarity.Common"}, basePrice=25, stockRange={min=1, max=5} },
    { item="Base.Mop",                tags={"Weapon.Melee.LongBlunt", "Theme.Survival", "Rarity.Common"}, basePrice=30, stockRange={min=1, max=5} },
    { item="Base.Stone2",             tags={"Resource.Material.Raw", "Origin.Nomad"},  basePrice=5,  stockRange={min=5, max=15} },
    { item="Base.FlintNodule",        tags={"Resource.Material.Raw", "Theme.Survival"},      basePrice=15, stockRange={min=2, max=8} },
    { item="Base.Pen",                tags={"Misc.Scholastic", "Rarity.Common"},        basePrice=2,  stockRange={min=5, max=10} },
    { item="Base.Pencil",             tags={"Misc.Scholastic", "Rarity.Common"},        basePrice=2,  stockRange={min=5, max=10} },
    { item="Base.CompassGeometry",    tags={"Misc.Scholastic", "Rarity.Uncommon"},      basePrice=15, stockRange={min=1, max=3} },

})

print("[DynamicTrading] Weapons Registry Complete \n.")
