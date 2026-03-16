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

    -- [Tool.Medical] [Rarity.Rare] (6 items)
    { item="Base.ScissorsBluntMedical", basePrice=73, tags={"Tool.Medical", "Rarity.Rare", "Origin.Clinical", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.Stethoscope", basePrice=37, tags={"Tool.Medical", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.TongueDepressor", basePrice=38, tags={"Tool.Medical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TongueDepressorBox", basePrice=37, tags={"Tool.Medical", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.Tweezers", basePrice=38, tags={"Tool.Medical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Tweezers_Forged", basePrice=38, tags={"Tool.Medical", "Rarity.Rare"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Medical Registry Complete")
