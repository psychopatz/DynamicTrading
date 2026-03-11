-- ============================================================================
-- Resource Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Resource.Fuel.Liquid] [Rarity.Rare] (4 items)
    { item="Base.GasmaskFilter", basePrice=45, tags={"Resource.Fuel.Liquid", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.GasmaskFilterCrafted", basePrice=45, tags={"Resource.Fuel.Liquid", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Lantern_Propane", basePrice=7, tags={"Resource.Fuel.Liquid", "Rarity.Rare"}, stockRange={min=0, max=2} },
    { item="Base.Propane_Refill", basePrice=14, tags={"Resource.Fuel.Liquid", "Rarity.Rare"}, stockRange={min=0, max=4} },
})

DynamicTrading.Log("DTCommons", "Init", "Item", "Fuel Registry Complete")
