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

    -- [Electronics.Gadget.Communication] [Rarity.Rare] (5 items)
    { item="Base.CordlessPhone", basePrice=79, tags={"Electronics.Gadget.Communication", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=2} },
    { item="Base.Headphones", basePrice=80, tags={"Electronics.Gadget.Communication", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=4} },
    { item="Base.Microphone", basePrice=172, tags={"Electronics.Gadget.Communication", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=4} },
    { item="Base.Pager", basePrice=80, tags={"Electronics.Gadget.Communication", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=7} },
    { item="Base.Receiver", basePrice=161, tags={"Electronics.Gadget.Communication", "Rarity.Rare", "Origin.Vanilla", "Electronics.Communicator"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Communication Registry Complete")
