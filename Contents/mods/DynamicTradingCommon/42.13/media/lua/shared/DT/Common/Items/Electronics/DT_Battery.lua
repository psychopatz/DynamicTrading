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

    -- [Electronics.Battery] [Rarity.Rare] (7 items)
    { item="Base.Battery", basePrice=9724, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=10} },
    { item="Base.BatteryBox", basePrice=8, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=4} },
    { item="Base.CarBattery1", basePrice=136000, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=2} },
    { item="Base.CarBattery2", basePrice=136000, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=2} },
    { item="Base.CarBattery3", basePrice=136000, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=2} },
    { item="Base.CarBatteryCharger", basePrice=4, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=2} },
    { item="Base.Lighter_Battery", basePrice=1360, tags={"Electronics.Battery", "Rarity.Rare", "Electronics.PowerSource"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Battery Registry Complete")
