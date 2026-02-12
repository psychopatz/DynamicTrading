require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: SOLAR FLARE
-- =============================================================================

DynamicTrading.Events.Register("SolarFlare", {
    name = "Solar Flare",
    type = "flash",
    description = "Atmospheric interference hits radios.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.4,
        traderLimit = 0.8
    },
    effects = {
        ["Communication"] = { price = 3.0 },
        ["Electronics"] = { price = 0.5 }
    }
})
