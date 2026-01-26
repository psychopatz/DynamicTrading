require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. SMALL GAME TRAPS (Mice/Rats)
-- =============================================================================
-- Catches bait for larger traps or fishing.
{ item="Base.TrapMouse", basePrice=5, tags={"Trapping", "Tool", "Common"}, stockRange={min=2, max=10} },
-- =============================================================================
-- 2. BIRD TRAPS
-- =============================================================================
-- Very fragile, made of twigs.
{ item="Base.TrapStick",        basePrice=5,   tags={"Trapping", "Tool", "Primitive"}, stockRange={min=2, max=8} },

-- =============================================================================
-- 3. MEDIUM GAME TRAPS (Rabbits/Squirrels)
-- =============================================================================
-- Primitive/Wooden (Craftable)
{ item="Base.TrapSnare",        basePrice=8,   tags={"Trapping", "Tool", "Primitive"}, stockRange={min=2, max=8} },
{ item="Base.TrapBox",          basePrice=12,  tags={"Trapping", "Tool", "Wood"}, stockRange={min=1, max=5} },
{ item="Base.TrapCrate",        basePrice=12,  tags={"Trapping", "Tool", "Wood"}, stockRange={min=1, max=5} },

-- Metal (High Durability & Catch Rate)
{ item="Base.TrapCage",         basePrice=35,  tags={"Trapping", "Tool", "Metal", "Durable"}, stockRange={min=1, max=4} },

})

print("[DynamicTrading] Traps Registry Complete.")
