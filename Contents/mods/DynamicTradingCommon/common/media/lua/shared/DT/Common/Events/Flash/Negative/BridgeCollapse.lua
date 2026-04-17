require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: LOGISTICS FAILURE
-- =============================================================================

DynamicTrading.Events.Register("BridgeCollapse", {
    name = "Logistics Failure",
    sentiment = "Negative",
    type = "flash",
    description = "A major trade route collapsed. Fewer traders can reach range.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 0.6,
        globalStock = 0.7 -- Less items overall too
    , traderBudgetMult = 0.5},
    effects = {
        ["Resource.Fuel"] = { price = 2.5 },
        ["Clothing.Armor.Heavy"] = { price = 2.0 },
        ["Resource.Parts"] = { price = 2.0 }
    },
    factionImpact = {
        stockpileAdd = { fuel = -50 },
        stabilityAdd = -2
    }
})
