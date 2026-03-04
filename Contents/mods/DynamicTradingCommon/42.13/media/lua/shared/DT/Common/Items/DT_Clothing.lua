require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({

    -- =============================================================================
    -- CRAFTED ARMOR (SURVIVALIST)
    -- =============================================================================
    -- Logic: Bone/Wood are "Common" (1.0x). Tire is "Uncommon" (1.25x). 
    -- Magazine is "Junk" (0.5x) because it is fragile.
    
    -- BONE (Moderate protection, accessible)
    { item="Base.Cuirass_Bone",        tags={"Clothing.Armor.Torso", "Theme.Survival", "Rarity.Common"}, basePrice=150, stockRange={min=1, max=5} },
    { item="Base.Necklace_Choker_Bone",tags={"Clothing.Accessory.Neck", "Theme.Survival", "Rarity.Common"}, basePrice=45,  stockRange={min=1, max=7} },
    { item="Base.VambraceBone_Left",   tags={"Clothing.Armor.Arms", "Theme.Survival", "Rarity.Common"}, basePrice=60,  stockRange={min=1, max=7} },
    { item="Base.VambraceBone_Right",  tags={"Clothing.Armor.Arms", "Theme.Survival", "Rarity.Common"}, basePrice=60,  stockRange={min=1, max=7} },
    { item="Base.GreaveBone_Left",     tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=75,  stockRange={min=1, max=7} },
    { item="Base.GreaveBone_Right",    tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=75,  stockRange={min=1, max=7} },
    { item="Base.Shoulderpad_Bone_L",  tags={"Clothing.Armor.Shoulders", "Theme.Survival", "Rarity.Common"}, basePrice=60,  stockRange={min=1, max=7} },
    { item="Base.Shoulderpad_Bone_R",  tags={"Clothing.Armor.Shoulders", "Theme.Survival", "Rarity.Common"}, basePrice=60,  stockRange={min=1, max=7} },
    { item="Base.ThighBone_L",         tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=80,  stockRange={min=1, max=7} },
    { item="Base.ThighBone_R",         tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=80,  stockRange={min=1, max=7} },

    -- WOOD (Basic protection, Carpenter thematic)
    { item="Base.Cuirass_Wood",        tags={"Clothing.Armor.Torso", "Theme.Survival", "Origin.Industrial", "Rarity.Common"}, basePrice=110, stockRange={min=1, max=5} },
    { item="Base.VambraceWood_Left",   tags={"Clothing.Armor.Arms", "Theme.Survival", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=7} },
    { item="Base.VambraceWood_Right",  tags={"Clothing.Armor.Arms", "Theme.Survival", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=7} },
    { item="Base.GreaveWood_Left",     tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=7} },
    { item="Base.GreaveWood_Right",    tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=55, stockRange={min=1, max=7} },
    { item="Base.Shoulderpad_Wood_L",  tags={"Clothing.Armor.Shoulders", "Theme.Survival", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=7} },
    { item="Base.Shoulderpad_Wood_R",  tags={"Clothing.Armor.Shoulders", "Theme.Survival", "Rarity.Common"}, basePrice=45, stockRange={min=1, max=7} },
    { item="Base.ThighWood_L",         tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=60, stockRange={min=1, max=7} },
    { item="Base.ThighWood_R",         tags={"Clothing.Armor.Legs", "Theme.Survival", "Rarity.Common"}, basePrice=60, stockRange={min=1, max=7} },

    -- TIRE (Heavy protection)
    { item="Base.Cuirass_Tire",        tags={"Clothing.Armor.Torso", "Quality.Junk", "Rarity.Uncommon"}, basePrice=180, stockRange={min=0, max=3} },
    { item="Base.VambraceTire_Left",   tags={"Clothing.Armor.Arms", "Quality.Junk", "Rarity.Uncommon"}, basePrice=75, stockRange={min=0, max=4} },
    { item="Base.VambraceTire_Right",  tags={"Clothing.Armor.Arms", "Quality.Junk", "Rarity.Uncommon"}, basePrice=75, stockRange={min=0, max=4} },
    { item="Base.GreaveTire_Left",     tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Uncommon"}, basePrice=90, stockRange={min=0, max=4} },
    { item="Base.GreaveTire_Right",    tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Uncommon"}, basePrice=90, stockRange={min=0, max=4} },
    { item="Base.Shoulderpad_Tire_L",  tags={"Clothing.Armor.Shoulders", "Quality.Junk", "Rarity.Uncommon"}, basePrice=70, stockRange={min=0, max=4} },
    { item="Base.Shoulderpad_Tire_R",  tags={"Clothing.Armor.Shoulders", "Quality.Junk", "Rarity.Uncommon"}, basePrice=70, stockRange={min=0, max=4} },
    { item="Base.ThighTire_L",         tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Uncommon"}, basePrice=100, stockRange={min=0, max=4} },
    { item="Base.ThighTire_R",         tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Uncommon"}, basePrice=100, stockRange={min=0, max=4} },

    -- MAGAZINE (Improvised)
    { item="Base.Cuirass_Magazine",       tags={"Clothing.Armor.Torso", "Quality.Junk", "Rarity.Common"}, basePrice=40, stockRange={min=2, max=10} },
    { item="Base.GreaveMagazine_Left",    tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=10} },
    { item="Base.GreaveMagazine_Right",   tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=10} },
    { item="Base.ThighMagazine_L",        tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Common"}, basePrice=25, stockRange={min=2, max=10} },
    { item="Base.ThighMagazine_R",        tags={"Clothing.Armor.Legs", "Quality.Junk", "Rarity.Common"}, basePrice=25, stockRange={min=2, max=10} },
    { item="Base.VambraceMagazine_Left",  tags={"Clothing.Armor.Arms", "Quality.Junk", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=10} },
    { item="Base.VambraceMagazine_Right", tags={"Clothing.Armor.Arms", "Quality.Junk", "Rarity.Common"}, basePrice=20, stockRange={min=2, max=10} },

    -- =============================================================================
    -- MILITARY & LAW ENFORCEMENT
    -- =============================================================================
    -- Logic: Base prices increased. High tier items get "Rare" (2.0x Price) or "Legendary" (5.0x).
    
    -- VESTS (Tiered)
    { item="Base.Vest_BulletCivilian",    tags={"Clothing.Armor.Vest", "Origin.Police", "Rarity.Uncommon"}, basePrice=450, stockRange={min=1, max=3} }, -- Tactical/Riot Tier
    { item="Base.Vest_BulletPolice",      tags={"Clothing.Armor.Vest", "Origin.Police", "Rarity.Rare"},     basePrice=750, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletArmy",        tags={"Clothing.Armor.Vest", "Origin.Military", "Rarity.Rare"},   basePrice=1200, stockRange={min=0, max=2} }, -- Heavy Armor Tier
    { item="Base.Vest_BulletDesert",      tags={"Clothing.Armor.Vest", "Origin.Military", "Rarity.Rare"},   basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletDesertNew",   tags={"Clothing.Armor.Vest", "Origin.Military", "Rarity.Rare"},   basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletOliveDrab",   tags={"Clothing.Armor.Vest", "Origin.Military", "Rarity.Rare"},   basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.Vest_BulletSWAT",        tags={"Clothing.Armor.Vest", "Origin.Police", "Rarity.Legendary"}, basePrice=1800, stockRange={min=0, max=1} },

    -- LIMB PROTECTION (Military)
    { item="Base.Vambrace_BodyArmour_Left_Army",  tags={"Clothing.Armor.Arms", "Origin.Military", "Rarity.Rare"}, basePrice=250, stockRange={min=0, max=2} },
    { item="Base.Vambrace_BodyArmour_Right_Army", tags={"Clothing.Armor.Arms", "Origin.Military", "Rarity.Rare"}, basePrice=250, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Left_Army",     tags={"Clothing.Armor.Legs", "Origin.Military", "Rarity.Rare"}, basePrice=300, stockRange={min=0, max=2} },
    { item="Base.GreaveBodyArmour_Right_Army",    tags={"Clothing.Armor.Legs", "Origin.Military", "Rarity.Rare"}, basePrice=300, stockRange={min=0, max=2} },
    { item="Base.ThighBodyArmour_L_Army",         tags={"Clothing.Armor.Legs", "Origin.Military", "Rarity.Rare"}, basePrice=350, stockRange={min=0, max=2} },
    { item="Base.ThighBodyArmour_R_Army",         tags={"Clothing.Armor.Legs", "Origin.Military", "Rarity.Rare"}, basePrice=350, stockRange={min=0, max=2} },
    
    -- LIMB PROTECTION (Police)
    { item="Base.Vambrace_BodyArmour_Left_Police", tags={"Clothing.Armor.Arms", "Origin.Police", "Rarity.Uncommon"}, basePrice=180, stockRange={min=0, max=3} },
    { item="Base.Vambrace_BodyArmour_Right_Police",tags={"Clothing.Armor.Arms", "Origin.Police", "Rarity.Uncommon"}, basePrice=180, stockRange={min=0, max=3} },
    { item="Base.GreaveBodyArmour_Left_Police",    tags={"Clothing.Armor.Legs", "Origin.Police", "Rarity.Uncommon"}, basePrice=220, stockRange={min=0, max=3} },
    { item="Base.GreaveBodyArmour_Right_Police",   tags={"Clothing.Armor.Legs", "Origin.Police", "Rarity.Uncommon"}, basePrice=220, stockRange={min=0, max=3} },

    -- =============================================================================
    -- METAL & SPORTS (SPECIALIZED)
    -- =============================================================================

    -- METAL (Heavy Weight Protection)
    { item="Base.Cuirass_Metal",                  tags={"Clothing.Armor.Torso", "Origin.Industrial", "Rarity.Rare"}, basePrice=650, stockRange={min=0, max=2} },
    { item="Base.ShinKneeGuard_L_Metal",          tags={"Clothing.Armor.Legs", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=280, stockRange={min=0, max=4} },
    { item="Base.ShinKneeGuard_R_Metal",          tags={"Clothing.Armor.Legs", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=280, stockRange={min=0, max=4} },
    { item="Base.ShinKneeGuardSpike_L_Metal",     tags={"Clothing.Armor.Legs", "Quality.Luxury", "Rarity.Rare"},      basePrice=450, stockRange={min=0, max=1} },
    { item="Base.ShinKneeGuardSpike_R_Metal",     tags={"Clothing.Armor.Legs", "Quality.Luxury", "Rarity.Rare"},      basePrice=450, stockRange={min=0, max=1} },
    { item="Base.Shoulderpad_Articulated_L_Metal",tags={"Clothing.Armor.Shoulders", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=220, stockRange={min=0, max=4} },
    { item="Base.Shoulderpad_Articulated_R_Metal",tags={"Clothing.Armor.Shoulders", "Origin.Industrial", "Rarity.Uncommon"}, basePrice=220, stockRange={min=0, max=4} },
    
    -- SPORTS (Common)
    { item="Base.Shoulderpads_Football",     tags={"Clothing.Armor.Shoulders", "Rarity.Common"}, basePrice=300, stockRange={min=1, max=5} },
    { item="Base.Shoulderpads_IceHockey",    tags={"Clothing.Armor.Shoulders", "Rarity.Common"}, basePrice=330, stockRange={min=1, max=5} },
    { item="Base.Vest_CatcherVest",          tags={"Clothing.Armor.Torso", "Rarity.Common"},     basePrice=380, stockRange={min=1, max=5} },
    { item="Base.ShinKneeGuard_L_Baseball",  tags={"Clothing.Armor.Legs", "Rarity.Common"},      basePrice=120, stockRange={min=2, max=10} },
    { item="Base.ShinKneeGuard_R_Baseball",  tags={"Clothing.Armor.Legs", "Rarity.Common"},      basePrice=120, stockRange={min=2, max=10} },

    -- =============================================================================
    -- UTILITY, BELTS & BACKPACKS
    -- =============================================================================
    
    -- TACTICAL RIGS
    { item="Base.Bag_ALICE_BeltSus", tags={"Clothing.Utility.Belt", "Origin.Military", "Rarity.Uncommon"}, basePrice=250, stockRange={min=1, max=5} },
    { item="Base.Bag_ChestRig",      tags={"Clothing.Utility.Vest", "Origin.Military", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=5} },
    { item="Base.AmmoStrap_Bullets", tags={"Clothing.Utility.Accessory", "Theme.Survival", "Rarity.Common"}, basePrice=150, stockRange={min=2, max=10} },
    { item="Base.AmmoStrap_Shells",  tags={"Clothing.Utility.Accessory", "Theme.Survival", "Rarity.Common"}, basePrice=150, stockRange={min=2, max=10} },
    { item="Base.HolsterDouble",     tags={"Clothing.Utility.Accessory", "Origin.Police", "Rarity.Rare"},     basePrice=350, stockRange={min=0, max=3} },
    { item="Base.HolsterShoulder",   tags={"Clothing.Utility.Accessory", "Origin.Police", "Rarity.Uncommon"}, basePrice=220, stockRange={min=1, max=5} },
    { item="Base.Belt2",             tags={"Clothing.Utility.Belt", "Rarity.Common"},                      basePrice=50,  stockRange={min=5, max=25} },
    { item="Base.SCBA",              tags={"Clothing.Utility.Mask", "Theme.Hazard", "Rarity.Rare"},        basePrice=850, stockRange={min=0, max=1} },

    -- CONTAINER / BACKPACKS
    -- Military Grade
    { item="Base.Bag_ALICEpack",     tags={"Container.Backpack", "Origin.Military", "Rarity.Rare"}, basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.Bag_SurvivorBag",   tags={"Container.Backpack", "Theme.Survival", "Rarity.Rare"},   basePrice=1100, stockRange={min=0, max=2} },
    { item="Base.ManPackRadio",      tags={"Container.Backpack", "Origin.Military", "Rarity.Rare"}, basePrice=850,  stockRange={min=0, max=2} },
    
    -- Civilian Grade
    { item="Base.Bag_BigHikingBag",    tags={"Container.Backpack", "Theme.Survival", "Rarity.Uncommon"}, basePrice=750, stockRange={min=1, max=4} },
    { item="Base.Bag_NormalHikingBag", tags={"Container.Backpack", "Theme.Survival", "Rarity.Common"},   basePrice=450, stockRange={min=2, max=6} },
    { item="Base.Bag_DuffelBag",       tags={"Container.Backpack", "Rarity.Common"},                  basePrice=250, stockRange={min=5, max=15} },
    { item="Base.Bag_Schoolbag",       tags={"Container.Backpack", "Rarity.Common"},                  basePrice=150, stockRange={min=5, max=15} },
    { item="Base.Bag_GolfBag",         tags={"Container.Backpack", "Rarity.Common"},                  basePrice=180, stockRange={min=1, max=5} },
    
    -- Specialized
    { item="Base.Bag_MedicalBag",      tags={"Container.Backpack", "Origin.Medical", "Rarity.Uncommon"}, basePrice=350, stockRange={min=1, max=5} },

})

print("[DynamicTrading] Clothing Registry Complete \n.")
