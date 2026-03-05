-- =============================================================================
-- DYNAMIC TRADING: TOOL - RESOURCE
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Resource
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Fleshing_Tool",        tags={"Tool.Resource.Butcher", "Rarity.Common"},     basePrice=45,  stockRange={min=1, max=4} },
    { item="Base.Fleshing_Tool_Bone",   tags={"Tool.Resource.Survival", "Theme.Survival", "Rarity.Common"}, basePrice=15,  stockRange={min=2, max=6} },
    { item="Base.OilPress",             tags={"Tool.Resource.Farmer", "Rarity.Uncommon"},    basePrice=180, stockRange={min=0, max=2} },
    { item="Base.SheepShears",          tags={"Tool.Resource.Farmer", "Rarity.Common"},      basePrice=55,  stockRange={min=1, max=4} },
})

print("[DynamicTrading] Tool/Resource Registry Loaded.")
