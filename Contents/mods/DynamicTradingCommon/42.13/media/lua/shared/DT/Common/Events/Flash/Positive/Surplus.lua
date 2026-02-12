require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: MILITARY SURPLUS
-- =============================================================================

DynamicTrading.Events.Register("MilitarySurplus", {
    name = "Military Surplus",
    sentiment = "Positive",
    type = "flash",
    description = "A military bunker was raided. Gear is everywhere.",
    canSpawn = function() return true end,
    system = { globalStock = 1.5 },
    effects = {
        ["Gun"] = { price = 0.6, vol = 2.0 },
        ["Ammo"] = { price = 0.5, vol = 3.0 },
        ["Military"] = { price = 0.7, vol = 2.0 },
        ["Tactical"] = { price = 0.7 }
    },
    inject = { ["Ammo"] = 5, ["Military"] = 3 }
})
