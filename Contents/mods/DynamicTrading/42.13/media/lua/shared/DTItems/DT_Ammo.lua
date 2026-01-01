require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION (As defined in DT_Ammo.lua)
-- ==========================================================
local function RegisterAmmo(commonTags, items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)
        local finalTags = {"Ammo"}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Ammo",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Balanced for Project Zomboid 42.13)
-- ==========================================================


-- ==========================================================
-- DYNAMIC TRADING: LOOSE AMMUNITION ONLY
-- Inner Workings:
-- 1. BASE PRICING: Scaled by caliber stopping power. .38 is the floor (1), while 5.56/308 are premium (8-10).
-- 2. STOCK: Common civilian rounds (9mm, .38) have high availability. Military/Hunting rounds are restricted.
-- 3. TAGGING: Assigned based on the "MerchantTypes" logic (Police, Hunting, Military).
-- ==========================================================

RegisterAmmo({}, {
    -- ID: Base.223Bullets | Use: Varmint/Hunting | Tier: Mid-High
    { item="Base.223Bullets",    price=7,  min=5,  max=20, tags={"Hunting"},          id="Buy223Loose" },
    
    -- ID: Base.308Bullets | Use: Sniper/Hunting | Tier: High (Damage)
    { item="Base.308Bullets",    price=9,  min=5,  max=15, tags={"Hunting", "Rare"},  id="Buy308Loose" },
    
    -- ID: Base.Bullets38 | Use: Low-caliber Civil | Tier: Baseline
    { item="Base.Bullets38",     price=1,  min=15, max=50, tags={"Police"},           id="Buy38Loose" },
    
    -- ID: Base.Bullets44 | Use: Magnum Revolver | Tier: High (Rarity)
    { item="Base.Bullets44",     price=5,  min=5,  max=15, tags={"Rare"},             id="Buy44Loose" },
    
    -- ID: Base.Bullets45 | Use: Heavy Handgun | Tier: Mid
    { item="Base.Bullets45",     price=3,  min=10, max=40, tags={"Police"},           id="Buy45Loose" },
    
    -- ID: Base.556Bullets | Use: Military Rifle | Tier: Top
    { item="Base.556Bullets",    price=10, min=5,  max=15, tags={"Military", "Rare"}, id="Buy556Loose" },
    
    -- ID: Base.Bullets9mm | Use: Standard Sidearm | Tier: Common
    { item="Base.Bullets9mm",    price=2,  min=15, max=50, tags={"Police"},           id="Buy9mmLoose" },
    
    -- ID: Base.ShotgunShells | Use: Crowd Control | Tier: High (Utility)
    { item="Base.ShotgunShells", price=6,  min=8,  max=24, tags={"Hunting", "Police"},id="BuyShotgunLoose" },
})

-- ==========================================================
-- DYNAMIC TRADING: AMMUNITION BOXES
-- Inner Workings & Balancing:
-- 1. PRICING: Scaled by round count (20 vs 25 vs 50) and stopping power. 
--    .308 and 5.56 are highest tier due to rifle/military utility. 
--    Shotgun shells are mid-high due to high clearing efficiency.
-- 2. AVAILABILITY: Handgun boxes (9mm, .38) have higher stock (min/max). 
--    Rifle and Magnum boxes are more restricted to balance high-tier gameplay.
-- 3. TAGS: Mapped for Gunrunner, Police, Hunting, and Military merchants.
-- ==========================================================

RegisterAmmo({"Gun"}, {
    -- .38 Special (50 Rounds) - Lowest power civilian round.
    { item="Base.Bullets38Box",       price=25, min=3, max=10, tags={"Police"},            id="Buy38Box" },
    
    -- .44 Magnum (20 Rounds) - Rare, high-damage handgun round.
    { item="Base.Bullets44Box",       price=55, min=1, max=4,  tags={"Rare"},              id="Buy44Box" },
    
    -- .45 Auto (50 Rounds) - Standard police stopping power.
    { item="Base.Bullets45Box",       price=45, min=2, max=6,  tags={"Police"},            id="Buy45Box" },
    
    -- .223 Round (50 Rounds) - Long-range hunting caliber.
    { item="Base.223Box",             price=70, min=1, max=4,  tags={"Hunting"},           id="Buy223Box" },
    
    -- .308 Round (20 Rounds) - Top-tier sniper/hunting damage.
    { item="Base.308Box",             price=80, min=1, max=3,  tags={"Hunting", "Rare"},   id="Buy308Box" },
    
    -- 5.56mm Round (50 Rounds) - Military grade, high fire rate utility.
    { item="Base.556Box",             price=95, min=1, max=3,  tags={"Military", "Rare"},  id="Buy556Box" },
    
    -- 9mm Round (50 Rounds) - Most common reliable sidearm round.
    { item="Base.Bullets9mmBox",      price=35, min=3, max=8,  tags={"Police"},            id="Buy9mmBox" },
    
    -- Shotgun Shells (25 Rounds) - Essential for horde management.
    { item="Base.ShotgunShellsBox",   price=65, min=2, max=6,  tags={"Hunting", "Police"}, id="BuyShotgunBox" },
})


