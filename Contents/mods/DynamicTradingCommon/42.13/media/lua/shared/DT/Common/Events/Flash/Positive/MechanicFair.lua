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
    effects = {
        ["CarPart"] = { price = 0.6, vol = 3.0 },
        ["Mechanic"] = { price = 0.8, vol = 2.0 },
        ["Tool"] = { price = 0.9 },
        ["Fuel"] = { price = 1.2 }
    },
    inject = { ["CarPart"] = 5 },
    factionImpact = {
        stockpileAdd = { fuel = 100 },
        wealthAdd = 100
    }
})
