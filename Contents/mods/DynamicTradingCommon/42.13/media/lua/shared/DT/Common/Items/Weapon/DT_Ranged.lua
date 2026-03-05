-- =============================================================================
-- DYNAMIC TRADING: WEAPON - RANGED
-- =============================================================================
-- Root Category: Weapon
-- Sub Category: Ranged
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Aerosolbomb",        tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Uncommon"}, basePrice=150, stockRange={min=1, max=3} },
    { item="Base.AerosolbombSensorV3",tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Legendary"}, basePrice=650, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle",           tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Legendary"},basePrice=2500, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2",          tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Rare"},   basePrice=1800, stockRange={min=0, max=1} },
    { item="Base.Bullets38", basePrice=4, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=100} },
    { item="Base.Bullets38Box",     basePrice=180,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=12} }, -- 50 rounds,
    { item="Base.Bullets38Carton",     basePrice=1400, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Rare"}, stockRange={min=1, max=2} },
    { item="Base.Bullets44", basePrice=15, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=5, max=25} },
    { item="Base.Bullets44Box",     basePrice=270, tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Rare"},   stockRange={min=1, max=5} },  -- 20 rounds,
    { item="Base.Bullets45", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=80} },
    { item="Base.Bullets45Box",     basePrice=315,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Uncommon"}, stockRange={min=1, max=8} }, -- 50 rounds,
    { item="Base.Bullets45Carton",     basePrice=2450, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.Bullets9mm", basePrice=5, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=100} },
    { item="Base.Bullets9mmBox",    basePrice=225,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=12} }, -- 50 rounds,
    { item="Base.Bullets9mmCarton",    basePrice=1750, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Rare"}, stockRange={min=1, max=2} },
    { item="Base.DoubleBarrelShotgun",    tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Uncommon"}, basePrice=850, stockRange={min=0, max=2} },
    { item="Base.FlameTrap",          tags={"Weapon.Ranged.Explosive", "Theme.Survival", "Rarity.Rare"},      basePrice=350, stockRange={min=0, max=2} },
    { item="Base.HuntingRifle",           tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Uncommon"},  basePrice=1200, stockRange={min=0, max=2} },
    { item="Base.Molotov",            tags={"Weapon.Ranged.Explosive", "Theme.Survival", "Rarity.Common"},    basePrice=180, stockRange={min=1, max=4} },
    { item="Base.NoiseTrap",          tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Common"},   basePrice=85,  stockRange={min=2, max=6} },
    { item="Base.NoiseTrapSensorV3",  tags={"Weapon.Ranged.Explosive", "Origin.Civ", "Rarity.Rare"},      basePrice=350, stockRange={min=0, max=1} },
    { item="Base.PipeBomb",           tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Uncommon"}, basePrice=280, stockRange={min=1, max=3} },
    { item="Base.PipeBombRemote",     tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Rare"},     basePrice=450, stockRange={min=0, max=1} },
    { item="Base.Pistol",                 tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"},   basePrice=600, stockRange={min=0, max=3} }, -- Scaling 500-1000,
    { item="Base.Pistol2",                tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=750, stockRange={min=0, max=2} },
    { item="Base.Pistol3",                tags={"Weapon.Ranged.Firearm", "Origin.Militia", "Rarity.Rare"},   basePrice=950, stockRange={min=0, max=1} },
    { item="Base.Revolver",               tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=650, stockRange={min=0, max=2} },
    { item="Base.Revolver_Long",          tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Rare"},    basePrice=850, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short",         tags={"Weapon.Ranged.Firearm", "Rarity.Common"},                  basePrice=450, stockRange={min=1, max=3} },
    { item="Base.Shotgun",                tags={"Weapon.Ranged.Firearm", "Origin.Police", "Rarity.Uncommon"}, basePrice=900, stockRange={min=0, max=2} },
    { item="Base.ShotgunSawnoff",         tags={"Weapon.Ranged.Firearm", "Theme.Survival", "Rarity.Rare"},    basePrice=750, stockRange={min=0, max=1} },
    { item="Base.ShotgunShells", basePrice=10, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=10, max=50} },
    { item="Base.ShotgunShellsBox", basePrice=225,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=10} }, -- 25 rounds,
    { item="Base.ShotgunShellsCarton", basePrice=1750, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBomb",          tags={"Weapon.Ranged.Explosive", "Origin.Militia", "Rarity.Common"},    basePrice=110, stockRange={min=1, max=5} },
    { item="Base.VarmintRifle",           tags={"Weapon.Ranged.Firearm", "Theme.Hunting", "Rarity.Common"},    basePrice=800,  stockRange={min=1, max=3} },
})

print("[DynamicTrading] Weapon/Ranged Registry Loaded.")
