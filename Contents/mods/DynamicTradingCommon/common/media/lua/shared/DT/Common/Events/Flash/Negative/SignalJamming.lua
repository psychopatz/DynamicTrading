require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: MILITARY JAMMING
-- =============================================================================

DynamicTrading.Events.Register("SignalJamming", {
    name = "Military Jamming",
    sentiment = "Negative",
    type = "flash",
    description = "A rogue military signal is drowning out all traffic.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        scanChance = 0.3, -- -70% Chance to find anyone
        traderLimit = 0.8
    , traderBudgetMult = 0.5},
    effects = {
        ["Electronics.Communicator"] = { price = 3.0 }, -- Better radios needed to punch through
        ["Theme.Militia"] = { price = 0.5 }, -- Maybe they are selling surplus?
        ["Electronics"] = { price = 2.0 }
    },
    factionImpact = {
        stabilityAdd = -3
    }
})
