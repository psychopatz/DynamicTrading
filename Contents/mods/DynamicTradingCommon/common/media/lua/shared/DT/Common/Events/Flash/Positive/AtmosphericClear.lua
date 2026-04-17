require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: IONOSPHERIC CLARITY
-- =============================================================================

DynamicTrading.Events.Register("AtmosphericClear", {
    name = "Atmospheric Clear",
    sentiment = "Positive",
    type = "flash",
    description = "Perfect atmospheric conditions. Radio signals are crystal clear.",
    canSpawn = function() return true end,
    system = {
        scanChance = 2.0, -- Double scan chance (Easy mode)
        traderBudgetMult = 1.2
    },
    effects = {
        ["Electronics.Communicator"] = { price = 1.2 }, -- Good radios in demand to use the clear air
        ["Electronics"] = { price = 1.1 }
    },
    factionImpact = {
        stabilityAdd = 1
    }
})
