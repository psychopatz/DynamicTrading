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
    { item="Base.Axe", basePrice=112, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Old", basePrice=112, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Sawblade", basePrice=76, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Axe_Sawblade_Hatchet", basePrice=61, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Axe_ScrapCleaver", basePrice=35, tags={"Weapon.Melee.Axe", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.AxeStone", basePrice=77, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.HandAxe", basePrice=75, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.HandAxe_Old", basePrice=74, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.HandAxeForged", basePrice=75, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Hatchet_Bone", basePrice=71, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.IceAxe", basePrice=75, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.JawboneBovide_Axe", basePrice=77, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.StoneAxeLarge", basePrice=123, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.WoodAxe", basePrice=174, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.WoodAxeForged", basePrice=165, tags={"Weapon.Melee.Axe", "Rarity.Common"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Axe Registry Complete")
