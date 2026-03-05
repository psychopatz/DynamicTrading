require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. BACKPACKS (The Essentials)
-- =============================================================================
-- MILITARY GRADE (Best Weight Reduction/Capacity)
{ item="Base.Bag_ALICEpack",                basePrice=800, tags={"Container.Backpack.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICEpack_Army",           basePrice=800, tags={"Container.Backpack.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICEpack_DesertCamo",     basePrice=800, tags={"Container.Backpack.Military", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_SurvivorBag",              basePrice=650, tags={"Container.Backpack.Survival", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_Military",                 basePrice=350, tags={"Container.Backpack.Military", "Rarity.Uncommon"}, stockRange={min=1, max=2} },

-- CRAFTED FRAMEPACKS (High Capacity)
{ item="Base.Bag_CraftedFramepack_Large3",  basePrice=180, tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=0, max=1} }, -- 35 Cap
{ item="Base.Bag_CraftedFramepack_Large2",  basePrice=120, tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=0, max=2} }, -- 25 Cap
{ item="Base.Bag_CraftedFramepack_Large",   basePrice=80,  tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=1, max=3} },
{ item="Base.Bag_TarpFramepack_Large",      basePrice=70,  tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=1, max=3} },
{ item="Base.Bag_CraftedFramepack_Small",   basePrice=40,  tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=1, max=5} },
{ item="Base.Bag_TarpFramepack_Small",      basePrice=35,  tags={"Container.Backpack.Survival", "Quality.Standard"}, stockRange={min=1, max=5} },

