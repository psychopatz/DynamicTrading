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

    -- [Electronics.Television] [Rarity.Common] (3 items)
    { item="Base.TvAntique", basePrice=68, tags={"Electronics.Television", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=1} },
    { item="Base.TvBlack", basePrice=68, tags={"Electronics.Television", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=1} },
    { item="Base.TvWideScreen", basePrice=68, tags={"Electronics.Television", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Television Registry Complete")
