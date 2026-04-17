-- =============================================================================
-- 7. FACTION SYSTEM CONFIGURATION (SHARED PARITY)
-- =============================================================================
DynamicTrading.Config.ResourceMap = {
    ["Food"] = "food",
    ["Food.Perishable.Vegetable"] = "food", ["Food.Perishable.Fruit"] = "food", ["Food.Perishable.Grain"] = "food", ["Food.Perishable.Meat"] = "food",
    ["Food.Perishable"] = "food", ["Food.NonPerishable"] = "food", ["Food.Perishable.Fish"] = "food", ["Tool.Resource.Farming"] = "food",
    ["Weapon.Ranged.Ammo"] = "ammo", ["Weapon.Ranged.Firearm"] = "ammo", ["Weapon.Melee"] = "ammo",
    ["Medical.General"] = "meds", ["Medical.General.Pills"] = "meds", ["Medical.Healthcare"] = "meds",
    ["Resource.Fuel"] = "fuel", ["Electronics.General"] = "fuel"
}

DynamicTrading.Config.Sim = {
    BaseConsumption = { food = 1.0, meds = 0.1, ammo = 0.2, fuel = 0.5 },
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
