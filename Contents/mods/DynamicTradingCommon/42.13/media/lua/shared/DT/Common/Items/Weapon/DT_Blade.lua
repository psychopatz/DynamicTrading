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

    -- [Weapon.Melee.Blade] [Rarity.Common] (59 items)
    { item="Base.BaseballBat_Metal_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.BreadKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ButterKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.ButterKnife_Gold", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Luxury", "Weapon.Melee"}, stockRange={min=1, max=6} },
    { item="Base.ButterKnife_Silver", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.CrudeKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.CrudeShortSword", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.CrudeSword", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.CrudeSword_Broken", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Cudgel_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=0, max=2} },
    { item="Base.DullBoneKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.FieldHockeyStick_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.FightingKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.FlintKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.HuntingKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.HuntingKnifeForged", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Katana", basePrice=2, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Katana_Broken", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.KitchenKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.KitchenKnifeForged", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.KnifeButterfly", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.KnifeFillet", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.KnifeParing", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.KnifePocket", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.KnifeShiv", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.KnifeSushi", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.LargeKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.LargeKnife_Scrap", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.LongCrudeKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.LongHandle_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Machete", basePrice=2, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Machete_Crude", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.MacheteForged", basePrice=2, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.MacheteKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.MeatCleaver", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.MeatCleaver_Scrap", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.MeatCleaverForged", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Plank_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.RailroadSpikeKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.Scalpel", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.ShortBat_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.ShortSword", basePrice=2, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.ShortSword_Scrap", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SmallKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.SpearFightingKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearHuntingKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearKnifeSmall", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearLargeKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearScrapKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SpearSteakKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.SteakKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=3, max=15} },
    { item="Base.StoneKnifeLong", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Sword", basePrice=2, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Sword_Broken", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=2, max=10} },
    { item="Base.Sword_Scrap", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.Sword_Scrap_Broken", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Weapon.Melee"}, stockRange={min=1, max=5} },
    { item="Base.TableLeg_Sawblade", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Common", "Weapon.Melee"}, stockRange={min=1, max=5} },

    -- [Weapon.Melee.Blade] [Rarity.Rare] (2 items)
    { item="Base.Handiknife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Weapon.Melee"}, stockRange={min=0, max=6} },
    { item="Base.SwitchKnife", basePrice=1, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Weapon.Melee"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Blade Registry Complete")
