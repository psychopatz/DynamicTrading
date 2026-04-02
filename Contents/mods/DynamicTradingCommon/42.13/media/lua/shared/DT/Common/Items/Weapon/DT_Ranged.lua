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
    { item="Base.AssaultRifle", basePrice=427, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2", basePrice=465, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgun", basePrice=457, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgunSawnoff", basePrice=421, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.HuntingRifle", basePrice=466, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS14_Rifle", basePrice=428, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS3T_Shotgun", basePrice=444, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L92_Carbine", basePrice=394, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L94_Rifle", basePrice=426, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.MSR7T_Rifle", basePrice=465, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Pistol", basePrice=335, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol2", basePrice=330, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol3", basePrice=356, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver", basePrice=333, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Revolver_CapGun", basePrice=256, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Revolver_Long", basePrice=360, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short", basePrice=303, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Rifle_CapGun", basePrice=266, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Shotgun", basePrice=445, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ShotgunSawnoff", basePrice=415, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.TrapperCarbine", basePrice=364, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.VarmintRifle", basePrice=417, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Ranged Registry Complete")
