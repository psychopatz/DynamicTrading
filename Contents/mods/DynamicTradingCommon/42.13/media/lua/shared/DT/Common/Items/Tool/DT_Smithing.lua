-- =============================================================================
-- DYNAMIC TRADING: TOOL - SMITHING
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Smithing
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BlacksmithAnvilUntreated", tags={"Tool.Smithing.Anvil", "Quality.Standard", "Rarity.Rare"}, basePrice=1000, stockRange={min=0, max=1} },
    { item="Base.CeramicCrucible",   tags={"Tool.Smithing.Crucible", "Rarity.Uncommon"},                        basePrice=150, stockRange={min=1, max=3} },
    { item="Base.IronIngotMold",     tags={"Tool.Smithing.Mold", "Rarity.Uncommon"},                            basePrice=100, stockRange={min=1, max=2} }, -- Reusable,
    { item="Base.SteelIngotMold",    tags={"Tool.Smithing.Mold", "Rarity.Uncommon"},                            basePrice=120, stockRange={min=1, max=2} },
})

print("[DynamicTrading] Tool/Smithing Registry Loaded.")
