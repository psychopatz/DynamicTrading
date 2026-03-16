require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: OLD WORLD CACHE
-- =============================================================================

DynamicTrading.Events.Register("TechBoom", {
    name = "Old World Cache",
    sentiment = "Positive",
    type = "flash",
    description = "A shipment of electronics was found.",
    canSpawn = function() return true end,
    effects = {
        ["Electronics"] = { price = 0.4, vol = 3.0 },
        ["Resource.Material.General"] = { price = 0.5, vol = 2.0 }, -- Generic parts
        ["Electronics.Communicator"] = { price = 0.5, vol = 2.0 }
    },
    inject = { ["Electronics"] = 4 },
    factionImpact = {
        wealthAdd = 500
    }
})
