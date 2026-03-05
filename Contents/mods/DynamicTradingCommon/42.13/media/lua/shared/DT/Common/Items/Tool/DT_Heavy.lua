-- =============================================================================
-- DYNAMIC TRADING: TOOL - HEAVY
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Heavy
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.PickAxe",              tags={"Tool.Heavy", "Rarity.Uncommon"}, basePrice=300, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Tool/Heavy Registry Loaded.")
