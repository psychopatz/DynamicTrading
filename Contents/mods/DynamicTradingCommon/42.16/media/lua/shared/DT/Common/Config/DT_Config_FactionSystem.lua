-- =============================================================================
-- 7. FACTION SYSTEM CONFIGURATION (SHARED PARITY)
-- =============================================================================
DynamicTrading.Config.ResourceMap = {
    ["Food"] = "food",
    ["Food.Perishable.Vegetable"] = "food", ["Food.Perishable.Fruit"] = "food", ["Food.Perishable.Grain"] = "food", ["Food.Perishable.Meat"] = "food",
    ["Food.Perishable"] = "food", ["Food.NonPerishable"] = "food", ["Food.Perishable.Fish"] = "food", ["Tool.Resource.Farming"] = "food",
    ["Weapon.Ranged.Ammo"] = "ammo", ["Weapon.Ranged.Firearm"] = "ammo", ["Weapon.Melee"] = "ammo",
    ["Medical.General"] = "meds", ["Medical.General.Pills"] = "meds", ["Medical.Healthcare"] = "meds",
    ["Resource.Fuel"] = "fuel", ["Electronics.General"] = "fuel",
    ["Resource.Water"] = "water",
    ["Tool.Resource.Parts"] = "materials", ["Resource.Parts"] = "materials", ["Resource.Construction"] = "materials", ["Electronics.Parts"] = "materials"
}

DynamicTrading.Config.Sim = {
    BaseConsumption = { food = 1.0, water = 0.8, meds = 0.1, ammo = 0.3, fuel = 5.0, materials = 2.0 },
    ShortageThresholds = {
        water = 1,
        meds = 2,
        ammo = 1,
        fuel = 1,
        materials = 3
    },
    ProductionMultiplier = 2.0,
    StarvationThreshold = 3,
    DeathRate = 0.1,
    RecruitCost = { food = 50, meds = 10 },
    MaxDailyGrowth = 2
}

DynamicTrading.Config.TraderBudget = {
    BaseBudget = 500,
    MinBudget = 100,
    MaxBudget = 15000,
    IncapacitatedPenaltyMult = 0.25 -- Only 25% returned on incapacitation (75% penalty)
}

DynamicTrading.Config.FactionEvents = {
    Thresholds = {
        FoodHigh = 50.0,
        FoodLow = 5.0,
        AmmoLow = 10.0,
        WealthHigh = 5000
    },
    Meta = { "Inflation", "EconomicCollapse", "Recession" }
}

DynamicTrading.Config.Horde = {
    MinIntervalDays = 3,
    MaxIntervalDays = 7,
    BaseHordeSize = 5,
    WorldAgeScale = 0.5,
    MaxHordeSize = 100,
    BarricadeDamagePerZombie = 2,
    CasualtiesPerRemaining = 5
}
function DynamicTrading.Config.GetSandboxMult(key)
    if not SandboxVars or not SandboxVars.DynamicTrading then return 1.0 end
    local val = SandboxVars.DynamicTrading[key]
    if val == nil then return 1.0 end
    return tonumber(val) or 1.0
end
