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

    -- [Weapon.Melee.Axe] [Rarity.Common] (15 items)
    { item="Base.Axe", basePrice=136, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Axe_Old", basePrice=136, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Axe_Sawblade", basePrice=100, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Axe_Sawblade_Hatchet", basePrice=85, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Axe_ScrapCleaver", basePrice=42, tags={"Weapon.Melee.Axe", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.AxeStone", basePrice=101, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.HandAxe", basePrice=99, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HandAxe_Old", basePrice=98, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.HandAxeForged", basePrice=99, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Hatchet_Bone", basePrice=95, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.IceAxe", basePrice=99, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.JawboneBovide_Axe", basePrice=101, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.StoneAxeLarge", basePrice=147, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.WoodAxe", basePrice=198, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.WoodAxeForged", basePrice=189, tags={"Weapon.Melee.Axe", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Axe Registry Complete")
