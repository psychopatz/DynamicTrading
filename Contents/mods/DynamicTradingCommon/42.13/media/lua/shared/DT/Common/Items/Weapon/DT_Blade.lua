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
    { item="Base.BaseballBat_Metal_Sawblade", basePrice=542, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Sawblade", basePrice=533, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BreadKnife", basePrice=506, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ButterKnife", basePrice=499, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.ButterKnife_Gold", basePrice=2071, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Luxury", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ButterKnife_Silver", basePrice=497, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.CrudeKnife", basePrice=522, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.CrudeShortSword", basePrice=569, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.CrudeSword", basePrice=602, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSword_Broken", basePrice=168, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Cudgel_Sawblade", basePrice=546, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.DullBoneKnife", basePrice=495, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.FieldHockeyStick_Sawblade", basePrice=528, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FightingKnife", basePrice=537, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FlintKnife", basePrice=515, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HuntingKnife", basePrice=540, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HuntingKnifeForged", basePrice=540, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Katana", basePrice=763, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Katana_Broken", basePrice=172, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.KitchenKnife", basePrice=522, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KitchenKnifeForged", basePrice=522, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KnifeButterfly", basePrice=521, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeFillet", basePrice=508, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.KnifeParing", basePrice=518, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifePocket", basePrice=521, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeShiv", basePrice=511, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.KnifeSushi", basePrice=533, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LargeKnife", basePrice=539, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LargeKnife_Scrap", basePrice=161, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.LongCrudeKnife", basePrice=525, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LongHandle_Sawblade", basePrice=533, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Machete", basePrice=590, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Machete_Crude", basePrice=543, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MacheteForged", basePrice=590, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MacheteKnife", basePrice=539, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MeatCleaver", basePrice=524, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MeatCleaver_Scrap", basePrice=155, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.MeatCleaverForged", basePrice=524, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Plank_Sawblade", basePrice=531, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.RailroadSpikeKnife", basePrice=530, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.ShortBat_Sawblade", basePrice=537, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ShortSword", basePrice=585, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortSword_Scrap", basePrice=168, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SmallKnife", basePrice=516, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.SpearFightingKnife", basePrice=571, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearHuntingKnife", basePrice=571, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearKnife", basePrice=560, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearKnifeSmall", basePrice=560, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearLargeKnife", basePrice=571, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearScrapKnife", basePrice=171, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SpearSteakKnife", basePrice=559, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SteakKnife", basePrice=511, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=9} },
    { item="Base.StoneKnifeLong", basePrice=527, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Sword", basePrice=618, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Sword_Broken", basePrice=173, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Sword_Scrap", basePrice=177, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Sword_Scrap_Broken", basePrice=167, tags={"Weapon.Melee.Blade", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.TableLeg_Sawblade", basePrice=522, tags={"Weapon.Melee.Blade", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },

    -- [Weapon.Melee.Blade] [Rarity.Rare] (2 items)
    { item="Base.Handiknife", basePrice=944, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.SwitchKnife", basePrice=944, tags={"Weapon.Melee.Blade", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Blade Registry Complete")
