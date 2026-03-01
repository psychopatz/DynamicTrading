require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: SALMON RUN
-- =============================================================================

DynamicTrading.Events.Register("FishingTourney", {
    name = "Fishing Tournament",
    sentiment = "Positive",
    type = "flash",
    description = "Fish are biting like crazy!",
    canSpawn = function() return true end,
    effects = {
        ["Fish"] = { price = 0.5, vol = 3.0 },
        ["Bait"] = { price = 1.5, vol = 0.5 },
        ["Food"] = { price = 0.9 }
    },
    inject = { ["Fish"] = 5 },
    factionImpact = {
        stockpileAdd = { food = 300 },
        stabilityAdd = 3
    }
})
