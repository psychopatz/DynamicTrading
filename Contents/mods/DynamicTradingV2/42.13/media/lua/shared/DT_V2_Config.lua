DynamicTrading = DynamicTrading or {}
DynamicTrading.V2 = {}
DynamicTrading.V2.Config = {}

-- =============================================================================
-- RESOURCE MAPPING (Archetype Tags -> Faction Macro Resources)
-- =============================================================================
-- When a Faction Member (Archetype) "generates" items, they contribute to these pools.
DynamicTrading.V2.Config.ResourceMap = {
    -- Food Sources
    ["Vegetable"] = "food",
    ["Fruit"] = "food",
    ["Grain"] = "food",
    ["Meat"] = "food",
    ["Fresh"] = "food",
    ["Canned"] = "food",
    ["Fish"] = "food",
    ["Farming"] = "food", -- Seeds/Tools contribute to food sustainability indirectly (simplified)
    
    -- Ammo Sources
    ["Ammo"] = "ammo",
    ["Gun"] = "ammo", -- Guns imply ammo presence or trade value for ammo
    ["Weapon"] = "ammo",
    
    -- Medical Sources
    ["Medical"] = "meds",
    ["Pills"] = "meds",
    ["Bandage"] = "meds",
    
    -- Fuel/Energy
    ["Fuel"] = "fuel",
    ["Electronics"] = "fuel" -- Simplified: Electronics/Batteries = Energy
}

-- =============================================================================
-- FACTION SIMULATION CONSTANTS
-- =============================================================================
DynamicTrading.V2.Config.Sim = {
    -- Consumption Per Person Per Day
    BaseConsumption = {
        food = 1.0,
        meds = 0.1, -- Occasional sickness/injury
        ammo = 0.2, -- Defense usage
        fuel = 0.5
    },
    
    -- Production Multiplier (How much "allocation" score converts to resource)
    -- e.g., Alloc of 6 "Vegetable" * 2.0 = 12 Food units per day
    ProductionMultiplier = 2.0,
    
    -- Starvation / Death
    StarvationThreshold = 3, -- Days without food before people start dying
    DeathRate = 0.1, -- % of population that dies per day when starving
    
    -- Growth
    RecruitCost = {
        food = 50, -- Surplus needed to attract 1 recruit
        meds = 10
    },
    MaxDailyGrowth = 2 -- Max recruits a single faction can absorb per day
}
