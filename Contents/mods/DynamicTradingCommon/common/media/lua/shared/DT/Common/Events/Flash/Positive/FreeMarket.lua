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
    , traderBudgetMult = 1.5, autoBuyPriceMult = 0.7},
    effects = {
        ["Quality.Luxury"] = { price = 1.2, vol = 1.5 },
        ["Resource.Material.MetalForm.Coin"] = { price = 1.5 }, -- If currency items exist
        ["Misc.General"] = { price = 0.9, vol = 1.5 }
    },
    factionImpact = {
        wealthAdd = 1000
    }
})
