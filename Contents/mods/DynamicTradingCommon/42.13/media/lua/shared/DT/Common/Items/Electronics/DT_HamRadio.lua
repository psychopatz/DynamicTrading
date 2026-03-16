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

    -- [Electronics.Radio.TwoWay.Ham] [Rarity.Common] (3 items)
    { item="Base.HamRadio1", basePrice=184, tags={"Electronics.Radio.TwoWay.Ham", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=1} },
    { item="Base.HamRadio2", basePrice=184, tags={"Electronics.Radio.TwoWay.Ham", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=1} },
    { item="Base.HamRadioMakeShift", basePrice=184, tags={"Electronics.Radio.TwoWay.Ham", "Rarity.Common", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Transmitter"}, stockRange={min=0, max=1} },

    -- [Electronics.Radio.TwoWay.Ham] [Rarity.Rare] (1 item)
    { item="Base.ManPackRadio", basePrice=276, tags={"Electronics.Radio.TwoWay.Ham", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] HamRadio Registry Complete")
