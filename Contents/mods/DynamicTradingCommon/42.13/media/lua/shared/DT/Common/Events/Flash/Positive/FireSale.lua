require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: LIQUIDATION
-- =============================================================================

DynamicTrading.Events.Register("FireSale", {
    name = "Fire Sale",
    sentiment = "Positive",
    type = "flash",
    description = "Traders are offloading stock cheap.",
    canSpawn = function() return true end,
    effects = {
        ["Misc"] = { price = 0.5, vol = 1.5 },
        ["Luxury"] = { price = 1.5 },
        ["Junk"] = { price = 0.1 }
    },
    factionImpact = {
        wealthAdd = -100,
        stockpileAdd = { food = 200, ammo = 200 }
    }
})
