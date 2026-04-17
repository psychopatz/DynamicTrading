require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: RADIO SILENCE
-- =============================================================================

DynamicTrading.Events.Register("WitchHunt", {
    name = "Radio Silence",
    sentiment = "Negative",
    type = "flash",
    description = "Someone is hunting broadcasters. Traders have gone dark.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        traderLimit = 0.3, -- Only 30% of normal traders available
        scanChance = 0.8
    , passiveIncomeMult = 0.6},
    effects = {
        ["Weapon"] = { price = 1.5 },
        ["Theme.Police"] = { price = 2.0 },
        ["Electronics.Communicator"] = { price = 0.5, vol = 0.2 } -- Dumping gear to hide
    },
    factionImpact = {
        memberCountPct = -0.02,
        stabilityAdd = -20
    }
})
