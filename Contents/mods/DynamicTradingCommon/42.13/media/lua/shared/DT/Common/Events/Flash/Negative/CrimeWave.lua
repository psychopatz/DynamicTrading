require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: LOOTER GANGS
-- =============================================================================

DynamicTrading.Events.Register("CrimeWave", {
    name = "Looter Gangs",
    type = "flash",
    description = "Bandits are raiding. Locks and weapons needed.",
    canSpawn = function() return true end,
    effects = {
        ["Police"] = { price = 2.0, vol = 0.5 },
        ["Weapon"] = { price = 1.5 },
        ["Gun"] = { price = 1.5 },
        ["Safety"] = { price = 2.0 } -- Found in DT_Household
    }
})
