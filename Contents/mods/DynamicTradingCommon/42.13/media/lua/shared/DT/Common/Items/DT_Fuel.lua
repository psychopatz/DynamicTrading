require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. GASOLINE & CONTAINERS (The Lifeblood)
-- =============================================================================
-- The Gas Can is the standard unit of trade for energy.
{ item="Base.PetrolCan", basePrice=120, tags={"Fuel", "Generator", "Essential"}, stockRange={min=1, max=3} },
-- Improvised Fuel Containers (Molotov components / Small transport)
-- Prices vary slightly by container size/utility

-- =============================================================================
-- 2. FIRE STARTERS (Ignition)
-- =============================================================================
-- Essential for smokers, cooking, and heating.

-- Lighters (Durable / High Capacity)
{ item="Base.Lighter",              basePrice=10,  tags={"Fire", "Tool", "Tobacco", "Common"}, stockRange={min=5, max=20} },
{ item="Base.LighterDisposable",    basePrice=8,   tags={"Fire", "Tool", "Tobacco", "Common"}, stockRange={min=5, max=20} },
{ item="Base.LighterBBQ",           basePrice=15,  tags={"Fire", "Tool", "Cooking"}, stockRange={min=2, max=10} }, -- Best durability

-- Matches (Finite / Cheap)
{ item="Base.Matches",              basePrice=2,   tags={"Fire", "Tobacco", "Common"}, stockRange={min=10, max=50} }, -- Matchbook (10)
{ item="Base.Matchbox",             basePrice=8,   tags={"Fire", "Tobacco", "Stockpile"}, stockRange={min=5, max=20} }, -- Matchbox (50)

-- Primitive / Improvised (Last Resort)
{ item="Base.PercedWood",           basePrice=1,   tags={"Fire", "Tool", "Primitive", "Junk"}, stockRange={min=1, max=5} }, -- Notched Plank
{ item="Base.Lighter_Battery",      basePrice=2,   tags={"Fire", "Tool", "Improvised"}, stockRange={min=0, max=5} }, -- Engineer craft
})

print("[DynamicTrading] Fuel Registry Complete \n.")
