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
    , traderBudgetMult = 2.0, autoBuyPriceMult = 0.8},
    effects = {
        ["Misc.General"] = { price = 0.8, vol = 2.0 },
        ["Food"] = { vol = 1.5 },
        ["Resource.Material"] = { vol = 1.5 }
    },
    factionImpact = {
        wealthAdd = 500,
        stockpileAdd = { food = 50, ammo = 50, meds = 50, fuel = 50 }
    }
})
