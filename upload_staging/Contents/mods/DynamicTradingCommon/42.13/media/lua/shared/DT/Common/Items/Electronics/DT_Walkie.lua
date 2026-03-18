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

    -- [Electronics.Radio.TwoWay.Walkie] [Rarity.Rare] (6 items)
    { item="Base.WalkieTalkie1", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.WalkieTalkie2", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.WalkieTalkie3", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.WalkieTalkie4", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.WalkieTalkie5", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
    { item="Base.WalkieTalkieMakeShift", basePrice=286, tags={"Electronics.Radio.TwoWay.Walkie", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator", "Electronics.Radio.TwoWay", "Electronics.Portable", "Electronics.Transmitter"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Walkie Registry Complete")
