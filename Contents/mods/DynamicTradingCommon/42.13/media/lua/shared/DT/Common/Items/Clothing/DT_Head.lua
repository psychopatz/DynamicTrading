-- =============================================================================
-- DYNAMIC TRADING: CLOTHING - HEAD
-- =============================================================================
-- Root Category: Clothing
-- Sub Category: Head
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Hat_Cowboy_Plastic",   basePrice=15,  tags={"Clothing.Head.Hat", "Literature.Music.Fun"}, stockRange={min=0, max=2} }, -- It has a whistle,
    { item="Base.Hat_SurgicalCap",      basePrice=30, tags={"Clothing.Head.Hat", "Origin.Healthcare"}, stockRange={min=2, max=12} },
})

print("[DynamicTrading] Clothing/Head Registry Loaded.")
