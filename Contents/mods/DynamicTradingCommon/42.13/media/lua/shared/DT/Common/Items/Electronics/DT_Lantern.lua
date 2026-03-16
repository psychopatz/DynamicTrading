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
    { item="Base.Lantern_CraftedElectric", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Copper", basePrice=136, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Police", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_CopperLit", basePrice=136, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Origin.Police", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Forged", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_ForgedLit", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Gold", basePrice=202, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_GoldLit", basePrice=202, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Quality.Luxury", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_Silver", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Hurricane_SilverLit", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_HurricaneLit", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
    { item="Base.Lantern_Propane", basePrice=126, tags={"Electronics.Light.Lantern", "Rarity.Rare", "Electronics.LightSource"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Lantern Registry Complete")
