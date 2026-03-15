-- ============================================================================
-- Electronics Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Electronics.Gadget.Light.Flashlight] [Rarity.Rare] (7 items)
    { item="Base.CandleBox", basePrice=8, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.FlashLight_AngleHead", basePrice=2271, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.FlashLight_AngleHead_Army", basePrice=2380, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Origin.Militia", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.Flashlight_Crafted", basePrice=850, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.HandTorch", basePrice=2271, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.PenLight", basePrice=34000, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=10} },
    { item="Base.Torch", basePrice=972, tags={"Electronics.Gadget.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Flashlight Registry Complete")
