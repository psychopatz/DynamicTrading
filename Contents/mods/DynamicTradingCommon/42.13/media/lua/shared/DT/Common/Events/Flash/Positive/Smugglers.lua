require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: BLACK MARKET SURGE
-- =============================================================================

DynamicTrading.Events.Register("Smugglers", {
    name = "Black Market Surge",
    type = "flash",
    description = "The underground market is active.",
    canSpawn = function() return true end,
    effects = {
        ["Alcohol"] = { price = 0.6, vol = 2.0 },
        ["Tobacco"] = { price = 0.6, vol = 2.0 },
        ["Jewelry"] = { price = 0.5 },
        ["Illegal"] = { price = 0.5, vol = 2.0 }
    }
})
