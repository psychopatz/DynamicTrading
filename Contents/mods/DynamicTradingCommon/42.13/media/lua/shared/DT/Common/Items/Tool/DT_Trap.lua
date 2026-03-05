-- =============================================================================
-- DYNAMIC TRADING: TOOL - TRAP
-- =============================================================================
-- Root Category: Tool
-- Sub Category: Trap
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.TrapBox",          basePrice=120, tags={"Tool.Trap", "Quality.Standard", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.TrapCage",         basePrice=280, tags={"Tool.Trap", "Quality.Metal", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.TrapCrate",        basePrice=120, tags={"Tool.Trap", "Quality.Standard", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
    { item="Base.TrapMouse", basePrice=25, tags={"Tool.Trap", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
    { item="Base.TrapSnare",        basePrice=85, tags={"Tool.Trap", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=4} },
    { item="Base.TrapStick", basePrice=45, tags={"Tool.Trap", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=4} },
})

print("[DynamicTrading] Tool/Trap Registry Loaded.")
