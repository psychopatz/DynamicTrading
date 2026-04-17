require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: VIRAL OUTBREAK
-- =============================================================================

DynamicTrading.Events.Register("Outbreak", {
    name = "Virus Outbreak",
    sentiment = "Negative",
    type = "flash",
    description = "A sickness spreads. Medicine is critical.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    system = { autoBuyPriceMult = 2.0, traderBudgetMult = 0.7 },
    effects = {
        ["Medical"] = { price = 3.5, vol = 0.2 },
        ["Medical.General.Pills"] = { price = 3.0 },
        ["Medical.Healthcare"] = { price = 2.5 },
        ["Food"] = { price = 1.2 }
    },
    factionImpact = {
        memberCountPct = -0.15,
        stockpileAdd = { meds = -100 },
        stabilityAdd = -20
    }
})
