require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: HAM RADIO MEETUP
-- =============================================================================

DynamicTrading.Events.Register("RadioClub", {
    name = "Radio Club Meet",
    sentiment = "Positive",
    type = "flash",
    description = "The old Ham Radio operators are active tonight.",
    canSpawn = function() return true end,
    system = {
        scanChance = 1.5,
        traderLimit = 1.5
    , passiveIncomeMult = 1.1},
    effects = {
        ["Electronics.Communicator"] = { price = 0.5, vol = 3.0 }, -- Radios are cheap
        ["Resource.Parts"] = { vol = 2.0 },
        ["Electronics.Battery"] = { vol = 2.0 }
    },
    inject = { ["Electronics.Communicator"] = 3 },
    factionImpact = {
        stabilityAdd = 5
    }
})
