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

    -- [Weapon.Part.Accessory] [Rarity.Rare] (11 items)
    { item="Base.AmmoStraps", basePrice=87, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.ChokeTubeFull", basePrice=84, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.ChokeTubeImproved", basePrice=84, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.GunLight", basePrice=84, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.Laser", basePrice=83, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.RecoilPad", basePrice=84, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.RedDot", basePrice=83, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.TritiumSights", basePrice=84, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.x2Scope", basePrice=83, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.x4Scope", basePrice=83, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.x8Scope", basePrice=82, tags={"Weapon.Part.Accessory", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
})

print("[DynamicTrading] Part Registry Complete")
