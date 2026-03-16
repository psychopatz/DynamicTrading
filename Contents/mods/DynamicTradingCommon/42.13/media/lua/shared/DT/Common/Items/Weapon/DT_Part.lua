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
    { item="Base.AmmoStraps", basePrice=3, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.ChokeTubeFull", basePrice=37, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.ChokeTubeImproved", basePrice=37, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.GunLight", basePrice=13600, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Laser", basePrice=7, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.RecoilPad", basePrice=17, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.RedDot", basePrice=11, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.TritiumSights", basePrice=42, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.x2Scope", basePrice=18, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.x4Scope", basePrice=14, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.x8Scope", basePrice=7, tags={"Weapon.Part.Accessory", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Part Registry Complete")
