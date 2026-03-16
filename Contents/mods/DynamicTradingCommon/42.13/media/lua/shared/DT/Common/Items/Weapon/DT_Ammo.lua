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
    { item="Base.3030Box", basePrice=14, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.3030Bullets", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.3030Carton", basePrice=12, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.308Box", basePrice=14, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.308Bullets", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.308Carton", basePrice=12, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.556Box", basePrice=17, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.556Bullets", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.556Carton", basePrice=14, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bullets357", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.Bullets357Box", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bullets357Carton", basePrice=5, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Bullets38", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.Bullets38Box", basePrice=8, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bullets38Carton", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Bullets44", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.Bullets44Box", basePrice=6, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bullets44Carton", basePrice=4, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Bullets45", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.Bullets45Box", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bullets45Carton", basePrice=5, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Bullets9mm", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=100} },
    { item="Base.Bullets9mmBox", basePrice=8, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Bullets9mmCarton", basePrice=7, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.ShotgunShells", basePrice=19, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.ShotgunShellsBox", basePrice=4, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.ShotgunShellsCarton", basePrice=3, tags={"Weapon.Ranged.Ammo", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Ammo Registry Complete")
