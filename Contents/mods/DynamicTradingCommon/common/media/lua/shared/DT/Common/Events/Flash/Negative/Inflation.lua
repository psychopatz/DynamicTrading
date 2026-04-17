require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: MARKET PANIC
-- =============================================================================

DynamicTrading.Events.Register("Inflation", {
    name = "Market Panic",
    sentiment = "Negative",
    type = "flash",
    description = "Currency is losing value rapidly.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = { autoBuyPriceMult = 2.5, traderBudgetMult = 0.6 },
    effects = {
        ["Misc"] = { price = 2.0 },
        ["Quality.Luxury"] = { price = 0.2 }
    },
    factionImpact = {
        wealthAdd = -500,
        stabilityAdd = -3
    }
})
