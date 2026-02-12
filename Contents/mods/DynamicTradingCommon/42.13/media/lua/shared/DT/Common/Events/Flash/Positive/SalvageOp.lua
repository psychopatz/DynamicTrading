require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: URBAN SALVAGE
-- =============================================================================

DynamicTrading.Events.Register("SalvageOp", {
    name = "Urban Salvage",
    type = "flash",
    description = "Scavengers cleared a warehouse.",
    canSpawn = function() return true end,
    effects = {
        ["Material"] = { price = 0.5, vol = 4.0 },
        ["Junk"] = { price = 0.1, vol = 5.0 },
        ["Electronics"] = { price = 0.8 },
        ["Metal"] = { price = 0.6 }
    },
    inject = { ["Material"] = 5 }
})
