require "DT/Common/Config"
if not DynamicTrading then return end

-- =============================================================================
-- FLUID PRICE REGISTRY
-- =============================================================================
-- This file defines the base value of fluids per unit.
-- Prices are multiplied by the amount in a container to calculate final value.

DynamicTrading.Fluids = {
    -- FUEL
    ["Base.Petrol"]     = { basePrice = 250.0, tags = {"Resource.Fuel", "Rarity.Common"} },
    
    -- BEVERAGES
    ["Base.Water"]      = { basePrice = 45.0,  tags = {"Food.Drink", "Rarity.Common"} },
    ["Base.Beer"]       = { basePrice = 35.0,  tags = {"Food.Drink.Alcohol", "Rarity.Common"} },
    ["Base.Wine"]       = { basePrice = 120.0, tags = {"Food.Drink.Alcohol", "Rarity.Uncommon"} },
    ["Base.Milk"]       = { basePrice = 85.0,  tags = {"Food.Drink", "Rarity.Common"} },
    ["Base.Coffee"]     = { basePrice = 150.0, tags = {"Food.Drink", "Rarity.Uncommon"} },
    
    -- CHEMICALS
    ["Base.CleaningLiquid"]  = { basePrice = 2.0,  tags = {"Medical.Utility.Clean"} },
}

print("[DynamicTrading] Fluid Registry Complete.")
