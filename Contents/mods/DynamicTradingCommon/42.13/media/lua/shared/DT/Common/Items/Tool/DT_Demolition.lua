-- =============================================================================
-- DYNAMIC TRADING: TOOL - DEMOLITION
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Demolition
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Sledgehammer",         tags={"Tool.Demolition", "Rarity.Rare"},       basePrice=800, stockRange={min=0, max=1} }, -- Real: 2000,
})

print("[DynamicTrading] Tool/Demolition Registry Loaded.")
