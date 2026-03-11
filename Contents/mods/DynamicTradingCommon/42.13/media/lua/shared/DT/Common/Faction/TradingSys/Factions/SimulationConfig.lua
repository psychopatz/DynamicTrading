-- ==============================================================================
-- SimulationConfig.lua
-- Centralized configuration for the Faction Simulation Engine.
-- Moved to Common to allow V1 and V2 to share the same simulation logic.
-- ==============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionConfig = {}

-- =============================================================================
-- 1. RESOURCE MAPPING (Archetype Tags -> Faction Macro Resources)
-- =============================================================================
DynamicTrading.FactionConfig.ResourceMap = {
    ["Vegetable"] = "food",
    ["Fruit"] = "food",
    ["Grain"] = "food",
    ["Meat"] = "food",
    ["Fresh"] = "food",
    ["Canned"] = "food",
    ["Fish"] = "food",
    ["Farming"] = "food",
    
    ["Ammo"] = "ammo",
    ["Gun"] = "ammo",
    ["Weapon"] = "ammo",
    
    ["Medical"] = "meds",
    ["Pills"] = "meds",
    ["Bandage"] = "meds",
    
    ["Fuel"] = "fuel",
    ["Electronics"] = "fuel"
}

-- =============================================================================
-- 2. FACTION SIMULATION CONSTANTS
-- =============================================================================
DynamicTrading.FactionConfig.Sim = {
    BaseConsumption = {
        food = 1.0,
        meds = 0.1,
        ammo = 0.2,
        fuel = 0.5
    },
    
    ProductionMultiplier = 2.0,
    StarvationThreshold = 3,
    DeathRate = 0.1,
    
    RecruitCost = {
        food = 50,
        meds = 10
    },
    MaxDailyGrowth = 2
}

-- =============================================================================
-- 3. EVENT THRESHOLDS (Director Logic)
-- =============================================================================
DynamicTrading.FactionConfig.Events = {
    Thresholds = {
        FoodHigh = 50.0,
        FoodLow = 5.0,
        AmmoLow = 10.0,
        WealthHigh = 5000
    }
}

DynamicTrading.Log("DTCommons", "Init", "Faction", "Faction Simulation Config Initialized")
