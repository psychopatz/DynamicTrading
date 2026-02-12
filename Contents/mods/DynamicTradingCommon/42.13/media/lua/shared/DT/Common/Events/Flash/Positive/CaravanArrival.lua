require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: TRADER CARAVAN
-- =============================================================================

DynamicTrading.Events.Register("CaravanArrival", {
    name = "Trader Caravan",
    sentiment = "Positive",
    type = "flash",
    description = "A massive convoy of traders is passing through the region.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 2.0, -- Double the daily limit
        scanChance = 1.2   -- +20% Scan chance
    },
    effects = {
        ["General"] = { price = 0.8, vol = 2.0 },
        ["Food"] = { vol = 1.5 },
        ["Material"] = { vol = 1.5 }
    }
})
