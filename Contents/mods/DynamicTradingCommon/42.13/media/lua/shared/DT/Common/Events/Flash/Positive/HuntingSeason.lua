-- =============================================================================
-- FLASH POSITIVE: MIGRATION
-- =============================================================================

DynamicTrading.Events.Register("HuntingSeason", {
    name = "Migration",
    type = "flash",
    description = "Wild game is migrating through the area.",
    canSpawn = function() return true end,
    effects = {
        ["Game"] = { price = 0.5, vol = 3.0 },
        ["Meat"] = { price = 0.6, vol = 2.0 },
        ["Trapping"] = { price = 1.5 },
        ["Leather"] = { price = 0.5 }
    },
    inject = { ["Game"] = 4, ["Trapping"] = 2 }
})
