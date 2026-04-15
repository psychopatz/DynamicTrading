-- ============================================================================
-- Tool Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Tool.Fishing] [Rarity.Common] (3 items)
    { item="Base.FishingRod", basePrice=42, tags={"Tool.Fishing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.FishingRodBreak", basePrice=42, tags={"Tool.Fishing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Gaffhook", basePrice=43, tags={"Tool.Fishing", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Fishing Registry Complete")
