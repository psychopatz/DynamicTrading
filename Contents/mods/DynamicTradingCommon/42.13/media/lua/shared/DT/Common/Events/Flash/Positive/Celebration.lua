require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: NEW WORLD FESTIVAL
-- =============================================================================

DynamicTrading.Events.Register("Celebration", {
    name = "Holiday Celebration",
    sentiment = "Positive",
    type = "flash",
    description = "Survivors are gathering to party.",
    canSpawn = function() return true end,
    effects = {
        ["Alcohol"] = { price = 2.0, vol = 0.2 },
        ["Sweets"] = { price = 2.0 },
        ["Music"] = { price = 2.0 },
        ["Fun"] = { price = 2.0 },
        ["Cosmetic"] = { price = 1.5 }
    },
    factionImpact = {
        stabilityAdd = 10,
        stockpileAdd = { food = -50 }
    }
})
