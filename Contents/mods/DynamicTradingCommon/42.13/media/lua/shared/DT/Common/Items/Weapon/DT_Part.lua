-- =============================================================================
-- DYNAMIC TRADING: WEAPON - PART
-- =============================================================================
-- Root Category: Weapon
-- Sub Category: Part
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.AmmoStraps",         tags={"Weapon.Part.Utility", "Rarity.Common"},                  basePrice=120, stockRange={min=1, max=3} },
    { item="Base.ChokeTubeFull",      tags={"Weapon.Part.Barrel", "Theme.Hunting", "Rarity.Uncommon"}, basePrice=180, stockRange={min=0, max=2} },
    { item="Base.GunLight",           tags={"Weapon.Part.Utility", "Origin.Police", "Rarity.Uncommon"}, basePrice=180, stockRange={min=1, max=4} },
    { item="Base.Laser",              tags={"Weapon.Part.Utility", "Origin.Militia", "Rarity.Rare"},   basePrice=450, stockRange={min=0, max=1} },
    { item="Base.M14Clip",  basePrice=250, tags={"Weapon.Part.Magazine", "Origin.Militia", "Rarity.Rare"},   stockRange={min=1, max=3} }, -- 20 rounds,
    { item="Base.RecoilPad",          tags={"Weapon.Part.Utility", "Rarity.Common"},                  basePrice=110, stockRange={min=1, max=3} },
    { item="Base.RedDot",             tags={"Weapon.Part.Sight", "Origin.Militia", "Rarity.Uncommon"}, basePrice=320, stockRange={min=1, max=2} },
    { item="Base.x2Scope",            tags={"Weapon.Part.Sight", "Rarity.Common"},                  basePrice=210, stockRange={min=1, max=3} },
    { item="Base.x4Scope",            tags={"Weapon.Part.Sight", "Theme.Hunting", "Rarity.Uncommon"},  basePrice=380, stockRange={min=0, max=2} },
    { item="Base.x8Scope",            tags={"Weapon.Part.Sight", "Origin.Militia", "Rarity.Rare"},    basePrice=650, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Weapon/Part Registry Loaded.")
