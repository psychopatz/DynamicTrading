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

    -- [Weapon.Melee.Blade] [Rarity.Common] (58 items)
    { item="Base.BaseballBat_Metal_Sawblade", basePrice=70, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.BaseballBat_Sawblade", basePrice=61, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.BreadKnife", basePrice=34, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.ButterKnife", basePrice=27, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.ButterKnife_Gold", basePrice=36, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Luxury"}, stockRange={min=1, max=6} },
    { item="Base.ButterKnife_Silver", basePrice=25, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.CrudeKnife", basePrice=50, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.CrudeShortSword", basePrice=97, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.CrudeSword", basePrice=130, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.CrudeSword_Broken", basePrice=27, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=2, max=10} },
    { item="Base.Cudgel_Sawblade", basePrice=74, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=0, max=2} },
    { item="Base.DullBoneKnife", basePrice=23, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.FieldHockeyStick_Sawblade", basePrice=56, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.FightingKnife", basePrice=65, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.FlintKnife", basePrice=43, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.HuntingKnife", basePrice=68, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.HuntingKnifeForged", basePrice=68, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Katana", basePrice=291, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Katana_Broken", basePrice=30, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=2, max=10} },
    { item="Base.KitchenKnife", basePrice=50, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.KitchenKnifeForged", basePrice=50, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.KnifeButterfly", basePrice=49, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.KnifeFillet", basePrice=36, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.KnifeParing", basePrice=46, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.KnifePocket", basePrice=49, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.KnifeShiv", basePrice=39, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.KnifeSushi", basePrice=61, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.LargeKnife", basePrice=67, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.LargeKnife_Scrap", basePrice=19, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=2, max=10} },
    { item="Base.LongCrudeKnife", basePrice=53, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.LongHandle_Sawblade", basePrice=61, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Machete", basePrice=118, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Machete_Crude", basePrice=71, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.MacheteForged", basePrice=118, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.MacheteKnife", basePrice=67, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.MeatCleaver", basePrice=52, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.MeatCleaver_Scrap", basePrice=14, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.MeatCleaverForged", basePrice=52, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Plank_Sawblade", basePrice=59, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.RailroadSpikeKnife", basePrice=58, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.ShortBat_Sawblade", basePrice=65, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.ShortSword", basePrice=113, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.ShortSword_Scrap", basePrice=27, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.SmallKnife", basePrice=44, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.SpearFightingKnife", basePrice=99, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SpearHuntingKnife", basePrice=99, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SpearKnife", basePrice=88, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SpearKnifeSmall", basePrice=88, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SpearLargeKnife", basePrice=99, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SpearScrapKnife", basePrice=30, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.SpearSteakKnife", basePrice=87, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.SteakKnife", basePrice=39, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=3, max=15} },
    { item="Base.StoneKnifeLong", basePrice=55, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Sword", basePrice=146, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.Sword_Broken", basePrice=32, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=2, max=10} },
    { item="Base.Sword_Scrap", basePrice=36, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.Sword_Scrap_Broken", basePrice=26, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.TableLeg_Sawblade", basePrice=50, tags={"Weapon.Melee.Blade", "Rarity.Common"}, stockRange={min=1, max=5} },

    -- [Weapon.Melee.Blade] [Rarity.Rare] (2 items)
    { item="Base.Handiknife", basePrice=71, tags={"Weapon.Melee.Blade", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.SwitchKnife", basePrice=71, tags={"Weapon.Melee.Blade", "Rarity.Rare"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Blade Registry Complete")
