require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: NEW WORLD FESTIVAL
-- =============================================================================

DynamicTrading.Events.Register("Celebration", {
    name = "Holiday Celebration",
    sentiment = "Positive",
    type = "flash",
    description = "Survivors are gathering to party.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.5 },
    effects = {
        ["Food.Drink.Alcohol"] = { price = 2.0, vol = 0.2 },
        ["Food.NonPerishable.Sweets"] = { price = 2.0 },
        ["Electronics.Gadget.Audio"] = { price = 2.0 },
        ["Literature.Media"] = { price = 2.0 },
        ["Clothing.Accessory.Cosmetic"] = { price = 1.5 }
    },
    factionImpact = {
        stabilityAdd = 10,
        stockpileAdd = { food = -50 }
    }
})