-- ==========================================================
-- DYNAMIC TRADING: WEAPON MAGAZINES
-- Inner Workings & Balancing:
-- 1. PRICING: Magazines are valued higher than ammunition boxes because they are 
--    reusable and critical for semi-auto/automatic weapon functionality.
--    - M16 (5.56) is top-tier due to 30-round capacity and military application.
--    - M14 (308) and D-E (44) are premium due to high stopping power/rarity.
--    - M9 and M1911 are standard police/civilian tier.
-- 2. STOCK: High-tier magazines (M16, M14, D-E) have a minimum stock of 0, 
--    making them rare finds at traders.
-- 3. TAGS: "Military" and "Rare" tags ensure these appear mostly at Gunrunners.
-- ==========================================================

RegisterAmmo({"Gun"}, {
    -- Desert Eagle Magazine (8 Rounds .44)
    { item="Base.44Clip",  price=85,  min=0, max=2, tags={"Rare"},      id="Buy44Clip" },
    
    -- M9 Beretta Magazine (15 Rounds 9mm)
    { item="Base.9mmClip",  price=65,  min=1, max=4, tags={"Police"},    id="Buy9mmClip" },
    
    -- M14 Rifle Magazine (20 Rounds .308)
    { item="Base.M14Clip", price=110, min=0, max=2, tags={"Hunting"},   id="BuyM14Clip" },
    
    -- M16 Assault Rifle Magazine (30 Rounds 5.56)
    { item="Base.556Clip", price=140, min=0, max=2, tags={"Military"},  id="Buy556Clip" },
    
    -- M1911 Magazine (7 Rounds .45)
    { item="Base.45Clip",  price=60,  min=1, max=3, tags={"Police"},    id="Buy45Clip" },
})

-- 1. EXPLOSIVE DEVICES (High Lethality)
RegisterTrap({
    { item="Base.PipeBomb",             price=180, min=1, max=4, tags={"Demolition", "Gunrunner"} },
    { item="Base.PipeBombSensorV1",     price=240, min=0, max=2, tags={"Demolition", "Engineer"} },
    { item="Base.PipeBombSensorV2",     price=260, min=0, max=1, tags={"Demolition", "Engineer"} },
    { item="Base.PipeBombSensorV3",     price=280, min=0, max=1, tags={"Demolition", "Engineer"} },
    { item="Base.PipeBombRemote",       price=350, min=0, max=1, tags={"Demolition", "Engineer"} },
    
    { item="Base.Aerosolbomb",          price=130, min=1, max=5, tags={"Demolition"} },
    { item="Base.AerosolbombSensorV1",  price=180, min=0, max=2, tags={"Demolition", "Engineer"} },
    { item="Base.AerosolbombSensorV2",  price=200, min=0, max=2, tags={"Demolition", "Engineer"} },
    { item="Base.AerosolbombSensorV3",  price=220, min=0, max=1, tags={"Demolition", "Engineer"} },
    { item="Base.AerosolbombRemote",    price=280, min=0, max=1, tags={"Demolition", "Engineer"} },
})

-- 2. INCENDIARY DEVICES (Area Denial)
RegisterTrap({
    { item="Base.Molotov",              price=90,  min=2, max=6, tags={"Arsonist", "Survivalist"} },
    { item="Base.FlameTrap",            price=110, min=1, max=4, tags={"Arsonist"} },
    { item="Base.FlameTrapSensorV1",    price=160, min=0, max=2, tags={"Arsonist", "Engineer"} },
    { item="Base.FlameTrapSensorV2",    price=180, min=0, max=1, tags={"Arsonist", "Engineer"} },
    { item="Base.FlameTrapSensorV3",    price=200, min=0, max=1, tags={"Arsonist", "Engineer"} },
    { item="Base.FlameTrapRemote",      price=250, min=0, max=1, tags={"Arsonist", "Engineer"} },
})

-- 3. DISTRACTION & STEALTH (Non-Lethal)
RegisterTrap({
    { item="Base.Firecracker",          price=15,  min=5, max=15, tags={"Stealth", "Junk"} },
    { item="Base.Firecracker_Crafted",  price=10,  min=2, max=10, tags={"Stealth", "Survivalist"} },
    
    { item="Base.NoiseTrap",            price=50,  min=2, max=6,  tags={"Stealth", "Scavenger"} },
    { item="Base.NoiseTrapSensorV1",    price=90,  min=0, max=2,  tags={"Stealth", "Engineer"} },
    { item="Base.NoiseTrapSensorV2",    price=110, min=0, max=2,  tags={"Stealth", "Engineer"} },
    { item="Base.NoiseTrapSensorV3",    price=130, min=0, max=1,  tags={"Stealth", "Engineer"} },
    { item="Base.NoiseTrapRemote",      price=160, min=0, max=1,  tags={"Stealth", "Engineer"} },
    
    { item="Base.SmokeBomb",            price=40,  min=2, max=6,  tags={"Stealth"} },
    { item="Base.SmokeBombSensorV1",    price=75,  min=0, max=2,  tags={"Stealth", "Engineer"} },
    { item="Base.SmokeBombSensorV2",    price=90,  min=0, max=2,  tags={"Stealth", "Engineer"} },
    { item="Base.SmokeBombSensorV3",    price=110, min=0, max=1,  tags={"Stealth", "Engineer"} },
    { item="Base.SmokeBombRemote",      price=140, min=0, max=1,  tags={"Stealth", "Engineer"} },
})