require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. SMALL GAME TRAPS (Mice/Rats)
-- =============================================================================
-- Catches bait for larger traps or fishing.
{ item="Base.TrapMouse", basePrice=25, tags={"Tool.Trap", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
-- =============================================================================
-- 2. BIRD TRAPS
-- =============================================================================
-- Very fragile, made of twigs.
{ item="Base.TrapStick", basePrice=45, tags={"Tool.Trap", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=4} },

-- =============================================================================
-- 3. MEDIUM GAME TRAPS (Rabbits/Squirrels)
-- =============================================================================
-- Primitive/Wooden (Craftable)
{ item="Base.TrapSnare",        basePrice=85, tags={"Tool.Trap", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=4} },
{ item="Base.TrapBox",          basePrice=120, tags={"Tool.Trap", "Quality.Standard", "Rarity.Uncommon"}, stockRange={min=0, max=2} },
{ item="Base.TrapCrate",        basePrice=120, tags={"Tool.Trap", "Quality.Standard", "Rarity.Uncommon"}, stockRange={min=0, max=2} },

-- Metal
{ item="Base.TrapCage",         basePrice=280, tags={"Tool.Trap", "Quality.Metal", "Rarity.Rare"}, stockRange={min=0, max=1} },

})

print("[DynamicTrading] Traps Registry Complete \n.")
