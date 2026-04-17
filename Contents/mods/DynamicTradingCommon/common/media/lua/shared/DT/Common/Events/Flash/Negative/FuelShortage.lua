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
    system = { autoBuyPriceMult = 1.3 },
    effects = {
        ["Resource.Fuel"] = { price = 4.0, vol = 0.1 },
        ["Resource.Parts"] = { price = 0.5 },
        ["Electronics.Generator"] = { price = 0.5 }
    },
    factionImpact = {
        stockpileAdd = { fuel = -200 },
        wealthAdd = -100
    }
})
