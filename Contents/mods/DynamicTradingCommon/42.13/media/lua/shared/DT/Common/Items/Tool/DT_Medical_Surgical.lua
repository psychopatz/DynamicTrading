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

    -- [Tool.Light] [Rarity.Rare] (3 items)
    { item="Base.FlashLight_AngleHead", basePrice=9085, tags={"Tool.Light", "Rarity.Rare", "Tool.HighUse"}, stockRange={min=0, max=6} },
    { item="Base.FlashLight_AngleHead_Army", basePrice=9520, tags={"Tool.Light", "Rarity.Rare", "Origin.Militia", "Tool.HighUse"}, stockRange={min=0, max=6} },
    { item="Base.Flashlight_Crafted", basePrice=3400, tags={"Tool.Light", "Rarity.Rare", "Tool.HighUse"}, stockRange={min=0, max=4} },

    -- [Tool.Medical.Surgical] [Rarity.Common] (1 item)
    { item="Base.Scalpel", basePrice=33, tags={"Tool.Medical.Surgical", "Rarity.Common", "Tool.Medical", "Tool.Fragile"}, stockRange={min=3, max=15} },

    -- [Tool.Medical.Surgical] [Rarity.Rare] (4 items)
    { item="Base.Forceps_Forged", basePrice=340, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Tool.Medical"}, stockRange={min=0, max=10} },
    { item="Base.SutureNeedle", basePrice=340, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Tool.Medical"}, stockRange={min=0, max=10} },
    { item="Base.SutureNeedleBox", basePrice=34, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Tool.Medical"}, stockRange={min=0, max=4} },
    { item="Base.SutureNeedleHolder", basePrice=113, tags={"Tool.Medical.Surgical", "Rarity.Rare", "Tool.Medical"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Medical Surgical Registry Complete")
