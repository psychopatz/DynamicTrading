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
    { item="Base.AssaultRifle", basePrice=403, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AssaultRifle2", basePrice=441, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgun", basePrice=433, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DoubleBarrelShotgunSawnoff", basePrice=396, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.HuntingRifle", basePrice=442, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS14_Rifle", basePrice=404, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.JS3T_Shotgun", basePrice=420, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L92_Carbine", basePrice=370, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.L94_Rifle", basePrice=402, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.MSR7T_Rifle", basePrice=441, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Pistol", basePrice=311, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol2", basePrice=306, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Pistol3", basePrice=332, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver", basePrice=309, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Revolver_CapGun", basePrice=232, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Revolver_Long", basePrice=336, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Revolver_Short", basePrice=279, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Rifle_CapGun", basePrice=242, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Shotgun", basePrice=421, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ShotgunSawnoff", basePrice=390, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.TrapperCarbine", basePrice=340, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.VarmintRifle", basePrice=393, tags={"Weapon.Ranged.Firearm", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Ranged Registry Complete")
