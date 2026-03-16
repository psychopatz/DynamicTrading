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
    { item="Base.Scalpel", basePrice=47, tags={"Tool.Medical.Surgical", "Rarity.Common", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=1, max=9} },

    -- [Tool.Medical.Surgical] [Rarity.Rare] (4 items)
    { item="Base.Forceps_Forged", basePrice=65, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.SutureNeedle", basePrice=64, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.SutureNeedleBox", basePrice=61, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.SutureNeedleHolder", basePrice=65, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=4} },
})

print("[DynamicTrading] Medical Surgical Registry Complete")
