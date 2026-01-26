require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- =============================================================================
-- 1. LOOSE ROUNDS (Change for pocket change)
-- =============================================================================
{ item="Base.Bullets38", basePrice=1, tags={"Ammo", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Bullets9mm", basePrice=1, tags={"Ammo", "Common"}, stockRange={min=10, max=50} },
{ item="Base.Bullets45", basePrice=2, tags={"Ammo", "Common"}, stockRange={min=10, max=40} },
{ item="Base.223Bullets", basePrice=2, tags={"Ammo", "Uncommon"}, stockRange={min=5, max=30} },
{ item="Base.ShotgunShells", basePrice=3, tags={"Ammo", "Common"}, stockRange={min=5, max=30} },
{ item="Base.556Bullets", basePrice=4, tags={"Ammo", "Rare"}, stockRange={min=5, max=20} },
{ item="Base.308Bullets", basePrice=5, tags={"Ammo", "Rare"}, stockRange={min=5, max=20} },
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
{ item="Base.223Box",           basePrice=90,  tags={"Ammo", "Uncommon"}, stockRange={min=1, max=6} }, -- 50 rounds
{ item="Base.308Box",           basePrice=90,  tags={"Ammo", "Rare"},     stockRange={min=1, max=5} }, -- 20 rounds
{ item="Base.556Box",           basePrice=180, tags={"Ammo", "Rare", "Military"}, stockRange={min=1, max=4} }, -- 50 rounds (M16 feed)

-- =============================================================================
-- 3. CARTONS (The Whales - Hardcore stockpile items)
-- =============================================================================
-- Calculated: (PerRound * Count) * 0.7 (Massive Discount) but extremely rare spawn

{ item="Base.Bullets38Carton",     basePrice=200,  tags={"Ammo", "Uncommon", "Stockpile"}, stockRange={min=1, max=1} },
{ item="Base.Bullets9mmCarton",    basePrice=420,  tags={"Ammo", "Uncommon", "Stockpile"}, stockRange={min=1, max=1} },
{ item="Base.ShotgunShellsCarton", basePrice=630,  tags={"Ammo", "Rare", "Stockpile"},     stockRange={min=1, max=1} }, -- The holy grail
{ item="Base.Bullets45Carton",     basePrice=500,  tags={"Ammo", "Rare", "Stockpile"},     stockRange={min=1, max=1} },

-- Military Cartons (Extremely expensive, usually only via "Surplus" Event or high tier traders)
{ item="Base.223Carton",           basePrice=840,  tags={"Ammo", "Rare", "Stockpile"},     stockRange={min=0, max=1} },
{ item="Base.308Carton",           basePrice=840,  tags={"Ammo", "Legendary", "Stockpile"},stockRange={min=0, max=1} },
{ item="Base.556Carton",           basePrice=1600, tags={"Ammo", "Legendary", "Stockpile"},stockRange={min=0, max=1} }, -- M16 for days

-- =============================================================================
-- 4. MAGAZINES (Essential for operation)
-- =============================================================================
-- Common Pistols
{ item="Base.9mmClip",  basePrice=20, tags={"Weapon", "Magazine", "Common"}, stockRange={min=1, max=5} }, -- M9
{ item="Base.45Clip",   basePrice=25, tags={"Weapon", "Magazine", "Uncommon"}, stockRange={min=1, max=4} }, -- M1911
{ item="Base.44Clip",   basePrice=35, tags={"Weapon", "Magazine", "Rare"},   stockRange={min=1, max=3} }, -- D-E (Rare gun)

-- Rifles (High value because the guns are paperweights without them)
{ item="Base.M14Clip",  basePrice=60, tags={"Weapon", "Magazine", "Rare"},   stockRange={min=0, max=3} }, -- 20 rounds
{ item="Base.556Clip",  basePrice=80, tags={"Weapon", "Magazine", "Legendary", "Military"}, stockRange={min=0, max=2} } -- M16 (30 rounds)
})

print("[DynamicTrading] Ammo Registry Complete.")
