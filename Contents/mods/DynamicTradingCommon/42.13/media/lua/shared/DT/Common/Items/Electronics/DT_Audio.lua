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

    -- [Electronics.Gadget.Audio] [Rarity.Rare] (4 items)
    { item="Base.Amplifier", basePrice=138, tags={"Electronics.Gadget.Audio", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
    { item="Base.Earbuds", basePrice=45, tags={"Electronics.Gadget.Audio", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.Speaker", basePrice=218, tags={"Electronics.Gadget.Audio", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.VideoGame", basePrice=126, tags={"Electronics.Gadget.Audio", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Audio Registry Complete")
