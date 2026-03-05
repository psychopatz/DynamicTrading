-- =============================================================================
-- DYNAMIC TRADING: TOOL - CLEANING
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Cleaning
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BathTowelWet",     basePrice=5,  tags={"Tool.Cleaning.Hygiene", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.DishClothWet",     basePrice=2,  tags={"Tool.Cleaning.Hygiene", "Quality.Waste"}, stockRange={min=0, max=0} },
    { item="Base.Soap2", basePrice=25, tags={"Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Sponge", basePrice=8, tags={"Tool.Cleaning.Hygiene", "Rarity.Common"}, stockRange={min=2, max=8} },
})

print("[DynamicTrading] Tool/Cleaning Registry Loaded.")
