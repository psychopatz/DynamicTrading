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

    -- [Weapon.Part.Ammo] [Rarity.Rare] (6 items)
    { item="Base.44Clip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.45Clip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.556Clip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.9mmClip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.JS14_Clip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.M14Clip", basePrice=70, tags={"Weapon.Part.Ammo", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Part Ammo Registry Complete")
