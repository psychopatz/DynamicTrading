require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: MASS PANIC
-- =============================================================================

DynamicTrading.Events.Register("PanicBroadcast", {
    name = "Mass Panic",
    sentiment = "Negative",
    type = "flash",
    description = "Everyone is screaming over the radio. Signals are everywhere but chaotic.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        scanChance = 1.5, -- Easy to hear *something*
        traderLimit = 0.5 -- Hard to find a *useful trader* amidst the noise
    , passiveIncomeMult = 0.8, traderBudgetMult = 0.8},
    effects = {
        ["Weapon"] = { price = 2.0 },
        ["Food"] = { price = 2.0 },
        ["Medical"] = { price = 2.0 }
    },
    factionImpact = {
        stabilityAdd = -15
    }
})
