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

    -- [Tool.Medical.Surgical] [Rarity.Common] (1 item)
    { item="Base.Scalpel", basePrice=36, tags={"Tool.Medical.Surgical", "Rarity.Common", "Tool.Fragile"}, stockRange={min=3, max=15} },

    -- [Tool.Medical.Surgical] [Rarity.Rare] (4 items)
    { item="Base.Forceps_Forged", basePrice=40, tags={"Tool.Medical.Surgical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SutureNeedle", basePrice=39, tags={"Tool.Medical.Surgical", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SutureNeedleBox", basePrice=37, tags={"Tool.Medical.Surgical", "Rarity.Rare"}, stockRange={min=0, max=4} },
    { item="Base.SutureNeedleHolder", basePrice=40, tags={"Tool.Medical.Surgical", "Rarity.Rare"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Medical Surgical Registry Complete")
