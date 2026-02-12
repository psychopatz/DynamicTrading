require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: MARKET PANIC
-- =============================================================================

DynamicTrading.Events.Register("Inflation", {
    name = "Market Panic",
    type = "flash",
    description = "Currency is losing value rapidly.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Misc"] = { price = 2.0 },
        ["Luxury"] = { price = 0.2 }
    }
})
