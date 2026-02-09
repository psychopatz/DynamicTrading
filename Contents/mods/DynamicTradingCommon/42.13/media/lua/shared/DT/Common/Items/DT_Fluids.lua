
require "DT/Common/Config"
if not DynamicTrading then return end

-- =============================================================================
-- FLUID PRICE REGISTRY
-- =============================================================================
-- This file defines the base value of fluids per unit.
-- Prices are multiplied by the amount in a container to calculate final value.

DynamicTrading.Fluids = {
    -- FUEL
    ["Base.Petrol"]     = { basePrice = 2.0, tags = {"Fuel", "Common"} },
    ["Base.Gasoline"]   = { basePrice = 2.0, tags = {"Fuel", "Common"} },
    ["Base.Diesel"]     = { basePrice = 1.8, tags = {"Fuel", "Common"} },
    
    -- BEVERAGES
    ["Base.Water"]      = { basePrice = 1.0, tags = {"Water", "Common"} },
    ["Base.Beer"]       = { basePrice = 5.0, tags = {"Alcohol", "Drink"} },
    ["Base.Wine"]       = { basePrice = 8.0, tags = {"Alcohol", "Drink"} },
    ["Base.Milk"]       = { basePrice = 4.0, tags = {"Food", "Drink"} },
    ["Base.Juice"]      = { basePrice = 3.0, tags = {"Food", "Drink"} },
    ["Base.Soda"]       = { basePrice = 2.5, tags = {"Food", "Drink"} },
    
    -- CHEMICALS
    ["Base.Bleach"]           = { basePrice = 3.0, tags = {"Clean", "Poison"} },
    ["Base.CleaningLiquid"]  = { basePrice = 2.5, tags = {"Clean"} },
    ["Base.Disinfectant"]   = { basePrice = 15.0, tags = {"Medical", "Clean"} },
    ["Base.Paint"]           = { basePrice = 10.0, tags = {"Material", "Build"} },
    ["Base.WashingDetergent"] = { basePrice = 3.5, tags = {"Clean"} },
    ["Base.Coffee"]          = { basePrice = 12.0, tags = {"Drink", "Food"} },
}

print("[DynamicTrading] Fluid Registry Complete.")
