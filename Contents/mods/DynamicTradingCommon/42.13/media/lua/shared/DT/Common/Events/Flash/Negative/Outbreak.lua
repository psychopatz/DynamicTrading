-- =============================================================================
-- FLASH NEGATIVE: VIRAL OUTBREAK
-- =============================================================================

DynamicTrading.Events.Register("Outbreak", {
    name = "Viral Outbreak",
    type = "flash",
    description = "A sickness spreads. Medicine is critical.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    effects = {
        ["Medical"] = { price = 3.5, vol = 0.2 },
        ["Pill"] = { price = 3.0 },
        ["Hygiene"] = { price = 2.5 },
        ["Food"] = { price = 1.2 }
    }
})
