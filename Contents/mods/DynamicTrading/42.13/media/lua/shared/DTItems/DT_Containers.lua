require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. BACKPACKS (The Essentials)
-- =============================================================================
-- MILITARY GRADE (Best Weight Reduction/Capacity)
{ item="Base.Bag_ALICEpack",                basePrice=250, tags={"Container", "Backpack", "Military", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICEpack_Army",           basePrice=250, tags={"Container", "Backpack", "Military", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_ALICEpack_DesertCamo",     basePrice=250, tags={"Container", "Backpack", "Military", "Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bag_SurvivorBag",              basePrice=220, tags={"Container", "Backpack", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.Bag_Military",                 basePrice=60,  tags={"Container", "Backpack", "Military"}, stockRange={min=1, max=3} },

-- CRAFTED FRAMEPACKS (High Capacity)
{ item="Base.Bag_CraftedFramepack_Large3",  basePrice=180, tags={"Container", "Backpack", "Survival"}, stockRange={min=0, max=1} }, -- 35 Cap
{ item="Base.Bag_CraftedFramepack_Large2",  basePrice=120, tags={"Container", "Backpack", "Survival"}, stockRange={min=0, max=2} }, -- 25 Cap
{ item="Base.Bag_CraftedFramepack_Large",   basePrice=80,  tags={"Container", "Backpack", "Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_TarpFramepack_Large",      basePrice=70,  tags={"Container", "Backpack", "Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_CraftedFramepack_Small",   basePrice=40,  tags={"Container", "Backpack", "Survival"}, stockRange={min=1, max=5} },
{ item="Base.Bag_TarpFramepack_Small",      basePrice=35,  tags={"Container", "Backpack", "Survival"}, stockRange={min=1, max=5} },

-- HIKING BAGS (High Civilian Tier)
{ item="Base.Bag_BigHikingBag",             basePrice=100, tags={"Container", "Backpack", "Rare"}, stockRange={min=1, max=3} },
{ item="Base.Bag_BigHikingBag_Travel",      basePrice=100, tags={"Container", "Backpack", "Rare"}, stockRange={min=1, max=3} },
{ item="Base.Bag_NormalHikingBag",          basePrice=70,  tags={"Container", "Backpack", "Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_HikingBag_Travel",         basePrice=70,  tags={"Container", "Backpack", "Uncommon"}, stockRange={min=2, max=5} },

-- DUFFEL BAGS (Standard Tier)
{ item="Base.Bag_DuffelBag",                basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_DuffelBagTINT",            basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_BaseballBag",              basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_BreakdownBag",             basePrice=45,  tags={"Container", "Backpack", "Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_BurglarBag",               basePrice=45,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_FoodCanned",               basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_FoodSnacks",               basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_InmateEscapedBag",         basePrice=35,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_MoneyBag",                 basePrice=50,  tags={"Container", "Backpack", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Bag_TennisBag",                basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ToolBag",                  basePrice=45,  tags={"Container", "Backpack", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.Bag_WeaponBag",                basePrice=45,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_WorkerBag",                basePrice=40,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=5} },

-- Police/SWAT/Sheriff Duffels
{ item="Base.Bag_Police",                   basePrice=45,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },
{ item="Base.Bag_SWAT",                     basePrice=50,  tags={"Container", "Backpack", "Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_Sheriff",                  basePrice=45,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=3} },

-- SCHOOL BAGS & SMALL BACKPACKS (Low Tier)
{ item="Base.Bag_Schoolbag",                basePrice=20,  tags={"Container", "Backpack", "Common"}, stockRange={min=5, max=15} },
{ item="Base.Bag_Schoolbag_Kids",           basePrice=20,  tags={"Container", "Backpack", "Common"}, stockRange={min=5, max=15} },
{ item="Base.Bag_Schoolbag_Medical",        basePrice=25,  tags={"Container", "Backpack", "Medical"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Schoolbag_Patches",        basePrice=20,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Schoolbag_Travel",         basePrice=20,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_GolfBag",                  basePrice=25,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_GolfBag_Melee",            basePrice=25,  tags={"Container", "Backpack", "Common"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FishingBasket",            basePrice=15,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=8} },

-- SATCHELS (Shoulder)
{ item="Base.Bag_Satchel",                  basePrice=15,  tags={"Container", "Backpack", "Common"}, stockRange={min=5, max=10} },
{ item="Base.Bag_SatchelPhoto",             basePrice=15,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Leather",          basePrice=25,  tags={"Container", "Backpack", "Uncommon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Mail",             basePrice=15,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Medical",          basePrice=20,  tags={"Container", "Backpack", "Medical"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Military",         basePrice=30,  tags={"Container", "Backpack", "Military"}, stockRange={min=2, max=5} },
{ item="Base.Bag_Satchel_Fishing",          basePrice=15,  tags={"Container", "Backpack", "Common"}, stockRange={min=2, max=5} },

-- PRIMITIVE / CRAFTED SATCHELS
{ item="Base.Bag_ClothSatchel_Burlap",      basePrice=10,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_Cotton",      basePrice=10,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_Denim",       basePrice=12,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_DenimBlack",  basePrice=12,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ClothSatchel_DenimLight",  basePrice=12,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_HideSatchel",              basePrice=15,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },

-- SLING BAGS / SIMPLE
{ item="Base.Bag_CrudeLeatherBag",          basePrice=15,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_CrudeTarpBag",             basePrice=10,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_HideSlingBag",             basePrice=10,  tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.Bag_SheetSlingBag",            basePrice=5,   tags={"Container", "Backpack", "Primitive", "Junk"}, stockRange={min=5, max=15} },
{ item="Base.Bag_TarpSlingBag",             basePrice=8,   tags={"Container", "Backpack", "Primitive"}, stockRange={min=2, max=8} },

-- SPECIALTY GUN BAGS (Long Weapon Storage)
{ item="Base.Bag_RifleCaseCloth",           basePrice=20,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseCloth2",          basePrice=20,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseClothCamo",       basePrice=25,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunCaseCloth",         basePrice=20,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_ShotgunCaseCloth2",        basePrice=20,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=2, max=5} },

-- SPECIALTY DUFFELS (Shotgun/Weapon variants)
{ item="Base.Bag_ShotgunBag",               basePrice=35,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunDblBag",            basePrice=35,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunDblSawnoffBag",     basePrice=35,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunSawnoffBag",        basePrice=35,  tags={"Container", "Backpack", "Weapon"}, stockRange={min=1, max=3} },

-- HYDRATION
{ item="Base.Bag_HydrationBackpack",        basePrice=50,  tags={"Container", "Backpack", "Survival"}, stockRange={min=0, max=2} },
{ item="Base.Bag_HydrationBackpack_Camo",   basePrice=55,  tags={"Container", "Backpack", "Survival"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 2. WEARABLE STORAGE (Belt/Webbing/Fanny)
-- =============================================================================

-- FANNY PACKS (Essential Extra Storage)
{ item="Base.Bag_FannyPackFront",           basePrice=30,  tags={"Container", "Wearable", "Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_FannyPackBack",            basePrice=30,  tags={"Container", "Wearable", "Common"}, stockRange={min=2, max=10} },
{ item="Base.Bag_FannyPackBack_Hide",       basePrice=30,  tags={"Container", "Wearable", "Primitive"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackFront_Hide",      basePrice=30,  tags={"Container", "Wearable", "Primitive"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackBack_Tarp",       basePrice=20,  tags={"Container", "Wearable", "Primitive"}, stockRange={min=1, max=5} },
{ item="Base.Bag_FannyPackFront_Tarp",      basePrice=20,  tags={"Container", "Wearable", "Primitive"}, stockRange={min=1, max=5} },

-- TACTICAL WEBBING (Hotbar Slots)
{ item="Base.Bag_ALICE_BeltSus",            basePrice=80,  tags={"Container", "Wearable", "Military", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.Bag_ALICE_BeltSus_Camo",       basePrice=80,  tags={"Container", "Wearable", "Military", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.Bag_ALICE_BeltSus_Green",      basePrice=80,  tags={"Container", "Wearable", "Military", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.Bag_ChestRig",                 basePrice=70,  tags={"Container", "Wearable", "Military", "Rare"}, stockRange={min=0, max=2} },
{ item="Base.Bag_ChestRig_Tarp",            basePrice=40,  tags={"Container", "Wearable", "Primitive"}, stockRange={min=1, max=3} },
{ item="Base.HolsterShoulder",              basePrice=40,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=5} },

-- BANDOLIERS (Ammo Efficiency)
{ item="Base.AmmoStrap_Bullets",            basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Brown_Bullets",      basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Bullets_223",        basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Bullets_308",        basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Shells",             basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },
{ item="Base.AmmoStrap_Brown_Shells",       basePrice=50,  tags={"Container", "Wearable", "Tactical"}, stockRange={min=1, max=3} },

-- =============================================================================
-- 3. HANDHELD & BASE STORAGE (Organizers)
-- =============================================================================

-- PROTECTIVE CASES (Heavy Duty)
{ item="Base.Bag_ProtectiveCase",           basePrice=25,  tags={"Container", "Organizer", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCase_Survivalist",basePrice=30, tags={"Container", "Organizer", "Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCase_Tools",     basePrice=30,  tags={"Container", "Organizer", "Tool"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary",   basePrice=35,  tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary_Medical", basePrice=35, tags={"Container", "Organizer", "Medical"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseMilitary_Tools", basePrice=35, tags={"Container", "Organizer", "Tool"}, stockRange={min=1, max=3} },

-- SMALL PROTECTIVE CASES (Pistols/Radios)
{ item="Base.Bag_ProtectiveCaseSmall",      basePrice=15,  tags={"Container", "Organizer"}, stockRange={min=2, max=8} },
{ item="Base.Bag_ProtectiveCaseSmall_Armorer",basePrice=20,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Electronics",basePrice=20,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_FirstAid",basePrice=20,tags={"Container", "Organizer", "Medical"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_KeyCutting",basePrice=15,tags={"Container", "Organizer", "Tool"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol1",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol2",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Pistol3",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver1",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver2",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Revolver3",basePrice=15,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_Survivalist",basePrice=20,tags={"Container", "Organizer", "Survival"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_WalkieTalkie",basePrice=15,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmall_WalkieTalkiePolice",basePrice=15,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary",basePrice=20,tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_FirstAid",basePrice=25,tags={"Container", "Organizer", "Medical"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_Pistol1",basePrice=20,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_ProtectiveCaseSmallMilitary_WalkieTalkie",basePrice=20,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=5} },

-- BULKY CASES (Heavy Storage)
{ item="Base.Bag_ProtectiveCaseBulky",      basePrice=30,  tags={"Container", "Organizer", "Heavy"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_Audio",basePrice=30,  tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_HAMRadio1",basePrice=35,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_SCBA", basePrice=30,  tags={"Container", "Organizer", "Tool"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyHazard",basePrice=35,  tags={"Container", "Organizer", "Medical"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulky_Survivalist",basePrice=35,tags={"Container", "Organizer", "Survival"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyMilitary",basePrice=40,tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyMilitary_HAMRadio2",basePrice=45,tags={"Container", "Organizer", "Electronics"}, stockRange={min=1, max=3} },

-- BULKY AMMO CASES
{ item="Base.Bag_ProtectiveCaseBulkyAmmo",  basePrice=30,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_223",basePrice=30, tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_308",basePrice=30, tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_38",basePrice=30,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_44",basePrice=30,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_45",basePrice=30,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_556",basePrice=30, tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_9mm",basePrice=30, tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_Hunting",basePrice=30,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ProtectiveCaseBulkyAmmo_ShotgunShells",basePrice=30,tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=3} },

-- HARD CASES (Gun/Instrument)
{ item="Base.Bag_RifleCase",                basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police",         basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police2",        basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCase_Police3",        basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_ShotgunCase_Police",       basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.Bag_RifleCaseGreen",           basePrice=30,  tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=3} },
{ item="Base.Bag_RifleCaseGreen2",          basePrice=30,  tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ShotgunCaseGreen",         basePrice=30,  tags={"Container", "Organizer", "Military"}, stockRange={min=1, max=3} },
{ item="Base.RifleCase1",                   basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase2",                   basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase3",                   basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.RifleCase4",                   basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.ShotgunCase1",                 basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.ShotgunCase2",                 basePrice=25,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=5} },
{ item="Base.PistolCase1",                  basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.PistolCase2",                  basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.PistolCase3",                  basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase1",                basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase2",                basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.RevolverCase3",                basePrice=15,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=2, max=8} },
{ item="Base.Guitarcase",                   basePrice=20,  tags={"Container", "Organizer", "Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_SaxophoneCase",            basePrice=20,  tags={"Container", "Organizer", "Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_TrumpetCase",              basePrice=15,  tags={"Container", "Organizer", "Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_ViolinCase",               basePrice=15,  tags={"Container", "Organizer", "Music"}, stockRange={min=1, max=3} },
{ item="Base.Bag_FluteCase",                basePrice=10,  tags={"Container", "Organizer", "Music"}, stockRange={min=1, max=3} },
{ item="Base.Briefcase",                    basePrice=15,  tags={"Container", "Organizer", "Office"}, stockRange={min=2, max=8} },
{ item="Base.Briefcase_Money",              basePrice=40,  tags={"Container", "Organizer", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Suitcase",                     basePrice=15,  tags={"Container", "Organizer", "Travel"}, stockRange={min=2, max=8} },
{ item="Base.Flightcase",                   basePrice=20,  tags={"Container", "Organizer", "Travel"}, stockRange={min=1, max=5} },

-- AMMO BOXES (Organization)
{ item="Base.Bag_AmmoBox",                  basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=5, max=15} },
{ item="Base.Bag_AmmoBox_223",              basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_308",              basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_38",               basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_44",               basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_45",               basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_9mm",              basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_Hunting",          basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_Mixed",            basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },
{ item="Base.Bag_AmmoBox_ShotgunShells",    basePrice=10,  tags={"Container", "Organizer", "Weapon"}, stockRange={min=1, max=5} },

-- TOOLBOXES & KITS
{ item="Base.Toolbox",                      basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Bag_JanitorToolbox",           basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Farming",              basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Fishing",              basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Gardening",            basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Mechanic",             basePrice=15,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Toolbox_Wooden",               basePrice=10,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.SewingKit",                    basePrice=10,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Tacklebox",                    basePrice=12,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Bag_DoctorBag",                basePrice=20,  tags={"Container", "Organizer", "Medical"}, stockRange={min=1, max=5} },
{ item="Base.FirstAidKit",                  basePrice=10,  tags={"Container", "Organizer", "Medical"}, stockRange={min=5, max=15} },
{ item="Base.FirstAidKit_New",              basePrice=10,  tags={"Container", "Organizer", "Medical"}, stockRange={min=5, max=15} },
{ item="Base.FirstAidKit_NewPro",           basePrice=12,  tags={"Container", "Organizer", "Medical"}, stockRange={min=5, max=15} },
{ item="Base.FirstAidKit_Camping",          basePrice=10,  tags={"Container", "Organizer", "Medical"}, stockRange={min=2, max=8} },
{ item="Base.FirstAidKit_Camping_New",      basePrice=10,  tags={"Container", "Organizer", "Medical"}, stockRange={min=2, max=8} },
{ item="Base.FirstAidKit_Military",         basePrice=15,  tags={"Container", "Organizer", "Medical"}, stockRange={min=2, max=8} },
{ item="Base.Lunchbox",                     basePrice=8,   tags={"Container", "Organizer", "Food"}, stockRange={min=2, max=10} },
{ item="Base.Lunchbox2",                    basePrice=8,   tags={"Container", "Organizer", "Food"}, stockRange={min=2, max=10} },
{ item="Base.Lunchbag",                     basePrice=5,   tags={"Container", "Organizer", "Food"}, stockRange={min=5, max=15} },
{ item="Base.Cooler",                       basePrice=20,  tags={"Container", "Organizer", "Food"}, stockRange={min=2, max=8} },
{ item="Base.Cooler_Beer",                  basePrice=25,  tags={"Container", "Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Meat",                  basePrice=30,  tags={"Container", "Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Seafood",               basePrice=30,  tags={"Container", "Organizer", "Food"}, stockRange={min=1, max=5} },
{ item="Base.Cooler_Soda",                  basePrice=25,  tags={"Container", "Organizer", "Food"}, stockRange={min=1, max=5} },

-- HOLLOW BOOKS (Secret Storage)
{ item="Base.HollowBook",                   basePrice=10,  tags={"Container", "Secret"}, stockRange={min=1, max=5} },
{ item="Base.HollowBook_Handgun",           basePrice=15,  tags={"Container", "Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Kids",              basePrice=10,  tags={"Container", "Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Prison",            basePrice=10,  tags={"Container", "Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Valuables",         basePrice=20,  tags={"Container", "Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowBook_Whiskey",           basePrice=15,  tags={"Container", "Secret"}, stockRange={min=0, max=2} },
{ item="Base.HollowFancyBook",              basePrice=15,  tags={"Container", "Secret", "Luxury"}, stockRange={min=1, max=3} },

-- MISC ORGANIZERS
{ item="Base.Cashbox",                      basePrice=10,  tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox",                     basePrice=5,   tags={"Container", "Organizer"}, stockRange={min=2, max=10} },
{ item="Base.CigarBox_Gaming",              basePrice=8,   tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox_Keepsakes",           basePrice=8,   tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CigarBox_Kids",                basePrice=5,   tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.CookieJar",                    basePrice=5,   tags={"Container", "Decor"}, stockRange={min=2, max=8} },
{ item="Base.CookieJar_Bear",               basePrice=8,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Humidor",                      basePrice=15,  tags={"Container", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.JewelleryBox",                 basePrice=10,  tags={"Container", "Luxury"}, stockRange={min=2, max=8} },
{ item="Base.JewelleryBox_Fancy",           basePrice=20,  tags={"Container", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.MakeupCase_Professional",      basePrice=15,  tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.PencilCase",                   basePrice=5,   tags={"Container", "Scholastic"}, stockRange={min=5, max=15} },
{ item="Base.PencilCase_Gaming",            basePrice=5,   tags={"Container", "Scholastic"}, stockRange={min=2, max=8} },
{ item="Base.ToolRoll_Fabric",              basePrice=8,   tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.ToolRoll_Leather",             basePrice=12,  tags={"Container", "Organizer", "Tool"}, stockRange={min=2, max=10} },
{ item="Base.Hatbox",                       basePrice=5,   tags={"Container", "Organizer"}, stockRange={min=1, max=5} },
{ item="Base.Shoebox",                      basePrice=2,   tags={"Container", "Organizer"}, stockRange={min=5, max=20} },
{ item="Base.HalloweenCandyBucket",         basePrice=2,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },

-- GIFTS & PARCELS (Mystery Boxes)
{ item="Base.Present_ExtraSmall",           basePrice=2,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Present_Small",                basePrice=5,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Present_Medium",               basePrice=10,  tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Present_Large",                basePrice=15,  tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Present_ExtraLarge",           basePrice=20,  tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_ExtraSmall",            basePrice=2,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Small",                 basePrice=5,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Medium",                basePrice=8,   tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_Large",                 basePrice=10,  tags={"Container", "Decor"}, stockRange={min=1, max=5} },
{ item="Base.Parcel_ExtraLarge",            basePrice=15,  tags={"Container", "Decor"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. JUNK CONTAINERS & SACKS
-- =============================================================================
-- Trash bags (Utility)
{ item="Base.Bag_TrashBag",                 basePrice=2,   tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Garbagebag",                   basePrice=2,   tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Garbagebag_box",               basePrice=10,  tags={"Container", "Stockpile"}, stockRange={min=1, max=5} },

-- Sacks (Farming/Sand)
{ item="Base.Bag_Gunny",                    basePrice=5,   tags={"Container", "Material"}, stockRange={min=5, max=20} },
{ item="Base.EmptySandbag",                 basePrice=5,   tags={"Container", "Material"}, stockRange={min=5, max=20} },
{ item="Base.WheatSack",                    basePrice=5,   tags={"Container", "Material"}, stockRange={min=5, max=20} },
{ item="Base.WheatSeedSack",                basePrice=8,   tags={"Container", "Material"}, stockRange={min=2, max=10} },
{ item="Base.Bag_HideSack",                 basePrice=5,   tags={"Container", "Material"}, stockRange={min=5, max=20} },
{ item="Base.Bag_TarpSack",                 basePrice=5,   tags={"Container", "Material"}, stockRange={min=5, max=20} },
{ item="Base.Bag_DeadMice",                 basePrice=10,  tags={"Container", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Bag_DeadRats",                 basePrice=10,  tags={"Container", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Bag_DeadRoaches",              basePrice=5,   tags={"Container", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Bag_TreasureBag",              basePrice=50,  tags={"Container", "Rare"}, stockRange={min=0, max=1} },

-- Laundry
{ item="Base.Bag_Laundry",                  basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=15} },
{ item="Base.Bag_LaundryLinen",             basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=15} },
{ item="Base.Bag_LaundryHospital",          basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=15} },

-- Small Totes & Baskets
{ item="Base.Tote",                         basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Tote_Bags",                    basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Tote_Clothing",                basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Bag_Dancer",                   basePrice=5,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Bag_BirthdayBasket",           basePrice=5,   tags={"Container", "Junk"}, stockRange={min=2, max=8} },
{ item="Base.Bag_GardenBasket",             basePrice=5,   tags={"Container", "Junk"}, stockRange={min=2, max=8} },
{ item="Base.Bag_BowlingBallBag",           basePrice=5,   tags={"Container", "Junk"}, stockRange={min=2, max=8} },

-- Pouches
{ item="Base.DiceBag",                      basePrice=2,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.GemBag",                       basePrice=5,   tags={"Container", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.SeedBag",                      basePrice=2,   tags={"Container", "Farming"}, stockRange={min=5, max=20} },
{ item="Base.SeedBag_Farming",              basePrice=2,   tags={"Container", "Farming"}, stockRange={min=5, max=20} },

-- Paper/Plastic Disposables
{ item="Base.Plasticbag",                   basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Plasticbag_Bags",              basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Plasticbag_Clothing",          basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag1",                  basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag2",                  basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag3",                  basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag4",                  basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBag5",                  basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.GroceryBagGourmet",            basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.PaperBag",                     basePrice=0.2, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Paperbag_Jays",                basePrice=0.2, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.Paperbag_Spiffos",             basePrice=0.2, tags={"Container", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.TakeoutBox_Chinese",           basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.TakeoutBox_Styrofoam",         basePrice=0.5, tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_ExtraSmall",        basePrice=1,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Small",             basePrice=1,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Medium",            basePrice=1,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_Large",             basePrice=1,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.ProduceBox_ExtraLarge",        basePrice=1,   tags={"Container", "Junk"}, stockRange={min=5, max=20} },
{ item="Base.Handbag",                      basePrice=5,   tags={"Container", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.Purse",                        basePrice=5,   tags={"Container", "Junk"}, stockRange={min=2, max=10} },
})