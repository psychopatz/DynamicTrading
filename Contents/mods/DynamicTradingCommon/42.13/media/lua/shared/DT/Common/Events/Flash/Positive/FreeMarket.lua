require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: FREE MARKET DAY
-- =============================================================================

DynamicTrading.Events.Register("FreeMarket", {
    name = "Free Market Day",
    sentiment = "Positive",
    type = "flash",
    description = "Traders are actively broadcasting to sell stock.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 1.8 -- Almost double traders
    },
    effects = {
        ["Luxury"] = { price = 1.2, vol = 1.5 },
        ["Money"] = { price = 1.5 }, -- If currency items exist
        ["General"] = { price = 0.9, vol = 1.5 }
    },
    factionImpact = {
        wealthAdd = 1000
    }
})
