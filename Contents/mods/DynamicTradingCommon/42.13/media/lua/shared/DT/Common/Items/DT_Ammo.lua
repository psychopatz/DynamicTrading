require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- =============================================================================
-- 1. LOOSE ROUNDS (Change for pocket change)
-- =============================================================================
{ item="Base.Bullets38", basePrice=1, tags={"Ammo", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Bullets9mm", basePrice=1, tags={"Ammo", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Bullets45", basePrice=2, tags={"Ammo", "Common"}, stockRange={min=10, max=40} },
{ item="Base.ShotgunShells", basePrice=3, tags={"Ammo", "Common"}, stockRange={min=5, max=30} },
{ item="Base.Bullets44", basePrice=6, tags={"Ammo", "Rare"}, stockRange={min=2, max=15} },
-- =============================================================================
-- 2. AMMO BOXES (Standard Trade Units)
-- =============================================================================
-- Calculated: (PerRound * Count) * 0.9 (Bulk Discount)

-- Civilian / Police
{ item="Base.Bullets38Box",     basePrice=22,  tags={"Ammo", "Common"}, stockRange={min=2, max=10} }, -- 50 rounds
{ item="Base.Bullets9mmBox",    basePrice=45,  tags={"Ammo", "Common"}, stockRange={min=2, max=10} }, -- 50 rounds
{ item="Base.ShotgunShellsBox", basePrice=65,  tags={"Ammo", "Common"}, stockRange={min=2, max=8} },  -- 25 rounds
{ item="Base.Bullets45Box",     basePrice=55,  tags={"Ammo", "Uncommon"}, stockRange={min=1, max=8} }, -- 50 rounds
{ item="Base.Bullets44Box",     basePrice=100, tags={"Ammo", "Rare"},   stockRange={min=1, max=5} },  -- 20 rounds (High value)

-- Rifle / Military
-- (Rifle ammo boxes handled via sub-components if applicable, or currently removed as Base.223Box etc are missing)

-- =============================================================================
-- 3. CARTONS (The Whales - Hardcore stockpile items)
-- =============================================================================
-- Calculated: (PerRound * Count) * 0.7 (Massive Discount) but extremely rare spawn

{ item="Base.Bullets38Carton",     basePrice=200,  tags={"Ammo", "Uncommon", "Stockpile"}, stockRange={min=1, max=1} },
{ item="Base.Bullets9mmCarton",    basePrice=420,  tags={"Ammo", "Uncommon", "Stockpile"}, stockRange={min=1, max=1} },
{ item="Base.ShotgunShellsCarton", basePrice=630,  tags={"Ammo", "Rare", "Stockpile"},     stockRange={min=1, max=1} }, -- The holy grail
{ item="Base.Bullets45Carton",     basePrice=500,  tags={"Ammo", "Rare", "Stockpile"},     stockRange={min=1, max=1} },

-- Military Cartons (Extremely expensive, usually only via "Surplus" Event or high tier traders)

-- =============================================================================
-- 4. MAGAZINES (Essential for operation)
-- =============================================================================
-- Common Pistols
-- Magazines are currently missing in vanilla or renamed (e.g., 9mmClip, 45Clip, 44Clip, 556Clip)

-- Rifles (High value because the guns are paperweights without them)
{ item="Base.M14Clip",  basePrice=60, tags={"Weapon", "Magazine", "Rare"},   stockRange={min=0, max=3} }, -- 20 rounds
})

print("[DynamicTrading] Ammo Registry Complete \n.")
