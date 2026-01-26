require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- ==========================================================
    -- 1. AXES (Standard & Heavy)
    -- ==========================================================
    { item="Base.Axe",                tags={"Weapon", "Tool", "Common"},      basePrice=150, stockRange={min=1, max=3} },
    { item="Base.Axe_Old",            tags={"Weapon", "Tool", "Junk"},        basePrice=110, stockRange={min=1, max=2} },
    { item="Base.WoodAxe",            tags={"Weapon", "Tool", "Heavy", "Carpenter"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.WoodAxeForged",      tags={"Weapon", "Tool", "Heavy", "Rare"},     basePrice=220, stockRange={min=0, max=1} },
    { item="Base.PickAxe",            tags={"Weapon", "Tool", "Heavy", "Mechanic"}, basePrice=160, stockRange={min=0, max=2} },
    { item="Base.PickAxeForged",      tags={"Weapon", "Tool", "Heavy", "Rare"},     basePrice=190, stockRange={min=0, max=1} },

    -- ==========================================================
    -- 2. AXES (Small / One-Handed)
    -- ==========================================================
    { item="Base.HandAxe",            tags={"Weapon", "Tool", "Common"},      basePrice=75,  stockRange={min=1, max=4} },
    { item="Base.HandAxe_Old",        tags={"Weapon", "Tool", "Junk"},        basePrice=55,  stockRange={min=1, max=3} },
    { item="Base.HandAxeForged",      tags={"Weapon", "Tool", "Rare"},        basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.Hatchet",            tags={"Weapon", "Tool", "Common"},      basePrice=70,  stockRange={min=1, max=4} },
    { item="Base.IceAxe",             tags={"Weapon", "Tool", "Rare"},        basePrice=100, stockRange={min=0, max=1} },
    { item="Base.MeatCleaver",        tags={"Weapon", "Butcher", "Common"},   basePrice=45,  stockRange={min=1, max=3} },
    { item="Base.MeatCleaverForged",  tags={"Weapon", "Butcher", "Rare"},     basePrice=60,  stockRange={min=0, max=2} },
    { item="Base.HandScythe",         tags={"Weapon", "Farmer", "Common"},    basePrice=50,  stockRange={min=1, max=3} },
    { item="Base.HandScytheForged",   tags={"Weapon", "Farmer", "Rare"},      basePrice=65,  stockRange={min=0, max=2} },

    -- ==========================================================
    -- 3. PRIMITIVE & BONE WEAPONS
    -- ==========================================================
    { item="Base.Hatchet_Bone",         tags={"Weapon", "Survivalist", "Common"}, basePrice=30, stockRange={min=1, max=3} },
    { item="Base.JawboneBovide_Axe",    tags={"Weapon", "Survivalist", "Common"}, basePrice=35, stockRange={min=1, max=3} },
    { item="Base.Saw_Flint",            tags={"Weapon", "Survivalist", "Common"}, basePrice=20, stockRange={min=1, max=4} },
    { item="Base.PrimitiveScythe",      tags={"Weapon", "Farmer", "Survivalist"}, basePrice=25, stockRange={min=1, max=3} },
    { item="Base.LargeBoneClub_Spiked", tags={"Weapon", "Survivalist", "Common"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Bone",          tags={"Weapon", "Survivalist", "Common"}, basePrice=80, stockRange={min=1, max=3} },
    { item="Base.Fleshing_Tool_Bone",   tags={"Tool", "Survivalist", "Common"},   basePrice=15, stockRange={min=2, max=6} },

    -- ==========================================================
    -- 4. SCRAP WEAPONS (The "Sawblade" & "RailSpike" Series)
    -- ==========================================================
    -- Axes & Cleavers
    { item="Base.Axe_ScrapCleaver",       tags={"Weapon", "Scavenger", "Junk"}, basePrice=55, stockRange={min=1, max=3} },
    { item="Base.Axe_Sawblade",           tags={"Weapon", "Scavenger", "Junk"}, basePrice=85, stockRange={min=0, max=2} },
    { item="Base.Axe_Sawblade_Hatchet",   tags={"Weapon", "Scavenger", "Junk"}, basePrice=65, stockRange={min=1, max=3} },
    { item="Base.MeatCleaver_Scrap",      tags={"Weapon", "Scavenger", "Junk"}, basePrice=25, stockRange={min=1, max=4} },
    
    -- Blunts (Cudgels/Bats/Pipes)
    { item="Base.TableLeg_Sawblade",         tags={"Weapon", "Scavenger", "Junk"}, basePrice=40, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RailSpike",     tags={"Weapon", "Scavenger", "Junk"}, basePrice=65, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Sawblade",      tags={"Weapon", "Scavenger", "Junk"}, basePrice=75, stockRange={min=0, max=2} },
    { item="Base.ShortBat_RailSpike",        tags={"Weapon", "Scavenger", "Junk"}, basePrice=40, stockRange={min=1, max=3} },
    { item="Base.ShortBat_Sawblade",         tags={"Weapon", "Scavenger", "Junk"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.FieldHockeyStick_Sawblade", tags={"Weapon", "Scavenger", "Junk"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.MetalPipe_Railspike",       tags={"Weapon", "Scavenger", "Junk"}, basePrice=45, stockRange={min=0, max=2} },
    { item="Base.TreeBranch_Railspike",      tags={"Weapon", "Survivalist", "Junk"},basePrice=20, stockRange={min=1, max=4} },
    
    -- Long Handles
    { item="Base.LongHandle_Railspike",   tags={"Weapon", "Scavenger", "Junk"}, basePrice=35, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Sawblade",    tags={"Weapon", "Scavenger", "Junk"}, basePrice=40, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Can",         tags={"Weapon", "Scavenger", "Junk"}, basePrice=45, stockRange={min=1, max=5} },
    { item="Base.LongHandle_Brake",       tags={"Weapon", "Scavenger", "Junk"}, basePrice=70, stockRange={min=0, max=3} },
    { item="Base.LongHandle_Nails",       tags={"Weapon", "Survivalist", "Junk"},basePrice=35, stockRange={min=1, max=5} },
    { item="Base.LongHandle_RakeHead",    tags={"Weapon", "Farmer", "Junk"},     basePrice=55, stockRange={min=1, max=4} },

    -- Heavy Scrap (Brake Discs & Mauls)
    { item="Base.ScrapWeapon_Brake",      tags={"Weapon", "Scavenger", "Heavy"}, basePrice=80, stockRange={min=0, max=2} },
    { item="Base.Cudgel_Brake",           tags={"Weapon", "Scavenger", "Heavy"}, basePrice=95, stockRange={min=0, max=1} },
    { item="Base.Cudgel_Sawblade",        tags={"Weapon", "Scavenger", "Heavy"}, basePrice=90, stockRange={min=0, max=1} },
    { item="Base.Cudgel_SpadeHead",       tags={"Weapon", "Scavenger", "Heavy"}, basePrice=85, stockRange={min=0, max=1} },
    { item="Base.Plank_Brake",            tags={"Weapon", "Scavenger", "Junk"}, basePrice=50, stockRange={min=0, max=3} },
    { item="Base.Plank_Sawblade",         tags={"Weapon", "Scavenger", "Junk"}, basePrice=45, stockRange={min=0, max=3} },

    -- ==========================================================
    -- 5. HEAVY TOOLS & BLUNTS (Sledgehammers & Crowbars)
    -- ==========================================================
    { item="Base.Sledgehammer",       tags={"Weapon", "Tool", "Heavy", "Legendary"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2",      tags={"Weapon", "Tool", "Heavy", "Legendary"}, basePrice=500, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", tags={"Weapon", "Tool", "Heavy", "Legendary"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.Crowbar",            tags={"Weapon", "Tool", "Common"},        basePrice=150, stockRange={min=1, max=3} },
    { item="Base.CrowbarForged",      tags={"Weapon", "Tool", "Rare"},          basePrice=200, stockRange={min=0, max=1} },
    { item="Base.PickAxe",            tags={"Weapon", "Tool", "Heavy", "Rare"}, basePrice=160, stockRange={min=0, max=2} },
    
    -- Mauls & Heavy Blunts
    { item="Base.BlockMaul",          tags={"Weapon", "Heavy", "Uncommon"},     basePrice=210, stockRange={min=0, max=2} },
    { item="Base.RailroadSpikePuller",tags={"Weapon", "Tool", "Heavy"},         basePrice=190, stockRange={min=0, max=1} },
    { item="Base.LongMace",           tags={"Weapon", "Heavy", "Survivalist"},  basePrice=140, stockRange={min=0, max=2} },
    { item="Base.LongMace_Stone",     tags={"Weapon", "Heavy", "Survivalist"},  basePrice=60,  stockRange={min=1, max=3} },
    { item="Base.EngineMaul",         tags={"Weapon", "Heavy", "Mechanic"},     basePrice=175, stockRange={min=0, max=1} },
    { item="Base.ScrapMaul",          tags={"Weapon", "Heavy", "Scavenger"},    basePrice=150, stockRange={min=0, max=2} },
    { item="Base.StoneMaul",          tags={"Weapon", "Heavy", "Survivalist"},  basePrice=70,  stockRange={min=1, max=3} },
    
    -- Bucket & Kettle Maces
    { item="Base.BucketMace_Metal",   tags={"Weapon", "Heavy", "Scavenger"},    basePrice=115, stockRange={min=0, max=2} },
    { item="Base.BucketMace_Wood",    tags={"Weapon", "Heavy", "Scavenger"},    basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.KettleMace_Metal",   tags={"Weapon", "Heavy", "Scavenger"},    basePrice=130, stockRange={min=0, max=2} },
    { item="Base.KettleMace_Wood",    tags={"Weapon", "Heavy", "Scavenger"},    basePrice=110, stockRange={min=0, max=2} },
    { item="Base.BarBell",            tags={"Weapon", "Heavy", "Junk"},         basePrice=180, stockRange={min=0, max=2} },
    { item="Base.BarBell_Forged",     tags={"Weapon", "Heavy", "Rare"},         basePrice=250, stockRange={min=0, max=1} },

    -- ==========================================================
    -- 6. BASEBALL BATS & SPORTS GEAR
    -- ==========================================================
    { item="Base.BaseballBat",                tags={"Weapon", "General", "Common"},      basePrice=50,  stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Crafted",        tags={"Weapon", "General", "Common"},      basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.BaseballBat_Metal",          tags={"Weapon", "General", "Rare"},        basePrice=120, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Nails",          tags={"Weapon", "Survivalist", "Common"},  basePrice=60,  stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Spiked",         tags={"Weapon", "Survivalist", "Common"},  basePrice=70,  stockRange={min=1, max=3} },
    { item="Base.BaseballBat_Can",            tags={"Weapon", "Scavenger", "Junk"},      basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.BaseballBat_ScrapSheet",     tags={"Weapon", "Scavenger", "Junk"},      basePrice=100, stockRange={min=0, max=2} },
    { item="Base.BaseballBat_GardenForkHead", tags={"Weapon", "Farmer", "Uncommon"},     basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.BaseballBat_RakeHead",       tags={"Weapon", "Farmer", "Uncommon"},     basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.BaseballBat_Metal_Bolts",    tags={"Weapon", "Scavenger", "Rare"},      basePrice=140, stockRange={min=0, max=1} },
    { item="Base.BaseballBat_Metal_Sawblade", tags={"Weapon", "Scavenger", "Rare"},      basePrice=160, stockRange={min=0, max=1} },
    
    -- Other Sports
    { item="Base.Golfclub",                   tags={"Weapon", "Junk", "Common"},         basePrice=35,  stockRange={min=1, max=4} },
    { item="Base.Poolcue",                    tags={"Weapon", "Junk", "Common"},         basePrice=15,  stockRange={min=1, max=5} },
    { item="Base.FieldHockeyStick",           tags={"Weapon", "General", "Common"},      basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.FieldHockeyStick_Nails",     tags={"Weapon", "Survivalist", "Common"},  basePrice=35,  stockRange={min=1, max=3} },
    { item="Base.IceHockeyStick",             tags={"Weapon", "General", "Common"},      basePrice=25,  stockRange={min=1, max=4} },
    { item="Base.IceHockeyStick_BarbedWire",  tags={"Weapon", "Survivalist", "Common"},  basePrice=45,  stockRange={min=0, max=2} },
    { item="Base.LaCrosseStick",              tags={"Weapon", "General", "Common"},      basePrice=30,  stockRange={min=1, max=3} },

    -- ==========================================================
    -- 7. GARDENING TOOLS (Weapons)
    -- ==========================================================
    { item="Base.Shovel",             tags={"Weapon", "Tool", "Farmer", "Common"},  basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Shovel2",            tags={"Weapon", "Tool", "Farmer", "Common"},  basePrice=65, stockRange={min=1, max=4} },
    { item="Base.SpadeForged",        tags={"Weapon", "Tool", "Farmer", "Rare"},    basePrice=85, stockRange={min=0, max=2} },
    { item="Base.SnowShovel",         tags={"Weapon", "Tool", "General", "Common"}, basePrice=45, stockRange={min=1, max=3} },
    { item="Base.GardenHoe",          tags={"Weapon", "Tool", "Farmer", "Common"},  basePrice=55, stockRange={min=1, max=3} },
    { item="Base.GardenHoeForged",    tags={"Weapon", "Tool", "Farmer", "Rare"},    basePrice=75, stockRange={min=0, max=2} },
    { item="Base.Rake",               tags={"Weapon", "Tool", "Farmer", "Common"},  basePrice=30, stockRange={min=1, max=4} },
    { item="Base.LeafRake",           tags={"Weapon", "Tool", "Farmer", "Common"},  basePrice=20, stockRange={min=1, max=4} },
    { item="Base.EntrenchingTool",    tags={"Weapon", "Tool", "Military", "Common"},basePrice=55, stockRange={min=1, max=3} },
    { item="Base.ScrapWeaponGardenFork", tags={"Weapon", "Scavenger", "Junk"},       basePrice=70, stockRange={min=0, max=2} },
    { item="Base.ScrapWeaponSpade",   tags={"Weapon", "Scavenger", "Junk"},          basePrice=65, stockRange={min=0, max=2} },
    
    -- Weaponized Tool Heads
    { item="Base.GardenForkHead",     tags={"Weapon", "Material", "Farmer"}, basePrice=40, stockRange={min=1, max=5} },
    { item="Base.SpadeHead",          tags={"Weapon", "Material", "Farmer"}, basePrice=40, stockRange={min=1, max=5} },

    -- ==========================================================
    -- 8. CUDGELS (Short Blunts)
    -- ==========================================================
    { item="Base.Cudgel_ScrapSheet",      tags={"Weapon", "Scavenger", "Junk"}, basePrice=95, stockRange={min=0, max=2} },
    { item="Base.Cudgel_GardenForkHead",  tags={"Weapon", "Farmer", "Uncommon"}, basePrice=90, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Nails",           tags={"Weapon", "Survivalist", "Junk"},basePrice=65, stockRange={min=1, max=4} },
    { item="Base.Cudgel_Railspike",       tags={"Weapon", "Scavenger", "Junk"},  basePrice=85, stockRange={min=1, max=3} },
    { item="Base.Cudgel_Spike",           tags={"Weapon", "Survivalist", "Junk"},basePrice=75, stockRange={min=1, max=3} },

    -- ==========================================================
    -- 9. SPEARS
    -- ==========================================================
    -- Garden Tools as Spears
    { item="Base.GardenFork",             tags={"Weapon", "Spear", "Farmer"},        basePrice=85,  stockRange={min=1, max=3} },
    { item="Base.GardenFork_Forged",      tags={"Weapon", "Spear", "Farmer", "Rare"},basePrice=110, stockRange={min=0, max=2} },
    
    -- Attachment Spears
    { item="Base.SpearLong",              tags={"Weapon", "Spear", "Rare"},          basePrice=95,  stockRange={min=0, max=2} },
    { item="Base.SpearHuntingKnife",      tags={"Weapon", "Spear", "Survivalist"},   basePrice=130, stockRange={min=0, max=1} },
    { item="Base.SpearFightingKnife",     tags={"Weapon", "Spear", "Military"},      basePrice=140, stockRange={min=0, max=1} },
    { item="Base.SpearLargeKnife",        tags={"Weapon", "Spear", "Survivalist"},   basePrice=120, stockRange={min=0, max=2} },
    { item="Base.SpearShort",             tags={"Weapon", "Spear", "Scavenger"},     basePrice=75,  stockRange={min=1, max=3} },
    { item="Base.SpearStone",             tags={"Weapon", "Spear", "Survivalist"},   basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.SpearKnife",             tags={"Weapon", "Spear", "Scavenger"},     basePrice=60,  stockRange={min=1, max=4} },
    { item="Base.SpearScrewdriver",       tags={"Weapon", "Spear", "Scavenger"},     basePrice=55,  stockRange={min=1, max=3} },
    
    -- Basic Spears
    { item="Base.SpearCrafted",           tags={"Weapon", "Spear", "Common"},        basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.SpearCraftedFireHardened", tags={"Weapon", "Spear", "Common"},      basePrice=25,  stockRange={min=1, max=5} },
    { item="Base.ClosedUmbrellaBlack",    tags={"Weapon", "Spear", "Junk"},          basePrice=10,  stockRange={min=1, max=3} },

    -- ==========================================================
    -- 10. FIREARMS
    -- ==========================================================
    -- Handguns
    { item="Base.Pistol",                 tags={"Weapon", "Gun", "Police", "Common"},   basePrice=300, stockRange={min=1, max=3} },
    { item="Base.Pistol2",                tags={"Weapon", "Gun", "Police", "Uncommon"}, basePrice=350, stockRange={min=1, max=2} },
    { item="Base.Pistol3",                tags={"Weapon", "Gun", "Military", "Rare"},   basePrice=650, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short",         tags={"Weapon", "Gun", "General", "Common"},  basePrice=200, stockRange={min=1, max=3} },
    { item="Base.Revolver",               tags={"Weapon", "Gun", "Police", "Uncommon"}, basePrice=320, stockRange={min=1, max=2} },
    { item="Base.Revolver_Long",          tags={"Weapon", "Gun", "Hunting", "Rare"},    basePrice=550, stockRange={min=0, max=1} },
    
    -- Shotguns
    { item="Base.Shotgun",                tags={"Weapon", "Gun", "Police", "Common"},   basePrice=500, stockRange={min=1, max=2} },
    { item="Base.DoubleBarrelShotgun",    tags={"Weapon", "Gun", "Hunting", "Uncommon"},basePrice=450, stockRange={min=1, max=2} },
    { item="Base.ShotgunSawnoff",         tags={"Weapon", "Gun", "Survivalist", "Rare"},basePrice=400, stockRange={min=0, max=1} },
    
    -- Rifles
    { item="Base.AssaultRifle",           tags={"Weapon", "Gun", "Military", "Legendary"},basePrice=1500, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2",          tags={"Weapon", "Gun", "Military", "Rare"},   basePrice=850, stockRange={min=0, max=1} },
    { item="Base.HuntingRifle",           tags={"Weapon", "Gun", "Hunting", "Uncommon"}, basePrice=700, stockRange={min=1, max=2} },
    { item="Base.VarmintRifle",           tags={"Weapon", "Gun", "Hunting", "Common"},   basePrice=450, stockRange={min=1, max=3} },
    
    -- Novelty
    { item="Base.Revolver_CapGun",        tags={"Junk", "Toy"}, basePrice=20, stockRange={min=1, max=2} },

    -- ==========================================================
    -- 11. WEAPON PARTS & ATTACHMENTS
    -- ==========================================================
    { item="Base.x8Scope",            tags={"WeaponPart", "Military", "Rare"},    basePrice=400, stockRange={min=0, max=1} },
    { item="Base.x4Scope",            tags={"WeaponPart", "Hunting", "Uncommon"}, basePrice=250, stockRange={min=0, max=2} },
    { item="Base.x2Scope",            tags={"WeaponPart", "General", "Common"},   basePrice=150, stockRange={min=1, max=3} },
    { item="Base.RedDot",             tags={"WeaponPart", "Military", "Uncommon"},basePrice=220, stockRange={min=1, max=2} },
    { item="Base.Laser",              tags={"WeaponPart", "Military", "Rare"},    basePrice=350, stockRange={min=0, max=1} },
    { item="Base.GunLight",           tags={"WeaponPart", "Police", "Uncommon"},  basePrice=120, stockRange={min=1, max=4} },
    { item="Base.AmmoStraps",         tags={"WeaponPart", "Gunrunner", "Uncommon"},basePrice=100, stockRange={min=1, max=3} },
    { item="Base.RecoilPad",          tags={"WeaponPart", "Gunrunner", "Uncommon"},basePrice=90,  stockRange={min=1, max=3} },
    { item="Base.ChokeTubeFull",      tags={"WeaponPart", "Hunting", "Uncommon"}, basePrice=130, stockRange={min=0, max=2} },

    -- ==========================================================
    -- 12. EXPLOSIVES & TRAPS
    -- ==========================================================
    { item="Base.Molotov",            tags={"Weapon", "Survivalist", "Common"},    basePrice=120, stockRange={min=1, max=4} },
    { item="Base.PipeBomb",           tags={"Weapon", "Military", "Uncommon"},     basePrice=180, stockRange={min=1, max=3} },
    { item="Base.Aerosolbomb",        tags={"Weapon", "Scavenger", "Uncommon"},    basePrice=110, stockRange={min=1, max=3} },
    { item="Base.FlameTrap",          tags={"Weapon", "Survivalist", "Rare"},      basePrice=140, stockRange={min=1, max=3} },
    { item="Base.SmokeBomb",          tags={"Weapon", "Military", "Common"},       basePrice=70,  stockRange={min=1, max=5} },
    { item="Base.NoiseTrap",          tags={"Weapon", "Electronics", "Common"},    basePrice=50,  stockRange={min=2, max=6} },
    { item="Base.PipeBombRemote",     tags={"Weapon", "Military", "Rare"},         basePrice=300, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV3",tags={"Weapon", "Scavenger", "Rare"},        basePrice=250, stockRange={min=0, max=1} },
    { item="Base.NoiseTrapSensorV3",  tags={"Weapon", "Electronics", "Uncommon"},  basePrice=150, stockRange={min=0, max=2} },
    { item="Base.Firecracker",        tags={"Junk", "Distraction"},                basePrice=20,  stockRange={min=2, max=10} },

    -- ==========================================================
    -- 13. MUSICAL & IMPROVISED JUNK
    -- ==========================================================
    { item="Base.GuitarAcoustic",     tags={"Weapon", "Junk"}, basePrice=80,  stockRange={min=0, max=2} },
    { item="Base.GuitarElectric",     tags={"Weapon", "Junk"}, basePrice=120, stockRange={min=0, max=1} },
    { item="Base.GuitarElectricBass", tags={"Weapon", "Junk"}, basePrice=130, stockRange={min=0, max=1} },
    { item="Base.Banjo",              tags={"Weapon", "Junk"}, basePrice=70,  stockRange={min=0, max=2} },
    { item="Base.Saxophone",          tags={"Weapon", "Junk"}, basePrice=150, stockRange={min=0, max=1} },
    { item="Base.Trumpet",            tags={"Weapon", "Junk"}, basePrice=100, stockRange={min=0, max=1} },
    { item="Base.Keytar",             tags={"Weapon", "Junk"}, basePrice=200, stockRange={min=0, max=1} },
    
    { item="Base.Plank",              tags={"Material", "Common"}, basePrice=5,  stockRange={min=5, max=20} },
    { item="Base.Plank_Nails",        tags={"Weapon", "Junk"},     basePrice=12, stockRange={min=2, max=10} },
    { item="Base.Plank_Saw",          tags={"Weapon", "Junk"},     basePrice=15, stockRange={min=1, max=5} },
    { item="Base.LongStick",          tags={"Weapon", "Junk"},     basePrice=8,  stockRange={min=2, max=10} },
    { item="Base.LargeBranch",        tags={"Weapon", "Junk"},     basePrice=15, stockRange={min=2, max=8} },
    { item="Base.Broom",              tags={"Tool", "Junk"},       basePrice=10, stockRange={min=1, max=5} },
    { item="Base.Mop",                tags={"Tool", "Junk"},       basePrice=12, stockRange={min=1, max=5} },
    { item="Base.Stone2",             tags={"Material", "Junk"},   basePrice=2,  stockRange={min=5, max=15} },
    { item="Base.FlintNodule",        tags={"Material", "Junk"},   basePrice=5,  stockRange={min=2, max=8} },
    { item="Base.Pen",                tags={"Tool", "Junk"},       basePrice=1,  stockRange={min=5, max=10} },
    { item="Base.Pencil",             tags={"Tool", "Junk"},       basePrice=1,  stockRange={min=5, max=10} },
    { item="Base.CompassGeometry",    tags={"Tool", "Junk"},       basePrice=8,  stockRange={min=1, max=3} },

})

print("[DynamicTrading] Weapons Registry Complete.")
