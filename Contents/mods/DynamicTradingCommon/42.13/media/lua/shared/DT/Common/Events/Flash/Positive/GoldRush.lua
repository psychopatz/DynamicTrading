require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: GOLD PANIC
-- =============================================================================

DynamicTrading.Events.Register("GoldRush", {
    name = "Gold Panic",
    type = "flash",
    description = "Survivors are hoarding precious metals.",
    canSpawn = function() return true end,
    effects = {
        ["Gold"] = { price = 3.0 },
        ["Silver"] = { price = 2.5 },
        ["Jewelry"] = { price = 2.0 },
        ["Luxury"] = { price = 1.5 }
    }
})
