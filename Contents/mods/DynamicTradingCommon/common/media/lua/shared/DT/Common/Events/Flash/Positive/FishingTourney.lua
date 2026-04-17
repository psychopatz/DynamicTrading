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
    system = { passiveIncomeMult = 1.3 },
    effects = {
        ["Food.Perishable.Fish"] = { price = 0.5, vol = 3.0 },
        ["Resource.Fishing"] = { price = 1.5, vol = 0.5 },
        ["Tool.Fishing"] = { price = 1.2, vol = 1.0 },
        ["Food"] = { price = 0.9 }
    },
    inject = { ["Food.Perishable.Fish"] = 5, ["Resource.Fishing"] = 3, ["Tool.Fishing"] = 2 },
    factionImpact = {
        stockpileAdd = { food = 300 },
        stabilityAdd = 3
    }
})
