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

    -- [Weapon.Ranged.Firearm] [Rarity.Common] (22 items)
    { item="Base.AssaultRifle", basePrice=875, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2", basePrice=913, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgun", basePrice=905, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgunSawnoff", basePrice=868, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.HuntingRifle", basePrice=914, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS14_Rifle", basePrice=876, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS3T_Shotgun", basePrice=892, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L92_Carbine", basePrice=842, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L94_Rifle", basePrice=874, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.MSR7T_Rifle", basePrice=913, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Pistol", basePrice=783, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol2", basePrice=778, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol3", basePrice=804, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver", basePrice=781, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Revolver_CapGun", basePrice=704, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Revolver_Long", basePrice=808, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short", basePrice=751, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Rifle_CapGun", basePrice=714, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Shotgun", basePrice=893, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ShotgunSawnoff", basePrice=862, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.TrapperCarbine", basePrice=812, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.VarmintRifle", basePrice=865, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Ranged Registry Complete")
