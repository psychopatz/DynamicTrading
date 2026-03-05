-- =============================================================================
-- DYNAMIC TRADING: TOOL - FARMER
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Farmer
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.KnapsackSprayer",         tags={"Tool.Farmer", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=280, stockRange={min=0, max=1} },
    { item="Base.KnapsackSprayer_Stowed",  tags={"Tool.Farmer", "Quality.Heavy", "Rarity.Uncommon"}, basePrice=250, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Tool/Farmer Registry Loaded.")
