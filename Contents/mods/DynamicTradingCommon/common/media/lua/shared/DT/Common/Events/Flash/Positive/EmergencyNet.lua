require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: EMERGENCY BROADCAST
-- =============================================================================

DynamicTrading.Events.Register("EmergencyNet", {
    name = "Emergency Broadcast",
    sentiment = "Positive",
    type = "flash",
    description = "The automated emergency network is pinging all active stations.",
    canSpawn = function() return true end,
    system = {
        scanChance = 1.8,
        traderLimit = 1.2
    , traderBudgetMult = 1.2},
    effects = {
        ["Medical"] = { price = 0.8 },
        ["Clothing.Protective"] = { price = 0.8 },
        ["Theme.Survival"] = { price = 0.8 }
    },
    factionImpact = {
        stabilityAdd = 5
    }
})
