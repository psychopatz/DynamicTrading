require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: URBAN SALVAGE
-- =============================================================================

DynamicTrading.Events.Register("SalvageOp", {
    name = "Urban Salvage",
    sentiment = "Positive",
    type = "flash",
    description = "Scavengers cleared a warehouse.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.3 },
    effects = {
        ["Resource.Material"] = { price = 0.5, vol = 4.0 },
        ["Quality.Waste"] = { price = 0.1, vol = 5.0 },
        ["Electronics"] = { price = 0.8 },
        ["Resource.Material.Metal"] = { price = 0.6 }
    },
    inject = { ["Resource.Material"] = 5 },
    factionImpact = {
        stockpileAdd = { ammo = 100, fuel = 100, meds = 50 }
    }
})
