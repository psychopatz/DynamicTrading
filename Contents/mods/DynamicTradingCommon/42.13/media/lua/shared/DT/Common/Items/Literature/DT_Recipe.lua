-- ============================================================================
-- Literature Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Literature.Recipe] [Rarity.Rare] (3 items)
    { item="Base.EngineerMagazine1", basePrice=102, tags={"Literature.Recipe", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.EngineerMagazine2", basePrice=102, tags={"Literature.Recipe", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.EngineerMagazine3", basePrice=102, tags={"Literature.Recipe", "Rarity.Rare"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Recipe Registry Complete")
