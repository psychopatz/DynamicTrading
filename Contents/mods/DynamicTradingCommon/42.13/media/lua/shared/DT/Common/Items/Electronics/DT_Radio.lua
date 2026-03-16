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

    -- [Electronics.Radio.Broadcast] [Rarity.Rare] (1 item)
    { item="Base.CDplayer", basePrice=79, tags={"Electronics.Radio.Broadcast", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.Broadcast", "Electronics.Portable"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Radio Registry Complete")
