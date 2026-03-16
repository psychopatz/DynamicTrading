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

    -- [Electronics.Light.Flashlight] [Rarity.Rare] (7 items)
    { item="Base.CandleBox", basePrice=40, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.FlashLight_AngleHead", basePrice=174, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.FlashLight_AngleHead_Army", basePrice=200, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Militia", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.Flashlight_Crafted", basePrice=173, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.HandTorch", basePrice=174, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=6} },
    { item="Base.PenLight", basePrice=78, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=10} },
    { item="Base.Torch", basePrice=173, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Flashlight Registry Complete")
