require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: AUTO MEET
-- =============================================================================

DynamicTrading.Events.Register("MechanicFair", {
    name = "Mechanic Fair",
    sentiment = "Positive",
    type = "flash",
    description = "Mechanics are trading parts freely.",
    canSpawn = function() return true end,
    system = { traderBudgetMult = 1.2 },
    effects = {
        ["Resource.Parts"] = { price = 0.6, vol = 3.0 },
        ["Weapon.Part"] = { price = 0.8, vol = 2.0 },
        ["Tool"] = { price = 0.9 },
        ["Resource.Fuel"] = { price = 1.2 }
    },
    inject = { ["Resource.Parts"] = 5 },
    factionImpact = {
        stockpileAdd = { fuel = 100 },
        wealthAdd = 100
    }
})
