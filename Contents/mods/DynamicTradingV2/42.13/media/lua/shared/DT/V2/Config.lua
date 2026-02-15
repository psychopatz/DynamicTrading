require "DT/Common/Config"
DynamicTrading = DynamicTrading or {}
DynamicTrading.V2 = {}
DynamicTrading.V2.Config = {}

-- =============================================================================
-- RESOURCE MAPPING & SIMULATION CONSTANTS (Moved to Common)
-- =============================================================================
require "DT/Common/Faction/TradingSys/Factions/SimulationConfig"

-- Alias new Common config to V2 for backward compatibility
DynamicTrading.V2.Config.ResourceMap = DynamicTrading.FactionConfig.ResourceMap
DynamicTrading.V2.Config.Sim = DynamicTrading.FactionConfig.Sim

-- =============================================================================
-- EVENT REGISTRY (V2 Director Logic)
-- =============================================================================
DynamicTrading.V2.Config.Events = {
    -- Thresholds for reactive flash events (units per member)
    Thresholds = {
        FoodHigh = 50.0,  -- Above this -> BumperCrop
        FoodLow = 5.0,    -- Below this -> Famine
        AmmoLow = 10.0,   -- Below this -> Vulnerable
        WealthHigh = 5000 -- Above this -> Raid (candidate)
    },
    
    -- Meta Event Names (Global/Permanent)
    Meta = {
        "Inflation",
        "EconomicCollapse",
        "Recession"
    }
}

-- Ensure common events are reachable
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Events/Seasonal/Negative/Winter"
-- future: add other base seasonal/flash events here if not auto-loaded

print("DynamicTrading: V2 Config Initialized.")
