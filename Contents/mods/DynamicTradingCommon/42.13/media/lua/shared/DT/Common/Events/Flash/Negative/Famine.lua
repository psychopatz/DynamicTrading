require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: CROP BLIGHT
-- =============================================================================

DynamicTrading.Events.Register("Famine", {
    name = "Crop Blight",
    sentiment = "Negative",
    type = "flash",
    description = "Crops have died. Food prices skyrocket.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    effects = {
        ["Food"] = { price = 2.5, vol = 0.3 },
        ["Farming"] = { price = 3.0 },
        ["Canned"] = { price = 2.0 },
        ["Fresh"] = { price = 4.0, vol = 0.1 }
    },
    factionImpact = {
        stockpileAdd = { food = -500 },
        memberCountPct = -0.05,
        stabilityAdd = -10
    }
})
