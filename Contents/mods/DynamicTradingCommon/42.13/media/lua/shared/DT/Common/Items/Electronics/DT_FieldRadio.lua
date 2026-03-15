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

    -- [Electronics.Gadget.Radio.TwoWay.Portable] [Rarity.Rare] (1 item)
    { item="Base.ManPackRadio", basePrice=32, tags={"Electronics.Gadget.Radio.TwoWay.Portable", "Rarity.Rare", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] FieldRadio Registry Complete")
