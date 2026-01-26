require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({

    -- =============================================================================
    -- CRAFTED ARMOR (SURVIVALIST)
    -- =============================================================================
    -- Logic: Bone/Wood are "Common" (1.0x). Tire is "Uncommon" (1.25x). 
    -- Magazine is "Junk" (0.5x) because it is fragile.
    
    -- BONE (Moderate protection, accessible)
    { item="Base.Cuirass_Bone",        tags={"Armor", "Survivalist", "Common"}, basePrice=110, stockRange={min=1, max=3} },
    { item="Base.Necklace_Choker_Bone",tags={"Armor", "Survivalist", "Common"}, basePrice=45,  stockRange={min=1, max=3} },
    { item="Base.VambraceBone_Left",   tags={"Armor", "Survivalist", "Common"}, basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.VambraceBone_Right",  tags={"Armor", "Survivalist", "Common"}, basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.GreaveBone_Left",     tags={"Armor", "Survivalist", "Common"}, basePrice=50,  stockRange={min=1, max=4} },
    { item="Base.GreaveBone_Right",    tags={"Armor", "Survivalist", "Common"}, basePrice=50,  stockRange={min=1, max=4} },
    { item="Base.Shoulderpad_Bone_L",  tags={"Armor", "Survivalist", "Common"}, basePrice=45,  stockRange={min=1, max=4} },
    { item="Base.Shoulderpad_Bone_R",  tags={"Armor", "Survivalist", "Common"}, basePrice=45,  stockRange={min=1, max=4} },
    { item="Base.ThighBone_L",         tags={"Armor", "Survivalist", "Common"}, basePrice=55,  stockRange={min=1, max=4} },
    { item="Base.ThighBone_R",         tags={"Armor", "Survivalist", "Common"}, basePrice=55,  stockRange={min=1, max=4} },

    -- WOOD (Basic protection, Carpenter thematic)
    { item="Base.Cuirass_Wood",        tags={"Armor", "Survivalist", "Carpenter", "Common"}, basePrice=80, stockRange={min=1, max=3} },
    { item="Base.VambraceWood_Left",   tags={"Armor", "Survivalist", "Common"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.VambraceWood_Right",  tags={"Armor", "Survivalist", "Common"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.GreaveWood_Left",     tags={"Armor", "Survivalist", "Common"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.GreaveWood_Right",    tags={"Armor", "Survivalist", "Common"}, basePrice=35, stockRange={min=1, max=4} },
    { item="Base.Shoulderpad_Wood_L",  tags={"Armor", "Survivalist", "Common"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.Shoulderpad_Wood_R",  tags={"Armor", "Survivalist", "Common"}, basePrice=30, stockRange={min=1, max=4} },
    { item="Base.ThighWood_L",         tags={"Armor", "Survivalist", "Common"}, basePrice=40, stockRange={min=1, max=4} },
    { item="Base.ThighWood_R",         tags={"Armor", "Survivalist", "Common"}, basePrice=40, stockRange={min=1, max=4} },

    -- TIRE (Heavy protection, adds "Heavy" tag for potential movement penalties/filters)
    { item="Base.Cuirass_Tire",        tags={"Armor", "Scavenger", "Heavy", "Uncommon"}, basePrice=130, stockRange={min=0, max=2} },
    { item="Base.VambraceTire_Left",   tags={"Armor", "Scavenger", "Uncommon"}, basePrice=55, stockRange={min=0, max=3} },
    { item="Base.VambraceTire_Right",  tags={"Armor", "Scavenger", "Uncommon"}, basePrice=55, stockRange={min=0, max=3} },
    { item="Base.GreaveTire_Left",     tags={"Armor", "Scavenger", "Uncommon"}, basePrice=65, stockRange={min=0, max=3} },
    { item="Base.GreaveTire_Right",    tags={"Armor", "Scavenger", "Uncommon"}, basePrice=65, stockRange={min=0, max=3} },
    { item="Base.Shoulderpad_Tire_L",  tags={"Armor", "Scavenger", "Uncommon"}, basePrice=50, stockRange={min=0, max=3} },
    { item="Base.Shoulderpad_Tire_R",  tags={"Armor", "Scavenger", "Uncommon"}, basePrice=50, stockRange={min=0, max=3} },
    { item="Base.ThighTire_L",         tags={"Armor", "Scavenger", "Uncommon"}, basePrice=70, stockRange={min=0, max=3} },
    { item="Base.ThighTire_R",         tags={"Armor", "Scavenger", "Uncommon"}, basePrice=70, stockRange={min=0, max=3} },

    -- MAGAZINE (Added 'Junk' tag which applies 0.5x price multiplier from your config)
    { item="Base.Cuirass_Magazine",       tags={"Armor", "Scavenger", "Junk"}, basePrice=70, stockRange={min=2, max=6} }, -- Real Price: 35
    { item="Base.GreaveMagazine_Left",    tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.GreaveMagazine_Right",   tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.ThighMagazine_L",        tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.ThighMagazine_R",        tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.VambraceMagazine_Left",  tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },
    { item="Base.VambraceMagazine_Right", tags={"Armor", "Scavenger", "Junk"}, basePrice=30, stockRange={min=2, max=6} },

    -- =============================================================================
    -- MILITARY & LAW ENFORCEMENT
    -- =============================================================================
    -- Logic: Base prices increased. High tier items get "Rare" (2.0x Price) or "Legendary" (5.0x).
    
    -- VESTS
    { item="Base.Vest_BulletCivilian",    tags={"Armor", "Gunrunner", "Uncommon"},     basePrice=300, stockRange={min=1, max=3} },
    { item="Base.Vest_BulletPolice",      tags={"Armor", "Police", "Uncommon"},        basePrice=400, stockRange={min=1, max=2} },
    { item="Base.Vest_BulletArmy",        tags={"Armor", "Military", "Rare"},          basePrice=500, stockRange={min=0, max=2} }, -- Real Price: 1000
    { item="Base.Vest_BulletDesert",      tags={"Armor", "Military", "Rare"},          basePrice=500, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletDesertNew",   tags={"Armor", "Military", "Rare"},          basePrice=500, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletOliveDrab",   tags={"Armor", "Military", "Rare"},          basePrice=500, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletSWAT",        tags={"Armor", "Military", "Legendary"},     basePrice=400, stockRange={min=0, max=1} }, -- Real Price: 2000

    -- LIMB PROTECTION (Military)
    { item="Base.Vambrace_BodyArmour_Left_Army",  tags={"Armor", "Military", "Rare"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.Vambrace_BodyArmour_Right_Army", tags={"Armor", "Military", "Rare"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Left_Army",     tags={"Armor", "Military", "Rare"}, basePrice=140, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Right_Army",    tags={"Armor", "Military", "Rare"}, basePrice=140, stockRange={min=0, max=2} },
    { item="Base.ThighBodyArmour_L_Army",         tags={"Armor", "Military", "Rare"}, basePrice=150, stockRange={min=0, max=2} },
    { item="Base.ThighBodyArmour_R_Army",         tags={"Armor", "Military", "Rare"}, basePrice=150, stockRange={min=0, max=2} },
    
    -- LIMB PROTECTION (Police)
    { item="Base.Vambrace_BodyArmour_Left_Police", tags={"Armor", "Police", "Uncommon"}, basePrice=100, stockRange={min=0, max=2} },
    { item="Base.Vambrace_BodyArmour_Right_Police",tags={"Armor", "Police", "Uncommon"}, basePrice=100, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Left_Police",    tags={"Armor", "Police", "Uncommon"}, basePrice=120, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Right_Police",   tags={"Armor", "Police", "Uncommon"}, basePrice=120, stockRange={min=0, max=2} },

    -- =============================================================================
    -- METAL & SPORTS (SPECIALIZED)
    -- =============================================================================

    -- METAL (High bite protection, high weight)
    { item="Base.Cuirass_Metal",                  tags={"Armor", "Mechanic", "Heavy", "Rare"}, basePrice=450, stockRange={min=0, max=1} },
    { item="Base.ShinKneeGuard_L_Metal",          tags={"Armor", "Mechanic", "Uncommon"},      basePrice=180, stockRange={min=0, max=2} },
    { item="Base.ShinKneeGuard_R_Metal",          tags={"Armor", "Mechanic", "Uncommon"},      basePrice=180, stockRange={min=0, max=2} },
    { item="Base.ShinKneeGuardSpike_L_Metal",     tags={"Armor", "Mechanic", "Rare"},          basePrice=250, stockRange={min=0, max=1} },
    { item="Base.ShinKneeGuardSpike_R_Metal",     tags={"Armor", "Mechanic", "Rare"},          basePrice=250, stockRange={min=0, max=1} },
    { item="Base.Shoulderpad_Articulated_L_Metal",tags={"Armor", "Mechanic", "Uncommon"},      basePrice=140, stockRange={min=0, max=2} },
    { item="Base.Shoulderpad_Articulated_R_Metal",tags={"Armor", "Mechanic", "Uncommon"},      basePrice=140, stockRange={min=0, max=2} },
    
    -- SPORTS (Common, low durability)
    { item="Base.Shoulderpads_Football",     tags={"Armor", "Clothing", "Common"}, basePrice=200, stockRange={min=0, max=2} },
    { item="Base.Shoulderpads_IceHockey",    tags={"Armor", "Clothing", "Common"}, basePrice=220, stockRange={min=0, max=2} },
    { item="Base.Vest_CatcherVest",          tags={"Armor", "Clothing", "Common"}, basePrice=250, stockRange={min=0, max=2} },
    { item="Base.ShinKneeGuard_L_Baseball",  tags={"Armor", "Clothing", "Common"}, basePrice=85,  stockRange={min=1, max=3} },
    { item="Base.ShinKneeGuard_R_Baseball",  tags={"Armor", "Clothing", "Common"}, basePrice=85,  stockRange={min=1, max=3} },

    -- =============================================================================
    -- UTILITY, BELTS & BACKPACKS
    -- =============================================================================
    
    -- TACTICAL RIGS
    { item="Base.Bag_ALICE_BeltSus", tags={"Clothing", "Military", "Survival"}, basePrice=160, stockRange={min=1, max=3} },
    { item="Base.Bag_ChestRig",      tags={"Clothing", "Military", "Gunrunner"}, basePrice=130, stockRange={min=1, max=4} },
    { item="Base.AmmoStrap_Bullets", tags={"Clothing", "Gunrunner"},             basePrice=90,  stockRange={min=1, max=3} },
    { item="Base.AmmoStrap_Shells",  tags={"Clothing", "Gunrunner"},             basePrice=90,  stockRange={min=1, max=3} },
    { item="Base.HolsterDouble",     tags={"Clothing", "Police"},                basePrice=140, stockRange={min=0, max=2} },
    { item="Base.HolsterShoulder",   tags={"Clothing", "Police"},                basePrice=110, stockRange={min=1, max=3} },
    { item="Base.Belt2",             tags={"Clothing", "Common"},                basePrice=15,  stockRange={min=5, max=15} },
    { item="Base.SCBA",              tags={"Clothing", "Heavy", "Rare"},         basePrice=450, stockRange={min=0, max=1} },

    -- CONTAINER / BACKPACKS
    -- Added "Container" tag (useful for future filters). 
    -- Prices balanced based on Capacity vs Weight Reduction.
    
    -- Military Grade (High Capacity/Reduction)
    { item="Base.Bag_ALICEpack",     tags={"Clothing", "Container", "Military", "Rare"}, basePrice=700, stockRange={min=0, max=1} },
    { item="Base.Bag_SurvivorBag",   tags={"Clothing", "Container", "Survivalist", "Rare"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.ManPackRadio",      tags={"Electronics", "Military", "Rare"}, basePrice=500, stockRange={min=0, max=1} },
    
    -- Civilian Grade
    { item="Base.Bag_BigHikingBag",    tags={"Clothing", "Container", "Survivalist", "Uncommon"}, basePrice=400, stockRange={min=1, max=2} },
    { item="Base.Bag_NormalHikingBag", tags={"Clothing", "Container", "Survivalist", "Common"},   basePrice=250, stockRange={min=1, max=3} },
    { item="Base.Bag_DuffelBag",       tags={"Clothing", "Container", "Common"},                  basePrice=130, stockRange={min=2, max=6} },
    { item="Base.Bag_Schoolbag",       tags={"Clothing", "Container", "Common"},                  basePrice=70,  stockRange={min=2, max=8} },
    { item="Base.Bag_GolfBag",         tags={"Clothing", "Container", "Common"},                  basePrice=90,  stockRange={min=1, max=3} },
    
    -- Specialized
    { item="Base.Bag_MedicalBag",      tags={"Clothing", "Container", "Medical", "Uncommon"},     basePrice=180, stockRange={min=1, max=3} },

})

print("[DynamicTrading] Clothing Registry Complete.")
