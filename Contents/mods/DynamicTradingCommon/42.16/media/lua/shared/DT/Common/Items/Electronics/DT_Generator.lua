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

    -- [Electronics.Generator] [Rarity.Common] (4 items)
    { item="Base.Generator", basePrice=4495, tags={"Electronics.Generator", "Rarity.Common", "Origin.Vanilla", "Electronics.PowerGenerator"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Blue", basePrice=4500, tags={"Electronics.Generator", "Rarity.Common", "Origin.Vanilla", "Electronics.PowerGenerator"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Old", basePrice=4495, tags={"Electronics.Generator", "Rarity.Common", "Origin.Vanilla", "Electronics.PowerGenerator"}, stockRange={min=0, max=1} },
    { item="Base.Generator_Yellow", basePrice=4495, tags={"Electronics.Generator", "Rarity.Common", "Origin.Vanilla", "Electronics.PowerGenerator"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Generator Registry Complete")
