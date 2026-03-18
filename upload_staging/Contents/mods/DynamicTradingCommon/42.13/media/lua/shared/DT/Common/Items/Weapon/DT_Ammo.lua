-- ============================================================================
-- Weapon Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Weapon.Ranged.Ammo] [Rarity.Rare] (27 items)
    { item="Base.3030Box", basePrice=93, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.3030Bullets", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.3030Carton", basePrice=268, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.308Box", basePrice=93, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.308Bullets", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.308Carton", basePrice=268, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.556Box", basePrice=87, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.556Bullets", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.556Carton", basePrice=232, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.Bullets357", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.Bullets357Box", basePrice=116, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Bullets357Carton", basePrice=412, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Bullets38", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.Bullets38Box", basePrice=104, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Bullets38Carton", basePrice=340, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Bullets44", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.Bullets44Box", basePrice=128, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Bullets44Carton", basePrice=484, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Bullets45", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.Bullets45Box", basePrice=116, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Bullets45Carton", basePrice=412, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Bullets9mm", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=24} },
    { item="Base.Bullets9mmBox", basePrice=104, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Bullets9mmCarton", basePrice=340, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ShotgunShells", basePrice=61, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.ShotgunShellsBox", basePrice=145, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.ShotgunShellsCarton", basePrice=592, tags={"Weapon.Ranged.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Ammo Registry Complete")
