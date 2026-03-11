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

    -- [Electronics.Battery] [Rarity.Rare] (2 items)
    { item="Base.BatteryBox", basePrice=8, tags={"Electronics.Battery", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.CarBatteryCharger", basePrice=4, tags={"Electronics.Battery", "Rarity.Rare"}, stockRange={min=0, max=2} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "Battery Registry Complete")
