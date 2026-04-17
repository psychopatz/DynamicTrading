require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: SOLAR FLARE
-- =============================================================================

DynamicTrading.Events.Register("SolarFlare", {
    name = "Solar Flare",
    sentiment = "Negative",
    type = "flash",
    description = "Atmospheric interference hits radios.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.4,
        traderLimit = 0.8
    , passiveIncomeMult = 0.9},
    effects = {
        ["Electronics.Communicator"] = { price = 3.0 },
        ["Electronics"] = { price = 0.5 }
    },
    factionImpact = {
        stabilityAdd = -2
    }
})
