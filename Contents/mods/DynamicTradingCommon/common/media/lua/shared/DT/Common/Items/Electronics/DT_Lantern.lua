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

    -- [Electronics.Light.Lantern] [Rarity.Rare] (12 items)
    { item="Base.Lantern_CraftedElectric", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Copper", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_CopperLit", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Forged", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_ForgedLit", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Gold", basePrice=334, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_GoldLit", basePrice=334, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Silver", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_SilverLit", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_HurricaneLit", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Propane", basePrice=151, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Vanilla", "Electronics.LightSource"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Lantern Registry Complete")
