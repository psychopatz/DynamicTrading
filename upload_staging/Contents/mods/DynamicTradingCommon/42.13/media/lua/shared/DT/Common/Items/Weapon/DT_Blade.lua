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
    { item="Base.BaseballBat_Metal_Sawblade", basePrice=94, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Sawblade", basePrice=85, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BreadKnife", basePrice=58, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ButterKnife", basePrice=51, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.ButterKnife_Gold", basePrice=139, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ButterKnife_Silver", basePrice=49, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.CrudeKnife", basePrice=74, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.CrudeShortSword", basePrice=121, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.CrudeSword", basePrice=154, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSword_Broken", basePrice=34, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Cudgel_Sawblade", basePrice=98, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DullBoneKnife", basePrice=47, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.FieldHockeyStick_Sawblade", basePrice=80, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FightingKnife", basePrice=89, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FlintKnife", basePrice=67, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HuntingKnife", basePrice=92, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HuntingKnifeForged", basePrice=92, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Katana", basePrice=315, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Katana_Broken", basePrice=37, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.KitchenKnife", basePrice=74, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KitchenKnifeForged", basePrice=74, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KnifeButterfly", basePrice=73, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeFillet", basePrice=60, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KnifeParing", basePrice=70, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifePocket", basePrice=73, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeShiv", basePrice=63, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeSushi", basePrice=85, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LargeKnife", basePrice=91, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LargeKnife_Scrap", basePrice=26, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.LongCrudeKnife", basePrice=77, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LongHandle_Sawblade", basePrice=85, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Machete", basePrice=142, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Machete_Crude", basePrice=95, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MacheteForged", basePrice=142, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MacheteKnife", basePrice=91, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MeatCleaver", basePrice=76, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MeatCleaver_Scrap", basePrice=21, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MeatCleaverForged", basePrice=76, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Plank_Sawblade", basePrice=83, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.RailroadSpikeKnife", basePrice=82, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.ShortBat_Sawblade", basePrice=89, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ShortSword", basePrice=137, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortSword_Scrap", basePrice=34, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SmallKnife", basePrice=68, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.SpearFightingKnife", basePrice=123, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearHuntingKnife", basePrice=123, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearKnife", basePrice=112, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearKnifeSmall", basePrice=112, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearLargeKnife", basePrice=123, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearScrapKnife", basePrice=37, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearSteakKnife", basePrice=111, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SteakKnife", basePrice=63, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.StoneKnifeLong", basePrice=79, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Sword", basePrice=170, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Sword_Broken", basePrice=39, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Sword_Scrap", basePrice=43, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Sword_Scrap_Broken", basePrice=33, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.TableLeg_Sawblade", basePrice=74, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },

    -- [Weapon.Melee.Blade] [Rarity.Rare] (2 items)
    { item="Base.Handiknife", basePrice=115, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.SwitchKnife", basePrice=115, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Blade Registry Complete")
