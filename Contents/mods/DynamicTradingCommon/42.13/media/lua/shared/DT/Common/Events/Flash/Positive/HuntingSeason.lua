require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: MIGRATION
-- =============================================================================

DynamicTrading.Events.Register("HuntingSeason", {
    name = "Migration",
    sentiment = "Positive",
    type = "flash",
    description = "Wild game is migrating through the area.",
    canSpawn = function() return true end,
    effects = {
        ["Game"] = { price = 0.5, vol = 3.0 },
        ["Meat"] = { price = 0.6, vol = 2.0 },
        ["Trapping"] = { price = 1.5 },
        ["Leather"] = { price = 0.5 }
    },
    inject = { ["Game"] = 4, ["Trapping"] = 2 },
    factionImpact = {
        stockpileAdd = { food = 400, ammo = -50 }
    }
})
