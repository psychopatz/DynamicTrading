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
    { item="Base.CandleBox", basePrice=65, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.FlashLight_AngleHead", basePrice=198, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.FlashLight_AngleHead_Army", basePrice=261, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Electronics.LightSource"}, stockRange={min=0, max=3} },
    { item="Base.Flashlight_Crafted", basePrice=198, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=2} },
    { item="Base.HandTorch", basePrice=198, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=4} },
    { item="Base.PenLight", basePrice=103, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=7} },
    { item="Base.Torch", basePrice=198, tags={"Electronics.Light.Flashlight", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Flashlight Registry Complete")
