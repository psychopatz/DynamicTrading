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

    -- [Electronics.Light.Component] [Rarity.Rare] (11 items)
    { item="Base.LightBulb", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbBlue", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbBox", basePrice=44, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.LightBulbCyan", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbGreen", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbMagenta", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbOrange", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbPink", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbPurple", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbRed", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.LightBulbYellow", basePrice=45, tags={"Electronics.Light.Component", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Lighting Registry Complete")
