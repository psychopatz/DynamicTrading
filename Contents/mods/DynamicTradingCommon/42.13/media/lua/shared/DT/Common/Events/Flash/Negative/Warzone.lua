require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: FACTION CONFLICT
-- =============================================================================

DynamicTrading.Events.Register("Warzone", {
    name = "Faction Conflict",
    type = "flash",
    description = "War has broken out. Traders are hiding, ammo is scarce.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    system = { traderLimit = 0.5 },
    effects = {
        ["Gun"] = { price = 2.5, vol = 0.5 },
        ["Ammo"] = { price = 3.0, vol = 0.2 },
        ["Medical"] = { price = 1.5 },
        ["Armor"] = { price = 2.0 }
    }
})
