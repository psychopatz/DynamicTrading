require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: MIGRATION
-- =============================================================================

DynamicTrading.Events.Register("HuntingSeason", {
    name = "Migration",
    sentiment = "Positive",
    type = "flash",
    description = "Wild game is migrating through the area.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.2 },
    effects = {
        ["Food.Perishable.Meat"] = { price = 0.5, vol = 3.0 },
        ["Food.Perishable"] = { price = 0.6, vol = 2.0 },
        ["Building.Survival.Trap"] = { price = 1.5 },
        ["Resource.Material.Leather"] = { price = 0.5 }
    },
    inject = { ["Food.Perishable.Meat"] = 4, ["Building.Survival.Trap"] = 2 },
    factionImpact = {
        stockpileAdd = { food = 400, ammo = -50 }
    }
})
