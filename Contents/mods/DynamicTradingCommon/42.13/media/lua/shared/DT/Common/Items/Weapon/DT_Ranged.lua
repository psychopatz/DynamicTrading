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

    -- [Weapon.Firearm.Ranged] [Rarity.Common] (16 items)
    { item="Base.AssaultRifle", basePrice=36, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.AssaultRifle2", basePrice=33, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.DoubleBarrelShotgun", basePrice=36, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.DoubleBarrelShotgunSawnoff", basePrice=30, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.HuntingRifle", basePrice=35, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Pistol", basePrice=51, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Pistol2", basePrice=51, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Pistol3", basePrice=46, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Revolver", basePrice=55, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Revolver_CapGun", basePrice=66, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.Revolver_Long", basePrice=47, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Revolver_Short", basePrice=50, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Rifle_CapGun", basePrice=44, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Shotgun", basePrice=33, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.ShotgunSawnoff", basePrice=20, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.VarmintRifle", basePrice=34, tags={"Weapon.Firearm.Ranged", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Ranged Registry Complete")
