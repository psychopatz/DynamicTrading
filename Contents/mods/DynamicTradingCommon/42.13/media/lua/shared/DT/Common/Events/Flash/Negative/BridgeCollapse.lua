-- =============================================================================
-- FLASH NEGATIVE: LOGISTICS FAILURE
-- =============================================================================

DynamicTrading.Events.Register("BridgeCollapse", {
    name = "Logistics Failure",
    type = "flash",
    description = "A major trade route collapsed. Fewer traders can reach range.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 0.6,
        globalStock = 0.7 -- Less items overall too
    },
    effects = {
        ["Fuel"] = { price = 2.5 },
        ["Heavy"] = { price = 2.0 },
        ["CarPart"] = { price = 2.0 }
    }
})