-- HIKING BAGS (High Civilian Tier)
{ item="Base.Bag_BigHikingBag",             basePrice=450, tags={"Container.Backpack.Civ", "Rarity.Rare"}, stockRange={min=1, max=2} },
{ item="Base.Bag_BigHikingBag_Travel",      basePrice=450, tags={"Container.Backpack.Civ", "Rarity.Rare"}, stockRange={min=1, max=2} },
{ item="Base.Bag_NormalHikingBag",          basePrice=300, tags={"Container.Backpack.Civ", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_HikingBag_Travel",         basePrice=300, tags={"Container.Backpack.Civ", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- DUFFEL BAGS (Standard Tier)
{ item="Base.Bag_DuffelBag",                basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_DuffelBagTINT",            basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_BaseballBag",              basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_BreakdownBag",             basePrice=220, tags={"Container.Backpack.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.Bag_BurglarBag",               basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=2} },
{ item="Base.Bag_FoodCanned",               basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=2} },
{ item="Base.Bag_FoodSnacks",               basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=2} },
{ item="Base.Bag_InmateEscapedBag",         basePrice=160, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=2} },
{ item="Base.Bag_MoneyBag",                 basePrice=300, tags={"Container.Backpack.Duffel", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_TennisBag",                basePrice=180, tags={"Container.Backpack.Duffel", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ToolBag",                  basePrice=200, tags={"Container.Backpack.Duffel", "Theme.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_WeaponBag",                basePrice=220, tags={"Container.Backpack.Duffel", "Origin.Militia", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_WorkerBag",                basePrice=180, tags={"Container.Backpack.Duffel", "Theme.Utility", "Rarity.Common"}, stockRange={min=1, max=3} },

-- Police/SWAT/Sheriff Duffels
{ item="Base.Bag_Police",                   basePrice=180,  tags={"Container.Backpack.Duffel", "Origin.Police", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_SWAT",                     basePrice=350,  tags={"Container.Backpack.Duffel", "Origin.Police", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_Sheriff",                  basePrice=180,  tags={"Container.Backpack.Duffel", "Origin.Police", "Rarity.Common"}, stockRange={min=1, max=3} },

-- SCHOOL BAGS & SMALL BACKPACKS (Low Tier)
{ item="Base.Bag_Schoolbag",                basePrice=120, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.Bag_Schoolbag_Kids",           basePrice=120, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.Bag_Schoolbag_Medical",        basePrice=140, tags={"Container.Backpack.Civ", "Origin.Healthcare", "Rarity.Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Schoolbag_Patches",        basePrice=130, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Schoolbag_Travel",         basePrice=120, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_GolfBag",                  basePrice=110, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_GolfBag_Melee",            basePrice=110, tags={"Container.Backpack.Civ", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FishingBasket",            basePrice=80,  tags={"Container.Backpack.Civ", "Theme.Survival", "Rarity.Common"}, stockRange={min=2, max=8} },

-- SATCHELS (Shoulder)
{ item="Base.Bag_Satchel",                  basePrice=90, tags={"Container.Backpack.Satchel", "Rarity.Common"}, stockRange={min=5, max=10} },
{ item="Base.Bag_SatchelPhoto",             basePrice=95, tags={"Container.Backpack.Satchel", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Leather",          basePrice=140, tags={"Container.Backpack.Satchel", "Quality.Premium", "Rarity.Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Mail",             basePrice=90, tags={"Container.Backpack.Satchel", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Medical",          basePrice=110, tags={"Container.Backpack.Satchel", "Origin.Healthcare", "Rarity.Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Military",         basePrice=180, tags={"Container.Backpack.Satchel", "Origin.Militia", "Rarity.Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Fishing",          basePrice=90, tags={"Container.Backpack.Satchel", "Rarity.Common"}, stockRange={min=2, max=5} },

-- PRIMITIVE / CRAFTED SATCHELS
{ item="Base.Bag_ClothSatchel_Burlap",      basePrice=45, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_Cotton",      basePrice=45, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_Denim",       basePrice=55, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_DenimBlack",  basePrice=55, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_DenimLight",  basePrice=55, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_HideSatchel",              basePrice=80, tags={"Container.Backpack.Satchel", "Theme.Survival"}, stockRange={min=2, max=8} },

-- SLING BAGS / SIMPLE
{ item="Base.Bag_CrudeLeatherBag",          basePrice=65, tags={"Container.Backpack.Sling", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_CrudeTarpBag",             basePrice=45, tags={"Container.Backpack.Sling", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_HideSlingBag",             basePrice=55, tags={"Container.Backpack.Sling", "Theme.Survival"}, stockRange={min=2, max=8} },
{ item="Base.Bag_SheetSlingBag",            basePrice=25, tags={"Container.Backpack.Sling", "Quality.Waste"}, stockRange={min=5, max=15} },
{ item="Base.Bag_TarpSlingBag",             basePrice=35, tags={"Container.Backpack.Sling", "Theme.Survival"}, stockRange={min=2, max=8} },

-- SPECIALTY GUN BAGS (Long Weapon Storage)
{ item="Base.Bag_RifleCaseCloth",           basePrice=20,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseCloth2",          basePrice=20,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseClothCamo",       basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunCaseCloth",         basePrice=20,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_ShotgunCaseCloth2",        basePrice=20,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },

-- SPECIALTY DUFFELS (Shotgun/Weapon variants)
{ item="Base.Bag_ShotgunBag",               basePrice=35,  tags={"Container.Backpack.Duffel", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunDblBag",            basePrice=35,  tags={"Container.Backpack.Duffel", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunDblSawnoffBag",     basePrice=35,  tags={"Container.Backpack.Duffel", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ShotgunSawnoffBag",        basePrice=35,  tags={"Container.Backpack.Duffel", "Theme.Combat"}, stockRange={min=1, max=3} },

-- HYDRATION
-- (Consolidated in DT_ContainersFluid.lua)

-- =============================================================================
-- 2. WEARABLE STORAGE (Belt/Webbing/Fanny)
-- =============================================================================

-- FANNY PACKS (Essential Extra Storage)
{ item="Base.Bag_FannyPackFront",           basePrice=30,  tags={"Container.Backpack.FannyPack", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_FannyPackBack",            basePrice=30,  tags={"Container.Backpack.FannyPack", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_FannyPackBack_Hide",       basePrice=30,  tags={"Container.Backpack.FannyPack", "Origin.Nomad"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackFront_Hide",      basePrice=30,  tags={"Container.Backpack.FannyPack", "Origin.Nomad"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackBack_Tarp",       basePrice=20,  tags={"Container.Backpack.FannyPack", "Origin.Nomad"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackFront_Tarp",      basePrice=20,  tags={"Container.Backpack.FannyPack", "Origin.Nomad"}, stockRange={min=1, max=5} },

-- TACTICAL WEBBING (Hotbar Slots)
{ item="Base.Bag_ALICE_BeltSus",            basePrice=350, tags={"Container.Backpack.Tactical", "Origin.Militia", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICE_BeltSus_Camo",       basePrice=350, tags={"Container.Backpack.Tactical", "Origin.Militia", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICE_BeltSus_Green",      basePrice=350, tags={"Container.Backpack.Tactical", "Origin.Militia", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ChestRig",                 basePrice=300, tags={"Container.Backpack.Tactical", "Origin.Militia", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ChestRig_Tarp",            basePrice=120, tags={"Container.Backpack.Tactical", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.HolsterShoulder",              basePrice=250, tags={"Container.Backpack.Tactical", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- BANDOLIERS (Ammo Efficiency)
{ item="Base.AmmoStrap_Bullets",            basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Brown_Bullets",      basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Bullets_308",        basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Shells",             basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Brown_Shells",       basePrice=50,  tags={"Container.Wearable.FannyPack", "Clothing.Utility.Belt"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. HANDHELD & BASE STORAGE (Organizers)
-- =============================================================================

-- PROTECTIVE CASES (Heavy Duty)
{ item="Base.Bag_ProtectiveCase",           basePrice=25,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCase_Survivalist",basePrice=30, tags={"Container.Organizer", "Theme.Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCase_Tools",     basePrice=30,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary",   basePrice=35,  tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary_Medical", basePrice=35, tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary_Tools", basePrice=35, tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=1, max=3} },

-- SMALL PROTECTIVE CASES (Pistols/Radios)
{ item="Base.Bag_ProtectiveCaseSmall",      basePrice=15,  tags={"Container.Organizer"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ProtectiveCaseSmall_Armorer",basePrice=20,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Electronics",basePrice=20,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_FirstAid",basePrice=20,tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_KeyCutting",basePrice=15,tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol1",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol2",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol3",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver1",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver2",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver3",basePrice=15,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Survivalist",basePrice=20,tags={"Container.Organizer", "Theme.Survival"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_WalkieTalkie",basePrice=15,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_WalkieTalkiePolice",basePrice=15,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary",basePrice=20,tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_FirstAid",basePrice=25,tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_Pistol1",basePrice=20,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_WalkieTalkie",basePrice=20,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=5} },

-- BULKY CASES (Heavy Storage)
{ item="Base.Bag_ProtectiveCaseBulky",      basePrice=30,  tags={"Container.Organizer", "Quality.Heavy"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_Audio",basePrice=30,  tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_HAMRadio1",basePrice=35,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_SCBA", basePrice=30,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyHazard",basePrice=35,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_Survivalist",basePrice=35,tags={"Container.Organizer", "Theme.Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyMilitary",basePrice=40,tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyMilitary_HAMRadio2",basePrice=45,tags={"Container.Organizer", "Theme.Digital"}, stockRange={min=1, max=3} },

-- BULKY AMMO CASES
{ item="Base.Bag_ProtectiveCaseBulkyAmmo",  basePrice=30,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_308",basePrice=30, tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_38",basePrice=30,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_44",basePrice=30,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_45",basePrice=30,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_556",basePrice=30, tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_9mm",basePrice=30, tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_Hunting",basePrice=30,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_ShotgunShells",basePrice=30,tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=3} },

-- HARD CASES (Gun/Instrument)
{ item="Base.Bag_RifleCase",                basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police",         basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police2",        basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police3",        basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_ShotgunCase_Police",       basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseGreen",           basePrice=30,  tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=3} },
{ item="Base.Bag_RifleCaseGreen2",          basePrice=30,  tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunCaseGreen",         basePrice=30,  tags={"Container.Organizer", "Origin.Militia"}, stockRange={min=1, max=3} },
{ item="Base.RifleCase1",                   basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase2",                   basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase3",                   basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase4",                   basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.ShotgunCase1",                 basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.ShotgunCase2",                 basePrice=25,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=5} },
{ item="Base.PistolCase1",                  basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.PistolCase2",                  basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.PistolCase3",                  basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase1",                basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase2",                basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase3",                basePrice=15,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=2, max=8} },
{ item="Base.Guitarcase",                   basePrice=20,  tags={"Container.Organizer", "Literature.Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_SaxophoneCase",            basePrice=20,  tags={"Container.Organizer", "Literature.Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_TrumpetCase",              basePrice=15,  tags={"Container.Organizer", "Literature.Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ViolinCase",               basePrice=15,  tags={"Container.Organizer", "Literature.Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_FluteCase",                basePrice=10,  tags={"Container.Organizer", "Literature.Music"}, stockRange={min=1, max=3} },
{ item="Base.Briefcase",                    basePrice=15,  tags={"Container.Organizer", "Theme.Office"}, stockRange={min=2, max=8} },
{ item="Base.Briefcase_Money",              basePrice=40,  tags={"Container.Organizer", "Quality.Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Suitcase",                     basePrice=15,  tags={"Container.Organizer", "Container.Misc"}, stockRange={min=2, max=8} },
{ item="Base.Flightcase",                   basePrice=20,  tags={"Container.Organizer", "Container.Misc"}, stockRange={min=1, max=5} },

-- AMMO BOXES (Organization)
{ item="Base.Bag_AmmoBox",                  basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=5, max=15} },
{ item="Base.Bag_AmmoBox_308",              basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_38",               basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_44",               basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_45",               basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_9mm",              basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_Hunting",          basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_Mixed",            basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_ShotgunShells",    basePrice=10,  tags={"Container.Organizer", "Theme.Combat"}, stockRange={min=1, max=5} },

-- TOOLBOXES & KITS
{ item="Base.Toolbox",                      basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Bag_JanitorToolbox",           basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Farming",              basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Fishing",              basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Gardening",            basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Mechanic",             basePrice=15,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Wooden",               basePrice=10,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.SewingKit",                    basePrice=10,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Tacklebox",                    basePrice=12,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Bag_DoctorBag",                basePrice=20,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=1, max=5} },
-- (Consolidated in DT_Medical.lua)
{ item="Base.FirstAidKit_New",              basePrice=10,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=5, max=15} },
{ item="Base.FirstAidKit_NewPro",           basePrice=12,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=5, max=15} },
{ item="Base.FirstAidKit_Camping",          basePrice=10,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=2, max=8} },
{ item="Base.FirstAidKit_Camping_New",      basePrice=10,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=2, max=8} },
{ item="Base.FirstAidKit_Military",         basePrice=15,  tags={"Container.Organizer", "Theme.Clinical"}, stockRange={min=2, max=8} },
{ item="Base.Lunchbox",                     basePrice=8,   tags={"Container.Organizer", "Food"}, stockRange={min=2, max=10} },
{ item="Base.Lunchbox2",                    basePrice=8,   tags={"Container.Organizer", "Food"}, stockRange={min=2, max=10} },
{ item="Base.Lunchbag",                     basePrice=5,   tags={"Container.Organizer", "Food"}, stockRange={min=5, max=15} },
{ item="Base.Cooler",                       basePrice=20,  tags={"Container.Organizer", "Food"}, stockRange={min=2, max=8} },
{ item="Base.Cooler_Beer",                  basePrice=25,  tags={"Container.Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Meat",                  basePrice=30,  tags={"Container.Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Seafood",               basePrice=30,  tags={"Container.Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Soda",                  basePrice=25,  tags={"Container.Organizer", "Food"}, stockRange={min=1, max=5} },

-- HOLLOW BOOKS (Secret Storage)
{ item="Base.HollowBook",                   basePrice=10,  tags={"Container.Secret"}, stockRange={min=1, max=5} },
{ item="Base.HollowBook_Handgun",           basePrice=15,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Kids",              basePrice=10,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Prison",            basePrice=10,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Valuables",         basePrice=20,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Whiskey",           basePrice=15,  tags={"Container.Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowFancyBook",              basePrice=15,  tags={"Container.Secret", "Quality.Luxury"}, stockRange={min=1, max=3} },

-- MISC ORGANIZERS
{ item="Base.Cashbox",                      basePrice=10,  tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox",                     basePrice=5,   tags={"Container.Organizer"}, stockRange={min=2, max=10} },
{ item="Base.CigarBox_Gaming",              basePrice=8,   tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox_Keepsakes",           basePrice=8,   tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox_Kids",                basePrice=5,   tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CookieJar",                    basePrice=5,   tags={"Container.Misc"}, stockRange={min=2, max=8} },
{ item="Base.CookieJar_Bear",               basePrice=8,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Humidor",                      basePrice=15,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=1, max=3} },
{ item="Base.JewelleryBox",                 basePrice=10,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=2, max=8} },
{ item="Base.JewelleryBox_Fancy",           basePrice=20,  tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=1, max=3} },
{ item="Base.MakeupCase_Professional",      basePrice=15,  tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.PencilCase",                   basePrice=5,   tags={"Container.Organizer"}, stockRange={min=5, max=15} },
{ item="Base.PencilCase_Gaming",            basePrice=5,   tags={"Container.Organizer"}, stockRange={min=2, max=8} },
{ item="Base.ToolRoll_Fabric",              basePrice=8,   tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.ToolRoll_Leather",             basePrice=12,  tags={"Container.Organizer", "Theme.Utility"}, stockRange={min=2, max=10} },
{ item="Base.Hatbox",                       basePrice=5,   tags={"Container.Organizer"}, stockRange={min=1, max=5} },
{ item="Base.Shoebox",                      basePrice=2,   tags={"Container.Organizer"}, stockRange={min=5, max=20} },
{ item="Base.HalloweenCandyBucket",         basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },

-- GIFTS & PARCELS (Mystery Boxes)
{ item="Base.Present_ExtraSmall",           basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Present_Small",                basePrice=5,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Present_Medium",               basePrice=10,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Present_Large",                basePrice=15,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Present_ExtraLarge",           basePrice=20,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_ExtraSmall",            basePrice=2,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Small",                 basePrice=5,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Medium",                basePrice=8,   tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Large",                 basePrice=10,  tags={"Container.Misc"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_ExtraLarge",            basePrice=15,  tags={"Container.Misc"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. JUNK CONTAINERS & SACKS
-- =============================================================================
-- Trash bags (Utility)
{ item="Base.Bag_TrashBag",                 basePrice=2,   tags={"Container.General", "Quality.Waste"}, stockRange={min=10, max=50} },
{ item="Base.Garbagebag",                   basePrice=2,   tags={"Container.General", "Quality.Waste"}, stockRange={min=10, max=50} },
{ item="Base.Garbagebag_box",               basePrice=10,  tags={"Container.Organizer", "Quality.Waste"}, stockRange={min=1, max=5} },

-- Sacks (Farming/Sand)
{ item="Base.Bag_Gunny",                    basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
{ item="Base.EmptySandbag",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
{ item="Base.WheatSack",                    basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
{ item="Base.WheatSeedSack",                basePrice=8,   tags={"Container.Sack.Material"}, stockRange={min=2, max=10} },
{ item="Base.Bag_HideSack",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
{ item="Base.Bag_TarpSack",                 basePrice=5,   tags={"Container.Sack.Material"}, stockRange={min=5, max=20} },
{ item="Base.Bag_DeadMice",                 basePrice=10,  tags={"Container.General"}, stockRange={min=0, max=1} },
{ item="Base.Bag_DeadRats",                 basePrice=10,  tags={"Container.General"}, stockRange={min=0, max=1} },
{ item="Base.Bag_DeadRoaches",              basePrice=5,   tags={"Container.General"}, stockRange={min=0, max=1} },
{ item="Base.Bag_TreasureBag",              basePrice=50,  tags={"Container.General", "Rarity.Rare"}, stockRange={min=0, max=1} },

-- Laundry
{ item="Base.Bag_Laundry",                  basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },
{ item="Base.Bag_LaundryLinen",             basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },
{ item="Base.Bag_LaundryHospital",          basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },

-- Small Totes & Baskets
{ item="Base.Tote",                         basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.Tote_Bags",                    basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.Tote_Clothing",                basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.Bag_Dancer",                   basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.Bag_BirthdayBasket",           basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },
{ item="Base.Bag_GardenBasket",             basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },
{ item="Base.Bag_BowlingBallBag",           basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },

-- Pouches
{ item="Base.DiceBag",                      basePrice=2,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.GemBag",                       basePrice=5,   tags={"Misc.Decor", "Quality.Luxury"}, stockRange={min=2, max=10} },
{ item="Base.SeedBag",                      basePrice=2,   tags={"Container.General", "Theme.Farming"}, stockRange={min=5, max=20} },
{ item="Base.SeedBag_Farming",              basePrice=2,   tags={"Container.General", "Theme.Farming"}, stockRange={min=5, max=20} },

-- Paper/Plastic Disposables
{ item="Base.Plasticbag",                   basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.Plasticbag_Bags",              basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.Plasticbag_Clothing",          basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag1",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag2",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag3",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag4",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag5",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBagGourmet",            basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.PaperBag",                     basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.Paperbag_Jays",                basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.Paperbag_Spiffos",             basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
{ item="Base.TakeoutBox_Chinese",           basePrice=0.5, tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.TakeoutBox_Styrofoam",         basePrice=0.5, tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_ExtraSmall",        basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Small",             basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Medium",            basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Large",             basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_ExtraLarge",        basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
{ item="Base.Handbag",                      basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=10} },
{ item="Base.Purse",                        basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=10} },
})

print("[DynamicTrading] Containers Registry Complete \n.")
