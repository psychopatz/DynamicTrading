require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. GASOLINE & CONTAINERS (The Lifeblood)
-- =============================================================================
-- The Gas Can is the standard unit of trade for energy.
{ item="Base.PetrolCan", basePrice=250, tags={"Resource.Fuel.Container", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
-- Improvised Fuel Containers (Molotov components / Small transport)
-- Prices vary slightly by container size/utility

-- =============================================================================
-- 2. FIRE STARTERS (Ignition)
-- =============================================================================
-- Essential for smokers, cooking, and heating.

-- Lighters (Durable / High Capacity)
{ item="Base.Lighter",              basePrice=80,  tags={"Tool.Camping.Fire", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.LighterDisposable",    basePrice=45,  tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.LighterBBQ",           basePrice=60,  tags={"Tool.Camping.Fire", "Rarity.Uncommon"}, stockRange={min=1, max=3} },

-- Matches (Finite / Cheap)
{ item="Base.Matches",              basePrice=10,  tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=3, max=12} },
{ item="Base.Matchbox",             basePrice=25,  tags={"Tool.Camping.Fire", "Rarity.Common"}, stockRange={min=2, max=8} },

-- Primitive / Improvised (Last Resort)
{ item="Base.PercedWood",           basePrice=45,  tags={"Tool.Camping.Fire", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.Lighter_Battery",      basePrice=35,  tags={"Tool.Camping.Fire", "Quality.Primitive", "Rarity.Common"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Fuel Registry Complete \n.")
