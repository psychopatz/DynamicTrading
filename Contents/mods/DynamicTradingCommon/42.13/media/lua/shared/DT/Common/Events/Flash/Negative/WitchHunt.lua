-- =============================================================================
-- FLASH NEGATIVE: RADIO SILENCE
-- =============================================================================

DynamicTrading.Events.Register("WitchHunt", {
    name = "Radio Silence",
    type = "flash",
    description = "Someone is hunting broadcasters. Traders have gone dark.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        traderLimit = 0.3, -- Only 30% of normal traders available
        scanChance = 0.8
    },
    effects = {
        ["Weapon"] = { price = 1.5 },
        ["Security"] = { price = 2.0 },
        ["Communication"] = { price = 0.5, vol = 0.2 } -- Dumping gear to hide
    }
})
