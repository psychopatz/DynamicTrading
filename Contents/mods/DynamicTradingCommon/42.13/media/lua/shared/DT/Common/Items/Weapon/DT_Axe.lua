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

    -- [Weapon.Melee.Axe] [Rarity.Common] (17 items)
    { item="Base.Axe", basePrice=3, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Old", basePrice=3, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Sawblade", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Sawblade_Hatchet", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Axe_ScrapCleaver", basePrice=2, tags={"Weapon.Melee.Axe", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.AxeStone", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.HandAxe", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.HandAxe_Old", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.HandAxeForged", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Hatchet_Bone", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.IceAxe", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.JawboneBovide_Axe", basePrice=1, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.PickAxe", basePrice=2, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.PickAxeForged", basePrice=2, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.StoneAxeLarge", basePrice=3, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.WoodAxe", basePrice=12, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.WoodAxeForged", basePrice=8, tags={"Weapon.Melee.Axe", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Axe Registry Complete")
