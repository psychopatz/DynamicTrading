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
    },
    effects = {
        ["Communication"] = { price = 0.5, vol = 3.0 }, -- Radios are cheap
        ["Component"] = { vol = 2.0 },
        ["Battery"] = { vol = 2.0 }
    },
    inject = { ["Communication"] = 3 },
    factionImpact = {
        stabilityAdd = 5
    }
})
