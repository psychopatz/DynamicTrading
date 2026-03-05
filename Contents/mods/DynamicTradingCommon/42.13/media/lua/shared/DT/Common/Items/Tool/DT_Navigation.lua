-- =============================================================================
-- DYNAMIC TRADING: TOOL - NAVIGATION
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Navigation
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CompassDirectional",      basePrice=45,  tags={"Tool.Navigation", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Tool/Navigation Registry Loaded.")
