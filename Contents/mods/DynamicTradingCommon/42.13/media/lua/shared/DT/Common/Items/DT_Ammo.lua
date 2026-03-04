require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- =============================================================================
-- 1. LOOSE ROUNDS (Change for pocket change)
-- =============================================================================
{ item="Base.Bullets38", basePrice=4, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=100} },
{ item="Base.Bullets9mm", basePrice=5, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=100} },
{ item="Base.Bullets45", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=20, max=80} },
{ item="Base.ShotgunShells", basePrice=10, tags={"Weapon.Ranged.Ammo", "Rarity.Common"}, stockRange={min=10, max=50} },
{ item="Base.Bullets44", basePrice=15, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=5, max=25} },
-- =============================================================================
-- 2. AMMO BOXES (Standard Trade Units)
-- =============================================================================
-- Calculated: (PerRound * Count) * 0.9 (Bulk Discount)

-- Civilian / Police
{ item="Base.Bullets38Box",     basePrice=180,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=12} }, -- 50 rounds
{ item="Base.Bullets9mmBox",    basePrice=225,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=12} }, -- 50 rounds
{ item="Base.ShotgunShellsBox", basePrice=225,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Common"}, stockRange={min=2, max=10} }, -- 25 rounds
{ item="Base.Bullets45Box",     basePrice=315,  tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Uncommon"}, stockRange={min=1, max=8} }, -- 50 rounds
{ item="Base.Bullets44Box",     basePrice=270, tags={"Weapon.Ranged.Ammo", "Origin.Police", "Rarity.Rare"},   stockRange={min=1, max=5} },  -- 20 rounds

-- Rifle / Military
-- (Rifle ammo boxes handled via sub-components if applicable, or currently removed as Base.223Box etc are missing)

-- =============================================================================
-- 3. CARTONS (The Whales - Hardcore stockpile items)
-- =============================================================================
-- Calculated: (PerRound * Count) * 0.7 (Massive Discount) but extremely rare spawn

{ item="Base.Bullets38Carton",     basePrice=1400, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Rare"}, stockRange={min=1, max=2} },
{ item="Base.Bullets9mmCarton",    basePrice=1750, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Rare"}, stockRange={min=1, max=2} },
{ item="Base.ShotgunShellsCarton", basePrice=1750, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },
{ item="Base.Bullets45Carton",     basePrice=2450, tags={"Weapon.Ranged.Ammo", "Origin.Militia", "Rarity.Legendary"}, stockRange={min=0, max=1} },

-- Military Cartons (Extremely expensive, usually only via "Surplus" Event or high tier traders)

-- =============================================================================
-- 4. MAGAZINES (Essential for operation)
-- =============================================================================
-- Common Pistols
-- Magazines are currently missing in vanilla or renamed (e.g., 9mmClip, 45Clip, 44Clip, 556Clip)

-- Rifles (High value because the guns are paperweights without them)
{ item="Base.M14Clip",  basePrice=250, tags={"Weapon.Part.Magazine", "Origin.Militia", "Rarity.Rare"},   stockRange={min=1, max=3} }, -- 20 rounds
})

print("[DynamicTrading] Ammo Registry Complete \n.")
