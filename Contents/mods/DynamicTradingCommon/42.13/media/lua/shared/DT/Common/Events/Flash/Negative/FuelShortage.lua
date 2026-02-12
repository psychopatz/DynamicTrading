require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: REFINERY EXPLOSION
-- =============================================================================

DynamicTrading.Events.Register("FuelShortage", {
    name = "Refinery Explosion",
    sentiment = "Negative",
    type = "flash",
    description = "Fuel production has halted.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    effects = {
        ["Fuel"] = { price = 4.0, vol = 0.1 },
        ["CarPart"] = { price = 0.5 },
        ["Generator"] = { price = 0.5 }
    },
    factionImpact = {
        stockpileAdd = { fuel = -200 },
        wealthAdd = -100
    }
})
