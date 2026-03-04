
require "DT/Common/Config"
if not DynamicTrading then return end

-- =============================================================================
-- FLUID PRICE REGISTRY
-- =============================================================================
-- This file defines the base value of fluids per unit.
-- Prices are multiplied by the amount in a container to calculate final value.

DynamicTrading.Fluids = {
    -- FUEL
    ["Base.Petrol"]     = { basePrice = 180.0, tags = {"Fuel", "Common"} },
    ["Base.Petrol"]     = { basePrice = 180.0, tags = {"Fuel", "Common"} },
    
    -- BEVERAGES
    ["Base.Water"]      = { basePrice = 80.0, tags = {"Water", "Common"} },
    ["Base.Beer"]       = { basePrice = 95.0, tags = {"Alcohol", "Drink"} },
    ["Base.Wine"]       = { basePrice = 70.0, tags = {"Alcohol", "Drink"} },
    ["Base.Milk"]       = { basePrice = 94.0, tags = {"Food", "Drink"} },
    ["Base.Milk"]       = { basePrice = 94.0, tags = {"Food", "Drink"} },
    
    -- CHEMICALS
    ["Base.Bleach"]           = { basePrice = 3.0, tags = {"Clean", "Poison"} },
    ["Base.CleaningLiquid"]  = { basePrice = 2.5, tags = {"Clean"} },
    ["Base.Disinfectant"]   = { basePrice = 15.0, tags = {"Medical", "Clean"} },
    ["Base.Disinfectant"]   = { basePrice = 15.0, tags = {"Medical", "Clean"} },
    ["Base.Coffee"]          = { basePrice = 172.0, tags = {"Drink", "Food"} },
}

print("[DynamicTrading] Fluid Registry Complete.")
