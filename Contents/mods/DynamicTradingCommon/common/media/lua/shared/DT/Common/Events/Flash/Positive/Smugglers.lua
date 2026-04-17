require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: BLACK MARKET SURGE
-- =============================================================================

DynamicTrading.Events.Register("Smugglers", {
    name = "Smuggler Run",
    sentiment = "Positive",
    type = "flash",
    description = "The underground market is active.",
    canSpawn = function() return true end,
    system = { traderBudgetMult = 1.5 },
    effects = {
        ["Food.Drink.Alcohol"] = { price = 0.6, vol = 2.0 },
        ["Medical.General.Drug"] = { price = 0.6, vol = 2.0 },
        ["Clothing.Accessory.Jewelry"] = { price = 0.5 },
        ["Quality.Luxury"] = { price = 0.5, vol = 2.0 }
    },
    factionImpact = {
        wealthAdd = 300,
        stockpileAdd = { ammo = 200 },
        stabilityAdd = -2
    }
})
