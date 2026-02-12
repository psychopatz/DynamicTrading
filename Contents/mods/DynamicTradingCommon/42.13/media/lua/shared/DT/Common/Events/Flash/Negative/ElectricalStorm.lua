require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: THUNDERSTORM INTERFERENCE
-- =============================================================================

DynamicTrading.Events.Register("ElectricalStorm", {
    name = "Thunderstorm Interference",
    type = "flash",
    description = "Heavy static makes long-range comms impossible.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.5
    },
    effects = {
        ["Battery"] = { price = 2.0 },
        ["Light"] = { price = 1.5 },
        ["Electronics"] = { price = 1.5 }
    }
})
