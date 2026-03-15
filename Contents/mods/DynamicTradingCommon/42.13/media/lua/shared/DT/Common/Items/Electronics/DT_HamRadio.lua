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

    -- [Electronics.Gadget.Radio.TwoWay.Ham] [Rarity.Common] (3 items)
    { item="Base.HamRadio1", basePrice=27, tags={"Electronics.Gadget.Radio.TwoWay.Ham", "Rarity.Common", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.HamRadio2", basePrice=19, tags={"Electronics.Gadget.Radio.TwoWay.Ham", "Rarity.Common", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.HamRadioMakeShift", basePrice=27, tags={"Electronics.Gadget.Radio.TwoWay.Ham", "Rarity.Common", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] HamRadio Registry Complete")
